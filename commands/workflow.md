---
description: Show workflow overview and check current project status
---

# Workflow Status and Guide

## Purpose

Show the complete development workflow and check where the current project stands in that workflow. Use this command when:
- Onboarding to the workflow system
- Returning to a project after time away
- Checking what's been done and what's next
- Reminding yourself of the process

## Process

### Step 1: Display the Workflow

Show the user a succinct workflow overview:

```
Development Workflow
====================

1. /imagine [project]      → Explore ideas (creates: ideas/[project]/)
2. /sketch [project]       → Architecture design (creates: sketches/[project]-sketch.md)
3. /tech-stack [project]   → Choose technologies (creates: tech-stack/[project]-tech-stack.md)
4. /propose [project]      → Technical proposal (creates: proposals/[project]-proposal.md)
5. /write-stories {{file}} → User stories (creates: project-management/backlog/*.md)
6. /implement-story {{file}}→ Build & review (moves through: backlog → in-progress → done)

Optional branches:
  • /pitch or /brief - After /imagine for approvals
  • /review → /revise - Validate and refine proposals
  • /simplify or /break-into-phases - For complex proposals

Utility:
  • /ds - Decompose complex tasks
  • /scaffold-pm - Set up project management
```

**New: Interactive Design Workflow (Experimental)**

Alternative to /sketch → /tech-stack → /propose for iterative, conversation-driven design:

```
Interactive Design Commands
============================

/design              → Conversational diagram creation (iterates in same session)
                       Creates: design/diagrams/[name].md

/concept             → 1-2 page "what we're building" document
                       Creates: design/concept.md

/through-line        → Define MVP critical path (the "one thread through")
                       Creates: design/through-line.md

/parking-lot         → Capture future ideas by category
                       Creates: design/parking-lot.md

/architecture        → Generate ARCHITECTURE.md from design artifacts
                       Creates: ARCHITECTURE.md

When to use:
  • You want iterative, whiteboard-style design conversations
  • Multiple people iterating over days/weeks
  • Need to separate MVP from future enhancements upfront

Note: This workflow is experimental. Original workflow remains primary.
```

### Step 2: Check Current Directory

Analyze what exists in the current working directory:

**Check for:**
1. `project-management/` directory and structure
2. `ideas/` directory and projects within
3. `sketches/` directory and sketch files
4. `tech-stack/` directory and tech-stack files
5. `proposals/` directory and proposal files
6. `pitches/` directory and pitch files
7. `briefs/` directory and brief files
8. `design/` directory and artifacts (diagrams/, concept.md, through-line.md, parking-lot.md)
9. `ARCHITECTURE.md` at project root
10. Project management story files in backlog/in-progress/etc.

### Step 3: Present Status Report

Based on what you found, create a status report:

#### Project Management Setup

```
✓ Project management structure exists
  - Backlog: [X] stories
  - In Progress: [Y] stories
  - Ready for Review: [Z] stories
  - Done: [N] stories
```

or

```
✗ No project management structure found
  → Run /scaffold-pm to set up project tracking
```

#### Active Projects

For each project discovered, show its workflow status:

```
Project: [project-name]
  ✓ Ideas documented (ideas/[project]/)
    - [N] conversation sessions
    - Last updated: [date from file timestamps]
  ✓ Pitch created (pitches/[project]-pitch.md)
  ✓ Brief created (briefs/[project]-brief.md)
  ✓ Architecture sketched (sketches/[project]-sketch.md)
  ✓ Tech stack defined (tech-stack/[project]-tech-stack.md)
  ✓ Proposal created (proposals/[project]-proposal.md)
  ✗ No user stories yet

  → Next step: Run /write-stories to break proposal into stories
```

or for a project just started:

```
Project: [project-name]
  ✓ Ideas documented (ideas/[project]/)
    - [N] conversation sessions
    - Last updated: [date]
  ✗ No architectural sketch yet

  → Next step: Run /sketch to create architectural design
  → Or: Run /pitch or /brief if you need approval first
  → Or: Try /design for interactive, conversation-driven design
```

#### Interactive Design Artifacts (if using experimental workflow)

If `design/` directory exists:

