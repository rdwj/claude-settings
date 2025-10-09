# Concept Command

You are helping the user create a concise concept document that explains what they're building.

## Context

After design sessions produce diagrams, the user needs a written document that:
- Explains the problem and solution at a high level
- References the design artifacts created
- Stays conceptual (not implementation details)
- Fits on 1-2 pages

This document helps communicate the vision to others and serves as a reference point.

## Your Task

**Create a 1-2 page concept document in `design/concept.md`**

## Process

### 1. Gather Context

Check for existing design artifacts:
- Look in `design/diagrams/` for architecture diagrams
- Check if `design/concept.md` already exists (iteration vs. new)
- Ask the user for any additional context needed

### 2. Ask Clarifying Questions

If information is missing, ask:
- What problem does this solve?
- Who is this for?
- What's the core value proposition?
- Any important constraints or requirements?

**Keep it brief** - 2-3 questions max.

### 3. Write the Concept Document

Structure the document with these sections:

**## Overview**
- 2-3 sentences: What is this and what problem does it solve?

**## Problem Statement**
- What's the current pain point or opportunity?
- Why does this matter?

**## Solution Approach**
- High-level description of how the system works
- Reference the architecture diagram(s)
- Key components and their roles

**## Key Capabilities**
- What can this system do? (bulleted list)
- Focus on outcomes, not implementation

**## Design Artifacts**
- List and link to diagrams in `design/diagrams/`
- Brief description of each

### 4. Keep It Concise

**Length guidelines:**
- Overview: 2-3 sentences
- Problem Statement: 1 paragraph
- Solution Approach: 2-3 paragraphs
- Key Capabilities: 5-8 bullets
- Design Artifacts: Simple list

**Total: 1-2 pages when rendered**

### 5. Style Guidelines

- Use clear, jargon-free language
- Focus on "what" and "why", not "how"
- Avoid implementation details (specific technologies, APIs, etc.)
- Think "executive summary" not "technical spec"

## Example Structure

```markdown
# [Project Name] - Concept

## Overview

[2-3 sentence description of what this is and the problem it solves]

## Problem Statement

[1 paragraph explaining the pain point or opportunity]

## Solution Approach

[High-level description of how the system addresses the problem]

![Architecture Diagram](diagrams/example-architecture.md)

[Explanation of key components and flow]

## Key Capabilities

- Capability 1
- Capability 2
- Capability 3
- Capability 4
- Capability 5

## Design Artifacts

- **[Diagram Name](diagrams/diagram-file.md)** - Brief description
- **[Diagram Name](diagrams/other-diagram.md)** - Brief description

## Next Steps

[Optional: What needs to happen next in the design/development process]
```

## Key Principles

1. **Clarity over completeness** - It's OK to leave out details
2. **Conceptual, not technical** - Save implementation for later docs
3. **1-2 pages maximum** - Force yourself to be concise
4. **Reference, don't repeat** - Point to diagrams instead of describing them in detail
5. **Iterative** - Can be refined as design evolves

## After Creating

Once the concept document is saved:
- Show the user a summary
- Ask if any sections need refinement
- Suggest next steps (e.g., defining through-line, architecture patterns)
