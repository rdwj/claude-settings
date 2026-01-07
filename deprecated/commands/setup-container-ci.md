# Setup Container CI/CD with GHCR

Set up a GitHub Actions workflow that automatically discovers and builds container images, pushing them to GitHub Container Registry (ghcr.io).

## What This Command Does

1. Scans the repository for `Containerfile` or `Dockerfile` files
2. Creates a GitHub Actions workflow that:
   - Triggers on PRs to main (build and push with PR-specific tags)
   - Triggers on push to main (build and push with `latest` tag)
   - Auto-discovers all container-buildable projects
   - Uses matrix builds for parallel container builds
   - Uses GitHub Actions cache for faster builds

## Tagging Strategy

- **PRs**: `ghcr.io/{owner}/{repo}/{service}:pr-{number}` and `:sha`
- **Main**: `ghcr.io/{owner}/{repo}/{service}:latest` and `:sha`

This allows testing PR images before merge while keeping `:latest` for production-ready code.

## Prerequisites

- Repository must be public (for free ghcr.io access) or have GitHub Packages enabled
- Repository must be on GitHub
- `gh` CLI should be authenticated for verification

## Instructions

### Step 1: Discover Containerfiles

Search for all Containerfile and Dockerfile files in the repository:

```bash
find . -type f \( -name "Containerfile" -o -name "Dockerfile" \) -not -path "./.git/*" | sort
```

For each discovered file, determine:
- The build context (parent directory of the Containerfile)
- A service name (derived from the directory name)

### Step 2: Create .github/workflows Directory

```bash
mkdir -p .github/workflows
```

### Step 3: Generate the Workflow File

Create `.github/workflows/container-build.yaml` with content that:

1. **Defines triggers:**
   ```yaml
   on:
     push:
       branches: [main]
     pull_request:
       branches: [main]
   ```

2. **Sets permissions:**
   ```yaml
   permissions:
     contents: read
     packages: write
   ```

3. **Defines environment:**
   ```yaml
   env:
     REGISTRY: ghcr.io
     IMAGE_PREFIX: ghcr.io/${{ github.repository }}
   ```

4. **Creates a matrix job** for each discovered Containerfile with:
   - Service name
   - Build context path
   - Containerfile path

5. **Build steps:**
   - Checkout code
   - Set up Docker Buildx
   - Log in to ghcr.io
   - Determine tags (PR-specific or latest)
   - Build and push
   - Use GHA cache for layers
   - Target `linux/amd64` platform

### Step 4: Example Workflow Structure

```yaml
name: Build Containers

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  packages: write

env:
  REGISTRY: ghcr.io
  IMAGE_PREFIX: ghcr.io/${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          # Auto-generated from discovered Containerfiles
          - name: service-name
            context: path/to/service
            dockerfile: path/to/service/Containerfile
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Determine tags
        id: tags
        run: |
          if [[ "${{ github.event_name }}" == "pull_request" ]]; then
            # PR: tag with pr-{number} and sha
            echo "tags<<EOF" >> $GITHUB_OUTPUT
            echo "${{ env.IMAGE_PREFIX }}/${{ matrix.name }}:pr-${{ github.event.number }}" >> $GITHUB_OUTPUT
            echo "${{ env.IMAGE_PREFIX }}/${{ matrix.name }}:${{ github.sha }}" >> $GITHUB_OUTPUT
            echo "EOF" >> $GITHUB_OUTPUT
          else
            # Main: tag with latest and sha
            echo "tags<<EOF" >> $GITHUB_OUTPUT
            echo "${{ env.IMAGE_PREFIX }}/${{ matrix.name }}:latest" >> $GITHUB_OUTPUT
            echo "${{ env.IMAGE_PREFIX }}/${{ matrix.name }}:${{ github.sha }}" >> $GITHUB_OUTPUT
            echo "EOF" >> $GITHUB_OUTPUT
          fi

      - name: Build and push ${{ matrix.name }}
        uses: docker/build-push-action@v6
        with:
          context: ${{ matrix.context }}
          file: ${{ matrix.dockerfile }}
          push: true
          tags: ${{ steps.tags.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64
```

### Step 5: Handle Special Cases

When generating the workflow, consider:

1. **Shared libraries**: If a service depends on shared code (like `rag_core`), the build context may need to be a parent directory
2. **Monorepo structure**: Derive service names from directory structure
3. **Naming conventions**: Convert `snake_case` directories to `kebab-case` image names

### Step 6: Verify Repository Settings

Check that the repository is public or has packages enabled:

```bash
gh repo view --json isPrivate,visibility
```

If private, warn the user that GitHub Packages may require additional configuration.

### Step 7: Report Results

Provide a summary:
- List of discovered Containerfiles
- Generated workflow location
- Image naming scheme (`ghcr.io/{owner}/{repo}/{service}:tag`)
- Remind user to commit and push the workflow file
- Note that first push to main will trigger builds

## Customization Options

If the user wants to customize:
- **Path filters**: Add path-based triggers to only build when specific directories change
- **Additional registries**: Add quay.io or other registry support
- **Multi-arch builds**: Add `linux/arm64` to platforms
- **Release workflow**: Create a separate workflow for tagged releases with semver

## Notes

- GITHUB_TOKEN automatically has packages:write permission for the repository
- Images will be at: `ghcr.io/{owner}/{repo}/{service-name}:tag`
- First-time push creates the package; subsequent pushes update it
- Package visibility inherits from repository by default (public repo = public packages)
- PR images (`pr-*` tags) will accumulate over time; consider periodic cleanup or using GitHub's package retention policies
- PR images let you deploy to staging/test environments before merging
