# Implementation Plan: GitHub Integration for `create mcp-server`

## Overview

Add GitHub repository creation support to `fips-agents create mcp-server` command, allowing users to create projects that are automatically pushed to GitHub. Also add the missing `patch build` subcommand.

## Design Decisions

1. **Default behavior**: GitHub when `gh` CLI is available and authenticated; falls back to local-only
2. **Non-interactive mode**: `--yes` flag for agent/CI usage (skips prompts, uses defaults)
3. **Clean history**: Use "create empty repo + push customized" approach (Path B) for clean initial commit
4. **Template tracking**: Continue using `.template-info` file (works with `fips-agents patch`)

## Command Interface

```bash
# Default: detects gh CLI, prompts user if available
fips-agents create mcp-server my-server

# Explicit modes
fips-agents create mcp-server my-server --github    # Force GitHub
fips-agents create mcp-server my-server --local     # Force local-only (current behavior)

# Non-interactive (for agents/CI)
fips-agents create mcp-server my-server --yes       # GitHub if available, no prompts
fips-agents create mcp-server my-server --local --yes

# GitHub options
fips-agents create mcp-server my-server --github --private
fips-agents create mcp-server my-server --github --public          # default
fips-agents create mcp-server my-server --github --org myorg
fips-agents create mcp-server my-server --github --description "My MCP server"
fips-agents create mcp-server my-server --github --remote-only     # Don't clone locally
```

## Files to Modify

### 1. `src/fips_agents_cli/tools/github.py` (NEW)

GitHub CLI integration utilities.

```python
def is_gh_installed() -> bool
def is_gh_authenticated() -> bool
def create_github_repo(
    name: str,
    private: bool = False,
    org: str | None = None,
    description: str | None = None,
) -> tuple[bool, str, str | None]  # (success, repo_url, error_message)
def get_github_username() -> str | None
```

**Implementation details:**
- Use `subprocess.run()` to call `gh` CLI (not GitHub API directly)
- `gh auth status` to check authentication
- `gh repo create` with appropriate flags
- Parse JSON output with `--json` flag for reliability

### 2. `src/fips_agents_cli/tools/git.py` (MODIFY)

Add remote management functions.

```python
def add_remote(project_path: Path, name: str, url: str) -> None
def push_to_remote(project_path: Path, remote: str = "origin", branch: str = "main") -> bool
```

### 3. `src/fips_agents_cli/commands/create.py` (MODIFY)

Add new options and GitHub flow.

**New options:**
```python
@click.option("--github", "use_github", is_flag=True, default=False,
              help="Create GitHub repository and push")
@click.option("--local", "use_local", is_flag=True, default=False,
              help="Create local project only (skip GitHub)")
@click.option("--yes", "-y", is_flag=True, default=False,
              help="Non-interactive mode (use defaults, skip prompts)")
@click.option("--private", is_flag=True, default=False,
              help="Make GitHub repository private (default: public)")
@click.option("--org", default=None,
              help="GitHub organization to create repository in")
@click.option("--description", "-d", default=None,
              help="GitHub repository description")
@click.option("--remote-only", is_flag=True, default=False,
              help="Create GitHub repo without cloning locally")
```

**Flow logic:**
```
1. Validate project name
2. Determine mode:
   - If --local: use local flow
   - If --github: require gh CLI, use GitHub flow
   - If neither:
     - Check gh availability
     - If not available: local flow
     - If available + --yes: GitHub flow (public, user account)
     - If available + interactive: prompt user
3. Execute appropriate flow
4. Write .template-info with mode-specific metadata
```

### 4. `src/fips_agents_cli/tools/project.py` (MODIFY)

Update `write_template_info()` to include GitHub metadata.

```python
def write_template_info(
    project_path: Path,
    project_name: str,
    template_url: str,
    template_commit: str,
    github_repo: str | None = None,  # NEW: e.g., "username/my-server"
) -> None:
```

**Updated structure:**
```json
{
  "generator": {"tool": "fips-agents-cli", "version": "0.2.0"},
  "template": {"url": "...", "commit": "...", "full_commit": "..."},
  "project": {"name": "...", "created_at": "..."},
  "github": {"repo": "username/my-server", "url": "https://github.com/..."}  // NEW, optional
}
```

