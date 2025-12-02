# List Remote Agent Sessions

Show status of remote Claude Code agent sessions currently running or recently completed.

## Your Responsibilities

1. **Display Active Sessions**
   - Check git branches matching `*-remote-*` pattern
   - Read `.claude/handoff/PLAN.md` for task details
   - Show status and progress

2. **Check Remote Status** (if requested)
   - SSH to remote and check tmux sessions
   - Read agent logs for progress updates
   - Report completion status

3. **Suggest Next Steps**
   - How to retrieve completed work
   - How to monitor running agents
   - How to investigate failures

## How to Find Remote Sessions

1. **Check Git Branches**
   ```bash
   git fetch --all
   git branch -r | grep 'remote-[0-9]'
   ```

2. **Query Remote** (optional)
   ```bash
   ssh ec2-dev 'tmux list-sessions | grep agent-'
   ```

3. **Read Handoff Plans**
   For each remote branch found:
   ```bash
   git show origin/{branch}:.claude/handoff/PLAN.md
   ```

## Display Format

### Simple View (default)

```
🔍 Remote Agent Sessions

📋 pdf-citation
   Branch: main-remote-20251118-072718-pdf-citation
   Status: 🔄 Running
   Task: Implement PDF extraction + citation enhancement
   Started: 15 minutes ago

   💡 Monitor: ssh ec2-dev 'tmux attach -t agent-pdf-citation-*'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

No completed sessions found.
```

### Detailed View (with --detail flag)

```
🔍 Remote Agent Sessions (Detailed)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Session: pdf-citation
   Branch:   main-remote-20251118-072718-pdf-citation
   Status:   🔄 Running (15 minutes)
   Project:  /Users/wjackson/Developer/auto-news

   Task Goal:
   Implement Phase 1: PDF extraction and citation enhancement

   Success Criteria:
   - [ ] PDFExtractor utility created
   - [ ] Enhanced summarization with citations
   - [ ] References section in articles
   - [ ] Tests passing

   💡 Next Steps:
   - Monitor: ssh ec2-dev 'tmux attach -t agent-pdf-citation-*'
   - Check logs: ssh ec2-dev 'tail -f ~/claude-agents/logs/agent-pdf-citation-*/session.log'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Status Indicators

- 🔄 **Running**: Agent actively executing
- ✅ **Complete**: Ready to retrieve
- ❌ **Failed**: Check logs for errors
- ⏸️  **Stalled**: No activity > 2 hours

## Actions by Status

### For Running Sessions:
```
💡 Monitor progress:
   ssh ec2-dev 'tmux attach -t agent-{task}-*'

   View logs:
   ssh ec2-dev 'tail -f ~/claude-agents/logs/agent-{task}-*/session.log'
```

### For Complete Sessions:
```
💡 Retrieve work:
   1. Ask Claude: "Please help me review the work from {branch}"
   2. Claude will:
      - Fetch the branch
      - Show what changed
      - Check success criteria
      - Suggest merge or refinement
```

### For Failed Sessions:
```
💡 Investigate:
   ssh ec2-dev 'cat ~/claude-agents/logs/agent-{task}-*/result.txt'
   ssh ec2-dev 'cat ~/claude-agents/logs/agent-{task}-*/exit_code.txt'

   Then discuss with Claude:
   - What went wrong?
   - Fix locally or re-launch with better scope?
```

### For Stalled Sessions:
```
⚠️  Session appears stalled (no activity for {duration})

💡 Check status:
   ssh ec2-dev 'tmux attach -t agent-{task}-*'

   If truly stuck:
   ssh ec2-dev 'tmux kill-session -t agent-{task}-*'

   Then discuss with Claude: Should we re-launch with refined task?
