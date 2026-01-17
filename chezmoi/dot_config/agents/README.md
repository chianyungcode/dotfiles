 # Agents

 This folder stores configuration and assets for agents.

 ## Structure
 - `AGENTS.md`
   Primary marker/registry file for agents. Currently holds a simple identity string.
 - `commands/`
   Agent command tasks. Example: `commands/commit-pr/task.md`.
 - `hooks/`
   Hooks executed at specific moments. Example: `hooks/hook1.md`.
 - `skills/`
   Agent skill definitions (each skill has a `SKILL.md`).

 ## Available skills
 - `feedback-agent` — Review manually written code with a focus on understanding the feature, correctness, and learning.
 - `manual-code_low` — Concepts and documentation only, no code.
 - `manual-code_low-medium` — Concepts plus examples from documentation (no complete solutions).
 - `manual-code_medium` — Step-by-step guidance with examples that differ from the current codebase.

 ## Notes
 - Adjust `AGENTS.md` and files under `commands/`, `hooks/`, and `skills/` to fit your workflow.
 - Keep folder and file naming consistent so agents are easy to register and invoke.

---

# Tools
[iannuttall/dotagents: One location for all of your hooks, commands, skills, and AGENT/CLAUDE.md files.](https://github.com/iannuttall/dotagents)


## AI skills references
- https://skills.sh/
- https://github.com/numman-ali/openskills
- https://claude-plugins.dev/skills
- https://vercel.com/blog/introducing-react-best-practices
