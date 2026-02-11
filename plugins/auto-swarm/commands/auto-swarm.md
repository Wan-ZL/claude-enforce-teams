---
description: Configure Auto-Swarm delegation level — controls when Claude automatically creates Agent Teams
argument-hint: Optional level (full, smart, off)
---

# Auto-Swarm Configuration

You are helping the user configure the Auto-Swarm plugin, which controls when Claude Code automatically creates Agent Teams (Orchestrate teams of Claude Code sessions).

## Step 0: Prerequisites Check

Check if the user has Agent Teams enabled. Read `~/.claude/settings.json` and verify that `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set to `"1"`.

If NOT set, tell the user:
```
Agent Teams is not enabled. Add this to ~/.claude/settings.json:

{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}

Then restart Claude Code and run /auto-swarm again.
```
Stop here — do not proceed to Step 1.

## Step 1: Read Current Configuration

Read the file `~/.claude/auto-swarm-level`. The content will be one of: `full`, `smart`, or `off`. If the file doesn't exist, the default is `smart`.

Also read `~/.claude/CLAUDE.md` to check for existing `<!-- auto-swarm:start -->` / `<!-- auto-swarm:end -->` markers.

## Step 2: Show Current Status & Ask for Level

If `$ARGUMENTS` is provided and matches a valid level name (full, smart, off), skip asking and use that level directly.

Otherwise, display the following level table to the user. Mark the current level with "← Current". Then ask which level they want.

```
┌───┬──────────────────┬──────────────────────────────────────────────────────────┬────────────┐
│ # │ Level            │ Leader Role                                              │ Token Cost │
├───┼──────────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ 3 │ Full Delegate    │ Pure coordinator. Delegates ALL work to teammates.       │ ~3-10x     │
│ 2 │ Smart Delegate ★ │ Creates teams for complex tasks. Handles simple directly.│ ~2-5x      │
│ 1 │ Off              │ Normal Claude Code. No auto-team behavior.               │ ~1x        │
└───┴──────────────────┴──────────────────────────────────────────────────────────┴────────────┘
★ = Recommended
```

Use AskUserQuestion to let the user pick:

```json
{
  "questions": [
    {
      "question": "Select delegation level:",
      "header": "Swarm Level",
      "multiSelect": false,
      "options": [
        {
          "label": "3 - Full Delegate",
          "description": "Leader is a pure coordinator (CEO). Delegates ALL work to teammates — never reads, writes, or searches files directly. Maximizes parallelism and protects leader context window."
        },
        {
          "label": "2 - Smart Delegate (Recommended)",
          "description": "Leader is a tech lead. Creates teams for complex tasks (3+ files, research, debug, review). Handles simple stuff directly (greetings, trivial fixes, one-line answers)."
        },
        {
          "label": "1 - Off",
          "description": "Disables auto-swarm. Normal Claude Code behavior — only creates teams when you explicitly ask."
        }
      ]
    }
  ]
}
```

## Step 3: Write Level State File

Write the chosen level to `~/.claude/auto-swarm-level`:
- Full Delegate → write `full`
- Smart Delegate → write `smart`
- Off → write `off`

## Step 4: Write Configuration to CLAUDE.md

Read `~/.claude/CLAUDE.md` again. Then:

- If `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` markers exist, REPLACE everything between them (inclusive) with the new config below.
- If markers don't exist, INSERT the new config block BEFORE the line `## Parallel Agent Development Patterns` if it exists. If that line doesn't exist, append to the end of the file.

Use the appropriate template based on the chosen level:

---

### FULL DELEGATE Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Full Delegate Mode

**Active Level: FULL DELEGATE** — Change with `/auto-swarm`

You are a **COORDINATOR ONLY**. You MUST NOT do any work directly. For EVERY user request:

1. Create a team with TeamCreate
2. Define tasks with TaskCreate
3. Spawn teammates with Task tool (using team_name parameter) to handle ALL work
4. You ONLY synthesize teammate results and report to user

