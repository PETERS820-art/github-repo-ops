# github-repo-ops

OpenClaw skill for creating and managing GitHub repositories via `gh` CLI.

## Features

- Create private/public repositories
- Add README and .gitignore templates
- Clone existing repositories
- JSON output for automation

## Installation

### Option A: From .skill package
```powershell
# Download github-repo-ops.skill
Expand-Archive github-repo-ops.skill -DestinationPath "C:\Users\Administrator\.openclaw\workspace\skills"
openclaw gateway restart
```

### Option B: From source
```powershell
Copy-Item -Recurse github-repo-ops "C:\Users\Administrator\.openclaw\workspace\skills\github-repo-ops"
openclaw gateway restart
```

## Usage

```powershell
# Create a private repo with README and .gitignore
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" create my-project --private --WithReadme --GitIgnore Node

# Output as JSON
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" create my-project --private --json

# Clone existing repo
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" clone https://github.com/user/repo.git "C:\workspace\repo"

# Get repo info
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" info my-project --json
```

## Prerequisites

```bash
# Install gh CLI
gh --version

# Authenticate (one-time)
gh auth login
```

## Available .gitignore Templates

- `Node` — Node.js / npm
- `Python` — Python / pip
- `Rust` — Rust / cargo
- `Go` — Go modules
- `Common` — OS + IDE files

## License

MIT
