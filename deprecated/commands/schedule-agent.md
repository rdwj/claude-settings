# Schedule Agent: Recurring Remote Agent Tasks

You are helping the user create a scheduled remote agent task that runs periodically.

## Your Responsibilities

1. **Understand the Task**
   - Ask about task frequency and timing
   - Clarify what the agent should accomplish
   - Ensure task is idempotent (safe to run repeatedly)

2. **Create Schedule Configuration**
   - Generate YAML configuration for the task
   - Set up cron expression
   - Define environment variables if needed
   - Configure permissions and safety limits

3. **Register with Scheduler**
   - Add to ~/.claude/remotes/scheduled-tasks.yaml
   - Validate cron expression
   - Check for naming conflicts

4. **Setup Instructions**
   - Explain how to enable the scheduler
   - Show how to test manually
   - Provide monitoring guidance

## Schedule File Location

`~/.claude/remotes/scheduled-tasks.yaml`

## YAML Structure

```yaml
scheduled_tasks:
  - name: task-name              # Unique identifier (slug)
    schedule: "0 9 * * *"        # Cron expression
    project: ~/projects/myapp    # Project directory
    task: |                      # Task description (can be multi-line)
      What the agent should accomplish
    server: ec2-dev              # Which remote server (default: ec2-dev)
    permissions: developer       # Permission profile or --dangerous
    enabled: true                # Can pause without deleting
    env:                         # Environment variables
      API_KEY: ${API_KEY}
    conditions:                  # Optional: when to run
      monthly_cost_under: 200
      server_load_under: 0.7
    notifications:               # Optional: where to notify
      on_success: slack
      on_failure: email
    retry:                       # Optional: retry on failure
      enabled: true
      max_attempts: 3
      backoff: exponential
```

## Cron Expression Quick Reference

```
* * * * *
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
│ │ │ └──────── Month (1-12)
│ │ └───────────── Day of month (1-31)
│ └────────────────── Hour (0-23)
└─────────────────────── Minute (0-59)

Examples:
"0 9 * * *"      # Daily at 9 AM
"0 */4 * * *"    # Every 4 hours
"0 9 * * 1"      # Mondays at 9 AM
"0 0 * * 0"      # Sundays at midnight
"*/15 * * * *"   # Every 15 minutes
"0 2 * * 1-5"    # Weekdays at 2 AM
```

## Task Design Guidelines

### Idempotency is Critical
Tasks may run multiple times due to retries or manual triggers. Design them to:
- Check if work is already done before doing it
- Use timestamps/markers to track state
- Avoid duplicate processing

**Example: AI News Digest**
```yaml
task: |
  1. Read blog/processed-topics.txt to see what we've covered
  2. Use Tavily API to search recent AI news (last 24h)
  3. Filter out topics already in processed-topics.txt
  4. Pick most interesting new topic based on criteria
  5. Research topic deeply, create blog draft
  6. Append topic to processed-topics.txt
  7. Commit to git
```

### State Management
- Use files in project to track state (e.g., processed-topics.txt)
- Commit state changes to git
- Don't rely on external databases unless necessary

### Error Handling
- Tasks should log clearly what went wrong
- Partial completion should be safe
- Use git commits to mark progress

## Workflow

1. **Validate Input**
   ```bash
   # Check schedule expression is valid
   # Verify project directory exists
   # Ensure no naming conflict
   ```

2. **Create/Update Configuration**
   ```bash
   # Initialize file if doesn't exist
   mkdir -p ~/.claude/remotes

   if [[ ! -f ~/.claude/remotes/scheduled-tasks.yaml ]]; then
       cat > ~/.claude/remotes/scheduled-tasks.yaml <<EOF
   scheduled_tasks: []
   EOF
   fi
   ```

3. **Add Task Using yq or Manual Edit**
   ```yaml
   # Append new task to the list
   # Validate YAML syntax
   ```

4. **Enable Scheduler (One-Time Setup)**
   ```bash
   # Install scheduler cron job if not already present
   CRON_ENTRY="*/15 * * * * $HOME/bin/run-scheduled-claude-tasks >> $HOME/claude-agents/logs/scheduler.log 2>&1"

   (crontab -l 2>/dev/null | grep -v run-scheduled-claude-tasks; echo "$CRON_ENTRY") | crontab -
   ```

5. **Test Manually**
   ```bash
   # Don't wait for cron, test now
   ~/bin/run-scheduled-task <task-name>
   ```

## Example Interactions

### Example 1: AI News Digest