```
Design Artifacts:
  ✓ Diagrams: [N] diagrams in design/diagrams/
  ✓ Concept document (design/concept.md)
  ✓ Through-line defined (design/through-line.md)
  ✓ Parking lot with [N] future ideas
  ✓ ARCHITECTURE.md at project root

  → Next step: Continue to /propose or /write-stories
```

#### Multiple Projects

If multiple projects are found:

```
Found [N] projects in various stages:

1. [project-1]: Ideas → Sketch → Tech Stack → Proposal ✓ (Ready for /write-stories)
2. [project-2]: Ideas ✓ (Next: /sketch)
3. [project-3]: Full proposal + [X] stories in progress
```

### Step 4: Suggest Next Actions

Based on the analysis, provide clear next steps:

**If nothing exists:**
```
🚀 Getting Started

This appears to be a new project or empty directory.

Start here:
1. Run /scaffold-pm to set up project management (if implementing work)
2. Run /imagine [project-name] to start exploring your project ideas
3. Or skip ideation and go straight to /sketch if you know what you're building
```

**If ideas exist but no sketch:**
```
📐 Ready for Architecture

You have project ideas documented. Next steps:

1. Run /sketch [project-name] to create architectural design
   - Or run /pitch first if you need approval/funding
   - Or run /brief first for governance documentation

Fresh context recommended: Start a new Claude Code session before running /sketch
```

**If sketch exists but no tech-stack:**
```
🔧 Ready for Technology Selection

Your architecture is sketched. Next step:

1. Run /tech-stack [project-name] to choose frameworks and technologies

Fresh context recommended: Start a new Claude Code session
```

**If tech-stack exists but no proposal:**
```
📝 Ready for Detailed Design

Your architecture and technology are defined. Next step:

1. Run /propose [project-name] to create detailed technical proposal

Fresh context recommended: Start a new Claude Code session
```

**If proposal exists but no stories:**
```
📋 Ready for Planning

Your proposal is complete. Next steps:

1. Run /review proposals/[project]-proposal.md to validate
2. After review, run /write-stories proposals/[project]-proposal.md
   - Or /break-into-phases if the proposal is large/complex
   - Or /simplify if the proposal is over-engineered
```

**If stories exist:**
```
💻 Ready for Implementation

You have [X] stories in backlog. Next steps:

1. Review stories in project-management/backlog/
2. Run /implement-story [story-file] to start implementing
3. Stories will flow: backlog → in-progress → ready-for-review → done
```

**If work is in progress:**
```
🔨 Implementation Underway

Current work:
- [X] stories in progress
- [Y] stories ready for review
- [Z] stories completed

Next steps:
- Continue with /implement-story for backlog items
- Run /post-review for completed work
- Run /approve to finalize reviewed stories
```

### Step 5: Workflow Tips

End with helpful tips:

```
💡 Workflow Tips

- Use fresh Claude Code sessions between major steps (imagine → sketch → tech-stack → propose)
  This keeps context focused and prevents overwhelming the context window

- Each phase builds on the previous:
  ideas → sketch → tech-stack → propose → stories → implementation

- Optional branches:
  - /pitch or /brief after /imagine for approval
  - /simplify after /review if proposal is over-engineered
  - /break-into-phases after /review if proposal is complex

- Subagents do the heavy lifting:
  - pitch-writer, brief-writer for documentation
  - proposal-writer for technical design
  - research-analyst for technology research

- Project management:
  - Use ./project-management/scripts/promote.sh to move stories through states
  - Keep stories atomic and parallelizable

Need more detail? See ~/.claude/README.md for complete documentation.
```

## Output Format

Keep the output:
- **Visual**: Use ASCII diagrams, checkmarks (✓), X marks (✗), and emojis
- **Scannable**: Clear sections with headers
- **Actionable**: Always end with "Next steps"
- **Concise**: Don't overwhelm - focus on what matters for current state

## Notes

- This command is informational only - it doesn't modify anything
- If the user is in a monorepo with multiple projects, show status for each
- If no projects are found, assume they're starting fresh
- Be encouraging and clear about next steps
- Remind about fresh context for major phase transitions
- Don't assume project names - discover them from directory structure
