# Auto-Swarm

**Automatically activate Claude Code Agent Teams based on task complexity.**

Claude Code's [Agent Teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams) (Orchestrate teams) feature lets you coordinate multiple Claude instances working in parallel. But by default, Claude only creates teams when you explicitly ask for them.

**Auto-Swarm changes that.** Once installed, Claude automatically creates agent teams when it detects a task that would benefit from parallel work — no slash commands or special prompts needed.

## Architecture: Dual-Layer Enforcement

Auto-Swarm uses a **dual-layer architecture** because CLAUDE.md alone is unreliable for behavior enforcement:

```
┌─────────────────────────────────────────────────────────┐
│                    User Prompt                          │
│                       ↓                                 │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Layer 1: UserPromptSubmit Hook (DETERMINISTIC) │    │
│  │  • Always fires on every user prompt            │    │
│  │  • Reads ~/.claude/auto-swarm-level             │    │
│  │  • Injects additionalContext into system prompt │    │
│  │  • Cannot be ignored by the model               │    │
│  └─────────────────────────────────────────────────┘    │
│                       ↓                                 │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Layer 2: CLAUDE.md Rules (ADVISORY)            │    │
│  │  • Detailed team templates and criteria          │    │
│  │  • Orchestration rules and model selection       │    │
│  │  • Reinforces hook injection with more context   │    │
│  └─────────────────────────────────────────────────┘    │
│                       ↓                                 │
│            Claude creates Agent Team                    │
│         (or handles directly if simple)                 │
└─────────────────────────────────────────────────────────┘
```

**Why two layers?** CLAUDE.md instructions are advisory — the model can and does ignore them (~40-50% compliance for complex behavioral rules). Hooks are deterministic — they always execute and inject context that the model reliably follows (~80-85% compliance). Together, they achieve the highest possible enforcement rate.

## Features

- **Deterministic hook enforcement** via UserPromptSubmit — injects team-creation rules on every prompt
- **Advisory CLAUDE.md rules** — detailed team templates and orchestration guidance
- **3 delegation levels** — from "delegate everything" to "disabled"
- **`/auto-swarm` command** to switch levels anytime
- **4 specialized teammate agents** optimized for team scenarios:
  - `swarm-researcher` — parallel research with haiku (fast + cheap)
  - `swarm-implementer` — code implementation with file ownership
  - `swarm-reviewer` — code review from assigned perspective (security/quality/correctness/performance)
  - `swarm-debugger` — hypothesis testing with inter-agent debate

## Requirements

- Claude Code with Agent Teams enabled:
  ```json
  // ~/.claude/settings.json
  {
    "env": {
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    }
  }
  ```

## Install

### Step 1: Add the marketplace

In terminal:
```bash
claude plugin marketplace add Wan-ZL/claude-auto-swarm
```

Or in Claude Code:
```
/plugin marketplace add Wan-ZL/claude-auto-swarm
```

### Step 2: Install the plugin

In terminal:
```bash
claude plugin install auto-swarm@claude-auto-swarm
```

Or in Claude Code:
```
/plugin install auto-swarm@claude-auto-swarm
```

### Step 3: Configure delegation level

```
/auto-swarm
```

Choose from 3 levels. This writes:
1. The level to `~/.claude/auto-swarm-level` (read by the hook)
2. The auto-activation rules to `~/.claude/CLAUDE.md` (advisory reinforcement)

Both take effect in the next new conversation.

## Delegation Levels

| # | Level | Leader Role | Token Cost |
|---|-------|------------|------------|
| 3 | **Full Delegate** | Pure coordinator. Delegates ALL work to teammates. | ~3-10x |
| 2 | **Smart Delegate** ★ | Creates teams for complex tasks. Handles simple directly. | ~2-5x |
| 1 | **Off** | Normal Claude Code. No auto-team behavior. | ~1x |

★ = Recommended

### Full Delegate (CEO Mode)

The leader is a pure coordinator. It **never** reads files, writes code, runs commands, or searches the codebase directly. Every request — even "fix this typo" — goes through a team. This maximizes:
- **Parallelism**: All work is done by teammates in parallel
- **Context window protection**: Leader's context stays clean for coordination
- **Token cost**: Higher, since even simple tasks spawn teammates

### Smart Delegate (Tech Lead Mode)

The leader acts like a tech lead. Complex tasks (3+ files, research, debugging, review) get a team. Simple tasks (greetings, typo fixes, one-line answers) are handled directly. Best balance of automation and efficiency.

### Off

Disables auto-swarm entirely. Claude Code operates normally — teams only when you explicitly ask.

## How It Works

### The Problem

Claude Code has Agent Teams built in, but it defaults to working alone. Even for tasks that would clearly benefit from parallel work (researching a bug from multiple angles, reviewing code for security AND performance, implementing across frontend + backend), Claude works sequentially unless you specifically ask for a team.