**NEVER** use Read, Edit, Write, Bash, Grep, Glob, or WebSearch yourself — delegate ALL work to teammates. Your sole job is coordination: create teams, assign tasks, monitor progress, synthesize results, shut down teammates, clean up. Preserve your context window for coordination only.

### Team Templates

**Quick Response** (greetings, simple questions):
- 1 general-purpose teammate (haiku). Processes request, reports to leader.

**Research/Explore**: 2-3 Explore teammates (haiku), each on a different angle. Leader synthesizes.
**Implementation**: Plan teammate (architect) → 2-3 general-purpose implementers → reviewer. Pipeline with dependencies.
**Review**: 3 parallel reviewers — security, quality, correctness. Leader combines report.
**Debug**: 3 teammates testing competing hypotheses. They message each other to challenge theories.

### Orchestration Rules
1. Create tasks BEFORE spawning teammates — define task list with dependencies first
2. Delegate mindset — leader NEVER does the work directly, ALWAYS delegate
3. Model selection — haiku for simple/research, sonnet for implementation, opus for critical decisions
4. No file conflicts — each teammate owns distinct files
5. Rich spawn prompts — include file paths, conventions, focus areas
6. Auto-cleanup — all done → shutdown teammates → cleanup team → report to user
<!-- auto-swarm:end -->
```

---

### SMART DELEGATE Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Smart Delegate Mode

**Active Level: SMART DELEGATE** — Change with `/auto-swarm`

AUTOMATICALLY create an agent team when a task is complex enough to benefit from parallelism. Handle simple tasks directly.

### When to AUTO-CREATE Agent Teams

**USE AGENT TEAM when ANY is true:**
- Task touches 3+ files across different modules/directories
- Task has 2+ independent subtasks that can run in parallel
- Research/investigation with multiple angles to explore
- Debugging with multiple possible root causes
- Code review or PR review (spawn parallel specialist reviewers)
- Feature implementation spanning frontend + backend + tests
- Any broad exploration, comparison, or analysis task
- User says: investigate, explore, research, review, compare, debug, implement (multi-file)

**USE SUBAGENT when:**
- Single focused lookup (find a file, read one doc, quick grep)
- Task completes in < 1 minute
- No inter-agent communication needed

**SINGLE SESSION only when:**
- Trivial edit, typo fix, direct one-line answer, simple greeting

### Team Templates

**Research/Explore**: 2-3 Explore teammates (haiku), each on a different angle. Leader synthesizes.
**Implementation**: Plan teammate (architect) → 2-3 general-purpose implementers → reviewer. Pipeline with dependencies.
**Review**: 3 parallel reviewers — security, quality, correctness. Leader combines report.
**Debug**: 3 teammates testing competing hypotheses. They message each other to challenge theories.

### Orchestration Rules
1. Create tasks BEFORE spawning teammates — define task list with dependencies first
2. Delegate mindset — leader coordinates, doesn't implement
3. Model selection — haiku for research, sonnet for implementation, opus for critical decisions
4. No file conflicts — each teammate owns distinct files
5. Rich spawn prompts — include file paths, conventions, focus areas
6. Auto-cleanup — all done → shutdown teammates → cleanup team → report to user
<!-- auto-swarm:end -->
```

---

### OFF Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Disabled

**Active Level: OFF** — Change with `/auto-swarm`

Auto-Swarm is disabled. Claude Code operates normally — only create Agent Teams when explicitly requested by the user.
<!-- auto-swarm:end -->
```

---

## Step 5: Confirm

After writing, tell the user:
- Which level was set
- That the change takes effect in the **next new conversation**
- They can change it anytime with `/auto-swarm` or `/auto-swarm <level>`
- Brief explanation of what the level does

Examples by level:
- **Full Delegate**: "Every request goes through a team. Even 'fix this typo' will spawn a teammate. Leader never touches files directly — maximum context window protection."
- **Smart Delegate**: "'Investigate the login bug' → spawns a debug team. 'Fix typo in README' → leader handles directly."
- **Off**: "Normal Claude Code behavior. Teams only when you ask."
