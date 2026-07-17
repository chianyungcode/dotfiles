---
name: surprise-me
description: Research the current repository and comparable products to propose 3-5 fresh, evidence-backed feature ideas, score them, and select the strongest feature to build next. Use when the user says "Surprise me", asks "What feature should I build next?", explicitly invokes `$surprise-me`, or makes a similar request for a novel product feature, UX improvement, or next-feature recommendation.
---

# Surprise Me

## Objective

Discover practical features that fit the product naturally and could materially improve its users' experience. Produce a researched shortlist of 3-5 ideas, compare them with an equal-weight scoring rubric, select one winner, and publish the recommendation in both chat and a readable HTML report.

Write all user-facing output in English.

## Operating Rules

- Work read-only until the user explicitly authorizes a follow-up action, except for writing the requested recommendation report under `docs/chianyung/surprise-me/`.
- Inspect files, documentation, tests, configuration, and version-control history statically. Do not run the product, builds, tests, services, installers, migrations, or other state-changing commands for feature discovery.
- Keep version-control inspection read-only. Do not stage files, use intent-to-add, modify the index, switch branches, or create commits.
- Research current comparable products on the web for every recommendation. Do not call an idea fresh without checking the repository and the external product landscape.
- Infer the product, intended audience, and primary workflows from repository evidence. Ask only the minimum blocking question when the evidence is insufficient or conflicting.
- For an end-user product, recommend only features experienced directly by end users. Do not disguise developer tooling, observability, refactors, or internal operations as user features.
- If the repository is not intended to provide end-user features, such as a library, infrastructure project, or dotfiles repository, adapt ideas to its actual primary consumer. State this exception explicitly.
- Treat major usability, accessibility, user-visible performance, onboarding, empty-state, and broken-workflow improvements as valid features when they are not already represented in the project.
- Explore broadly across feature categories. Apply privacy, security, accessibility, offline, mobile, and responsive considerations only where relevant.
- Distinguish repository facts, web findings, inferences, and assumptions. Never present an inference as an observed fact.
- Cite repository evidence with clickable file paths and line numbers when the interface supports them. Cite every material external claim with a direct web link.

## Workflow

### 1. Establish the Product Context

Read applicable repository instructions first. Determine:

- The product's purpose and maturity
- Its primary end-user persona and jobs to be done
- Its important user journeys, interfaces, and pain points
- Its architecture, capabilities, constraints, and integration points
- The feature surface appropriate to this repository

Ask a concise clarification question only if the product or audience cannot be inferred reliably. Do not conduct a general product interview when repository evidence is sufficient.

### 2. Build a Repository Evidence Map

Inspect the relevant parts of the repository, including:

- README files and product documentation
- Source code and user-facing surfaces
- Tests as evidence of intended behavior
- Manifests, configuration, schemas, and architectural notes
- Issue, roadmap, changelog, and planning files available locally
- TODO, FIXME, feature-flag, stub, and placeholder signals
- Read-only version-control status, diffs, and recent history

Summarize the evidence needed for ideation; do not dump an exhaustive repository inventory.

Create an internal exclusion inventory containing:

- Existing features and close equivalents
- Work already present in the working tree or recent history
- Planned, flagged, or documented roadmap work
- TODOs, stubs, and partially implemented or unfinished features

Exclude all items in that inventory from the shortlist. Do not recommend completing unfinished work or merely repackaging a TODO as a new idea. A genuinely new improvement may build on a complete existing capability when it does not duplicate planned or partial work.

### 3. Research the External Landscape

Research 3-5 relevant comparable products. Prefer direct competitors; if none exist, select products with analogous users or workflows.

- Prefer official product pages, documentation, release notes, and other primary sources.
- Record the research date.
- Identify patterns competitors provide, gaps they leave, and approaches worth avoiding.
- Explain whether each shortlisted idea borrows, improves, combines, or differs from an observed pattern.
- Use recent sources where recency affects the claim; verify that current product behavior has not changed.

If web research is unavailable, disclose the limitation and ask whether the user wants a provisional repository-only analysis. Do not silently substitute memory for current research.

### 4. Generate and Filter Candidates

Generate a broad internal pool, then discard candidates that are:

- Already implemented, planned, flagged, partial, or documented as TODOs
- Primarily internal engineering work for an end-user product
- Generic suggestions unsupported by a repository-specific problem or opportunity
- Copies of competitor features with no useful adaptation to this product
- Incompatible with the product's purpose or architecture without a compelling reason

Keep the strongest 3-5 candidates. Favor practical improvements that fit the product naturally, but allow ambitious ideas and winners that could take longer than one week. Make effort and scope explicit; do not force a large feature into a misleading one-week estimate.

For each candidate, define:

