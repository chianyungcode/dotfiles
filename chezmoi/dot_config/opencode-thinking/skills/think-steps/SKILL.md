---
name: think-steps
description: Help a user who wants to code manually turn a feature idea, bug, or behavior into a clear non-technical general flow followed by practical technical steps. Use when the user asks for feature flow, step-by-step thinking, manual coding guidance, implementation planning, auth/routing/data/UI behavior breakdowns, or wants to understand what to build before writing code, without receiving a full project-specific implementation.
---

# Objective

Guide manual coding by converting a requested behavior into an easy-to-understand flow first, then a focused technical plan.

The goal is to help the user think before coding. Keep the answer conceptual enough that the user still writes the implementation manually.

# First Step: Understand Context

Before answering, gather only the context needed to make the steps accurate.

Use the user's description first. Inspect the project only when the request depends on framework, routing, auth, state management, folder structure, or existing patterns.

Infer:

- the actor or user involved
- the target screen, route, API, state, or data involved
- the expected behavior
- the current condition or trigger
- the success result
- the likely project stack if relevant

# Default Behavior

When this skill is active:

- Explain the feature in plain language first.
- Separate user-facing flow from technical steps.
- Keep technical steps small, ordered, and implementation-ready.
- Use the project's existing framework and patterns when known.
- Avoid giving a complete implementation unless the user explicitly asks for code.
- Prefer pseudocode, checkpoints, and file responsibility over full code.
- Ask at most one concise clarification question only if a safe assumption would change the flow significantly.

# Keyword Detection

Detect special intent keywords in the user's request.

- If the user includes `todocs`, write the final think-steps output to a markdown file.
- Treat `todocs` as an output instruction, not as part of the feature title.

# File Output Behavior

When `todocs` is present:

- Create the file under `issue_steps/` in the project root directory.
- Create `issue_steps/` if it does not exist.
- File name format must be `<date>-<issue_title>.md`.
- Use `YYYY-MM-DD` for `<date>`.
- Derive `<issue_title>` from the user's feature or issue summary.
- Convert `<issue_title>` to safe kebab-case.
- Remove or normalize characters that are unsafe for file names.
- Keep the title short but recognizable.

Example:

- `issue_steps/2026-04-25-redirect-user-to-login.md`

If the user does not provide a clear title:

- Derive it from `What We Are Building`.
- If still unclear, use a short summary such as `feature-flow` or `auth-flow`.

After creating the file, respond briefly with the saved file path and a short summary of the contents.

# Output Contract

Respond using this structure whenever possible:

## What We Are Building

Summarize the requested behavior in 1-2 short sentences.

## Assumptions

List only assumptions that affect the flow. Skip this section if there are no meaningful assumptions.

## General Flow

Write the flow from the user's perspective.

Rules:

- Use simple non-technical language.
- Keep each step observable.
- Mention the trigger, decision, result, and fallback.
- Avoid framework names, hooks, middleware, database terms, or code concepts here.

Example shape:

1. User tries to open `/dashboard`.
2. System checks whether the user is already logged in.
3. If the user is not logged in, user is sent to the login page.
4. After login succeeds, user can continue to the protected page.

## Technical Steps

Translate the general flow into implementation responsibilities.

Rules:

- Use concise ordered steps.
- Mention likely file or layer responsibility when helpful.
- Keep each step actionable but not fully coded.
- Include only the minimum APIs, framework concepts, or patterns needed.
- Prefer "create/check/connect/test" verbs.

Example shape:

1. Identify which routes require authentication.
2. Create or reuse an auth-checking layer such as middleware, route guard, or layout guard.
3. Read the user's current auth state from the existing session/token source.
4. Redirect unauthenticated users to the login route.
5. Allow authenticated users to continue to the protected route.

## Edge Cases

Include 2-5 relevant edge cases when useful, such as:

- user is already logged in
- session expires
- login succeeds and user should return to the original page
- auth state is still loading
- user has login but not enough permission

## Manual Coding Checklist

Give a short checklist the user can follow while coding manually.

Prefer checks like:

- route is protected
- unauthenticated access redirects correctly
- authenticated access still works
- loading state does not flash the wrong page
- browser back button behaves reasonably

# Technical Depth Rules

Adjust technical depth to the user's request:

- If the user asks for "alur", "flow", "logic", or "step", prioritize General Flow and short Technical Steps.
- If the user mentions a framework, include framework-specific concepts but keep examples tiny.
- If the user asks "apa yang harus saya buat", list components/files/layers and their responsibilities.
- If the user asks for code, provide a small skeleton or pseudocode before any real implementation.
- If the user asks to debug their own attempt, guide them through checking the flow before suggesting fixes.

# Manual Coding Boundaries

Allowed:

- feature flow
- technical step plan
- pseudocode
- file responsibility map
- tiny isolated snippets
- testing checklist
- key APIs or concepts to look up

Avoid by default:

- full components
- full middleware files
- full route handlers
- large copy-paste implementations
- unrelated architecture alternatives
- over-explaining common programming concepts

# Response Style

- Use Indonesian when the user writes in Indonesian.
- Keep language simple and direct.
- Make the answer feel like a thinking partner, not a lecture.
- Prefer 5-8 steps over long exhaustive plans.
- Name uncertainties clearly when context is missing.
- End with the next smallest manual action the user can take.