### 5. `src/fips_agents_cli/commands/patch.py` (MODIFY)

Add missing `build` subcommand.

```python
@patch.command("build")
@click.option("--dry-run", is_flag=True, help="Show what would be updated without making changes")
def build(dry_run: bool):
    """
    Update build and deployment files (Makefile, Containerfile, etc).

    Shows diffs and asks for confirmation before applying changes.
    """
    _patch_category("build", dry_run)
```

### 6. `tests/test_github.py` (NEW)

Tests for GitHub integration.

```python
class TestGitHubTools:
    def test_is_gh_installed_true(self)
    def test_is_gh_installed_false(self)
    def test_is_gh_authenticated_true(self)
    def test_is_gh_authenticated_false(self)
    def test_create_github_repo_success(self)
    def test_create_github_repo_already_exists(self)
    def test_create_github_repo_org(self)
    def test_create_github_repo_private(self)

class TestCreateMcpServerGitHub:
    def test_github_flag_requires_gh_cli(self)
    def test_github_flag_requires_auth(self)
    def test_github_flow_creates_repo(self)
    def test_github_flow_pushes_customized_code(self)
    def test_local_flag_skips_github(self)
    def test_yes_flag_non_interactive(self)
    def test_mutual_exclusion_github_local(self)
    def test_remote_only_skips_local_clone(self)
```

### 7. `tests/test_patch.py` (MODIFY)

Add test for build subcommand.

```python
def test_patch_build_command_exists(self, cli_runner):
    result = cli_runner.invoke(cli, ["patch", "build", "--help"])
    assert result.exit_code == 0
    assert "build and deployment files" in result.output.lower()
```

## Implementation Order

1. **Add `patch build` subcommand** (5 min)
   - Simple addition following existing pattern
   - Quick win, can be done first

2. **Create `tools/github.py`** (30 min)
   - `is_gh_installed()`, `is_gh_authenticated()`
   - `create_github_repo()` with all options
   - `get_github_username()`
   - Unit tests for each function

3. **Update `tools/git.py`** (15 min)
   - Add `add_remote()` function
   - Add `push_to_remote()` function
   - Unit tests

4. **Update `tools/project.py`** (10 min)
   - Add `github_repo` parameter to `write_template_info()`
   - Update JSON structure
   - Unit tests

5. **Update `commands/create.py`** (45 min)
   - Add all new Click options
   - Implement mode detection logic
   - Implement GitHub flow
   - Update success message for GitHub mode
   - Integration tests

6. **Final testing and documentation** (15 min)
   - Run full test suite
   - Update README if needed
   - Manual testing of happy paths

## Error Handling

| Scenario | Behavior |
|----------|----------|
| `--github` but `gh` not installed | Error with install hint |
| `--github` but not authenticated | Error: "Run `gh auth login` first" |
| `--github` + `--local` both set | Error: "Cannot use --github and --local together" |
| GitHub repo already exists | Error with suggestion to use different name |
| Network failure during push | Error with manual recovery steps |
| `--org` specified but no access | Error from `gh` CLI, pass through |

## Success Messages

**Local mode (existing):**
```
✓ Successfully created MCP server project!

Project Details:
  • Name: my-server
  • Module: my_server
  • Location: /path/to/my-server

Next Steps:
  1. Navigate to your project: cd my-server
  ...
```

**GitHub mode (new):**
```
✓ Successfully created MCP server project!

Project Details:
  • Name: my-server
  • Module: my_server
  • Location: /path/to/my-server
  • GitHub: https://github.com/username/my-server

Next Steps:
  1. Navigate to your project: cd my-server
  2. Your code is already pushed to GitHub!
  ...
```

## Testing Strategy

1. **Unit tests**: Mock `subprocess.run()` for `gh` CLI calls
2. **Integration tests**: Mock at `github.py` function level
3. **Manual tests**: Real `gh` CLI with test repositories

## Risk Mitigation

- **Backward compatibility**: Default behavior unchanged when `gh` not available
- **Cleanup on failure**: If GitHub repo created but push fails, warn user (don't auto-delete)
- **Rate limits**: `gh` CLI handles GitHub API rate limits internally