- A memorable feature name and one-sentence pitch
- The affected persona and user problem
- Repository evidence for the opportunity
- The proposed user experience
- Its novelty relative to the repository and researched products
- Expected user impact
- The smallest useful version
- A high-level implementation direction
- Risks and trade-offs
- A success metric
- A quick validation experiment
- An honest effort estimate

### 5. Score the Shortlist

Score every candidate from 1 to 5 on each criterion. Weight all five criteria equally and total them out of 25.

| Criterion | A score of 1 | A score of 5 |
| --- | --- | --- |
| User impact | Marginal or speculative improvement | Material improvement to an important user journey |
| Product fit | Weak connection or substantial product distortion | Natural extension of the product and its workflows |
| Novelty | Common, duplicative, or minimally differentiated | Fresh for both this product and its competitive context |
| Feasibility | High uncertainty, major dependencies, or difficult delivery | Clear implementation path with contained delivery risk |
| Evidence confidence | Mostly assumptions or weak signals | Strong repository and external evidence |

Lower novelty when competitors commonly provide an idea, but allow it to win when it fills an important gap and performs strongly overall. Do not manipulate scores to justify a preferred answer. Select the highest total; for a tie, explain the qualitative trade-off and choose transparently.

### 6. Present the Recommendation

Use this output order:

1. **Context and research basis**
   - State the inferred product, audience, research date, and inspected evidence.
   - Separate facts, web findings, inferences, and assumptions.
   - Briefly name the competitors or analogous products researched.
   - Mention important exclusions without exposing irrelevant internal notes.

2. **Shortlist scoring table**
   - Show all 3-5 ideas, each criterion's 1-5 score, total out of 25, and effort estimate.
   - Add a brief justification for scores; do not leave unexplained numbers.

3. **Candidate briefs**
   - Cover the required candidate fields concisely for every idea.
   - Keep repository and web citations adjacent to supported claims.

4. **Winner deep dive**
   - State why it won and why the other candidates lost.
   - Describe the user journey or before/after experience.
   - Expand the repository evidence and competitor comparison.
   - Describe expected impact across relevant dimensions such as time saved, friction, discoverability, accessibility, delight, retention, and trust.
   - Detail the smallest useful version and high-level implementation direction, including likely areas or files affected.
   - Identify dependencies, migrations, edge cases, effort, rollout strategy, and branch-sizing options.
   - Cover relevant privacy, security, accessibility, offline, mobile, or responsive implications.
   - Define quantitative or qualitative success measures and a lightweight validation experiment.
   - State risks, trade-offs, and remaining assumptions.

5. **Decision gate**
   - Ask whether the user wants a specification, implementation plan, issue, or implementation.
   - Wait for an explicit choice before taking any of those actions.

### 7. Write the HTML Report

Deliver the same recommendation in a self-contained HTML file so the user can read it outside the chat. Keep the chat response useful on its own, but make the HTML the polished, complete version rather than a different analysis.

Use the bundled renderer at [scripts/render_report.py](scripts/render_report.py). Resolve `REPO_ROOT` to the repository root (for example, with the read-only command `git rev-parse --show-toplevel`), create a temporary JSON spec outside the repository, then run:

```bash
python "$REPO_ROOT/chezmoi/dot_agents/skills/surprise-me/scripts/render_report.py" \
  /tmp/surprise-me-<slug>.json \
  --repo-root "$REPO_ROOT"
```

The spec must contain a `title`, an ISO `date_created` (`YYYY-MM-DD`), an optional `subtitle`, and non-empty `sections`. Each section has an `id`, `heading`, and raw `html` body. Include these sections at minimum:

- Context and research basis
- Shortlist scoring table
- Candidate briefs
- Winner deep dive
- Decision gate

Use semantic headings, tables, citations, links to repository files, readable code or implementation excerpts where useful, and `<details>` blocks for secondary detail. Keep the file self-contained: inline CSS, no CDN dependencies, responsive layout, and light/dark presentation.

The renderer writes to `docs/chianyung/surprise-me/` by default and names the file exactly:

```text
<date_created>-<title-slug>.html
```

For example, a report titled `Feature Ideas for Herdr` created on 2026-07-17 becomes `docs/chianyung/surprise-me/2026-07-17-feature-ideas-for-herdr.html`. Use lowercase hyphen-separated slugs, no extra timestamps or suffixes, and update an existing same-date/same-title report instead of creating a second filename. After rendering, verify the printed path exists and include it as a clickable local-file link in the chat response. Do not leave the temporary JSON spec in the repository.

## Stop Conditions

Do not create or modify source files, specifications, plans, issues, tickets, branches, commits, or the version-control index during the recommendation workflow. The requested HTML report under `docs/chianyung/surprise-me/` is the only allowed output artifact. Do not begin implementation. An implementation direction inside the analysis is allowed, but it must remain high-level.

If the repository evidence cannot identify a meaningful feature surface, or if mandatory research cannot be completed, explain the exact gap and ask only for the information or authorization needed to continue.
