---
name: github-repo-ops
description: GitHub repository creation and management via gh CLI. Use when user needs to create a new GitHub repo (private/public), set up initial files (README/.gitignore), or configure repo settings. Works standalone or as a prerequisite for project-ops skill.
---

# GitHub Repo Ops

Create and manage GitHub repositories via `gh` CLI.

## Prerequisites

```bash
# One-time auth
gh auth login
gh auth status
```

## Commands

### Create Repository

```powershell
# Via gh CLI directly
gh repo create <name> --private --confirm

# Via this skill wrapper
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" create my-project --private
```

### Create with Template

```powershell
# With README + .gitignore
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" create my-project --private --with-readme --gitignore Node
```

### Clone Existing Repo

```powershell
powershell -ExecutionPolicy Bypass -File "skills/github-repo-ops/scripts/repo.ps1" clone https://github.com/user/repo.git "C:\workspace\repo"
```

## Output Format

On success, returns JSON:

```json
{
  "name": "my-project",
  "html_url": "https://github.com/user/my-project",
  "clone_url": "https://github.com/user/my-project.git",
  "ssh_url": "git@github.com:user/my-project.git",
  "private": true,
  "created_at": "2026-03-25T09:30:00Z"
}
```

## Integration with project-ops

```powershell
# Step 1: Create repo
$repo = powershell -File skills/github-repo-ops/scripts/repo.ps1 create my-project --private --json
$repoObj = $repo | ConvertFrom-Json

# Step 2: Initialize project-ops with repo path
powershell -File skills/project-ops/scripts/project.ps1 init my-project "My Project" -RepoPath "C:\workspace\my-project"
```

## Available .gitignore Templates

- `Node` — Node.js / npm / yarn
- `Python` — Python / pip / venv
- `Rust` — Rust / cargo
- `Go` — Go modules
- `Java` — Maven / Gradle
- `Dotnet` — .NET / Visual Studio
- `Common` — OS files + IDE configs

See `assets/templates/gitignore/` for full list.

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `gh: not found` | gh CLI not installed | Install from https://cli.github.com |
| `authentication required` | Not logged in | Run `gh auth login` |
| `repo already exists` | Name taken | Choose different name or use `--force` |
