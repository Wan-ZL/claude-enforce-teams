# Enforce Teams

**Enforce Claude Code Agent Teams usage at configurable delegation levels.**

Uses a UserPromptSubmit hook to inject delegation behavior into every conversation turn. No CLAUDE.md modification needed.

See the [full documentation](../../README.md) for detailed usage, examples, and FAQ.

## Prerequisites

Agent Teams must be enabled first — it is an experimental feature:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Add this to `~/.claude/settings.json` (global) or `.claude/settings.json` (per-project).

## Install

```bash
claude plugin marketplace add Wan-ZL/claude-enforce-teams
claude plugin install enforce-teams@claude-enforce-teams
```

Then configure your delegation level:
```
/enforce-teams
```

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

## Uninstall

```bash
claude plugin remove enforce-teams@claude-enforce-teams
rm ~/.claude/enforce-teams-level
rm ~/.claude/hooks/enforce_teams_check.sh
```

Then remove the `UserPromptSubmit` hook entry referencing `enforce_teams_check.sh` from `~/.claude/settings.json`.

If `~/.claude/CLAUDE.md` contains an `<!-- enforce-teams:start -->` to `<!-- enforce-teams:end -->` block, delete that entire block.

## License

MIT
