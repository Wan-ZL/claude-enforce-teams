# Auto-Swarm

**Automatically activate Claude Code Agent Teams based on task complexity.**

Claude Code's [Agent Teams](https://code.claude.com/docs/en/agent-teams) (Orchestrate teams) feature lets you coordinate multiple Claude instances working in parallel. But by default, Claude only creates teams when you explicitly ask for them.

**Auto-Swarm changes that.** Once installed, Claude automatically creates agent teams when it detects a task that would benefit from parallel work — no slash commands or special prompts needed.

## Features

- **Auto-activation rules** injected into your CLAUDE.md so Claude knows WHEN to create teams
- **5 aggressiveness levels** — from "teams for literally everything including hello" to "only when absolutely necessary"
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

### Step 3: Configure aggressiveness level

```
/auto-swarm
```

Choose from 5 levels. This writes the auto-activation rules to your `~/.claude/CLAUDE.md`. The rules take effect in every new conversation.

## Aggressiveness Levels

| Level | When Teams Are Created | Token Cost | Example |
|-------|----------------------|------------|---------|
| **Extreme** | EVERYTHING. Even "hello" spawns a team | ~5-10x | "hello" → team with greeter teammate → "Hi! How can I help?" |
| **Maximum** | ALL tasks, no exceptions. Same as Extreme, professional tone | ~5-10x | "hello" → team → response. "fix typo" → team → fix |
| **Balanced** | Moderately complex: 3+ files, multi-angle research, code review | ~3x | "investigate this bug" → debug team with 3 hypotheses |
| **Conservative** | Clearly complex: 5+ files, major features, large PRs | ~2x | "refactor auth system" → implementation team |
| **Minimal** | Only when asked or 10+ files | ~1x | Only if you say "use a team" or massive task |

## How It Works

### The Problem

Claude Code has Agent Teams built in, but it defaults to working alone. Even for tasks that would clearly benefit from parallel work (researching a bug from multiple angles, reviewing code for security AND performance, implementing across frontend + backend), Claude works sequentially unless you specifically ask for a team.

### The Solution

Auto-Swarm adds a rules section to your CLAUDE.md that tells Claude:
1. **Decision criteria** — when to create a team vs use a subagent vs work alone
2. **Team templates** — which team composition to use for research, implementation, review, or debugging
3. **Orchestration rules** — how to manage tasks, file ownership, and cleanup

Since CLAUDE.md is loaded into every conversation, these rules are always active. Claude reads them and automatically creates teams when your task matches the criteria.

### Why CLAUDE.md?

Claude Code plugins can provide agents (subagent types) and commands (slash commands), but they can't inject "always-on" behavior rules. The only mechanism that loads into every conversation and directly controls Claude's decision-making is **CLAUDE.md**. That's why `/auto-swarm` writes rules there — it's the only way to make the behavior truly automatic.

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

### What happens after install (Balanced level)

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
/auto-swarm conservative
```

Or interactively:

```
/auto-swarm
```

Claude will ask you to pick a level and update your CLAUDE.md.

## Customization

The rules live in your `~/.claude/CLAUDE.md` between `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` markers. You can edit them directly if you want to fine-tune the criteria beyond the 5 preset levels.

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

### Step 3: Remove the rules from CLAUDE.md

Open `~/.claude/CLAUDE.md` and delete everything between `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` (inclusive).

## FAQ

**Q: Does this cost more tokens?**
A: Yes. Each teammate is a full Claude instance. A team of 3 uses ~4x the tokens of a single session. Auto-Swarm helps by using haiku for research tasks and only creating teams when the task actually benefits from parallelism.

**Q: Can teammates edit the same file?**
A: The orchestration rules explicitly prevent this. Each teammate owns distinct files. If overlap is needed, teammates coordinate via messages.

**Q: What if I want teams sometimes but not always?**
A: Use the Conservative or Minimal level. Or edit the rules in CLAUDE.md to add your own criteria.

**Q: Does this work with existing plugins?**
A: Yes. Auto-Swarm agents can work alongside agents from other plugins (feature-dev, code-review, etc.). The team leader picks the best agent type for each task.

## License

MIT
