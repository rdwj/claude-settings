# Remote Container Build Setup Guide

This guide covers the complete setup for building containers remotely on your EC2 instance using the `/build-remote` slash command.

## Overview

The remote build solution allows you to:
- Build containers on a RHEL EC2 instance with Podman
- Use persistent tmux sessions so builds continue even if SSH disconnects
- Automatically push images to quay.io registry
- Build with `--platform linux/amd64` for OpenShift compatibility
- Monitor builds in real-time or check on them later

## Architecture

```
Local Machine                 EC2 Instance (ec2-dev)
-------------                 ----------------------
Claude Code
    |
    | /build-remote
    v
Rsync files ----------------> ~/builds/{image-name}/
    |                              |
    |                              v
SSH + tmux session ---------> podman build --platform linux/amd64
                                   |
                                   v
                              podman push
                                   |
                                   v
                              quay.io/wjackson/{image-name}
```

## One-Time Setup

### Step 1: EC2 Instance Setup

SSH to your EC2 instance and complete these one-time configuration steps:

```bash
ssh ec2-dev
```

### Step 2: Install tmux

```bash
sudo dnf install -y tmux
```

Verify installation:
```bash
tmux -V
# Should show: tmux 3.x or similar
```

### Step 3: Configure Registry Authentication

Login to quay.io (credentials will be stored securely in Podman's auth.json):

```bash
podman login quay.io -u 'wjackson+wesjackson'
# When prompted, enter password: PG32Q02Z6O6R2HFGNUP1DQGC1Y3XXGM876FYAWPTQI909MT804GAS07QELOFJIS7
```

Verify login:
```bash
podman login quay.io
# Should show: Login Succeeded! (using stored credentials)
```

**How it works:**
- Credentials are stored in `~/.config/containers/auth.json` (or `/run/user/$(id -u)/containers/auth.json`)
- Automatically used by all `podman push` and `podman pull` commands
- Persists across SSH sessions
- More secure than environment variables or script-embedded credentials

### Step 4: Create tmux Configuration (Optional but Recommended)

Create a tmux config file for better user experience:

```bash
cat > ~/.tmux.conf << 'EOF'
# Mouse support for scrolling and pane selection
set -g mouse on

# Increase scrollback buffer (default is often only 2000 lines)
set-option -g history-limit 10000

# Better status bar colors
set -g status-bg colour235
set -g status-fg colour136

# Show session name and window info
set -g status-left '[#S] '
set -g status-right '%Y-%m-%d %H:%M'

# More intuitive pane splitting (optional)
bind | split-window -h
bind - split-window -v
EOF
```

Source the config (or just reconnect to SSH):
```bash
tmux source-file ~/.tmux.conf
```

### Step 5: Create Build Directory Structure

```bash
mkdir -p ~/builds
```

This directory will store transferred build contexts for all your images.

### Step 6: Verify Setup

Test that everything works:

```bash
# Test tmux
tmux new-session -d -s test "echo 'Hello from tmux'; sleep 5"
tmux attach -t test
# You should see the message, session will close after 5 seconds

# Test Podman
podman version

# Test registry access
podman pull quay.io/quay/busybox:latest
podman rmi quay.io/quay/busybox:latest
```

## Local Machine Setup

### Step 1: Verify SSH Configuration

Ensure you can SSH to ec2-dev without password prompts:

```bash
ssh ec2-dev "echo 'SSH working'"
```

If this doesn't work, add to your `~/.ssh/config`:

```
Host ec2-dev
    HostName <your-ec2-ip-or-dns>
    User <your-username>
    IdentityFile ~/.ssh/<your-key>.pem
    StrictHostKeyChecking no
```

### Step 2: Verify Rsync is Installed

```bash
which rsync
# Should return a path like /usr/bin/rsync
```

If not installed:
- macOS: `brew install rsync`
- Linux: `sudo dnf install rsync` or `sudo apt install rsync`

### Step 3: Test the Slash Command

The slash command `/build-remote` should now be available in Claude Code. It's defined in:
```
~/.claude/commands/build-remote.md
```

## Usage

### Basic Usage

From within a Claude Code conversation:

```bash
/build-remote my-app
```

This will:
1. Look for `./Containerfile` in your current directory
2. Transfer build context to `ec2-dev:~/builds/my-app/`
3. Build with tag `quay.io/wjackson/my-app:latest`
4. Push to registry
5. Run in tmux session named `build-my-app`

### With Custom Tag

```bash
/build-remote my-app v1.2.3
```

Builds and pushes `quay.io/wjackson/my-app:v1.2.3`

### With Custom Containerfile Location

```bash
/build-remote my-app latest ./docker/Containerfile
```

Uses Containerfile at `./docker/Containerfile` instead of `./Containerfile`

## Monitoring Builds

### Option 1: Attach to Running Build

```bash
ssh ec2-dev
tmux list-sessions  # See all active builds
tmux attach -t build-my-app
```

**Tmux keyboard shortcuts:**
- `Ctrl+b, d` - Detach from session (build continues)
- `Ctrl+b, [` - Enter scroll mode (use arrow keys, q to exit)
- Mouse scroll works if you configured tmux.conf

### Option 2: Check Build Output After Completion

```bash
ssh ec2-dev
tmux attach -t build-my-app
# Even if build finished, you can see the output
```

### Option 3: Kill a Build Session

```bash
ssh ec2-dev
tmux kill-session -t build-my-app
```

## Troubleshooting

### Build Fails with "permission denied"

**Cause:** Registry authentication not configured

**Solution:**
```bash
ssh ec2-dev
podman login quay.io -u 'wjackson+wesjackson'
# Enter password when prompted
```

### SSH Connection Fails

**Cause:** SSH config issue or EC2 instance not reachable

**Solution:**
```bash
# Test basic connectivity
ping <ec2-ip>

# Test SSH with verbose output
ssh -v ec2-dev

# Verify SSH key permissions
chmod 600 ~/.ssh/<your-key>.pem
```

### Rsync Fails or Times Out

**Cause:** Large build context or network issues

**Solution:**
- Add `.containerignore` or `.dockerignore` to exclude unnecessary files
- Check network connectivity
- Try manual rsync with verbose output:
  ```bash
  rsync -avz --progress ./ ec2-dev:~/builds/test/
  ```

### Build Context Missing Files

**Cause:** Files excluded by default rsync exclusions

**Solution:**
The command excludes these by default:
- `.git/`
- `venv/`
- `__pycache__/`
- `*.pyc`
- `.pytest_cache/`

If you need these files, modify the slash command to remove exclusions.

### Tmux Session Not Found

**Cause:** Session name mismatch or session already completed

**Solution:**
```bash
ssh ec2-dev
tmux list-sessions  # See all active sessions
```

Sessions persist until:
- Explicitly killed with `tmux kill-session`
- Server reboot
- 30+ days of inactivity (default tmux timeout)

### Platform Mismatch Warnings

**Cause:** Building on non-x86_64 architecture

**Solution:**
The command always uses `--platform linux/amd64` flag. This is correct for OpenShift deployment. Warnings are normal when building on ARM-based systems.

### Image Push Fails with "unauthorized"

**Cause:** Registry credentials expired or incorrect

**Solution:**
```bash
ssh ec2-dev
podman logout quay.io
podman login quay.io -u 'wjackson+wesjackson'
# Re-enter password
```

## Advanced Usage

### Building Multiple Images in Parallel

Each build gets its own tmux session, so you can run multiple builds:

```bash
/build-remote frontend
/build-remote backend
/build-remote worker
```

Monitor them:
```bash
ssh ec2-dev
tmux list-sessions
# build-frontend: 1 windows (created ...)
# build-backend: 1 windows (created ...)
# build-worker: 1 windows (created ...)

# Attach to any of them
tmux attach -t build-frontend
```

### Custom Build Arguments

If you need to pass build arguments, you can modify the slash command or create a custom Containerfile.

Example with build args in Containerfile:
```dockerfile
ARG BASE_IMAGE=registry.redhat.io/ubi9/ubi:latest
FROM $BASE_IMAGE
# ... rest of Containerfile
```

### Cleaning Up Old Build Contexts

Periodically clean up the builds directory on EC2:

```bash
ssh ec2-dev
cd ~/builds
ls -lht  # See all build contexts sorted by time
rm -rf old-project-name  # Remove specific ones
```

### Viewing Build Logs Later

Even after a tmux session closes, you can see what happened:

```bash
ssh ec2-dev
# If session still exists
tmux attach -t build-my-app

# Check podman build history
podman images | grep my-app
podman history quay.io/wjackson/my-app:latest
```

## Security Considerations

### Credential Storage

- Credentials stored in Podman's auth.json are base64-encoded but NOT encrypted
- File permissions should be `600` (only owner can read/write)
- On shared systems, consider using `podman login --authfile` with a custom location
- Credentials persist until `podman logout` is run

### Build Context Transfer

- Rsync transfers files over SSH (encrypted in transit)
- Default exclusions prevent sensitive files from being transferred
- Always use `.containerignore` to exclude secrets, credentials, keys

### EC2 Instance Access

- Ensure your EC2 instance security group only allows SSH from trusted IPs
- Use SSH key authentication (not passwords)
- Keep the instance OS and Podman updated
- Consider using AWS Session Manager instead of direct SSH for enhanced security

## Best Practices

1. **Use .containerignore files** to minimize build context size and prevent secret leakage
2. **Tag images semantically** (v1.0.0, not just "latest")
3. **Clean up old tmux sessions** periodically to avoid clutter
4. **Monitor disk usage** on EC2 instance (`df -h`, `podman system df`)
5. **Use UBI base images** for RHEL/OpenShift compatibility
6. **Test images locally first** before remote builds for faster iteration
7. **Keep build contexts small** for faster transfer and builds

## File Locations Reference

**EC2 Instance (ec2-dev):**
- Build contexts: `~/builds/{image-name}/`
- Podman auth: `~/.config/containers/auth.json` or `/run/user/$(id -u)/containers/auth.json`
- Tmux config: `~/.tmux.conf`
- Podman images: `~/.local/share/containers/storage/`

**Local Machine:**
- Slash command: `~/.claude/commands/build-remote.md`
- Setup guide: `~/.claude/docs/remote-build-setup.md`
- SSH config: `~/.ssh/config`

## Next Steps

After completing setup:

1. **Test with a simple image:**
   ```bash
   # Create a minimal test Containerfile
   echo "FROM registry.redhat.io/ubi9/ubi-minimal:latest" > Containerfile
   echo "CMD [\"echo\", \"Hello from remote build\"]" >> Containerfile

   # Build it remotely
   /build-remote test-image
   ```

2. **Monitor the build:**
   ```bash
   ssh ec2-dev
   tmux attach -t build-test-image
   ```

3. **Verify the push:**
   - Visit https://quay.io/repository/wjackson/test-image
   - You should see your newly pushed image

4. **Use in OpenShift:**
   ```bash
   oc new-app quay.io/wjackson/test-image --name=test
   ```

## Support and Feedback

If you encounter issues not covered in this guide:

1. Check tmux and Podman logs on the EC2 instance
2. Test each component individually (SSH, rsync, Podman, tmux)
3. Verify EC2 instance has sufficient disk space and resources
4. Check quay.io repository settings and permissions

## Appendix: Understanding the Workflow

### What Happens When You Run `/build-remote my-app`

1. **Claude Code parses arguments:**
   - Image: `my-app`
   - Tag: `latest` (default)
   - Containerfile: `./Containerfile` (default)
   - Full reference: `quay.io/wjackson/my-app:latest`

2. **Context verification:**
   - Checks that `./Containerfile` exists
   - Determines build context directory (current directory)

3. **File transfer:**
   - Creates `~/builds/my-app/` on ec2-dev if it doesn't exist
   - Rsyncs your project files (excluding .git, venv, etc.)
   - Shows transfer progress

4. **Remote build initiation:**
   - SSHs to ec2-dev
   - Creates tmux session named `build-my-app`
   - Runs `podman build --platform linux/amd64 -t quay.io/wjackson/my-app:latest -f Containerfile .`
   - Detaches, leaving build running

5. **Push to registry:**
   - After build completes, runs `podman push quay.io/wjackson/my-app:latest`
   - Uses stored credentials from `podman login`

6. **Feedback:**
   - Shows session name and monitoring instructions
   - Build continues even if you close Claude Code

### Why This Approach?

- **Reliability:** Tmux ensures builds complete even if network drops
- **Resource efficiency:** Build on powerful EC2 instance, not local machine
- **Compatibility:** Build on Linux for Linux deployment (avoids Mac ARM issues)
- **Security:** Credentials never leave the EC2 instance
- **Convenience:** Simple slash command, no complex scripts
- **Transparency:** Can monitor builds in real-time or review later
