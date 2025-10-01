# Scaffold Project Management Structure

Please create a project management directory structure in the current repository. This should be done non-destructively - if directories or files already exist, do not overwrite them.

Create the following structure:

```
project-management/
├── README.md
├── PROJECT-MANAGEMENT-RULES.md
├── scripts/
│   └── promote.sh
├── backlog/
├── in-progress/
├── ready-for-human-review/
├── done/
└── blocked/
```

Use bash commands to check for existing directories/files before creating them to ensure non-destructive execution.

## IMPORTANT: Project-Level CLAUDE.md Configuration

After creating the project management structure, you MUST add project-specific instructions to the project's CLAUDE.md file. This ensures all Claude Code sessions in this project will follow the workflow rules.

**Steps:**

1. Check if `CLAUDE.md` exists in the project root (current working directory)
2. If it doesn't exist, create it with the project management instructions below
3. If it does exist, check if it already contains a "# Project Management Workflow" section
4. If the section doesn't exist, append it to the end of the existing CLAUDE.md
5. If the section exists, skip this step to avoid duplication

**Content to add to CLAUDE.md:**

````markdown
# Project Management Workflow

This project uses a file-based project management system. **ALL work MUST follow this workflow.**

## Critical Rules for Claude Code

### Before Starting Any Work

1. Check `project-management/backlog/` for work items
2. When starting work on an item, you MUST run:
   ```bash
   ./project-management/scripts/promote.sh [filename] in-progress
   ```

### During Work

1. If you encounter a blocker, you MUST immediately run:
   ```bash
   ./project-management/scripts/promote.sh [filename] blocked
   ```
2. Add a note to the work item explaining what's blocking progress

### After Completing Work

1. When work is complete, you MUST run:
   ```bash
   ./project-management/scripts/promote.sh [filename] ready-for-human-review
   ```
2. **DO NOT consider a task complete until the file is in `ready-for-human-review/`**

### Workflow States

- `backlog/` - Identified work not yet started
- `in-progress/` - Currently working on
- `blocked/` - Cannot proceed due to dependencies or issues
- `ready-for-human-review/` - Complete, awaiting human approval
- `done/` - Approved and completed (human moves here)

### State Transitions You Must Execute

- Starting work: `backlog` → `in-progress`
- Hit blocker: `in-progress` → `blocked`
- Complete work: `in-progress` → `ready-for-human-review`
- Unblocked: `blocked` → `in-progress`

### Finding Work Items

Before asking the user what to work on, check these locations:
1. `project-management/in-progress/` - Any items here need completion
2. `project-management/blocked/` - Check if you can now unblock any items
3. `project-management/backlog/` - New work to start

### Complete Documentation

Read `project-management/PROJECT-MANAGEMENT-RULES.md` for the full workflow specification.

## Reminder

**YOU MUST USE THE PROMOTION SCRIPT** at the appropriate points. The human is relying on you to manage file locations correctly. Forgetting to promote files breaks the workflow.
````

## File Contents

### `project-management/README.md`

```markdown
# Project Management Workflow

This directory contains a file-based project management system for tracking work items through their lifecycle.

## Directory Structure

- **backlog/**: Work items that have been identified but not yet started
- **in-progress/**: Work items currently being worked on
- **ready-for-human-review/**: Completed work awaiting human review and approval
- **done/**: Completed and approved work items
- **blocked/**: Work items that are blocked by dependencies or issues

## Workflow

Work items flow through these states:

```
backlog → in-progress → ready-for-human-review → done
              ↓              ↓
           blocked    →  in-progress (rework)
```

## Using the Promotion Script

Use the `scripts/promote.sh` script to move items between directories:

```bash
# Start working on a backlog item
./scripts/promote.sh STORY-123.md in-progress

# Mark as blocked
./scripts/promote.sh STORY-123.md blocked

# Complete work and request review
./scripts/promote.sh STORY-123.md ready-for-human-review

# Move to done after approval
./scripts/promote.sh STORY-123.md done

