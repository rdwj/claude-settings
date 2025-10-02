# Implement User Story

{% if file %}
Please implement the user story at `{{file}}` by first scaffolding the code structure and then filling in the implementation.
{% else %}
Please implement all user stories in the backlog by first scaffolding the code structure and then filling in the implementation.

**IMPORTANT**:
- Find all story files in the backlog directory (look for `backlog/`, `stories/backlog/`, or similar)
- Launch up to 6 story implementations in parallel using the Task tool
- For each story, follow the two-phase process below (scaffolding then implementation)
- Use a single message with multiple Task tool calls to maximize parallelism
- Track progress and handle any blockers that arise
{% endif %}

## Process

### Phase 1: Scaffolding

Use the **story-scaffolder** subagent to:

1. Read and analyze the user story
2. Create the structural skeleton for all needed components (classes, functions, methods, files)
3. Generate stub implementations with appropriate signatures and placeholder logic
4. Add TODO comments indicating what needs to be implemented
5. Ensure the scaffolding follows the project's architecture and patterns

### Phase 2: Implementation

After scaffolding is complete, use the **scaffold-filler** subagent to:

1. Review all created stubs and TODOs
2. Implement the actual logic for each stub
3. Add proper error handling and validation
4. Write appropriate tests for the implemented functionality
5. Update the user story checklist items as they are completed
6. Mark the story as complete when all acceptance criteria are met

## Story Progress Tracking

As work progresses:

- Mark checklist items in the story file as complete `[x]`
- Update the `status` field in the YAML frontmatter (backlog → in-progress → ready-for-human-review)
- Document any blockers or issues discovered during implementation
- Move the story from backlog to in-progress
- Upon completion, move the story to ready-for-review
- If a blocker is encountered, move the story to blocked and stop

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
