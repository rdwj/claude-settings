# Implement User Story

{% if file %}
Please implement the user story at `{{file}}` by following the mandatory two-phase process: scaffolding first, then implementation.
{% else %}
Please implement all user stories in the backlog by following the mandatory two-phase process for each story.

**CRITICAL REQUIREMENTS**:
- Find all story files in the backlog directory (look for `backlog/`, `stories/backlog/`, or similar)
- Process up to 6 stories concurrently, BUT each story MUST complete Phase 1 before starting Phase 2
- **NEVER combine scaffolding and implementation into a single agent call** - always use two separate agents
- Parallelism applies ACROSS stories, not WITHIN a story's phases
- You are responsible for moving story files between directories as they progress
{% endif %}

## Mandatory Two-Phase Process

**IMPORTANT**: For EVERY story, regardless of complexity, you MUST:
1. Launch **story-scaffolder** agent and wait for completion
2. Then launch **scaffold-filler** agent

**DO NOT**:
- ❌ Tell story-scaffolder to "scaffold and implement"
- ❌ Skip scaffold-filler for "simple" stories
- ❌ Combine both phases into a single agent invocation

### Phase 1: Scaffolding (story-scaffolder agent)

Launch the **story-scaffolder** subagent to:

1. Read and analyze the user story
2. Create the structural skeleton for all needed components (classes, functions, methods, files)
3. Generate stub implementations with appropriate signatures and placeholder logic
4. Add TODO comments indicating what needs to be implemented
5. Ensure the scaffolding follows the project's architecture and patterns

**After Phase 1 completes**: YOU (the main agent) must move the story file from `backlog/` to `in-progress/`:
```bash
mv stories/backlog/story-NNNN-name.md stories/in-progress/
```

### Phase 2: Implementation (scaffold-filler agent)

After Phase 1 is complete, launch the **scaffold-filler** subagent to:

1. Review all created stubs and TODOs
2. Implement the actual logic for each stub
3. Add proper error handling and validation
4. Write appropriate tests for the implemented functionality
5. Update the user story checklist items as they are completed
6. Mark the story as complete when all acceptance criteria are met

**After Phase 2 completes**: YOU (the main agent) must move the story file from `in-progress/` to `done/`:
```bash
mv stories/in-progress/story-NNNN-name.md stories/done/
```

**If blocked**: Move the story to `blocked/` and stop working on it:
```bash
mv stories/in-progress/story-NNNN-name.md stories/blocked/
```

## Story File Movement Responsibility

**YOU (the implement-story agent) are responsible for ALL file movements**:

1. **Before Phase 1**: Story is in `backlog/`
2. **After Phase 1 completes**: YOU move story to `in-progress/`
3. **After Phase 2 completes**: YOU move story to `done/`
4. **If blocked at any point**: YOU move story to `blocked/`

**DO NOT**:
- Leave stories in multiple directories (only ONE location per story)
- Expect sub-agents to move files (they don't)
- Forget to move files after each phase

## Example Workflow for Multiple Stories

```
Story 0001:
  1. Launch story-scaffolder for 0001
  2. Wait for completion
  3. Move backlog/story-0001.md → in-progress/story-0001.md
  4. Launch scaffold-filler for 0001
  5. Wait for completion
  6. Move in-progress/story-0001.md → done/story-0001.md

Story 0002:
  1. Launch story-scaffolder for 0002
  2. Wait for completion
  3. Move backlog/story-0002.md → in-progress/story-0002.md
  4. Launch scaffold-filler for 0002
  5. Wait for completion
  6. Move in-progress/story-0002.md → done/story-0002.md

(Process up to 6 stories, but respect the two-phase sequence for each)
```

## Output

When complete, provide:

{% if file %}
- Summary of all files created or modified
- Confirmation that all acceptance criteria have been met
- Any notes about implementation decisions or trade-offs made
{% else %}
- Summary of all stories processed and their completion status
- List of files created or modified across all stories
- Any blockers encountered during parallel implementation
- Stories that require human review or additional attention
{% endif %}
