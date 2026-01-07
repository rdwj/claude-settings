---
name: scheduled-agents
description: Create and manage scheduled remote agent tasks that run periodically on ec2-dev. Use when setting up recurring tasks like daily news digests, security scans, dependency updates, or any automated agent workflow. Also use to list, pause, resume, or check status of scheduled tasks.
---

# Scheduled Agents

Manage recurring remote agent tasks that run on a schedule via cron on ec2-dev.

## When to Use This Skill

- Creating new scheduled tasks (daily digests, security scans, etc.)
- Listing all scheduled tasks and their status
- Checking next run times and recent history
- Pausing or resuming scheduled tasks
- Troubleshooting scheduled task failures

## Configuration Location

`~/.claude/remotes/scheduled-tasks.yaml`

## Creating a Scheduled Task

### YAML Structure

```yaml
scheduled_tasks:
  - name: task-name              # Unique identifier (slug)
    schedule: "0 9 * * *"        # Cron expression
    project: ~/projects/myapp    # Project directory
    task: |                      # Task description (multi-line)
      What the agent should accomplish
    server: ec2-dev              # Remote server (default: ec2-dev)
    permissions: developer       # Permission profile
    enabled: true                # Can pause without deleting
    env:                         # Environment variables
      API_KEY: ${API_KEY}
    conditions:                  # Optional: when to run
      monthly_cost_under: 200
    timeout_minutes: 120         # Kill if running too long
```

### Cron Expression Reference

```
* * * * *
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
│ │ │ └──────── Month (1-12)
│ │ └───────────── Day of month (1-31)
│ └────────────────── Hour (0-23)
└─────────────────────── Minute (0-59)

Common patterns:
"0 9 * * *"      # Daily at 9 AM
"0 */4 * * *"    # Every 4 hours
"0 9 * * 1"      # Mondays at 9 AM
"0 2 * * 1-5"    # Weekdays at 2 AM
```

## Task Design Guidelines

### Idempotency is Critical

Tasks may run multiple times. Design them to:
- Check if work is already done before doing it
- Use timestamps/markers to track state
- Avoid duplicate processing

**Example pattern:**
```yaml
task: |
  1. Read processed-topics.txt to see what we've covered
  2. Search for new content
  3. Skip if topic already in processed-topics.txt
  4. Do the work
  5. Append to processed-topics.txt
  6. Commit to git
```

### State Management

- Use files in project to track state
- Commit state changes to git
- Git commits mark progress/completion

### Quality Standards for Generated Content

When scheduling content generation tasks:
- Define audience and why they care
- Filter for technical substance over hype
- Check uniqueness (avoid duplicate coverage)
- Create drafts for human review (never auto-publish)
- Include working code examples

## Listing Scheduled Tasks

To see all scheduled tasks, read the configuration and calculate next runs:

```bash
cat ~/.claude/remotes/scheduled-tasks.yaml
```

### Status Indicators

- **Enabled**: Task is active and will run on schedule
- **Paused**: Task exists but won't run (enabled: false)
- **Running**: Task is currently executing
- **Overdue**: Task should have run but didn't

### Run Result Indicators

- **Success**: Exit code 0, completed normally
- **Failed**: Non-zero exit code
- **Skipped**: Task chose not to run (no work needed)
- **Timeout**: Task exceeded time limit

## Management Commands

### Test a task manually
```bash
ssh ec2-dev '~/bin/run-scheduled-task <task-name>'
```

### Pause a task
```bash
# Edit YAML and set enabled: false
# Or use: ~/bin/pause-scheduled-task <task-name>
```

### Resume a task
```bash
# Edit YAML and set enabled: true
# Or use: ~/bin/resume-scheduled-task <task-name>
```

### View logs
```bash
ssh ec2-dev 'tail -f ~/claude-agents/logs/agent-<task>-*/session.log'
```

### Check scheduler status
```bash
ssh ec2-dev 'crontab -l | grep run-scheduled-claude-tasks'
ssh ec2-dev 'tail -f ~/claude-agents/logs/scheduler.log'
```

## One-Time Setup

Install the scheduler cron job on ec2-dev:

```bash
ssh ec2-dev
CRON_ENTRY="*/15 * * * * \$HOME/bin/run-scheduled-claude-tasks >> \$HOME/claude-agents/logs/scheduler.log 2>&1"
(crontab -l 2>/dev/null | grep -v run-scheduled-claude-tasks; echo "$CRON_ENTRY") | crontab -
```

## Example Tasks

### Daily AI News Digest
```yaml
- name: ai-news-digest
  schedule: "0 9 * * *"
  project: ~/Developer/auto-news
  task: |
    1. Read blog/processed-topics.txt
    2. Search AI news via Tavily (last 24h)
    3. Filter for quality and uniqueness
    4. Create blog draft if interesting topic found
    5. Append topic to processed-topics.txt
    6. Commit to git
  env:
    TAVILY_API_KEY: ${TAVILY_API_KEY}
```

### Nightly Security Scan
```yaml
- name: security-scan
  schedule: "0 2 * * *"
  project: ~/projects/payment-api
  task: |
    Run OWASP dependency check
    Generate SECURITY-REPORT.md
    Commit findings to git
    Alert if high-severity issues found
```

### Weekly Dependency Updates
```yaml
- name: dep-updates
  schedule: "0 9 * * 1"
  project: ~/projects/api-server
  task: |
    Check for available updates
    Identify safe updates (patch/minor)
    Update package files
    Run tests
    Create PR if tests pass
```

## Troubleshooting

**Task not running:**
1. Check scheduler cron: `crontab -l | grep run-scheduled-claude-tasks`
2. Check scheduler logs: `tail ~/claude-agents/logs/scheduler.log`
3. Verify task enabled: `cat ~/.claude/remotes/scheduled-tasks.yaml`
4. Validate cron expression: https://crontab.guru

**Task failing:**
1. Check task logs: `tail ~/claude-agents/logs/agent-<task>-*/session.log`
2. Run manually: `~/bin/run-scheduled-task <name>`
3. Verify environment variables are set
4. Check permissions

## Cost Awareness

Set budget limits to prevent runaway costs:

```yaml
conditions:
  monthly_cost_under: 200
  daily_cost_under: 20
  cost_per_run_under: 5
```

Tasks pause automatically if limits exceeded.

## Output After Creating Task

```
Scheduled task created: {task-name}

Schedule: {human-readable schedule}
Project: {project-path}
Next run: {calculated next run time}

Test manually:
  ssh ec2-dev '~/bin/run-scheduled-task {task-name}'

Monitor:
  cat ~/.claude/remotes/scheduled-tasks.yaml
```
