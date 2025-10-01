# Write User Stories from Proposal

Please analyze the proposal document at `{{file}}` and create atomic user stories in `/project-management/backlog/`.

## Requirements

1. **Create directory structure**: If `/project-management/backlog/` does not exist, create it non-destructively
2. **Story format**: Each story should be a markdown file with YAML frontmatter
3. **Naming convention**: Use format `YYYYMMDD-####-short-description.md` where #### is a zero-padded story number
4. **Atomicity**: Stories should be small enough that many can be worked on in parallel
5. **Dependencies**: If a story depends on another, note it in the frontmatter

## Story Template

Each story file should follow this structure:

```markdown
---
story_id: "####"
title: "Short descriptive title"
created: "YYYY-MM-DD"
status: "backlog"
dependencies: []  # or ["0021", "0042"] if there are dependencies
estimated_complexity: "low|medium|high"
tags: ["tag1", "tag2"]
---

# Story ####: [Title]

## Description

Clear description of what needs to be accomplished and why.

## Acceptance Criteria

- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

## Technical Notes

Any relevant technical details, implementation hints, or architectural considerations.

## AI Directives

**IMPORTANT**: As you work through this story, please mark checklist items as complete `[x]` as you finish them. This ensures that if we need to pause and resume work, we have a clear record of progress. Update the `status` field in the frontmatter when moving between stages (in-progress, ready-for-human-review, done, blocked).

## Dependencies

[If applicable, list story dependencies and explain why they must be completed first]
```

## Process

1. Read and analyze the proposal document
2. Break down the proposal into logical, atomic work units
3. Identify dependencies between stories
4. Create numbered story files in `/project-management/backlog/`
5. Ensure each story can be worked on independently (unless dependencies are noted)
6. Provide a summary of all created stories with their IDs and titles