```
User: I want to schedule a daily task that researches AI news and creates blog drafts

You: Great! Let me help you set that up. A few questions:

1. What time should this run daily? (Consider your timezone)
2. Which project directory? (e.g., ~/projects/auto-news)
3. Do you have required API keys? (Tavily for news search)
4. Should it notify you on completion?

User: 9 AM daily, ~/Developer/auto-news, yes I have Tavily key, yes notify via Slack

You: Perfect! I'll create a scheduled task that:
- Runs daily at 9 AM
- Searches AI news from last 24 hours via Tavily
- Avoids duplicate topics
- Creates blog post drafts with code examples
- Commits to git
- Notifies you via Slack

Creating configuration now...

[Creates YAML entry]

✅ Scheduled task created: ai-news-digest

Configuration:
  Schedule: Daily at 9 AM (0 9 * * *)
  Project: ~/Developer/auto-news
  Server: ec2-dev
  Permissions: developer

Next steps:
  1. Set TAVILY_API_KEY environment variable on ec2-dev
  2. Test manually: ssh ec2-dev '~/bin/run-scheduled-task ai-news-digest'
  3. Monitor: /list-scheduled-agents

The scheduler checks every 15 minutes for tasks to run.
Your first automated run will be tomorrow at 9 AM.
```

### Example 2: Security Scan

```
User: /schedule-agent security-scan "0 2 * * *" "Run OWASP dependency check, create report"

You: I'll set up a nightly security scan at 2 AM. Which project should I scan?

User: ~/projects/payment-api

You:
✅ Scheduled task created: security-scan

Schedule: Daily at 2 AM
Project: ~/projects/payment-api
Task: Run OWASP dependency check and create security report

The agent will:
- Run OWASP dependency checker
- Generate SECURITY-REPORT.md
- Commit findings to git
- Alert if high-severity issues found

Test it manually first:
  ssh ec2-dev '~/bin/run-scheduled-task security-scan'
```

### Example 3: Weekly Dependency Updates

```
User: Every Monday morning, check for safe dependency updates and create a PR

You: Great use case! I'll set that up for Mondays at 9 AM.

✅ Scheduled task created: dependency-updates

Schedule: Mondays at 9 AM (0 9 * * 1)
Project: ~/projects/api-server

The agent will:
- Check for available updates (npm outdated, pip list --outdated)
- Identify "safe" updates (patch/minor versions)
- Update package files
- Run tests to verify nothing breaks
- Create feature branch
- Push and create PR with summary
- Notify you of PR for review

This won't auto-merge - you review and approve.
```

## Safety Considerations

### Cost Limits
```yaml
conditions:
  monthly_cost_under: 200  # Pause if spending exceeds budget
  daily_cost_under: 20
```

### Resource Limits
```yaml
conditions:
  server_load_under: 0.7   # Don't run if server busy
  max_concurrent_agents: 3  # Don't starve other tasks
```

### Task Timeout
```yaml
timeout_minutes: 120       # Kill if running longer than 2 hours
```

### Failure Notifications
```yaml
notifications:
  on_failure: email        # Alert immediately on failures
  on_stuck: slack          # Alert if no progress for 30min
```

## Advanced Features

### Conditional Execution
```yaml
task: |
  # Only process if new data available
  if ! git diff --quiet origin/main blog/processed-topics.txt; then
    echo "No new topics to process, exiting gracefully"
    exit 0
  fi
  # ... rest of task
```

### Dependency Chaining
```yaml
scheduled_tasks:
  - name: research-news
    schedule: "0 9 * * *"
    on_success: write-blog  # Trigger another task

  - name: write-blog
    schedule: manual        # Only runs when triggered
    depends_on: research-news
```

### Environment-Specific Schedules
```yaml
scheduled_tasks:
  - name: test-staging
    schedule: "0 */4 * * *"  # Every 4 hours
    project: ~/projects/api
    task: "Run tests against staging environment"
    env:
      ENV: staging
      API_URL: https://staging.example.com
```

## Monitoring

**Check next run time:**
```bash
~/bin/check-scheduled-tasks --next-run
```

**View recent runs:**
```bash
~/bin/check-scheduled-tasks --recent
```

**See what's enabled:**
```bash
/list-scheduled-agents
```

**Pause a task:**
```bash
~/bin/pause-scheduled-task ai-news-digest
# Or edit YAML and set enabled: false
```

## Troubleshooting

**Task not running:**
1. Check scheduler cron is installed: `crontab -l | grep run-scheduled-claude-tasks`
2. Check scheduler logs: `tail -f ~/claude-agents/logs/scheduler.log`
3. Verify task is enabled: `cat ~/.claude/remotes/scheduled-tasks.yaml`
4. Check cron expression: Use https://crontab.guru

**Task running but failing:**
1. Check task logs: `tail -f ~/claude-agents/logs/agent-<taskname>-*/session.log`
2. Run manually for debugging: `~/bin/run-scheduled-task <name>`
3. Check environment variables are set
4. Verify permissions allow required operations

