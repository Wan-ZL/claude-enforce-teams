# Claude Auto-Swarm Marketplace

A Claude Code plugin marketplace for automatic Agent Teams activation.

## Installation

### Step 1: Add this marketplace

```bash
claude plugin marketplace add Wan-ZL/claude-auto-swarm
```

### Step 2: Install the plugin

```bash
claude plugin install auto-swarm@claude-auto-swarm
```

Or in Claude Code, use:

```
/plugin install auto-swarm@claude-auto-swarm
```

### Step 3: Configure aggressiveness level

```
/auto-swarm
```

Choose from 5 levels: **Extreme**, **Maximum**, **Balanced**, **Conservative**, or **Minimal**.

## What This Does

Once installed, Claude Code will **automatically create Agent Teams** when it detects tasks that benefit from parallel work — no special prompts needed.

See [plugins/auto-swarm/README.md](plugins/auto-swarm/README.md) for full documentation.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| **auto-swarm** | Auto-activate Agent Teams with configurable aggressiveness. Includes 4 specialized teammate agents (researcher, implementer, reviewer, debugger). |

## License

MIT