Worse, putting team-creation rules in CLAUDE.md alone is unreliable. CLAUDE.md is advisory — the model frequently ignores complex behavioral instructions due to:
- System prompt competition (built-in instructions override CLAUDE.md)
- Lost-in-the-middle effect (LLMs attend less to middle of long prompts)
- Training data priors (model defaults to single-agent behavior)
- Context compaction (rules get lost when conversation history is compressed)

### The Solution

Auto-Swarm uses a **UserPromptSubmit hook** for deterministic enforcement. The hook:
1. Fires on every user prompt (not on teammate prompts — avoids recursive injection)
2. Reads the current level from `~/.claude/auto-swarm-level`
3. Injects a concise team-creation instruction as `additionalContext` in the system prompt
4. The model reliably follows injected context because it appears as a system-level instruction

CLAUDE.md provides the second layer with detailed team templates, orchestration rules, and model selection guidance. Together, the two layers achieve ~80-85% auto-team compliance vs ~40-50% with CLAUDE.md alone.

## Included Agents

These specialized agents are designed for team scenarios. They know how to use TaskList, TaskUpdate, and SendMessage for coordination.

### `auto-swarm:swarm-researcher`
- **Model:** haiku (fast, cheap — ideal for parallel research)
- **Tools:** Read-only + web search
- **Use:** Parallel research. Spawn 2-3 researchers, each investigating a different angle.

### `auto-swarm:swarm-implementer`
- **Model:** sonnet
- **Tools:** Full read/write access
- **Use:** Implementation with file ownership. Each implementer owns distinct files.

### `auto-swarm:swarm-reviewer`
- **Model:** sonnet
- **Tools:** Read-only
- **Use:** Code review from assigned perspective (security, quality, correctness, performance).

### `auto-swarm:swarm-debugger`
- **Model:** sonnet
- **Tools:** Read + bash
- **Use:** Hypothesis testing. Debuggers actively challenge each other's theories.

## Examples

### What happens after install (Smart Delegate level)

**You say:** "Investigate why the login is slow"

**Claude automatically:**
1. Creates team `debug-login`
2. Creates 3 tasks (database query analysis, auth middleware profiling, frontend rendering check)
3. Spawns 3 `swarm-debugger` teammates, one per hypothesis
4. Teammates investigate in parallel, message each other to challenge theories
5. Leader synthesizes findings and reports the root cause
6. Cleans up the team

**You say:** "Fix the typo in README"

**Claude:** Just fixes it. No team needed.

### Changing levels

```
/auto-swarm full
```

Or interactively:

```
/auto-swarm
```

Claude will ask you to pick a level and update your configuration.

## Customization

The CLAUDE.md rules live between `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` markers. You can edit them directly if you want to fine-tune the criteria beyond the 3 preset levels.

The hook reads from `~/.claude/auto-swarm-level` — you can also edit this file directly (`full`, `smart`, or `off`).

## Uninstall

### Step 1: Remove the plugin

In terminal:
```bash
claude plugin remove auto-swarm@claude-auto-swarm
```

Or in Claude Code:
```
/plugin remove auto-swarm@claude-auto-swarm
```

### Step 2: Remove the marketplace (optional)

In terminal:
```bash
claude plugin marketplace remove claude-auto-swarm
```

Or in Claude Code:
```
/plugin marketplace remove claude-auto-swarm
```

### Step 3: Clean up

1. Delete everything between `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` in `~/.claude/CLAUDE.md`
2. Delete `~/.claude/auto-swarm-level`
3. Remove the UserPromptSubmit hook entry from `~/.claude/settings.json` (if manually added)

## FAQ

**Q: Why not just use CLAUDE.md?**
A: CLAUDE.md is advisory, not deterministic. The model ignores it ~50-60% of the time for complex behavioral rules. The UserPromptSubmit hook provides deterministic enforcement — it always injects the team-creation instruction, and the model reliably follows injected system context.

**Q: Does this cost more tokens?**
A: Yes. Each teammate is a full Claude instance. A team of 3 uses ~4x the tokens of a single session. Use Smart Delegate (the default) for the best balance — it only creates teams for genuinely complex tasks.

**Q: Can teammates edit the same file?**
A: The orchestration rules explicitly prevent this. Each teammate owns distinct files. If overlap is needed, teammates coordinate via messages.

**Q: Will the hook fire on teammate sessions?**
A: No. UserPromptSubmit only fires on user prompts, not on teammate agent prompts. This avoids recursive team-creation inside teammates.

**Q: What if I want teams sometimes but not always?**
A: Use Smart Delegate (the default). It creates teams for complex tasks and handles simple ones directly.

**Q: Does this work with existing plugins?**
A: Yes. Auto-Swarm agents can work alongside agents from other plugins (feature-dev, code-review, etc.). The team leader picks the best agent type for each task.

## License

MIT