**Task running too often/not often enough:**
1. Verify cron expression: https://crontab.guru
2. Check timezone on server: `date`
3. Remember: scheduler checks every 15min, so tasks may run slightly late

## Best Practices

1. **Start with manual runs** - Test thoroughly before enabling schedule
2. **Use descriptive names** - Clear task names help monitoring
3. **Log everything** - Tasks should be verbose about what they're doing
4. **Git commits are markers** - Use them to show progress/completion
5. **Design for failures** - Tasks should gracefully handle API outages, etc.
6. **Monitor costs** - Scheduled tasks can add up quickly
7. **Review outputs** - Don't blindly trust automated outputs
8. **Start conservatively** - Daily is often better than hourly initially

## Quality Standards for Generated Content (Lessons Learned)

When scheduling content generation tasks (blog posts, reports, documentation):

### Audience Clarity
**Always define who this is for and why they care:**
```yaml
task: |
  Before creating content, ask:
  1. Who is this valuable for? (e.g., AI developers, architects, engineers)
  2. Why should they care? (What decision does this inform?)
  3. What can they DO with this information?

  Skip content that lacks clear answers to these questions.
```

### Technical Depth Over Hype
**Filter for substance, reject fluff:**
- ✅ **Accept**: Technical claims with metrics, novel approaches, working code
- ❌ **Reject**: Press releases, obvious news, fanboy content, marketing fluff
- ✅ **Accept**: Content that answers "how" and "why", not just "what"
- ❌ **Reject**: Content without specific implementation details

**Example quality filter:**
```yaml
task: |
  # Quality checklist before creating content:
  - [ ] Has specific technical claims (not vague promises)
  - [ ] Includes quantitative metrics with baselines
  - [ ] Provides actionable insights (not just "X is cool")
  - [ ] Can include working code examples
  - [ ] Hasn't been covered in last 30 days (check processed-topics.txt)

  If < 4/5 criteria met → skip this topic
```

### Uniqueness Check
**Prevent duplicate coverage:**
```yaml
task: |
  1. Read blog/processed-topics.txt
  2. Check if similar topic covered in last 30 days
  3. If too similar → skip and try next candidate
  4. If unique → proceed with research
  5. After completion → append to processed-topics.txt
```

### Human Review Required
**NEVER auto-publish generated content:**
```yaml
task: |
  Create drafts in blog/drafts/YYYY-MM-DD-{slug}/ with:
  - outline.md (structure overview)
  - abstract.md (summary for review)
  - full-post.md (complete draft)
  - code-examples/ (tested, working code)

  Commit to git for human review.
  DO NOT publish automatically.
```

### Practical Code Examples
**Generated code must be runnable:**
```yaml
task: |
  For technical content, include:
  - Working code snippets (not pseudocode)
  - Dependencies listed (with versions)
  - Setup instructions
  - Expected output examples

  Test code before committing.
```

### Citation Quality
**All claims need sources:**
```yaml
task: |
  For research-based content:
  - Extract quotable insights with attribution
  - Include inline citations [1], [2], [3]
  - Create References section at end
  - Track source URLs and access dates
  - Rate source quality (1-5 citation worthiness)
```

## Cost Awareness (Critical for Scheduled Tasks)

**Set hard budget limits:**
```yaml
conditions:
  monthly_cost_under: 200    # Total spending cap
  daily_cost_under: 20       # Per-day limit
  cost_per_run_under: 5      # Single task budget

# Task will pause if limits exceeded
```

**Example: Daily news digest with budget:**
```yaml
task: |
  Budget allocation for this run: $2.00

  1. Search (Tavily API): ~$0.10
  2. Extract 5 articles: ~$0.50
  3. Summarize with Haiku: ~$0.20
  4. Generate with Sonnet: ~$1.00
  5. Review with Sonnet: ~$0.20

  Total estimated: ~$2.00

  If budget exceeded at any step → save progress and exit gracefully
```

**Monitor actual costs:**
```bash
# Check monthly spending
cat ~/claude-agents/logs/costs-$(date +%Y-%m).log

# Alert if approaching limit
if [[ $(get_monthly_cost) -gt 180 ]]; then
  echo "⚠️  Monthly cost at $180/200 budget"
fi
```

## Output to User

After creating a scheduled task:

```
✅ Scheduled task created: {task-name}

Schedule: {human-readable schedule}
Project: {project-path}
Server: {server-name}
Next run: {calculated next run time}

Task will:
  {bullet points of what it does}

Setup required:
  {any env vars or config needed}

Test manually:
  ssh {server} '~/bin/run-scheduled-task {task-name}'

Monitor:
  /list-scheduled-agents
  tail -f ~/claude-agents/logs/scheduler.log

To pause: Edit ~/.claude/remotes/scheduled-tasks.yaml and set enabled: false
To delete: Remove entry from YAML file
```
