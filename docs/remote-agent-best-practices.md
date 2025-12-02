# Remote Agent Best Practices

**Version:** 2025-11-18
**Source:** Lessons learned from production remote agent workflow

This document captures critical lessons from building and operating remote Claude Code agent systems. Use this as a reference during conversations about remote handoffs, scheduled tasks, and parallel execution strategies.

---

## Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [Handoff Process](#handoff-process)
3. [Launch Verification](#launch-verification)
4. [Parallel vs Sequential Execution](#parallel-vs-sequential-execution)
5. [Planning ROI](#planning-roi)
6. [Content Quality Standards](#content-quality-standards)
7. [Cost Management](#cost-management)
8. [Troubleshooting Guide](#troubleshooting-guide)

---

## Core Philosophy

> **Remote agent handoff is a conversation, not a command.**

### Key Principles

1. **Facilitate, Don't Automate**
   - Handoffs require judgment about scope, risks, dependencies, boundaries
   - Slash commands can't make those decisions - only humans can
   - Manual conversation works better than rigid automation

2. **Verification Over Assumptions**
   - Always verify agent actually started
   - Check success criteria before merge
   - Test before scheduling

3. **Plan for Humans**
   - Detailed plans enable fast execution
   - Clear boundaries prevent scope creep
   - Success criteria enable objective evaluation

### What Works

✅ **Conversational handoff:**
```
User: "I need to hand off [task] to a remote agent"
Claude: [Discusses scope, risks, dependencies]
Claude: [Creates detailed PLAN.md with boundaries]
User: [Reviews and approves]
Claude: [Executes handoff: branch, push, launch script]
User: [Launches agent]
Claude: [Verifies agent started]
```

### What Doesn't Work

❌ **Automated slash command:**
```
User: /switch-to-remote "do the thing"
[Command tries to automate complex decisions]
[Gets scope wrong / misses dependencies / creates conflicts]
```

---

## Handoff Process

### 1. Scope Discussion

**Before writing any code, discuss:**

- What is the core task?
- What are the boundaries (must/must-not)?
- What dependencies exist?
- What risks need mitigation?
- What is the definition of done?

**Example conversation:**
```
User: "Hand off PDF extraction to remote agent"

Claude: "Let me clarify scope:
1. PDF extraction only, or also citation enhancement?
2. Should this modify existing pipeline code?
3. Are there other agents working on overlapping files?
4. Success = PDF text extracted, or also integrated into pipeline?
5. Any specific libraries required (tesseract, docling)?"

User: "Combine PDF + citations, integrate into pipeline, use docling"

Claude: "Perfect. That's a natural pairing. I'll create a combined
Phase 1 plan that does both together."
```

### 2. Create Detailed PLAN.md

**Structure:**
```markdown
# Task: [Concise title]

## Goal
[Single sentence: what success looks like]

## Success Criteria (Checkboxes)
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Tests passing
- [ ] Git commit made

## Boundaries
### Must
- Specific things that MUST be done
- With file paths and line numbers

### Must Not
- Things to explicitly avoid
- Why they're out of scope

## Implementation Details
### Step 1: [Action]
File: `path/to/file.py`
Lines: 45-67

```python
# Exact code snippet or clear pseudo-code
def example_function():
    # Show exactly what needs to happen
    pass
```

Why: [Rationale for this approach]

[Repeat for each step]

## Testing Strategy
- How to verify each step works
- Integration test requirements
- Expected outputs

## Time Estimate
- Estimated: X hours
- Reasoning: [Why this estimate]
```

**Time investment:** 30 minutes
**ROI:** 10-14x (saves 5-7 hours of agent exploration)

### 3. Prepare Handoff Materials

```bash
# Create feature branch
BRANCH="main-remote-$(date +%Y%m%d-%H%M%S)-${TASK_SLUG}"
git checkout -b "$BRANCH"

# Commit PLAN.md
mkdir -p .claude/handoff
cp /tmp/PLAN.md .claude/handoff/
git add .claude/handoff/PLAN.md
git commit -m "Add handoff plan for ${TASK_SLUG}"

# Push to remote
git push -u origin "$BRANCH"

# Create launch script
cat > /tmp/launch-remote-${TASK_SLUG}.sh <<'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$HOME/Developer/auto-news"
BRANCH="${BRANCH}"
TASK_NAME="${TASK_SLUG}"

cd "$PROJECT_DIR"

# CRITICAL: Handle untracked files before checkout
git stash push --include-untracked -m "Stashed before remote agent checkout"

# Fetch and checkout handoff branch
git fetch origin
git checkout "$BRANCH"

# CRITICAL: Start tmux server if not running (2025-11-18 lesson)
tmux start-server 2>/dev/null || true

# Launch agent in tmux
SESSION="agent-${TASK_NAME}-$(date +%Y%m%d-%H%M%S)"
tmux new-session -d -s "$SESSION" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION" "# Task: ${TASK_NAME}" C-m
tmux send-keys -t "$SESSION" "# Read .claude/handoff/PLAN.md for details" C-m
tmux send-keys -t "$SESSION" "claude-code" C-m

echo "✅ Agent launched in tmux session: $SESSION"
echo "Monitor: tmux attach -t $SESSION"

# CRITICAL: Verify session was created
sleep 1
if tmux list-sessions 2>/dev/null | grep -q "agent-"; then
    echo "✅ VERIFIED: Agent session running"
    tmux list-sessions | grep agent-
else
    echo "❌ FAILED: Agent session not found!"
    echo "Check tmux server status: tmux info"
    exit 1
fi
EOF

chmod +x /tmp/launch-remote-${TASK_SLUG}.sh
```

### 4. Execute Handoff

**Critical: Use checklist format, not prose**

```
✅ HANDOFF CHECKLIST

Required Actions:
[ ] 1. SCP launch script to remote
      scp /tmp/launch-remote-${TASK_SLUG}.sh ec2-dev:~/

[ ] 2. Execute launch script
      ssh ec2-dev 'bash ~/launch-remote-${TASK_SLUG}.sh'

[ ] 3. VERIFY agent started (CRITICAL!)
      ssh ec2-dev 'tmux list-sessions | grep agent-'

Expected output:
agent-${TASK_SLUG}-YYYYMMDD-HHMMSS: 1 windows (created ...)

If NO output → agent never started! Debug immediately.

Monitoring:
- Attach: ssh ec2-dev 'tmux attach -t agent-${TASK_SLUG}-*'
- Logs: ssh ec2-dev 'tail -f ~/claude-agents/logs/agent-${TASK_SLUG}-*/session.log'
```

---

## Launch Verification

### The Problem

**What went wrong (2025-11-18):**
1. Created handoff materials (branch, PLAN.md, launch script)
2. Displayed instructions for launching
3. Got distracted discussing other things
4. **Never actually launched the agent**
5. Discovered 1 hour later agent wasn't running

### The Solution

**ALWAYS verify immediately after handoff:**

```bash
# Step 1: Launch
ssh ec2-dev 'bash ~/launch-remote-${TASK_SLUG}.sh'

# Step 2: IMMEDIATELY verify (within 30 seconds)
ssh ec2-dev 'tmux list-sessions | grep agent-'

# Expected output:
# agent-pdf-citation-20251118-144414: 1 windows (created Mon Nov 18 14:44:14 2024)

# If NO output:
echo "❌ LAUNCH FAILED - Agent never started"
# Debug immediately - don't move on
```

### Common Launch Issues

#### Issue 1: Tmux Server Not Running

**Symptom:**
```
tmux new-session -d -s "agent-name"
error: no server running on /tmp/tmux-1000/default
```

**When:** 2025-11-18 Phase 2 launch

**Why:** Tmux server wasn't initialized on ec2-dev (may have stopped since last use)

**Impact:** Agent never starts, script continues as if it worked

**Fix in launch script:**
```bash
# Before creating session:
tmux start-server 2>/dev/null || true

# Then create session:
tmux new-session -d -s "$SESSION" -c "$PROJECT_DIR"

# Verify it worked:
sleep 1
if tmux list-sessions 2>/dev/null | grep -q "agent-"; then
    echo "✅ VERIFIED: Agent session running"
else
    echo "❌ FAILED: Agent session not found!"
    exit 1
fi
```

**Prevention:** Updated launch script template includes `tmux start-server` and verification step.

#### Issue 2: Untracked Files Blocking Checkout

**Symptom:**
```
error: The following untracked working tree files would be overwritten by checkout:
	deepmind_article_extracted.md
	extract_response.json
Please move or remove them before you switch branches.
```

**Why:** ec2-dev is a shared environment where test files accumulate between sessions.

**Fix:** Launch script must handle this:
```bash
# Before checkout:
git stash push --include-untracked -m "Stashed before remote agent checkout"

# Then safe to checkout:
git checkout "$BRANCH"
```

#### Issue 3: Instructions Displayed But Not Executed

**Symptom:** Launch instructions shown to user, but no actual execution.

**Why:** Displaying ≠ executing. Easy to get distracted.

**Fix:**
- Use checklist format (not prose)
- Verify immediately after each step
- Consider auto-launch with user confirmation

#### Issue 4: No Verification Agent Started

**Symptom:** Assume agent is running, discover hours later it never started.

**Why:** No immediate verification step.

**Fix:** Make verification mandatory:
```bash
# After launch, MUST run:
VERIFY=$(ssh ec2-dev 'tmux list-sessions | grep agent-' || echo "NONE")

if [[ "$VERIFY" == "NONE" ]]; then
    echo "❌ CRITICAL: Agent never started!"
    echo "Debug launch script and try again"
    exit 1
else
    echo "✅ Agent confirmed running: $VERIFY"
fi
```

---

## Parallel vs Sequential Execution

### The Problem

**Original plan (2025-11-18):**
```
Agent 1: Citation enhancement
Agent 2: PDF extraction
Agent 3: Query expansion

Run in parallel → Fast completion
```

**Reality discovered:**
```
All three would modify topic_pipeline.py:
- Agent 1: extract_content(), parse_summary_output()
- Agent 2: extract_content() (same function!)
- Agent 3: build_generation_context()

Result: MERGE HELL
```

### The Solution: Map File Modifications First

**Before proposing parallel execution:**

1. **List files each agent will modify**
2. **Check for overlaps**
3. **Decide: Parallel, Sequential, or Combined**

**Example analysis:**

```bash
# Agent 1 scope:
Files: src/dag/topic_pipeline.py (lines 89-124, 256-289)
       prompts/summarize_technical_article.yaml

# Agent 2 scope:
Files: src/dag/topic_pipeline.py (lines 89-124)  # OVERLAP!
       src/utils/pdf_extractor.py (new)
       pyproject.toml

# Agent 3 scope:
Files: src/dag/topic_pipeline.py (lines 312-378)
       prompts/generate_news_digest.yaml

# Verdict: topic_pipeline.py has OVERLAPS
# Solution: Sequential execution or combine overlapping tasks
```

### Decision Framework

| Scenario | Strategy | Reason |
|----------|----------|--------|
| Different files/modules | ✅ Parallel | No conflicts possible |
| Same file, different functions | ⚠️ Review carefully | May work if truly independent |
| Same file, same functions | ❌ Sequential | Guaranteed merge conflicts |
| Naturally related tasks | ✅ Combine | Better architecture, faster completion |
| Dependencies between tasks | ✅ Sequential | Build on previous work |

### Sequential Strategy That Worked

**Phase 1: PDF + Citation (Combined)**
- Why combined: Both modify extract_content(), natural pairing
- Time: 1 hour actual (6-8 estimated)
- Result: Clean implementation, no conflicts

**Phase 2: Query Expansion**
- Why sequential: Builds on Phase 1's extraction improvements
- Files: YAML only (no code conflicts)
- Time: 2-3 hours estimated

**Phase 3: Cross-Source Validation**
- Why sequential: Needs Phase 1's citation structure
- Files: Builds on established patterns
- Time: 4-5 hours estimated

### Key Insight

> "Sequential execution on same branch often faster than parallel with merge conflicts."

**Why:**
- No merge resolution time
- Agent 2 builds on Agent 1's patterns
- Agent 3 uses established structure
- Single review/merge process
- Clear progression

---

## Planning ROI

### Time Investment

**30 minutes creating comprehensive PLAN.md**

Includes:
- Clear goal statement
- Success criteria (checkboxes)
- Architectural boundaries (must/must-not)
- Implementation details with code snippets
- Specific file locations and line numbers
- Testing strategy

### Return on Investment

**5-7 hours saved** from:
- No exploration/research phase
- No architectural ambiguity
- No backtracking on wrong approaches
- Clear stopping point
- Easy verification

**ROI: 10-14x** return on planning time

### Agent Completion Speed

**Estimate vs Actual (2025-11-18 Phase 1):**
- Estimated: 6-8 hours
- Actual: ~1 hour
- **Completion rate: 6-8x faster**

**Why the huge difference?**
1. Over-cautious estimation (assumed exploration)
2. Clear instructions (exact code snippets, locations)
3. No decisions needed (all architectural choices pre-made)
4. Sequential subtasks (A → B → C flow, no backtracking)

### Estimation Guidelines

| Task Type | Estimation Approach |
|-----------|-------------------|
| Exploratory/research | Original conservative estimate probably right |
| Implementation with clear spec | **Divide estimate by 4-6** |
| Following examples/patterns | Very fast (1-2 hours for ~500 lines) |
| Refactoring unclear code | Add 50-100% buffer |
| New architectural decisions | Keep conservative estimate |

### What Makes a Good PLAN.md

✅ **Good example:**
```markdown
### Step 2: Enhance summarization prompt

File: `prompts/summarize_technical_article.yaml`
Lines: Add after line 12

Add new section:
```yaml
## QUOTABLE INSIGHTS
Extract 2-3 direct quotes that:
- Capture key technical insights
- Are attributable (include speaker/author context)
- Would strengthen citation in final article

Format: > "Quote text" — Author Name, Role
```

Why: Provides citation-ready quotes for article generation

Test: Run summarization on test article, verify quotes extracted
```

❌ **Bad example:**
```markdown
### Enhance summarization

Update the prompt to get better quotes

File: somewhere in prompts/
```

The first example tells the agent **exactly** what to do. The second requires exploration and decision-making.

---

## Content Quality Standards

When scheduling content generation tasks (blog posts, reports, documentation), enforce these standards:

### 1. Audience Clarity

**Before creating content:**
- Who is this valuable for? (specific role: AI developers, architects, engineers)
- Why should they care? (what decision does this inform?)
- What can they DO with this information? (actionable outcomes)

**Reject if:**
- Audience unclear
- No clear value proposition
- Purely informational (no actionable insights)

### 2. Technical Depth Over Hype

**Accept:**
✅ Technical claims with specific metrics
✅ Novel approaches with implementation details
✅ Working code examples
✅ Content answering "how" and "why", not just "what"

**Reject:**
❌ Press releases and marketing fluff
❌ Obvious news without insights
❌ Fanboy content ("X is amazing!")
❌ Vague promises without specifics

**Quality checklist:**
```yaml
Before creating content:
- [ ] Has specific technical claims (not vague promises)
- [ ] Includes quantitative metrics with baselines
- [ ] Provides actionable insights (not just "X is cool")
- [ ] Can include working code examples
- [ ] Hasn't been covered in last 30 days

If < 4/5 criteria met → skip this topic
```

### 3. Uniqueness Check

**Prevent duplicate coverage:**

```python
# In scheduled task:
def check_uniqueness(topic: str) -> bool:
    """Check if topic was recently covered."""
    processed = read_file("blog/processed-topics.txt")

    for past_topic in processed.split("\n"):
        if similarity(topic, past_topic) > 0.7:  # Too similar
            logger.info(f"Skipping {topic} - too similar to {past_topic}")
            return False

    return True  # Unique enough to proceed
```

### 4. Human Review Required

**NEVER auto-publish:**

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

**Why:**
- Quality control gate
- Brand alignment check
- Legal/compliance review
- Technical accuracy verification
- Final polish and voice adjustment

### 5. Practical Code Examples

**Generated code must be:**
- ✅ Runnable (not pseudocode)
- ✅ Dependencies listed (with versions)
- ✅ Setup instructions included
- ✅ Expected output shown
- ✅ Tested before committing

**Example:**
```markdown
## Code Example: PDF Extraction with Docling

### Setup
```bash
pip install docling>=2.0.0
```

### Implementation
```python
from docling.document_converter import DocumentConverter

converter = DocumentConverter()
result = converter.convert("paper.pdf")
markdown = result.document.export_to_markdown()
print(markdown)
```

### Expected Output
```
# Research Paper Title

## Abstract
This paper presents...
```

### 6. Citation Quality

**All research-based content needs:**
- Quotable insights with attribution
- Inline citations [1], [2], [3]
- References section at end
- Source URLs and access dates
- Source quality ratings (1-5 citation worthiness)

**Example:**
```markdown
The study found that "model performance improved 23% with
multimodal pretraining" [1].

## References

[1] Smith, J. et al. "Multimodal Pretraining for Large Language
Models." NeurIPS 2024. https://arxiv.org/abs/2024.12345
(Accessed: 2025-11-18)
```

---

## Cost Management

### Budget Limits

**Set hard limits in scheduled tasks:**

```yaml
conditions:
  monthly_cost_under: 200    # Total spending cap
  daily_cost_under: 20       # Per-day limit
  cost_per_run_under: 5      # Single task budget
```

**Task pauses automatically if limits exceeded.**

### Per-Task Budget Allocation

**Example: Daily news digest ($2.00 budget)**

```yaml
task: |
  Budget allocation for this run: $2.00

  1. Search (Tavily API): ~$0.10
  2. Extract 5 articles: ~$0.50
  3. Summarize with Haiku: ~$0.20
  4. Generate with Sonnet: ~$1.00
  5. Review with Sonnet: ~$0.20

  Total estimated: ~$2.00

  If budget exceeded at any step:
    - Save progress to drafts/
    - Log partial completion
    - Exit gracefully with code 0
```

### Cost Monitoring

```bash
# Check monthly spending
cat ~/claude-agents/logs/costs-$(date +%Y-%m).log

# Alert if approaching limit
MONTHLY_COST=$(get_monthly_cost)
if [[ $MONTHLY_COST -gt 180 ]]; then
    echo "⚠️  Monthly cost at $${MONTHLY_COST}/200 budget"
    # Send notification
fi

# Per-task cost tracking
echo "$(date),${TASK_NAME},${COST}" >> ~/claude-agents/logs/costs-$(date +%Y-%m).log
```

### Cost Optimization Strategies

1. **Use cheaper models for simple tasks**
   - Haiku for summarization
   - Sonnet only for writing/review

2. **Batch operations**
   - Process 5 articles per run (not 1)
   - Weekly updates (not daily) for low-priority tasks

3. **Early termination**
   - Check quality filters BEFORE expensive operations
   - Skip low-quality sources early

4. **Caching**
   - Cache search results for 24 hours
   - Reuse extracted content across summaries

---

## Troubleshooting Guide

### Issue: Agent Never Started

**Symptoms:**
- No tmux session visible
- No logs in ~/claude-agents/logs/
- Branch exists but no commits

**Diagnosis:**
```bash
# Check if tmux session exists
ssh ec2-dev 'tmux list-sessions | grep agent-'

# If empty → agent never launched
```

**Solutions:**
1. Check launch script executed successfully
2. Verify untracked files didn't block checkout
3. Check tmux is installed and working
4. Review launch script logs for errors

### Issue: Agent Running But Not Making Progress

**Symptoms:**
- tmux session exists
- No new commits for > 1 hour
- Logs show repeated errors or stuck state

**Diagnosis:**
```bash
# Attach to session to see what's happening
ssh ec2-dev 'tmux attach -t agent-{task}-*'

# Or check logs
ssh ec2-dev 'tail -50 ~/claude-agents/logs/agent-{task}-*/session.log'
```

**Common causes:**
1. **API rate limiting** - Wait and retry
2. **Missing credentials** - Check env vars on remote
3. **Ambiguous requirements** - PLAN.md wasn't clear enough
4. **Scope too large** - Break into smaller tasks
5. **Infinite loop** - Kill and relaunch with better bounds

**Solutions:**
- If fixable: Attach and intervene manually
- If stuck: Kill and relaunch with refined scope
- If architectural: Pull back to local, fix, re-handoff

### Issue: Merge Conflicts After Agent Completes

**Symptoms:**
```
CONFLICT (content): Merge conflict in src/dag/topic_pipeline.py
```

**Why this happened:**
- Main branch diverged during agent execution
- Another agent modified same files
- Manual changes on main overlapped

**Prevention:**
1. Fetch main before handoff
2. Sequential execution for overlapping files
3. Short-lived agents (< 8 hours)

**Resolution:**
```bash
# Rebase agent branch onto latest main
git checkout {agent-branch}
git fetch origin main
git rebase origin/main

# Resolve conflicts
# Test thoroughly
# Push force (safe on feature branch)
git push -f origin {agent-branch}
```

### Issue: Agent Completed But Tests Fail

**Symptoms:**
- Exit code 0 (success)
- Code changes look correct
- But: `pytest` fails on merged code

**Diagnosis:**
Check if agent ran tests:
```bash
# In agent logs, search for:
grep "pytest" ~/claude-agents/logs/agent-{task}-*/session.log
```

**Solutions:**

If agent didn't run tests:
1. Update PLAN.md template to require testing
2. Add "Tests passing" to success criteria

If tests pass on branch but fail after merge:
1. Integration issue with other changes
2. Rebase onto main and retest
3. May need manual fixes

### Issue: Scheduled Task Not Running

**Symptoms:**
- Task configured in scheduled-tasks.yaml
- Cron schedule looks correct
- But never executes

**Diagnosis:**
```bash
# Check scheduler cron installed
crontab -l | grep run-scheduled-claude-tasks

# Check scheduler logs
tail -50 ~/claude-agents/logs/scheduler.log

# Verify task enabled
cat ~/.claude/remotes/scheduled-tasks.yaml | grep -A 10 "name: {task-name}"
```

**Common causes:**
1. Scheduler cron not installed
2. Task disabled (`enabled: false`)
3. Cron expression invalid
4. Timezone mismatch

**Solutions:**
```bash
# Install scheduler cron
CRON="*/15 * * * * $HOME/bin/run-scheduled-claude-tasks >> $HOME/claude-agents/logs/scheduler.log 2>&1"
(crontab -l 2>/dev/null | grep -v run-scheduled-claude-tasks; echo "$CRON") | crontab -

# Enable task
# Edit ~/.claude/remotes/scheduled-tasks.yaml
# Set: enabled: true

# Validate cron expression
# Visit: https://crontab.guru
```

---

## Quick Reference

### Remote Handoff Checklist

```
[ ] 1. Discuss scope and boundaries with user
[ ] 2. Create detailed PLAN.md (30 min investment)
[ ] 3. Check for file overlaps if parallel execution
[ ] 4. Create feature branch
[ ] 5. Commit PLAN.md and push
[ ] 6. Generate launch script with git stash
[ ] 7. SCP launch script to remote
[ ] 8. Execute launch script
[ ] 9. VERIFY tmux session exists (CRITICAL!)
[ ] 10. Monitor initial progress
[ ] 11. When complete: fetch, review, test, merge
```

### Key Quotes

> "Remote agent handoff is a conversation, not a command."

> "Some processes should be facilitated, not automated."

> "Before parallelizing, map actual file modifications."

> "Well-scoped tasks with detailed plans complete 6x faster than estimates."

> "Slash commands are for execution, not judgment."

> "Sequential execution on same branch often faster than parallel with merge conflicts."

---

**Last updated:** 2025-11-18
**Next review:** After next major remote agent project
**Maintained by:** User + Claude Code collaborative learning
