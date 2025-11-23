import Foundation

// MARK: - Shell helpers

@discardableResult
func runShell(_ command: String) throws -> String {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c", command]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe()

    process.launch()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else { return "" }

    return output.trimmingCharacters(in: .whitespacesAndNewlines)
}

func safeReadFile(_ path: String, maxLength: Int? = nil) -> String {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else { return "" }
    guard let data = try? Data(contentsOf: url),
          var text = String(data: data, encoding: .utf8) else {
        return ""
    }

    if let max = maxLength, text.count > max {
        let endIndex = text.index(text.startIndex, offsetBy: max)
        text = String(text[..<endIndex])
    }

    return text
}

// MARK: - Repo context model

struct RepoContext {
    let requirements: String
    let roadmap: String
    let projectIndex: String
    let changedFiles: [String]
    let diff: String
    let testFilesContent: String
}

// MARK: - Collect repo context

func collectRepoContext() throws -> RepoContext {
    // 1. High-level docs
    let requirements = safeReadFile("requirements.md", maxLength: 8000)
    let roadmap = safeReadFile("roadmap.md", maxLength: 4000)
    let projectIndex = safeReadFile("project-index.md", maxLength: 4000)

    // 2. Determine head
    let head = try runShell("git rev-parse HEAD")

    // 3. First attempt: diff vs origin/main (good for PRs/CI)
    var base = try runShell("git merge-base HEAD origin/main || echo origin/main")
    var changedFilesOutput = try runShell("git diff --name-only \(base)...\(head)")
    var diffOutput = try runShell("git diff \(base)...\(head)")

    // 4. If no changes vs origin/main (common when you just pushed to main),
    //    fall back to last commit (HEAD^...HEAD) so local runs still show something.
    if changedFilesOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        // Best-effort: if HEAD^ doesn’t exist (e.g., first commit), keep origin/main
        if let previous = try? runShell("git rev-parse HEAD^") {
            base = previous
            changedFilesOutput = try runShell("git diff --name-only \(base)...\(head)")
            diffOutput = try runShell("git diff \(base)...\(head)")
            fputs("AI Test Review: Using HEAD^ as diff base (local fallback).\n", stderr)
        } else {
            fputs("AI Test Review: No previous commit, diff vs origin/main is empty.\n", stderr)
        }
    } else {
        fputs("AI Test Review: Using origin/main as diff base.\n", stderr)
    }

    // 5. Build changed files list
    let changedFiles = changedFilesOutput
        .split(separator: "\n")
        .map(String.init)
        .filter { !$0.isEmpty }

    // 6. Truncate diff for token safety
    let diff = diffOutput.count > 12000
        ? String(diffOutput.prefix(12000))
        : diffOutput

    // 7. Test files (still naive: all *Tests.swift, capped)
    let testFilesListOutput = try runShell("git ls-files \"*Tests.swift\" || echo \"\"")
    let testFiles = testFilesListOutput
        .split(separator: "\n")
        .map(String.init)
        .filter { !$0.isEmpty }
        .prefix(30)

    var testFilesContent = ""
    for file in testFiles {
        testFilesContent += "\n\n===== FILE: \(file) =====\n"
        testFilesContent += safeReadFile(file, maxLength: 2000)
    }

    return RepoContext(
        requirements: requirements,
        roadmap: roadmap,
        projectIndex: projectIndex,
        changedFiles: changedFiles,
        diff: diff,
        testFilesContent: testFilesContent
    )
}

// MARK: - Build the user content blob for GPT

func buildUserContent(from ctx: RepoContext) -> String {
    var parts: [String] = []

    parts.append("### Repo context\n")

    parts.append("#### requirements.md\n```markdown")
    parts.append(ctx.requirements)
    parts.append("```\n")

    parts.append("#### roadmap.md\n```markdown")
    parts.append(ctx.roadmap)
    parts.append("```\n")

    parts.append("#### project-index.md\n```markdown")
    parts.append(ctx.projectIndex)
    parts.append("```\n")

    parts.append("### Changed files\n```text")
    parts.append(ctx.changedFiles.joined(separator: "\n"))
    parts.append("```\n")

    parts.append("### Git diff\n```diff")
    parts.append(ctx.diff)
    parts.append("```\n")

    parts.append("### Related test files (truncated)\n```swift")
    parts.append(ctx.testFilesContent)
    parts.append("```")

    return parts.joined(separator: "\n")
}

// MARK: - OpenAI models

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - OpenAI call

func callOpenAI(userContent: String) throws -> String {
    guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
          !apiKey.isEmpty else {
        throw NSError(domain: "AITestReview", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "OPENAI_API_KEY env var is not set"
        ])
    }

    // IMPORTANT: replace this with the model ID of your custom GPT from the UI.
    let model = "gpt-4.1-mini"

    let systemPrompt = """
    You are acting as a test-review bot for an iOS Grocery & Recipe Manager app.

    Your responsibilities:
    1. Identify impacted features, flows, and modules (staples, recipes, grocery lists, usage tracking).
    2. Map changes to layers (domain models, Core Data, view models, SwiftUI views).
    3. Evaluate existing tests.
    4. Suggest new tests in GIVEN / WHEN / THEN format.
    5. Provide XCTest / XCUITest stubs when relevant.
    6. Keep recommendations stable, deterministic, and behavior-focused.

    Use the following output structure:

    ## Impact Summary
    - ...

    ## Affected Layers & Modules
    - ...

    ## Existing Tests & Gaps
    - ...

    ## Suggested Unit Tests
    1. `test_*` – Given/When/Then...
       - Rationale:
       - Example XCTest:
         ```swift
         ```

    ## Suggested UI Tests
    1. Scenario
       - Given/When/Then:
       - Pseudo XCUITest:
    """

    let requestBody = ChatRequest(
        model: model,
        messages: [
            .init(role: "system", content: systemPrompt),
            .init(role: "user", content: userContent)
        ],
        temperature: 0.2
    )

    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpBody = try JSONEncoder().encode(requestBody)

    let semaphore = DispatchSemaphore(value: 0)
    var result: Result<String, Error>!

    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        defer { semaphore.signal() }

        if let error = error {
            result = .failure(error)
            return
        }

        guard let data = data else {
            result = .failure(NSError(domain: "AITestReview", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "No data received"
            ]))
            return
        }

        do {
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            let content = decoded.choices.first?.message.content ?? ""
            result = .success(content)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? "<binary>"
            fputs("Decoding error: \(error)\nRaw response:\n\(raw)\n", stderr)
            result = .failure(error)
        }
    }

    task.resume()
    semaphore.wait()

    switch result {
    case .success(let content):
        return content
    case .failure(let error):
        throw error
    case .none:
        throw NSError(domain: "AITestReview", code: 3, userInfo: [
            NSLocalizedDescriptionKey: "Unknown error from OpenAI"
        ])
    }
}

// MARK: - Entry point

@main
struct AITestReviewCLI {
    static func main() {
        do {
            let ctx = try collectRepoContext()
            let userContent = buildUserContent(from: ctx)
            let aiOutput = try callOpenAI(userContent: userContent)

            // This is the Markdown comment you’ll later post in GitHub Actions.
            print(aiOutput)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
    }
}