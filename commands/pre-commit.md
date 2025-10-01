---
description: Check repository for secrets and ensure .gitignore is properly configured before committing
---

# Pre-Commit Security Check

## Purpose

Run security checks before committing code to ensure:
- No secrets are accidentally committed
- `.gitignore` properly excludes sensitive files
- `.gitleaks.toml` exists for managing false positives
- Common security patterns are followed

**Enhanced Intelligence:**
- Parses gitleaks JSON output for detailed analysis
- Categorizes findings by file type (docs, tests, examples, source)
- Generates specific `.gitleaks.toml` recommendations
- Distinguishes false positives from real secrets
- Offers to automatically apply fixes

Run this before:
- Creating commits
- Pushing to remote repositories
- Sharing code with team members

## Process

### Step 1: Check for Gitleaks

**Check if gitleaks is installed:**

```bash
which gitleaks
```

**If not installed:**
```
⚠️  Gitleaks not found

Gitleaks is a tool for detecting secrets in git repositories.

Install it:
- macOS: brew install gitleaks
- Linux: See https://github.com/gitleaks/gitleaks#installing
- Or: Use Docker: alias gitleaks='docker run -v "$(pwd):/path" ghcr.io/gitleaks/gitleaks:latest'

After installing, run /pre-commit again.
```

**If installed, proceed to Step 2.**

### Step 2: Scan for Secrets

Run gitleaks to scan the repository:

```bash
gitleaks detect --source . --no-banner --verbose --report-format json --report-path /tmp/gitleaks-report.json 2>&1
```

**If secrets are found:**

1. **Parse the JSON report** to analyze findings
2. **Categorize findings** by file type and location:
   - Documentation files (*.md, docs/)
   - Test files (tests/, test/, *_test.py, *.test.js)
   - Example files (examples/, *.example, *.sample)
   - Configuration templates (*.template, *.tmpl)
   - Source code files (actual potential secrets)

3. **Present findings with smart recommendations:**

```
🚨 SECRETS DETECTED

Gitleaks found potential secrets in your repository:

File: commands/pre-commit.md (lines 2)
Type: Asymmetric Private Key
Pattern: REDACTED

📋 Analysis: This appears to be in documentation/command files.

Recommended fix for .gitleaks.toml:

  paths = [
    # ... existing paths ...
    '''commands\/.*\.md$''',  # Command documentation with security examples
  ]

Would you like me to add this to .gitleaks.toml? (yes/no)
```

4. **For each finding, determine the appropriate action:**
   - **Documentation/Examples**: Suggest adding path patterns to `.gitleaks.toml`
   - **Test fixtures**: Suggest adding test path patterns
   - **Template files**: Suggest adding template patterns
   - **Source code**: ⚠️ Flag as HIGH PRIORITY - likely real secret

5. **Generate specific .gitleaks.toml additions** based on patterns found:

```toml
# Suggested additions for .gitleaks.toml:

[allowlist]
  paths = [
    '''commands\/.*\.md$''',      # Command docs with security examples
    '''agents\/.*\.md$''',         # Agent docs with code examples
    '''examples\/.*\.(pem|key)$''', # Example certificates
  ]

  regexes = [
    '''REDACTED''',                # Documentation placeholder
    '''YOUR_.*_HERE''',            # Template placeholder
  ]
```

6. **Offer to apply fixes automatically:**
   - Read existing `.gitleaks.toml`
   - Show what will be added
   - Apply if user confirms

**If no secrets found:**
```
✅ No secrets detected by gitleaks
```

### Step 3: Check .gitignore

**Verify .gitignore exists:**

If it doesn't exist:
```
⚠️  No .gitignore file found

Creating a basic .gitignore with common exclusions...
```

Create `.gitignore` with these common patterns:

```gitignore
# Environment variables and secrets
.env
.env.local
.env.*.local
*.key
*.pem
*.p12
*.pfx
credentials.json
secrets.yaml
secrets.yml

# API keys and tokens
*_key.txt
*_token.txt
*_secret.txt
api_keys.txt
tokens.txt

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
ENV/
env/

# Node
node_modules/
.npm
.yarn

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Temporary files
*.tmp
*.temp
tmp/
temp/

# Build artifacts
dist/
build/
*.egg-info/

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/

# Project-specific (add your patterns)
```

**If .gitignore exists, check for critical patterns:**

Required patterns to check:
- `.env` and variants
- `*.key`, `*.pem`, `*.p12`, `*.pfx`
- `credentials.json`, `secrets.yaml`
- `*_key.txt`, `*_token.txt`, `*_secret.txt`

**Report missing patterns:**
```
⚠️  .gitignore missing critical patterns:

The following patterns should be added to .gitignore:
- .env
- *.key
- credentials.json

Add these? [Present patterns to add]
```

**If user says yes, add them to .gitignore.**

### Step 4: Check for .gitleaks.toml

**Note:** If secrets were found in Step 2, specific `.gitleaks.toml` additions have already been suggested based on the findings.

**If .gitleaks.toml doesn't exist:**

```
💡 Creating .gitleaks.toml for managing false positives

Gitleaks configuration helps exclude legitimate examples and test data
from secret detection.
```

Create `.gitleaks.toml` based on the template from `~/.claude/.gitleaks.toml`:

