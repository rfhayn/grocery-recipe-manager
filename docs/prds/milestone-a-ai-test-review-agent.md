AI Test Review Agent – Product Requirements Document (PRD)

1. Overview

The AI Test Review Agent enhances development quality for the Grocery & Recipe Manager app by generating intelligent, context‑aware test recommendations during code review. It integrates directly into the development workflow through a Swift‑based CLI and GitHub Actions.

This PRD defines the full multi‑phase vision, requirements, user stories, success metrics, scope boundaries, and architectural constraints for the Test Review Agent.

⸻

2. Product Goals

2.1 Primary Goal

Improve code quality and developer productivity by automatically generating:
	•	Relevant unit test suggestions
	•	Contextual UI test scenarios
	•	Coverage awareness based on app requirements and architecture
	•	Early detection of test gaps before merge

2.2 Secondary Goals
	•	Reduce cognitive load on developers during reviews
	•	Ensure consistent, structured review quality across PRs
	•	Provide a foundation for future agentic automation (test generation, code fixes, etc.)

⸻

3. User Personas

Primary: Core App Developer (You, Claude, Rich)
	•	Wants fast feedback about what tests are missing
	•	Wants domain‑aware insights (staples, recipes, lists, usage tracking)
	•	Wants actionable GIVEN/WHEN/THEN test cases
	•	Wants consistent review assistance without noise

Secondary: Future Contributors (open source / team)
	•	Needs clarity on expected test structure
	•	Benefits from automated review to maintain quality standards

⸻

4. Functional Requirements by Phase

Phase 1 — Advisory Test Reviewer (Current Scope)

Objective

Provide non‑blocking, context‑aware test suggestions for each PR.

Requirements
	1.	Collect context:
	•	requirements.md
	•	roadmap.md
	•	project-index.md
	•	current-story.md
	•	next-prompt.md
	•	Any PRD file in the /prd directory whose name matches the active phase
	•	Unified git diff between feature branch and main
	•	Relevant *Tests.swift files
	2.	Prompting:
	•	Agent understands app domain at high level
	•	Suggestions use GIVEN/WHEN/THEN format

Out of Scope
	•	Generating actual Swift test code files
	•	Modifying repo contents
	•	Auto‑opening PRs with generated tests

⸻

Phase 2 — Coverage Gap Detector

Objective

Add intelligent assessment of test health and coverage completeness.

Requirements
	1.	Detect gaps such as:
	•	Missing tests for modified business rules
	•	Inconsistent behavior between view model and UI
	•	Untested edge cases derived from requirements.md
	2.	Summaries include:
	•	Mandatory vs Optional test scenarios
	•	Risk scoring (Low/Medium/High)
	3.	Additional context inputs:
	•	Domain models and Core Data schemas
	•	ViewModel responsibilities
	•	UX flows for staples, recipes, lists, usage tracking

Out of Scope
	•	Running coverage tools
	•	Enforcing minimum coverage thresholds

⸻

Phase 3 — Intelligent Test Generator

Objective

Begin generating actual test templates or runnable Swift test code.

Requirements
	1.	Produce compilable XCTest skeletons:
	•	Unit test templates
	•	UI test templates
	2.	Ensure output is deterministic and reviewable
	3.	Provide inline explanations of decisions

Out of Scope
	•	Writing full test logic
	•	Auto‑committing code

⸻

Phase 4 — Agentic Test Author (Future)

Objective

Allow the agent to propose and write actual tests in a structured, controlled workflow.

Requirements
	1.	Generate compilable tests with assertions
	2.	Validate against app architecture rules
	3.	Create a PR with changes (human approval required)

Out of Scope
	•	Automatic merges

⸻

5. Non‑Functional Requirements
	•	Predictable: Outputs must stay stable for identical diffs
	•	Readable: All test suggestions must use BDD-style phrasing
	•	Domain‑aware: Understand staples, recipes, grocery lists, inventory flows
	•	Performant: Execution < 10 seconds in CI
	•	Secure: API keys via GitHub Secrets
	•	Composable: CLI must remain modular for future enhancements

⸻

6. Success Metrics

Phase 1
	•	≥ 90% of PRs receive AI test suggestions
	•	Developers find suggestions useful in ≥ 75% of cases

Phase 2
	•	Coverage gap detection results in additional tests in ≥ 40% of PRs

Phase 3
	•	Generated test templates adopted in ≥ 30% of additions to test suites

Phase 4
	•	Agent-authored tests merged after human review in ≥ 25% of PRs

⸻

7. Technical Architecture (High-Level)

Components
	•	Swift CLI in Tools/AITestReview
	•	GitHub Actions workflow to:
	•	Build the CLI
	•	Run analysis
	•	Post comments via GitHub API
	•	OpenAI Chat Completions API
	•	Domain knowledge derived from repo docs

Key Flows
	1.	Local Developer Run
	•	swift run → gathers context → generates test review
	2.	PR Workflow
	•	GitHub Action executes CLI
	•	Produces markdown
	•	Posts PR comment

⸻

8. Risks & Mitigations
	•	Empty diffs → Use HEAD^ fallback
	•	Large diffs → Truncate context in prompt
	•	Noisy suggestions → Improve prompt domain-awareness
	•	API errors → Robust error handling in CLI

⸻

9. Open Questions
	•	Should the agent incorporate CloudKit schema awareness?
	•	Should Phase 3/4 include mutation testing suggestions?
	•	How much domain knowledge should be embedded vs dynamically inferred?

⸻

10. Appendix
	•	Related docs:
	•	current Lessons Learned
	•	roadmap.md
	•	requirements.md
	•	project-index.md

⸻