```

## Workflow

1. **List sessions:**
   ```bash
   /list-remotes
   ```

2. **See details:**
   ```bash
   /list-remotes --detail
   ```

3. **Check live status:**
   ```bash
   /list-remotes --check-remote
   ```

4. **For completed work:**
   ```
   User: "Please review the work from {branch-name}"

   Claude will:
   - Fetch branch
   - Show commits and file changes
   - Validate against success criteria
   - Run tests if needed
   - Suggest merge strategy
   ```

## Flags

- `--detail` or `-d`: Show detailed view with full task descriptions
- `--check-remote`: SSH to ec2-dev for live status (may be slow)
- No flags: Simple summary view

## Example: Retrieving Completed Work

Instead of a slash command, just have a conversation:

```
User: "The pdf-citation agent finished. Can you review the work?"

Claude:
  🔄 Fetching branch: main-remote-20251118-072718-pdf-citation

  📊 Changes:
    - 5 files modified
    - 847 lines added
    - 3 commits

  Commits:
    1. Add Docling PDF extractor
    2. Enhance summarization with citations
    3. Update article generation for References

  ✅ Success Criteria: 5/5 met
    ✓ PDFExtractor utility created
    ✓ Enhanced prompts with citation fields
    ✓ References section in articles
    ✓ Integration tests passing
    ✓ Git commits made

  Quality checks:
    ✓ Linting clean
    ✓ No merge conflicts with main
    ✓ Follows existing patterns

  💡 This looks good! Ready to merge into main?
```

## When Registry Exists

If `~/.claude/remotes/registry.json` exists (future enhancement), read it for additional metadata like:
- Estimated cost
- Actual duration
- Exit codes
- Custom notes

Otherwise, derive status from:
- Git branches
- Remote tmux sessions (if `--check-remote`)
- Handoff PLAN.md files

## Philosophy

Remote agent coordination is a conversation, not automation. This command provides **status visibility**, but retrieval and validation happen through **normal dialog with Claude**.

Why:
- Retrieval requires judgment (is work complete? good quality?)
- Validation needs context (what changed since handoff?)
- Merge strategy depends on situation (squash? ff? needs work?)
- Better handled conversationally than via rigid command

## Critical Launch Verification (Lesson Learned)

**ALWAYS verify the agent actually started** after handoff:

```bash
# Immediately after handoff, verify:
ssh ec2-dev 'tmux list-sessions | grep agent-'

# Expected output:
# agent-{task-name}-YYYYMMDD-HHMMSS: 1 windows (created Mon Nov 18 14:44:14 2024)

# If NO output → agent never started!
```

**Common launch issues:**
1. ❌ Untracked files blocking checkout
   - Fix: Launch script should `git stash --include-untracked` before checkout
2. ❌ Instructions displayed but not executed
   - Fix: Use checklist format, not prose
3. ❌ Got distracted between handoff and launch
   - Fix: Launch immediately, verify immediately

**Best practice:** After creating handoff materials, immediately execute launch and verify tmux session exists.

## Parallel vs Sequential Execution (Lesson Learned)

Before launching multiple agents in parallel, **map actual file modifications**:

```bash
# For each proposed agent task:
# 1. Identify which files will be modified
# 2. Check for overlaps

# Example analysis:
Agent 1: topic_pipeline.py (extract_content, parse_summary)
Agent 2: topic_pipeline.py (build_generation_context)
Agent 3: topic_pipeline.py (review_article)

# Verdict: OVERLAP DETECTED → Use sequential execution
```

**Decision framework:**
- ✅ **Parallel**: Different files/modules, no shared code
- ❌ **Parallel**: Same files, overlapping functions → merge conflicts
- ✅ **Sequential**: Build on each other's work, clean handoffs
- ✅ **Combined**: Naturally related tasks (e.g., PDF + Citations)

**Key insight:** Sequential execution on same branch often faster than parallel with merge conflicts.

## Planning ROI (Lesson Learned)

**Detailed PLAN.md = 10-14x ROI on planning time**

Invest 30 minutes creating comprehensive handoff plan with:
- ✅ Clear success criteria (checkboxes)
- ✅ Architectural boundaries (must/must-not)
- ✅ Implementation details with code snippets
- ✅ Specific file locations and line numbers
- ✅ Testing strategy

**Result:** Agent completes 6-8x faster than estimated, no exploration/backtracking needed.

**See:** `~/.claude/docs/remote-agent-best-practices.md` for detailed guidance