```toml
[allowlist]
  description = "Project-specific allowlist for false positives"

  # Ignore based on file paths
  paths = [
    # Example files
    '''\/example.*\.pem$''',
    '''\/examples\/''',

    # Test fixtures
    '''\/tests?\/fixtures\/''',
    '''\/test\/.*\.key$''',

    # Documentation
    '''README\.md$''',
    '''docs\/.*\.md$''',
  ]

  # Ignore based on line content
  regexes = [
    # Test/example passwords
    '''password.*['"]\s*['"]\s*$''',
    '''password.*Pass123''',
    '''password.*example''',

    # Documentation placeholders
    '''# Your (private key|certificate) here''',
    '''<your-.*-here>''',
    '''REPLACE_WITH_YOUR''',
    '''YOUR_.*_HERE''',
  ]
```

**If .gitleaks.toml exists:**
```
✅ .gitleaks.toml configuration exists
```

### Step 5: Check Staged Files

**List files staged for commit:**

```bash
git diff --cached --name-only
```

**Cross-reference with .gitignore:**

Check if any staged files should be in .gitignore:

```
⚠️  Potentially sensitive files staged:

The following files are staged but might contain secrets:
- config/database.yml (contains database credentials?)
- .env.production (environment file)

Review these files before committing.
```

**Common patterns that warrant warnings:**
- Files named `*.env*` (unless explicitly `*.env.example`)
- Files with `secret`, `credential`, `key`, `token` in name
- Files ending in `.pem`, `.key`, `.p12`, `.pfx`
- Files named `config/*.yml` or `config/*.yaml` (database configs)

### Step 6: Summary Report

**Present comprehensive security status:**

```
🔒 Pre-Commit Security Check

✅ Gitleaks scan: Clean (no secrets detected)
✅ .gitignore: Properly configured
✅ .gitleaks.toml: Configuration exists
✅ Staged files: No sensitive files detected

You're safe to commit!

Next steps:
- Review your changes: git diff --cached
- Create commit: git commit -m "Your message"
- Or use Claude Code's commit workflow
```

**If issues were found:**

```
🔒 Pre-Commit Security Check

🚨 Action required:

Documentation/Examples (Low Priority):
- [ ] Add suggested patterns to .gitleaks.toml (see recommendations above)

Source Code (HIGH PRIORITY):
- [ ] ⚠️ Remove actual secrets from source files
- [ ] Add missing .gitignore patterns
- [ ] Review staged files marked as potentially sensitive

⚠️  DO NOT commit until these issues are resolved.

After fixing:
- Run /pre-commit again to verify
- Then commit your changes safely
```

### Step 7: Offer to Update Files

**If .gitignore or .gitleaks.toml need updates:**

Ask: "Would you like me to add the missing patterns now?"

If yes:
1. Add patterns to `.gitignore`
2. Create or update `.gitleaks.toml`
3. Show what was added

If no:
- Provide the patterns to add manually
- Remind them to add before committing

## Example Workflow

**Scenario: Documentation files triggering false positives**

```bash
$ /pre-commit

🔒 Pre-Commit Security Check

Running gitleaks scan...

🚨 SECRETS DETECTED

┌─────────────────────────────────────────────────────────────
│ Finding #1: commands/pre-commit.md:2
│ Type: Asymmetric Private Key
│ Pattern: REDACTED
│
│ 📋 Analysis: Documentation file with security examples
│
│ Recommended fix:
│   Add to .gitleaks.toml paths:
│   '''commands\/.*\.md$''',
│
│ Priority: LOW (false positive in documentation)
└─────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────
│ Finding #2: src/config/database.py:12
│ Type: Generic API Key
│ Pattern: api_key = "sk_live_abc123..."
│
│ 📋 Analysis: Source code file with potential real secret
│
│ Action required: REMOVE THIS SECRET IMMEDIATELY
│
│ Priority: HIGH (likely real secret)
└─────────────────────────────────────────────────────────────

Summary:
- 1 HIGH priority issue (source code) - FIX IMMEDIATELY
- 1 LOW priority issue (documentation) - add to .gitleaks.toml

Would you like me to add the suggested .gitleaks.toml pattern? (yes/no)
```

This intelligent categorization helps you quickly:
1. Fix real secrets in source code first
2. Handle false positives in documentation appropriately
3. Get specific, actionable recommendations

## Additional Checks

### AWS/Cloud Credentials

Check for common credential patterns:
- `aws_access_key_id` / `aws_secret_access_key`
- `AKIA[0-9A-Z]{16}` (AWS access keys)
- API keys in common formats

### Private Keys

Warn about:
- `-----BEGIN PRIVATE KEY-----` patterns
- `-----BEGIN RSA PRIVATE KEY-----`
- Unless in files explicitly marked as examples

### Configuration Files

Check common config file patterns:
- `application.yml` with database credentials
- `database.yml` with passwords
- `.npmrc` with auth tokens
- `pip.conf` with credentials

## Notes

- This is a **helper command**, not a git hook
- It doesn't prevent commits - it guides you
- For automatic enforcement, set up actual git pre-commit hooks
- Gitleaks has comprehensive built-in rules
- `.gitleaks.toml` is for managing false positives in your project

## Best Practices

**For Example Files:**
- Name them with `.example` suffix: `secrets.yaml.example`
- Use placeholder values: `password: YOUR_PASSWORD_HERE`
- Document in comments: `# Replace with your actual key`

**For Test Fixtures:**
- Use obviously fake values: `password: "test123"`
- Keep in dedicated test directories
- Add test paths to `.gitleaks.toml` allowlist

**For Documentation:**
- Use placeholder format: `<your-api-key-here>`
- Clearly mark as examples in comments
- Add doc paths to `.gitleaks.toml` allowlist

## Integration with Git Hooks

To make this automatic, create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
# Run gitleaks check before every commit
gitleaks protect --verbose --redact --staged
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

But for now, just run `/pre-commit` manually before pushing code.
