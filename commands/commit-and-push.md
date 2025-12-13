---
description: Run pre-commit checks, commit changes following CLAUDE.md guidelines, and push to appropriate branch
---

# Commit and Push

Safely commit changes following project conventions and push to the appropriate branch.

## Overview

This command:
1. Runs `/pre-commit` security checks
2. Analyzes changes and generates a proper commit message
3. Determines the correct branch to push to (handles protected main branches)
4. Creates the commit and pushes

## Process

### Step 1: Run Pre-Commit Checks

**First, execute the pre-commit security checks:**

Run the full `/pre-commit` workflow. If any HIGH priority issues are found (real secrets in source code), STOP and report the issues. Do not proceed with commit.

For LOW priority issues (documentation false positives), offer to fix them but allow proceeding if the user chooses.

### Step 2: Check Git Status

```bash
git status --porcelain
```

If there are no changes to commit, inform the user and stop.

### Step 3: Determine Current Branch and Remote

```bash
git branch --show-current
git remote -v
```

Store the current branch name.

### Step 4: Check if Main Branch is Protected

Determine if we're on the main/master branch and if it's protected:

```bash
# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if we're on main/master
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    # Try to get protection status via gh CLI
    gh api repos/{owner}/{repo}/branches/$CURRENT_BRANCH/protection 2>/dev/null
fi
```

**If on protected main/master:**

Ask the user what type of branch to create:
- `feature/` - for new features
- `fix/` - for bug fixes
- `chore/` - for maintenance tasks
- `docs/` - for documentation changes
- `refactor/` - for code refactoring

Then ask for a brief branch name descriptor (e.g., "add-authentication", "fix-login-bug").

Create and switch to the new branch:
```bash
git checkout -b {type}/{descriptor}
```

### Step 5: Analyze Changes for Commit Message

**Gather information about the changes:**

```bash
# See what files changed
git status

# See the actual changes (staged and unstaged)
git diff
git diff --cached

# Check recent commit style
git log --oneline -5
```

### Step 6: Stage Changes

If there are unstaged changes, ask the user:
- Stage all changes? (`git add .`)
- Stage specific files? (list them)
- Stage interactively? (not supported - list files instead)

```bash
git add .
# or
git add <specific-files>
```

### Step 7: Generate Commit Message

**Follow CLAUDE.md commit message guidelines:**

1. **Format**: Use conventional commit format
   - Examples: `feat: Add user authentication`, `fix: Resolve login timeout`, `docs: Update API reference`

2. **Style**:
   - Use imperative mood ("Add" not "Adds" or "Added")
   - First line: concise summary (50-72 chars)
   - Body: explain the "why", not just the "what"
   - Do NOT include:
     - Generic "Changes" section with bulleted lists
     - "Files changed" section
     - Advertising like "Generated with Claude Code"
     - Co-authored-by trailers
     - Signed-off-by trailers (leave for human to add)

3. **Attribution**: Add `Assisted-by: Claude Code (Opus 4.5)` line

**Example format:**
```
feat: Add rate limiting to API endpoints

Prevents abuse by limiting requests to 100/minute per user.
Rate limit headers included in responses for client awareness.

Assisted-by: Claude Code (Opus 4.5)
```

**Present the proposed commit message to the user and ask for approval or modifications.**

### Step 8: Create the Commit

```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

### Step 9: Push to Remote

**Determine push strategy:**

```bash
# Check if branch exists on remote
git ls-remote --heads origin $(git branch --show-current)
```

**If new branch (no remote tracking):**
```bash
git push -u origin $(git branch --show-current)
```

**If existing branch with remote:**
```bash
git push
```

### Step 10: Offer to Create PR (if on feature branch)

If we pushed to a feature/fix/etc branch (not main), offer to create a PR:

```
Would you like me to create a pull request to merge this into main?
```

If yes, provide the gh command or guidance:
```bash
gh pr create --title "<PR title>" --body "<PR description>"
```

## Summary Report

After completion, provide:

```
Commit and Push Complete

Branch: {branch-name}
Commit: {short-hash} {commit-subject}
Remote: origin/{branch-name}

{If feature branch}
Next steps:
- Create PR: gh pr create
- Or visit: {repo-url}/compare/{branch-name}
```

## Error Handling

### Pre-commit Fails
```
Pre-commit checks failed. Please resolve the security issues before committing.
Run /pre-commit to see the details.
```

### Push Rejected (Protected Branch)
```
Push to {branch} was rejected. This branch appears to be protected.

Options:
1. Create a feature branch and push there
2. Create a PR from your feature branch

Would you like me to create a feature branch?
```

### Push Rejected (Out of Date)
```
Push rejected because remote has changes you don't have locally.

Options:
1. Pull and rebase: git pull --rebase origin {branch}
2. Pull and merge: git pull origin {branch}

Which would you prefer?
```

### No Remote Configured
```
No remote repository configured.

Add a remote with:
git remote add origin <repository-url>
```

## Notes

- This command respects branch protection rules
- Never force pushes without explicit user consent
- Always runs security checks before committing
- Follows the commit message conventions in CLAUDE.md
- Does not add Signed-off-by (left for human to add before final push)
- Adds Assisted-by attribution for AI transparency
