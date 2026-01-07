#!/bin/bash
# Resume a paused scheduled task by setting enabled: true
# Usage: resume-scheduled-task <task-name>

set -e

TASK_NAME="${1:?Usage: resume-scheduled-task <task-name>}"
CONFIG_FILE="$HOME/.claude/remotes/scheduled-tasks.yaml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: No scheduled tasks configuration found at $CONFIG_FILE"
    exit 1
fi

# Check if task exists
if ! grep -q "name: $TASK_NAME" "$CONFIG_FILE"; then
    echo "Error: Task '$TASK_NAME' not found in $CONFIG_FILE"
    exit 1
fi

# Check if yq is available
if command -v yq &> /dev/null; then
    # Use yq to update the enabled field
    yq -i "(.scheduled_tasks[] | select(.name == \"$TASK_NAME\") | .enabled) = true" "$CONFIG_FILE"
    echo "Task '$TASK_NAME' resumed successfully"
else
    echo "Warning: yq not installed"
    echo ""
    echo "To resume manually, edit $CONFIG_FILE and set enabled: true for task '$TASK_NAME'"
    echo ""
    echo "Or install yq: brew install yq"
    exit 1
fi

# Show current state
echo ""
echo "Current status:"
yq ".scheduled_tasks[] | select(.name == \"$TASK_NAME\") | {name, enabled, schedule}" "$CONFIG_FILE"
