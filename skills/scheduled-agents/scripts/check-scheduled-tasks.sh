#!/bin/bash
# Check status of all scheduled tasks
# Usage: check-scheduled-tasks [--next-run] [--recent]

CONFIG_FILE="$HOME/.claude/remotes/scheduled-tasks.yaml"
LOG_DIR="$HOME/claude-agents/logs"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "No scheduled tasks configured yet."
    echo ""
    echo "To create your first scheduled task, use the scheduled-agents skill."
    exit 0
fi

echo "Scheduled Remote Agents"
echo "========================"
echo ""

# Check if yq is available
if ! command -v yq &> /dev/null; then
    echo "Warning: yq not installed. Install with: brew install yq"
    echo ""
    echo "Raw configuration:"
    cat "$CONFIG_FILE"
    exit 0
fi

# Count tasks
TOTAL=$(yq '.scheduled_tasks | length' "$CONFIG_FILE")
ENABLED=$(yq '[.scheduled_tasks[] | select(.enabled != false)] | length' "$CONFIG_FILE")
PAUSED=$((TOTAL - ENABLED))

echo "Active: $ENABLED enabled, $PAUSED paused"
echo ""

# List all tasks
echo "Tasks:"
echo "------"
yq -r '.scheduled_tasks[] | "  " + .name + " | " + .schedule + " | " + (if .enabled == false then "PAUSED" else "ENABLED" end)' "$CONFIG_FILE"

echo ""

# Show recent runs if log exists
if [[ -f "$LOG_DIR/task-history.log" ]]; then
    echo "Recent runs (last 5):"
    echo "---------------------"
    tail -5 "$LOG_DIR/task-history.log" | while read line; do
        echo "  $line"
    done
    echo ""
fi

# Check if scheduler cron is installed
echo "Scheduler status:"
echo "-----------------"
if crontab -l 2>/dev/null | grep -q "run-scheduled-claude-tasks"; then
    echo "  Scheduler cron: INSTALLED"
else
    echo "  Scheduler cron: NOT INSTALLED"
    echo ""
    echo "  To install scheduler:"
    echo '  (crontab -l 2>/dev/null; echo "*/15 * * * * $HOME/bin/run-scheduled-claude-tasks >> $HOME/claude-agents/logs/scheduler.log 2>&1") | crontab -'
fi
