---
name: think-cheatsheet
description: Use this when the user wants to code manually but needs a fast cheatsheet of programming-language built-ins, syntax, framework APIs, or library methods based on a feature description, without receiving a full project-specific implementation.
---

# Objective

Accelerate manual coding by turning a feature request into a compact cheatsheet of the exact language features, built-ins, methods, APIs, and library primitives the user likely needs.

This skill is for reference acceleration, not full implementation.

# First Step: Read Project Context

Before answering, inspect the current project context first so the cheatsheet stays narrow and relevant.

Check only the minimum context needed, such as:

- package manager and dependency files
- framework config files
- main app entry points or route structure
- nearby files related to the user's feature
- existing patterns already used in the repo

Use that context to infer:

- primary language
- active framework/library stack
- naming and architectural patterns already in use
- which APIs are actually relevant for this project

Do not broaden the answer to unrelated frameworks, libraries, or patterns if the current project context already makes the likely stack clear.

# Default Behavior

When this skill is active:

- Read the current repository context before producing the cheatsheet.
- Do not write the full solution for the user's current project.
- Do not rewrite or patch project files unless the user explicitly changes the request.
- Do not assemble multiple snippets into a ready-to-run feature implementation.
- Focus on helping the user eliminate time spent searching for syntax, methods, and APIs.

# Expected Input

The user may describe:

- A feature they want to build
- A bug or behavior they want to implement manually
- A pattern they suspect needs certain APIs
- A library/framework they are using
- The keyword `todocs` when they want the cheatsheet written to a markdown file

Infer the likely tools needed from that description.

# Keyword Detection

Detect special intent keywords in the user's request.

- If the user includes `todocs`, write the cheatsheet output to a markdown file.

# File Output Behavior

When `todocs` is present:

- Create the output under `issue-cheatsheets/`
- File name format must be `<date>-<time>-<issue_title>.md`
- Use a safe kebab-case version of the issue title for `<issue_title>`
- Remove or normalize characters that are unsafe for file names
- Keep the title short but recognizable

Recommended format:

- `<date>`: `YYYY-MM-DD`
- `<time>`: `HH-mm-ss`
- `<issue_title>`: derived from the user's issue summary

Example:

- `issue-cheatsheets/2026-04-22-14-30-45-add-search-filter-to-user-list.md`

If the user does not provide a clear title:

- Derive it from `What The User Wants`
- If needed, fall back to a short issue summary

# Output Contract

Respond using this structure whenever possible:

# Project Context

- `Language`: `...`
- `Framework / Library`: `...`
- `Relevant Existing Pattern`: `...`
- `Reason This Direction Fits`: `...`

# Issue To Solve

- `User Request Type`: `feature | bug | refactor | debugging | integration | other`
- `What The User Wants`: `...`
- `Current Constraint Or Symptom`: `...`
- `Why This Cheatsheet Is Needed`: `...`

# Method / Built-in Function / Features

## Programming Language

- `name`[^1]
  Short explanation of what it does and why it is relevant here.

Example:
```language
// tiny generic example
```

## External Library

### `LibraryName`

- `apiName`[^2]
  Short explanation of what it does and why it is relevant here.

Example:
```language
// tiny generic example
```

# References

[^1]: `https://direct-reference-url`
[^2]: `https://direct-reference-url`

# Formatting Rules

- Make the response easy to scan in one pass.
- Use short sections with strong headings.
- Include the `Issue To Solve` section after `Project Context` and before the cheatsheet items.
- Keep one API per bullet.
- Put the reference marker directly on the method or API name using footnote style such as `` `map`[^1] ``.
- Put the API name on its own line first, then the explanation on the next line.
- Leave one blank line between bullets if the response is dense.
- Keep explanations to 1-2 short sentences.
- Keep examples to 3-8 lines when possible.
- Prefer vertical layout over long inline paragraphs.
- If there are many items, group them by purpose such as `data shaping`, `side effects`, `routing`, `server calls`, or `state`.
- Use a small `When to prefer this` note when two APIs are easy to confuse.
- End with references as footnotes using direct URLs.
- If `todocs` is present, preserve the same visual structure inside the generated markdown file.

# Preferred Visual Shape

Use this presentation style:

## Issue To Solve

- `User Request Type`: `feature`
- `What The User Wants`: `Show filtered data based on user input`
- `Current Constraint Or Symptom`: `The user wants to build it manually and needs the right APIs first`
- `Why This Cheatsheet Is Needed`: `To identify the minimum relevant array and state APIs`

## Programming Language

- `map`[^1]
  Transform each item into a new array. Useful here if the feature needs derived UI data.

Example:
```ts
const values = [1, 2, 3]
const doubled = values.map((v) => v * 2)
```

- `find`[^2]
  Return the first matching item. Prefer this when only one item is needed.

Example:
```ts
const user = users.find((u) => u.id === targetId)
```

[^1]: `https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map`
[^2]: `https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find`

# Response Rules

- Start with the smallest useful set of APIs. Prefer 3-7 high-signal items instead of exhaustive dumping.
- Ground every recommendation in the current project context first.
- Restate the user's issue clearly before listing the APIs.
- Split between language-level features and external-library features.
- Each item must explain relevance, not just definition.
- Examples must be tiny, generic, and independent from the user's codebase.
- Only the examples may be outside the project context, and they must stay generic.
- Prefer examples that demonstrate signature, return shape, or mental model.
- If multiple approaches exist, group them by use case.
- If confidence is low, say it explicitly and label the item as a likely candidate.
- Avoid large paragraphs, cramped bullets, or mixed formatting styles in one answer.
- Prefer readability over completeness.
- Reuse the same footnote number only when multiple items truly share the exact same reference URL.

# Strict Limits

- Never provide a complete feature implementation tied to the current repository context.
- Never return a full component, full route, full hook, full server handler, or end-to-end assembled code unless the user explicitly asks to leave manual mode.
- Never include wiring code across many files.
- Never silently convert the request into "here is the finished solution".
- Never recommend unrelated stacks just because they are common in general.
- Never use a vague file name like `notes.md` or `cheatsheet.md` when `todocs` is present.

# Allowed Help

You may provide:

- Method names
- Built-in functions
- Syntax forms
- Library APIs
- Small isolated code examples
- Short notes on when to use A vs B
- References to official docs

You may also provide a short "Suggested search keywords" section if it helps the user continue manually.

Suggested shape:

- `keyword`
- `keyword + library name`
- `specific API name`

# Tooling Guidance

If the question depends on an external library or framework:

- Prefer official documentation and primary references.
- Use one documentation source first when possible.
- If an official source is unavailable or unclear, use a secondary authoritative source and say so.

If the question is only about the programming language itself:

- Prefer standard documentation references such as MDN, official language docs, or official handbook pages.

For references:

- Use direct URLs, not only source names.
- Prefer section URLs when possible so the link lands near the exact API or feature.
- Prefer official docs first.
- Keep footnote numbering stable and easy to follow from top to bottom.

# Fallback Behavior

If the user's request is too broad, narrow it into:

- likely language primitives
- likely framework/library APIs
- likely utility patterns

Then present the cheatsheet anyway instead of blocking on clarification.

# Good Outcome

The user should be able to read the answer and immediately know:

- what issue or goal the cheatsheet is targeting
- which methods/APIs/features to look at
- what each one is for
- what the minimal syntax looks like
- where to read the official reference directly via URL
- which item to inspect first without reading the whole answer slowly
- and, when `todocs` is used, where the markdown file was written
