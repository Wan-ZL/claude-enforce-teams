---
description: Configure Auto-Swarm aggressiveness level — controls when Claude automatically creates Agent Teams
argument-hint: Optional level (extreme, maximum, balanced, conservative, minimal)
---

# Auto-Swarm Configuration

You are helping the user configure the Auto-Swarm plugin, which controls when Claude Code automatically creates Agent Teams (Orchestrate teams of Claude Code sessions).

## Step 1: Read Current Configuration

Read the user's `~/.claude/CLAUDE.md` file. Look for a section between `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` markers. If found, identify the current aggressiveness level from the `**Active Level:**` line.

## Step 2: Show Current Status & Ask for Level

If `$ARGUMENTS` is provided and matches a valid level name (extreme, maximum, balanced, conservative, minimal), skip asking and use that level directly.

Otherwise, use AskUserQuestion with the following configuration. Mark the current level with "(Current)" in its description. Order is from highest to lowest aggressiveness:

```json
{
  "questions": [
    {
      "question": "Select aggressiveness level for automatic Agent Teams (high → low):",
      "header": "Swarm Level",
      "multiSelect": false,
      "options": [
        {
          "label": "Extreme",
          "description": "Teams for EVERYTHING. Even 'hello' spawns a team. Pure swarm lifestyle."
        },
        {
          "label": "Maximum",
          "description": "Teams for ALL tasks, no exceptions. Same rules as Extreme, professional tone."
        },
        {
          "label": "Balanced (Recommended)",
          "description": "Teams for moderately complex tasks: 3+ files, multi-angle research, code review."
        },
        {
          "label": "Conservative",
          "description": "Teams only for clearly complex work: 5+ files, major features, large PRs."
        }
      ]
    }
  ]
}
```

If the user selects "Other", ask them to type one of: extreme, maximum, balanced, conservative, minimal. The "Minimal" level is available via Other or via `/auto-swarm minimal`.

## Step 3: Write Configuration to CLAUDE.md

After the user picks a level, read `~/.claude/CLAUDE.md` again. Then:

- If `<!-- auto-swarm:start -->` and `<!-- auto-swarm:end -->` markers exist, REPLACE everything between them (inclusive) with the new config below.
- If markers don't exist, INSERT the new config block BEFORE the line `## Parallel Agent Development Patterns` if it exists. If that line doesn't exist, append to the end of the file.

Use the appropriate template based on the chosen level:

---

### EXTREME Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — ALWAYS USE TEAMS

**Active Level: EXTREME** — Change with `/auto-swarm`

ALWAYS create an agent team for EVERY interaction. No exceptions. Even greetings, simple questions, and trivial tasks go through a team. This is the swarm lifestyle.

### Rules

**EVERY user message triggers a team.** No exceptions. Process:
1. Create a team immediately upon receiving any user message
2. Spawn at least 1 teammate (more for complex tasks)
3. Teammate(s) process the request and send results back to leader
4. Leader synthesizes and responds to user
5. Cleanup the team

**For greetings/simple questions** (hello, thanks, what time is it, etc.):
- Create team with 1 teammate (haiku, fast)
- Teammate formulates the response and sends to leader
- Leader relays to user and cleans up

**For any task with identifiable subtasks:**
- Create team with 2-5 teammates depending on complexity
- Each teammate handles one aspect in parallel

**For research/review/debug/implementation:**
- Use full team templates below with 3+ teammates

### Team Templates

**Quick Response** (greetings, simple questions, single-file edits):
- 1 general-purpose teammate (haiku). Processes request, reports to leader. Fast in-and-out.

**Research/Explore**: 2-3 Explore teammates (haiku), each on a different angle. Leader synthesizes.
**Implementation**: Plan teammate (architect) → 2-3 general-purpose implementers → reviewer. Pipeline with dependencies.
**Review**: 3 parallel reviewers — security, quality, correctness. Leader combines report.
**Debug**: 3 teammates testing competing hypotheses. They message each other to challenge theories.

### Orchestration Rules
1. Create tasks BEFORE spawning teammates — define task list with dependencies first
2. Delegate mindset — leader NEVER does the work directly, ALWAYS delegate to teammates
3. Model selection — haiku for simple/research tasks, sonnet for implementation, opus for critical decisions
4. No file conflicts — each teammate owns distinct files
5. Rich spawn prompts — include file paths, conventions, focus areas
6. Auto-cleanup — all done → shutdown teammates → cleanup team → report to user
<!-- auto-swarm:end -->
```

---

### MAXIMUM Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Act, don't ask

**Active Level: MAXIMUM** — Change with `/auto-swarm`

ALWAYS create an agent team for every task. Do NOT ask permission — just do it. No exceptions, not even for one-word inputs.

### Rules

**EVERY user message triggers a team.** No exceptions. This includes one-word messages, simple questions, greetings, and acknowledgments.

**For simple/quick interactions** (greetings, one-word input, factual questions, typo fixes):
- Create team with 1 teammate (haiku, fast)
- Teammate processes the request and sends result to leader
- Leader relays to user and cleans up

**For any task with identifiable subtasks:**
- Create team with 2-5 teammates depending on complexity
- Each teammate handles one aspect in parallel

**For research/review/debug/implementation:**
- Use full team templates below with 3+ teammates

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

### BALANCED Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Act, don't ask

**Active Level: BALANCED** — Change with `/auto-swarm`

AUTOMATICALLY create an agent team when a task is moderately complex. Do NOT ask permission — just do it.

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
- Trivial edit, typo fix, direct one-line answer

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

### CONSERVATIVE Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Use for complex tasks

**Active Level: CONSERVATIVE** — Change with `/auto-swarm`

Create agent teams only for clearly complex tasks that genuinely benefit from parallelism. Prefer subagents or single session for routine work.

### When to AUTO-CREATE Agent Teams

**USE AGENT TEAM when ANY is true:**
- Task touches 5+ files across different modules
- Task has 3+ clearly independent subtasks that benefit from parallelism
- Major debugging with 3+ plausible root causes
- PR review for 10+ changed files
- Full feature implementation spanning multiple layers (frontend + backend + database + tests)
- User explicitly mentions wanting thorough/parallel investigation

**USE SUBAGENT when:**
- Task touches 1-4 files
- Research with a single clear focus
- Code review for small PRs (< 10 files)
- Quick search or exploration

**SINGLE SESSION when:**
- Edits to 1-2 files, typo fixes, direct questions

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

### MINIMAL Template

```
<!-- auto-swarm:start -->
## Agent Teams Auto-Activation — Only when necessary

**Active Level: MINIMAL** — Change with `/auto-swarm`

Only create agent teams for very large tasks or when explicitly requested. Default to subagents or single session for most work.

### When to AUTO-CREATE Agent Teams

**USE AGENT TEAM only when:**
- Task touches 10+ files across many modules
- User explicitly asks for a team, swarm, or parallel agents
- Full-stack feature implementation with clear separation of concerns
- Very large PR review (20+ files)
- Complex debugging that has already failed with single-agent approaches

**USE SUBAGENT for most tasks:**
- Research, exploration, focused analysis
- Code review for normal PRs
- Implementation of moderate features
- Debugging with 1-2 hypotheses

**SINGLE SESSION when:**
- Simple edits, quick questions, small fixes

### Team Templates (when teams ARE used)

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

## Step 4: Confirm

After writing, tell the user:
- Which level was set
- That the change takes effect in the **next new conversation**
- They can change it anytime with `/auto-swarm` or `/auto-swarm <level>`
- Brief explanation with a concrete example of what triggers (and doesn't trigger) a team at this level
