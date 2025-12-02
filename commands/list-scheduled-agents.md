# List Scheduled Agents

You are helping the user view and manage scheduled remote agent tasks.

## Your Responsibilities

1. **Read Schedule Configuration**
   - Parse ~/.claude/remotes/scheduled-tasks.yaml
   - Show all configured tasks
   - Calculate next run times

2. **Display Task Status**
   - Which tasks are enabled/disabled
   - Recent run history
   - Success/failure counts

3. **Provide Management Options**
   - Suggest how to test tasks
   - Show how to pause/resume
   - Offer cleanup for completed runs

## Configuration File

`~/.claude/remotes/scheduled-tasks.yaml`

## Display Formats

### Summary View (Default)

```
📅 Scheduled Remote Agents

┌──────────────────┬──────────────┬─────────┬──────────────┬─────────────┐
│ Task             │ Schedule     │ Status  │ Next Run     │ Last Status │
├──────────────────┼──────────────┼─────────┼──────────────┼─────────────┤
│ ai-news-digest   │ Daily 9 AM   │ Enabled │ Tomorrow 9AM │ ✅ Success  │
│ security-scan    │ Daily 2 AM   │ Enabled │ Tonight 2AM  │ ✅ Success  │
│ dep-updates      │ Mon 9 AM     │ Enabled │ Mon 9 AM     │ ⏸️  Skipped │
│ test-staging     │ Every 4h     │ Paused  │ -            │ -           │
└──────────────────┴──────────────┴─────────┴──────────────┴─────────────┘

Active: 3 enabled, 1 paused
Recent runs: 2 success, 0 failed, 1 skipped (last 24h)

💡 Use --detail for full information
```

### Detailed View

```
📅 Scheduled Remote Agents (4 configured)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Task: ai-news-digest
   Schedule:  0 9 * * * (Daily at 9 AM)
   Status:    ✅ Enabled
   Project:   ~/Developer/auto-news
   Server:    ec2-dev

   Next run:  Tomorrow at 9:00 AM (in 14h 32m)
   Last run:  Today at 9:00 AM (8 hours ago)
   Result:    ✅ Success (exit code 0, 12m runtime)

   Task:
     Research AI news from last 24h via Tavily
     Create blog draft if interesting topic found
     Commit to git

   Recent history (last 5 runs):
     2025-11-17 09:00 ✅ Success (12m) - Created draft on "GraphRAG advances"
     2025-11-16 09:00 ✅ Success (8m) - Created draft on "Claude 4.5 release"
     2025-11-15 09:00 ⏸️  Skipped - No new interesting topics
     2025-11-14 09:00 ✅ Success (15m) - Created draft on "LangChain updates"
     2025-11-13 09:00 ❌ Failed - Tavily API timeout

   Environment:
     TAVILY_API_KEY: ***set***

   💡 Actions:
     Test now: ssh ec2-dev '~/bin/run-scheduled-task ai-news-digest'
     View logs: ssh ec2-dev 'tail -f ~/claude-agents/logs/agent-ai-news-digest-*/session.log'
     Pause: ~/bin/pause-scheduled-task ai-news-digest

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Task: security-scan
   Schedule:  0 2 * * * (Daily at 2 AM)
   Status:    ✅ Enabled
   Project:   ~/projects/payment-api
   Server:    ec2-dev

   Next run:  Tonight at 2:00 AM (in 6h 12m)
   Last run:  Today at 2:00 AM (18 hours ago)
   Result:    ✅ Success (exit code 0, 45m runtime)

   Task:
     Run OWASP dependency check
     Generate security report
     Alert if high-severity issues found

   Recent history:
     2025-11-17 02:00 ✅ Success (45m) - No high-severity issues
     2025-11-16 02:00 ✅ Success (42m) - No high-severity issues
     2025-11-15 02:00 ⚠️  Warning (38m) - 2 medium-severity issues found

   💡 Last report: ~/projects/payment-api/SECURITY-REPORT.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Task: test-staging
   Schedule:  0 */4 * * * (Every 4 hours)
   Status:    ⏸️  Paused
   Project:   ~/projects/api-server
   Server:    ec2-dev

   Next run:  - (paused)
   Last run:  2025-11-10 14:00 (7 days ago)
   Result:    ✅ Success (exit code 0, 5m runtime)

   💡 To resume: ~/bin/resume-scheduled-task test-staging
```

