# Protect Main Branch

Set up branch protection for the main branch with CODEOWNERS and GitHub branch protection rules.

## What This Command Does

1. Creates `.github/CODEOWNERS` file with @rdwj as the code owner for all files
2. Uses `gh` CLI to configure branch protection rules on the `main` branch:
   - Requires pull request reviews before merging
   - Requires CODEOWNERS review
   - Prevents direct pushes to main
   - Requires linear history (no merge commits from direct pushes)

## Prerequisites

- Repository must be on GitHub
- `gh` CLI must be authenticated (`gh auth status`)
- You must have admin access to the repository

## Instructions

Execute the following steps:

### Step 1: Verify GitHub CLI Authentication

```bash
gh auth status
```

If not authenticated, inform the user they need to run `gh auth login` first.

### Step 2: Get Repository Information

```bash
gh repo view --json owner,name,isPrivate
```

Store the owner and repo name for subsequent commands.

### Step 3: Create .github Directory (if needed)

```bash
mkdir -p .github
```

### Step 4: Create CODEOWNERS File

Create `.github/CODEOWNERS` with the following content:

```
# Code Owners - all PRs require approval from @rdwj
*       @rdwj
```

### Step 5: Set Up Branch Protection Rules

Use the GitHub API via `gh` to create branch protection:

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='null' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"required_approving_review_count":1}' \
  --field restrictions='null' \
  --field required_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field block_creations=false \
  --field required_conversation_resolution=true
```

### Step 6: Verify Protection

```bash
gh api repos/{owner}/{repo}/branches/main/protection --jq '.required_pull_request_reviews'
```

### Step 7: Report Results

Provide a summary of what was configured:
- CODEOWNERS file location
- Branch protection rules enabled
- Remind user to commit and push the CODEOWNERS file

## Notes

- If branch protection already exists, this will update it
- The CODEOWNERS file must be committed and pushed for code owner reviews to work
- For private repos, branch protection requires GitHub Pro/Team/Enterprise
- For public repos, branch protection is available on all plans

## Error Handling

- If the repo is not found, check that you're in a git repository with a GitHub remote
- If permission denied, verify you have admin access to the repository
- If branch protection fails on a private repo, it may require a paid GitHub plan
