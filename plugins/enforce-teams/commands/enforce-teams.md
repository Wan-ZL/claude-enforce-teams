---
description: Configure Enforce Teams delegation level — controls when the team leader automatically creates Agent Teams
argument-hint: Optional level (full, smart, off)
---

# Enforce Teams Configuration

You are helping the user configure the Enforce Teams plugin, which controls when the team leader automatically creates Agent Teams (orchestrate teams of Claude Code sessions).

## Step 0: Prerequisites Check

Check if the environment variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is set to `1` or `true`. Run:

```bash
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

If it is NOT set (empty or missing), warn the user:

> Agent Teams requires the experimental flag. Add this to your shell profile:
> ```
> export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
> ```
> Then restart your terminal and try again.

Stop here if the flag is not set.

## Step 1: Read Current Level

Read the file `~/.claude/enforce-teams-level`. It contains a single word: `full`, `smart`, or `off`.

- If the file does not exist, default to `smart`.
- Store the current level for display in Step 2.

## Step 2: Show Table & Ask for Level

If `$ARGUMENTS` is provided and matches a valid level name (`full`, `smart`, `off`), skip asking and use that level directly. Go to Step 3.

Otherwise, display the following level table to the user. Mark the current level with "← Current". Then ask which level they want.

```
┌───┬──────────────────┬──────────────────────────────────────────────────────────┐
│ # │ Level            │ Behavior                                                 │
├───┼──────────────────┼──────────────────────────────────────────────────────────┤
│ 3 │ Full Delegate    │ Pure coordinator. Delegates ALL work to teammates.       │
│ 2 │ Smart Delegate ★ │ Creates teams for complex tasks. Handles simple directly.│
│ 1 │ Off              │ Default Claude Code behavior. Teams require your approval│
└───┴──────────────────┴──────────────────────────────────────────────────────────┘
★ = Recommended
```

Use AskUserQuestion to let the user pick:

```json
{
  "questions": [
    {
      "question": "Select delegation level:",
      "header": "Enforce Teams Level",
      "multiSelect": false,
      "options": [
        {
          "label": "3 - Full Delegate",
          "description": "Pure coordinator. Delegates ALL work to teammates — never reads, writes, or searches files directly."
        },
        {
          "label": "2 - Smart Delegate (Recommended)",
          "description": "Creates teams for complex tasks (3+ files, research, debug, review). Handles simple stuff directly."
        },
        {
          "label": "1 - Off",
          "description": "Restores default Claude Code behavior. Claude may suggest teams but always asks for your approval first."
        }
      ]
    }
  ]
}
```

## Step 3: Write Level to File

Write the chosen level keyword to `~/.claude/enforce-teams-level`:

- "3 - Full Delegate" → write `full`
- "2 - Smart Delegate" → write `smart`
- "1 - Off" → write `off`

```bash
echo "full" > ~/.claude/enforce-teams-level
```

(Replace `full` with the appropriate level keyword.)

## Step 4: Confirm

After writing, tell the user:

- Which level was set
- That the change takes effect in the **next new conversation**
- They can change it anytime with `/enforce-teams` or `/enforce-teams <level>`
- Brief explanation with a concrete example of what triggers (and doesn't trigger) a team at this level

Examples per level:

- **Full Delegate**: "Every request goes through a team. Even 'fix this typo' will spawn a teammate. Leader never touches files directly."
- **Smart Delegate**: "'Investigate the login bug' → spawns a debug team. 'Fix typo in README' → leader handles directly."
- **Off**: "Default Claude Code behavior. Claude may suggest teams for complex tasks but will ask for your approval."