# Return to in-progress if changes needed
./scripts/promote.sh STORY-123.md in-progress
```

The script automatically updates the YAML frontmatter in each file to track status and history.

## File Naming Convention

Work items should follow this naming pattern:
- `YYYYMMDD-short-description.md` (e.g., `20250929-implement-auth.md`)
- Or: `STORY-ID-short-description.md` (e.g., `STORY-123-user-login.md`)

## Work Item Template

Each work item should include YAML frontmatter:

```yaml
---
status: backlog
created_date: 2025-09-29T10:30:00Z
updated_date: 2025-09-29T10:30:00Z
history:
  - status: backlog
    timestamp: 2025-09-29T10:30:00Z
---

# Title of Work Item

## Description
[What needs to be done]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Notes
[Any additional context]
```

## Important

**All contributors (human and AI) MUST read and follow the rules in `PROJECT-MANAGEMENT-RULES.md`.**
```

### `project-management/PROJECT-MANAGEMENT-RULES.md`

```markdown
# Project Management Rules

**IMPORTANT**: These rules MUST be followed by all contributors, including AI assistants like Claude Code.

## Mandatory File Promotion Rules

### For AI Assistants (Claude Code)

You MUST use the promotion script at these specific points:

1. **Starting Work**
   - BEFORE working on any item in `backlog/`, you MUST run:
     ```bash
     ./project-management/scripts/promote.sh [filename] in-progress
     ```

2. **Encountering Blocks**
   - IMMEDIATELY when you discover you cannot proceed (missing dependency, external blocker, unclear requirements), you MUST run:
     ```bash
     ./project-management/scripts/promote.sh [filename] blocked
     ```
   - Add a note to the work item explaining the blocker

3. **Completing Work**
   - AFTER completing all work on an item in `in-progress/`, you MUST run:
     ```bash
     ./project-management/scripts/promote.sh [filename] ready-for-human-review
     ```
   - Do NOT consider the task complete until the file has been moved to `ready-for-human-review/`

4. **Returning from Blocked**
   - When you resume work on a blocked item, you MUST run:
     ```bash
     ./project-management/scripts/promote.sh [filename] in-progress
     ```

### For Human Reviewers

1. **Approving Work**
   - After reviewing and approving work in `ready-for-human-review/`, run:
     ```bash
     ./project-management/scripts/promote.sh [filename] done
     ```

2. **Requesting Changes**
   - If changes are needed, return the item to in-progress:
     ```bash
     ./project-management/scripts/promote.sh [filename] in-progress
     ```
   - Add comments to the work item describing what needs to change

## Workflow State Transitions

Valid transitions:

- `backlog` → `in-progress` (start work)
- `in-progress` → `blocked` (hit blocker)
- `in-progress` → `ready-for-human-review` (complete work)
- `blocked` → `in-progress` (unblocked, resume work)
- `ready-for-human-review` → `done` (approved by human)
- `ready-for-human-review` → `in-progress` (changes requested by human)

## YAML Frontmatter Requirements

Every work item MUST have YAML frontmatter with these fields:

```yaml
---
status: [current-status]
created_date: [ISO 8601 timestamp]
updated_date: [ISO 8601 timestamp]
history:
  - status: [previous-status]
    timestamp: [ISO 8601 timestamp]
  - status: [current-status]
    timestamp: [ISO 8601 timestamp]
---
```

The `promote.sh` script maintains these fields automatically.

## File Naming Convention

- Use: `YYYYMMDD-short-description.md` or `STORY-ID-description.md`
- Keep descriptions concise but meaningful
- Use lowercase with hyphens (kebab-case)

## Creating New Work Items

When creating a new work item:

1. Place it in `backlog/`
2. Use the proper naming convention
3. Include complete YAML frontmatter (status: backlog)
4. Include:
   - Description of the work
   - Acceptance criteria
   - Any relevant context or dependencies

## Blocked Items

When marking an item as blocked:

1. Move it to `blocked/` using the script
2. Add a "Blocker" section to the work item describing:
   - What is blocking progress
   - What is needed to unblock
   - Who/what can resolve the blocker
3. Do NOT leave items in `in-progress/` if you cannot proceed

## Review Process

Items in `ready-for-human-review/`:

- Must be complete according to acceptance criteria
- Should include notes on implementation decisions
- Must have all tests passing (if applicable)
- Should include any relevant documentation updates

## Critical Reminder for Claude Code

**DO NOT FORGET**: After you complete work on ANY task from `in-progress/`, you MUST promote it to `ready-for-human-review/` using the script. This is NOT optional. The human is relying on you to move files correctly.

If you are unsure whether work is complete, ask the human before promoting.
```

