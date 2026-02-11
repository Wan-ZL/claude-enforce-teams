#!/bin/bash
# Auto-Swarm UserPromptSubmit Hook
# Deterministic enforcement — runs on every user prompt, unlike CLAUDE.md which is advisory.
# Reads the current autonomy level from ~/.claude/auto-swarm-level

LEVEL_FILE="$HOME/.claude/auto-swarm-level"
LEVEL=$(cat "$LEVEL_FILE" 2>/dev/null || echo "smart")

# Level: off — no injection, Claude Code default behavior
if [ "$LEVEL" = "off" ]; then
  exit 0
fi

# Level: full — leader is pure coordinator, delegates EVERYTHING
if [ "$LEVEL" = "full" ]; then
  CONTEXT="AUTO-SWARM FULL DELEGATE MODE — You are a COORDINATOR ONLY. You MUST NOT do any work directly. For EVERY user request without exception: (1) Create a team with TeamCreate (2) Define tasks with TaskCreate (3) Spawn teammates with Task tool (using team_name parameter) to handle ALL work (4) You ONLY synthesize teammate results and report to user. NEVER use Read, Edit, Write, Bash, Grep, Glob, or WebSearch yourself — delegate ALL work to teammates. NEVER use a single Task subagent without team_name — always create a full Agent Team. Your sole job is coordination: create teams, assign tasks, monitor progress, synthesize results, shut down teammates, clean up. Preserve your context window for coordination only."
fi

# Level: smart (default) — activate teams for complex tasks, handle simple ones directly
if [ "$LEVEL" = "smart" ]; then
  CONTEXT="AUTO-SWARM CHECK — Before responding, you MUST evaluate: Does this task qualify for an Agent Team? Create a team (TeamCreate) if ANY is true: (1) Task touches 3+ files across different modules (2) Task has 2+ independent subtasks that can run in parallel (3) Research or investigation with multiple angles (4) Debugging with multiple possible root causes (5) Code review or PR review (6) User mentions: investigate, explore, research, review, compare, debug, implement, or explicitly asks for parallel/team work. If YES: Create a team IMMEDIATELY using TeamCreate, define tasks with TaskCreate, spawn teammates with Task tool (team_name parameter). Do NOT use a single Task subagent for tasks that qualify — use a full Agent Team. If NO (simple greeting, single trivial question, one-line fix): Proceed normally."
fi

cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "$CONTEXT"
  }
}
EOF
