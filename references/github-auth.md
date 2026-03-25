# GitHub Authentication Guide

## One-Time Setup

```bash
# Install gh CLI (if not installed)
# Windows (winget):
winget install GitHub.cli

# macOS (brew):
brew install gh

# Verify installation
gh --version
```

## Authenticate

```bash
# Interactive login
gh auth login

# Follow prompts:
# 1. GitHub.com or GitHub Enterprise? → GitHub.com
# 2. HTTPS or SSH? → HTTPS (recommended)
# 3. Login with browser? → Yes
# 4. Copy one-time code and paste in browser
```

## Verify

```bash
gh auth status
```

Expected output:
```
✓ Logged in to github.com as <username>
✓ Token: gho_************************************
✓ Token scopes: gist, read:org, repo, workflow
```

## Troubleshooting

### "Authentication required"
Run `gh auth login` again.

### "Token expired"
Run `gh auth refresh`.

### "gh not found"
Install from https://cli.github.com or use package manager.