## Workflow

1. **Read Configuration**
   ```bash
   cat ~/.claude/remotes/scheduled-tasks.yaml
   ```

2. **Calculate Next Run Times**
   ```bash
   # For each task, parse cron expression
   # Calculate next execution time
   # Compare with current time
   ```

3. **Check Run History**
   ```bash
   # Look in ~/claude-agents/logs/ for recent runs
   # Parse exit codes and timestamps
   # Build history
   ```

4. **Format and Display**
   Based on flags:
   - Default: Summary table
   - `--detail`: Full information for each task
   - `--task <name>`: Details for specific task
   - `--recent`: Recent runs across all tasks

## Flags and Options

- `--detail` or `-d`: Show detailed view
- `--task <name>`: Show specific task details
- `--recent [N]`: Show N recent runs (default: 10)
- `--status <status>`: Filter by status (enabled|paused)
- `--next [N]`: Show N upcoming runs (default: 5)
- `--history <task>`: Full history for specific task

## Task Status Indicators

- ✅ **Enabled**: Task is active and will run on schedule
- ⏸️  **Paused**: Task exists but won't run (enabled: false)
- 🔄 **Running**: Task is currently executing
- ⏱️  **Overdue**: Task should have run but didn't

## Run Result Indicators

- ✅ **Success**: Exit code 0, completed normally
- ❌ **Failed**: Non-zero exit code
- ⚠️  **Warning**: Success but with warnings in output
- ⏸️  **Skipped**: Task chose not to run (no work needed)
- ⏱️  **Timeout**: Task exceeded time limit and was killed

## Recent History Format

Show last 5-10 runs for each task:
```
Recent history (last 5 runs):
  2025-11-17 09:00 ✅ Success (12m) - Created draft on "GraphRAG"
  2025-11-16 09:00 ✅ Success (8m) - Created draft on "Claude 4.5"
  2025-11-15 09:00 ⏸️  Skipped - No new topics
  2025-11-14 09:00 ✅ Success (15m) - Created draft on "LangChain"
  2025-11-13 09:00 ❌ Failed - API timeout
```

## Example Interactions

### Example 1: Quick Check

```
User: /list-scheduled-agents

You:
📅 Scheduled Remote Agents

Active: 3 enabled, 1 paused

Upcoming runs:
  Tonight 2 AM    - security-scan (in 6h)
  Tomorrow 9 AM   - ai-news-digest (in 14h)
  Monday 9 AM     - dep-updates (in 2d 14h)

Recent runs (last 24h):
  ✅ 2 successful
  ❌ 0 failed
  ⏸️  1 skipped

💡 Use /list-scheduled-agents --detail for full information
```

### Example 2: Detailed View

```
User: /list-scheduled-agents --detail

You: [Shows full detailed view as above]
```

### Example 3: Specific Task

```
User: /list-scheduled-agents --task ai-news-digest

You:
📋 Scheduled Task: ai-news-digest

Schedule:  Daily at 9 AM (0 9 * * *)
Status:    ✅ Enabled
Next run:  Tomorrow at 9:00 AM

Last 5 runs:
  2025-11-17 ✅ 12m - "GraphRAG advances"
  2025-11-16 ✅ 8m - "Claude 4.5 release"
  2025-11-15 ⏸️  0m - No topics
  2025-11-14 ✅ 15m - "LangChain updates"
  2025-11-13 ❌ 0m - API timeout

Success rate: 75% (3/4 last runs)
Avg runtime: 11.7 minutes

Latest output:
  Created: blog/drafts/2025-11-17-graphrag-advances/
  Files: outline.md, abstract.md, full-post.md, 3 code examples
  Commit: abc1234 "Add blog draft on GraphRAG advances"

💡 Test now: ssh ec2-dev '~/bin/run-scheduled-task ai-news-digest'
```