### `project-management/scripts/promote.sh`

```bash
#!/usr/bin/env bash

# promote.sh - Move work items between project management directories
# Usage: ./promote.sh <filename> <target-directory>
# Example: ./promote.sh STORY-123.md in-progress

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project management base directory
PM_BASE="project-management"

# Valid target directories
VALID_DIRS=("backlog" "in-progress" "ready-for-human-review" "done" "blocked")

# Function to print error and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to print success
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Check arguments
if [ $# -ne 2 ]; then
    error_exit "Usage: $0 <filename> <target-directory>\nValid directories: ${VALID_DIRS[*]}"
fi

FILENAME="$1"
TARGET_DIR="$2"

# Validate target directory
if [[ ! " ${VALID_DIRS[@]} " =~ " ${TARGET_DIR} " ]]; then
    error_exit "Invalid target directory: $TARGET_DIR\nValid directories: ${VALID_DIRS[*]}"
fi

# Find the file in any subdirectory
FOUND_FILE=""
CURRENT_DIR=""

for dir in "${VALID_DIRS[@]}"; do
    if [ -f "$PM_BASE/$dir/$FILENAME" ]; then
        FOUND_FILE="$PM_BASE/$dir/$FILENAME"
        CURRENT_DIR="$dir"
        break
    fi
done

if [ -z "$FOUND_FILE" ]; then
    error_exit "File '$FILENAME' not found in any project management directory"
fi

# Check if already in target directory
if [ "$CURRENT_DIR" = "$TARGET_DIR" ]; then
    warning "File is already in $TARGET_DIR/"
    exit 0
fi

TARGET_PATH="$PM_BASE/$TARGET_DIR/$FILENAME"

# Get current timestamp in ISO 8601 format
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check if file has YAML frontmatter
if ! head -n 1 "$FOUND_FILE" | grep -q '^---$'; then
    warning "File does not have YAML frontmatter. Adding basic frontmatter..."

    # Create temp file with frontmatter
    TEMP_FILE=$(mktemp)
    cat > "$TEMP_FILE" << EOF
---
status: $TARGET_DIR
created_date: $TIMESTAMP
updated_date: $TIMESTAMP
history:
  - status: $TARGET_DIR
    timestamp: $TIMESTAMP
---

EOF
    cat "$FOUND_FILE" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$FOUND_FILE"
else
    # Update existing frontmatter
    # This is a simple approach - extract frontmatter, update it, rebuild file

    # Extract frontmatter (between first two --- lines)
    TEMP_FRONT=$(mktemp)
    TEMP_BODY=$(mktemp)

    awk '/^---$/{if(++count==2) exit; next} count==1' "$FOUND_FILE" > "$TEMP_FRONT"
    awk '/^---$/{count++; next} count>=2' "$FOUND_FILE" > "$TEMP_BODY"

    # Update status and updated_date in frontmatter
    sed -i.bak "s/^status: .*/status: $TARGET_DIR/" "$TEMP_FRONT"
    sed -i.bak "s/^updated_date: .*/updated_date: $TIMESTAMP/" "$TEMP_FRONT"
    rm -f "$TEMP_FRONT.bak"

    # Append to history
    echo "  - status: $TARGET_DIR" >> "$TEMP_FRONT"
    echo "    timestamp: $TIMESTAMP" >> "$TEMP_FRONT"

    # Rebuild file
    TEMP_REBUILT=$(mktemp)
    echo "---" > "$TEMP_REBUILT"
    cat "$TEMP_FRONT" >> "$TEMP_REBUILT"
    echo "---" >> "$TEMP_REBUILT"
    cat "$TEMP_BODY" >> "$TEMP_REBUILT"

    mv "$TEMP_REBUILT" "$FOUND_FILE"
    rm -f "$TEMP_FRONT" "$TEMP_BODY"
fi

# Move the file
mv "$FOUND_FILE" "$TARGET_PATH"

success "✓ Moved $FILENAME from $CURRENT_DIR/ to $TARGET_DIR/"
echo "  Status updated: $TARGET_DIR"
echo "  Timestamp: $TIMESTAMP"
```

Make the script executable after creation:

```bash
chmod +x project-management/scripts/promote.sh
```