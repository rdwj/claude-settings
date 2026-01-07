#!/bin/bash
# Run a specific scheduled task by name
# Usage: run-scheduled-task <task-name>

set -e

TASK_NAME="${1:?Usage: run-scheduled-task <task-name>}"
CONFIG_FILE="$HOME/.claude/remotes/scheduled-tasks.yaml"
LOG_DIR="$HOME/claude-agents/logs"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: No scheduled tasks configuration found at $CONFIG_FILE"
    exit 1
fi

# Check if task exists
if ! grep -q "name: $TASK_NAME" "$CONFIG_FILE"; then
    echo "Error: Task '$TASK_NAME' not found in $CONFIG_FILE"
    echo ""
    echo "Available tasks:"
    grep "name:" "$CONFIG_FILE" | sed 's/.*name: /  - /'
    exit 1
fi

# Create log directory for this run
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TASK_LOG_DIR="$LOG_DIR/agent-$TASK_NAME-$TIMESTAMP"
mkdir -p "$TASK_LOG_DIR"

echo "Starting task: $TASK_NAME"
echo "Log directory: $TASK_LOG_DIR"
echo "Started at: $(date)"
echo ""

# Extract task details using yq if available, otherwise use grep/sed
if command -v yq &> /dev/null; then
    PROJECT=$(yq ".scheduled_tasks[] | select(.name == \"$TASK_NAME\") | .project" "$CONFIG_FILE")
    TASK=$(yq ".scheduled_tasks[] | select(.name == \"$TASK_NAME\") | .task" "$CONFIG_FILE")
    ENABLED=$(yq ".scheduled_tasks[] | select(.name == \"$TASK_NAME\") | .enabled // true" "$CONFIG_FILE")
else
    echo "Warning: yq not installed, using basic parsing"
    ENABLED="true"
fi

if [[ "$ENABLED" == "false" ]]; then
    echo "Task '$TASK_NAME' is paused (enabled: false)"
    exit 0
fi

# Run the task using Claude Code
cd "$PROJECT" 2>/dev/null || cd "$HOME"

echo "Running Claude Code agent for task..."
claude --print "$TASK" 2>&1 | tee "$TASK_LOG_DIR/session.log"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "Task completed at: $(date)"
echo "Exit code: $EXIT_CODE"

# Record result
echo "$TIMESTAMP $TASK_NAME exit=$EXIT_CODE" >> "$LOG_DIR/task-history.log"

exit $EXIT_CODE
