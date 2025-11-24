AI Test Review Agent – Lessons Learned

Goal

Introduce an AI-assisted “test review” step for pull requests in the Grocery & Recipe Manager app.
The AI agent should:
	•	Look at code changes in a PR
	•	Understand app requirements and architecture
	•	Suggest useful unit and UI tests in clear GIVEN/WHEN/THEN form

Phase 1 (Option A) – Advisory Test Reviewer

Decisions
	•	Implementation language for automation: Swift (CLI tool in this repo).
	•	Scope: Advisory only for now (agent suggests tests; it does not modify code).
	•	Inputs to the agent:
	•	requirements.md
	•	roadmap.md
	•	project-index.md
	•	Unified git diff between PR branch and main
	•	Contents of relevant *Tests.swift files (initially: all test files, later we’ll filter)
	•	Output: Markdown comment that can be posted on a PR.

To-do
	•	Implement Swift CLI to:
	•	Gather repo context and diff
	•	Call OpenAI (this custom GPT) with that context
	•	Print a well-structured Markdown test review
	•	Wire CLI into GitHub Actions to automatically add a PR comment
	•	Iterate on prompts and test selection for better signal