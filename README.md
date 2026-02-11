# Enforce Teams

**Enforce Claude Code Agent Teams usage at configurable delegation levels.**

Claude Code's [Agent Teams](https://code.claude.com/docs/en/agent-teams) feature lets you coordinate multiple Claude instances working in parallel. By default, Claude won't create a team without your approval.

**Enforce Teams changes that.** Choose a delegation level, and the team leader automatically creates agent teams based on your configured policy — no slash commands or special prompts needed.

## Prerequisites

Agent Teams is an **experimental feature** that must be opted into before this plugin can work. Enable it by adding the following to your settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Add this to `~/.claude/settings.json` (global) or `.claude/settings.json` (per-project).

## Features

- **Auto-activation via UserPromptSubmit hook** — delegation behavior injected into every conversation turn
- **3 delegation levels** — from "delegate everything" to "default behavior"
- **`/enforce-teams` command** to switch levels anytime

## Install

### Step 1: Add the marketplace

```bash
claude plugin marketplace add Wan-ZL/claude-enforce-teams
```

Or in Claude Code:
```
/plugin marketplace add Wan-ZL/claude-enforce-teams
```

### Step 2: Install the plugin

```bash
claude plugin install enforce-teams@claude-enforce-teams
```

Or in Claude Code:
```
/plugin install enforce-teams@claude-enforce-teams
```

### Step 3: Restart Claude Code

Restart Claude Code to load the plugin hooks. You can verify the hook is loaded by running `/hooks` — you should see:

```
bash ${CLAUDE_PLUGIN_ROOT}/hooks/enforce_teams_check.sh (read-only)  Plugin Hooks
```

### Step 4: Configure delegation level (optional)

```
/enforce-teams
```

Choose from 3 levels. The default is **Smart Delegate**. The selected level takes effect in the next new conversation.

## Delegation Levels

```
┌───┬──────────────────┬──────────────────────────────────────────────────────────┐
│ # │ Level            │ Behavior                                                 │
├───┼──────────────────┼──────────────────────────────────────────────────────────┤
│ 3 │ Full Delegate    │ Pure coordinator. Delegates ALL work to teammates.       │
│ 2 │ Smart Delegate * │ Creates teams for complex tasks. Handles simple directly.│
│ 1 │ Off              │ Default Claude Code behavior. Teams require your approval│
└───┴──────────────────┴──────────────────────────────────────────────────────────┘
* = Recommended
```

### Full Delegate (Level 3)

The team leader becomes a pure coordinator. Every user message triggers a team — the leader never does work directly. Even simple questions go through a teammate. This maximizes parallelism but uses more tokens.

### Smart Delegate (Level 2) — Recommended

The team leader creates teams when the task is complex enough to benefit from parallel work (3+ files, research, review, debugging, multi-file implementation). Simple tasks like typo fixes or direct questions are handled directly without a team.

### Off (Level 1)

Restores default Claude Code behavior. The team leader may suggest creating a team for complex tasks, but will always ask for your approval first. Teams are never created automatically.

## How It Works

### The Problem

Claude Code has Agent Teams built in, but it defaults to asking for permission before creating teams. Even for tasks that clearly benefit from parallel work (researching a bug from multiple angles, reviewing code for security AND performance, implementing across frontend + backend), Claude asks first rather than just creating the team.

### The Solution

Enforce Teams uses a **UserPromptSubmit hook** to inject delegation behavior into every conversation turn. The hook reads the configured level from `~/.claude/enforce-teams-level` and injects the appropriate context that tells Claude:

1. **Decision criteria** — when to create a team vs work alone
2. **Team templates** — which team composition to use for research, implementation, review, or debugging
3. **Orchestration rules** — how to manage tasks, file ownership, and cleanup

This approach means the plugin does **not** modify your CLAUDE.md. The behavior is injected dynamically at the start of each conversation turn.

## Examples

### Smart Delegate level (recommended)

**You say:** "Investigate why the login is slow"

**The team leader automatically:**
1. Creates team `debug-login`
2. Creates 3 tasks (database query analysis, auth middleware profiling, frontend rendering check)
3. Spawns 3 teammates, one per hypothesis
4. Teammates investigate in parallel, message each other to challenge theories
5. Leader synthesizes findings and reports the root cause
6. Cleans up the team

**You say:** "Fix the typo in README"

**Leader:** Just fixes it. No team needed.

### Changing levels

Directly:
```
/enforce-teams full-delegate
```

Or interactively:
```
/enforce-teams
```

Claude will show you all 3 levels and let you pick.

## Orchestration Rules

When teams are created, the following rules apply:

1. **Tasks before teammates** — define the task list with dependencies before spawning teammates
2. **Delegate mindset** — the leader coordinates, teammates do the work
3. **Model selection** — haiku for research tasks, sonnet for implementation and review
4. **No file conflicts** — each teammate owns distinct files
5. **Rich spawn prompts** — include file paths, conventions, and focus areas
6. **Auto-cleanup** — all done, shutdown teammates, cleanup team, report to user

## Uninstall

### Step 1: Remove the plugin

```bash
claude plugin remove enforce-teams@claude-enforce-teams
```

Or in Claude Code:
```
/plugin remove enforce-teams@claude-enforce-teams
```

Hooks are automatically removed when the plugin is uninstalled.

### Step 2: Remove the level config

```bash
rm ~/.claude/enforce-teams-level
```

### Optional: Remove the marketplace

```bash
claude plugin marketplace remove claude-enforce-teams
```

## FAQ

**Q: Does this use more tokens?**
A: Yes. Agent teams use more tokens due to coordination overhead and parallel processing. The exact amount depends on task complexity and team size. The plugin mitigates this by using haiku for research tasks and only creating teams when the task benefits from parallelism (at the Smart Delegate level).

**Q: Can teammates edit the same file?**
A: The orchestration rules prevent this. Each teammate owns distinct files. If overlap is needed, teammates coordinate via messages.

**Q: What if I want teams sometimes but not always?**
A: Use the Smart Delegate level (recommended). It creates teams for complex tasks and handles simple ones directly. Or use Off and let Claude ask before creating teams.

**Q: Does this work with existing plugins?**
A: Yes. Enforce Teams works alongside other plugins. The team leader picks the best approach for each task.

**Q: What happens if Agent Teams is not enabled?**
A: The plugin won't work. Agent Teams is an experimental feature that must be enabled first. See the [Prerequisites](#prerequisites) section.

## License

MIT