### Example 4: Recent Runs Across All Tasks

```
User: /list-scheduled-agents --recent 10

You:
📅 Recent Scheduled Task Runs (last 10)

2025-11-17 09:00  ✅ ai-news-digest    (12m) "GraphRAG advances"
2025-11-17 02:00  ✅ security-scan     (45m) No issues
2025-11-16 09:00  ✅ ai-news-digest    (8m) "Claude 4.5 release"
2025-11-16 02:00  ✅ security-scan     (42m) No issues
2025-11-15 09:00  ⏸️  ai-news-digest    (0m) Skipped
2025-11-15 02:00  ⚠️  security-scan     (38m) 2 medium-severity
2025-11-14 09:00  ✅ ai-news-digest    (15m) "LangChain updates"
2025-11-14 02:00  ✅ security-scan     (40m) No issues
2025-11-13 09:00  ❌ ai-news-digest    (0m) API timeout
2025-11-13 02:00  ✅ security-scan     (44m) No issues

Success rate: 80% (8/10)
```

### Example 5: Upcoming Runs

```
User: /list-scheduled-agents --next 5

You:
📅 Upcoming Scheduled Runs

Tonight 2:00 AM   (in 6h 12m)   security-scan
Tomorrow 9:00 AM  (in 14h 32m)  ai-news-digest
Tomorrow 2:00 AM  (in 1d 6h)    security-scan
Wed 9:00 AM       (in 1d 14h)   ai-news-digest
Wed 2:00 AM       (in 2d 6h)    security-scan

Next 24 hours: 2 runs scheduled
Next 7 days: 14 runs scheduled
```

## Management Actions

### Pause a Task
```bash
~/bin/pause-scheduled-task <task-name>
# or manually: edit YAML, set enabled: false
```

### Resume a Task
```bash
~/bin/resume-scheduled-task <task-name>
# or manually: edit YAML, set enabled: true
```

### Test Task Manually
```bash
ssh ec2-dev '~/bin/run-scheduled-task <task-name>'
```

### View Live Logs
```bash
ssh ec2-dev 'tail -f ~/claude-agents/logs/agent-<task>-*/session.log'
```

### Check Scheduler Status
```bash
# Is scheduler cron installed?
ssh ec2-dev 'crontab -l | grep run-scheduled-claude-tasks'

# Recent scheduler activity
ssh ec2-dev 'tail -f ~/claude-agents/logs/scheduler.log'
```

## Error Handling

**If configuration file doesn't exist:**
```
ℹ️  No scheduled tasks configured yet.

To create your first scheduled task:
  /schedule-agent

Or manually create: ~/.claude/remotes/scheduled-tasks.yaml
```

**If scheduler not installed:**
```
⚠️  Scheduler cron job not installed

Scheduled tasks are configured but won't run automatically.

To install scheduler:
  ssh ec2-dev
  (crontab -l 2>/dev/null; echo "*/15 * * * * \$HOME/bin/run-scheduled-claude-tasks >> \$HOME/claude-agents/logs/scheduler.log 2>&1") | crontab -

This will check for scheduled tasks every 15 minutes.
```

## Integration with Other Commands

- After `/schedule-agent`: New task appears in list
- After `/pause-scheduled-task`: Status shows as paused
- After manual run: Recent history updates
- Works with `/list-remotes` for currently running scheduled tasks

## Best Practices Display

When showing scheduled tasks, highlight:
- Tasks that haven't run recently (might be broken)
- Tasks with high failure rates (need attention)
- Tasks nearing cost/resource limits
- Paused tasks that might be forgotten

Example warning:
```
⚠️  Attention needed:

  security-scan: Failed last 2 runs (API authentication)
  test-staging: Paused 7 days ago (forgotten?)
  ai-news-digest: Approaching monthly cost limit ($180/$200)
```
