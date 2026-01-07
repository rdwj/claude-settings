# Architecture Command

You are helping the user create a high-level ARCHITECTURE.md file based on their design artifacts.

## Context

After design sessions produce diagrams, concepts, and through-lines, the user needs a canonical architecture document that:
- Captures architectural decisions and rationale
- Defines system boundaries and components
- Establishes integration patterns
- References design artifacts without repeating them
- Stays high-level (architectural principles, not implementation details)

This becomes the reference document for development and future architectural decisions.

## Your Task

**Create `ARCHITECTURE.md` at the project root based on design artifacts**

## Process

### 1. Gather Design Artifacts

Read everything in `design/`:
- `design/concept.md` - The problem and solution overview
- `design/diagrams/*.md` - Visual architecture
- `design/through-line.md` - The critical path
- `design/parking-lot.md` - Future considerations

If any are missing, ask the user to run those commands first.

### 2. Ask Clarifying Questions

If architectural details are unclear:
- "What are the major architectural patterns? (microservices, monolith, event-driven, etc.)"
- "Any specific architectural constraints or requirements?"
- "What are the integration points with external systems?"

**Keep it brief** - 2-3 questions max.

### 3. Write the Architecture Document

Structure:

**## Overview**
- 2-3 sentences: System architecture at highest level
- Reference the concept document

**## Architectural Principles**
- Key decisions and why they were made
- Patterns being followed (e.g., API-first, event-driven, etc.)
- Constraints and requirements

**## System Components**
- Major components and their responsibilities
- Reference architecture diagrams
- Keep descriptions high-level

**## Integration Patterns**
- How components communicate
- External service integrations
- Data flow patterns

**## Technology Stack (High-Level)**
- Categories only (database, message queue, etc.)
- NOT specific versions or implementation details
- Why these categories were chosen

**## Key Architectural Decisions**
- Important decisions and their rationale
- Trade-offs considered
- ADRs (Architecture Decision Records) if applicable

**## Design References**
- Links to design artifacts in `design/`
- Brief description of each

### 4. Keep It Architectural

**Include:**
- System structure and boundaries
- Component responsibilities
- Integration patterns
- Architectural principles and constraints
- Key decisions and rationale

**Exclude:**
- Implementation details (specific versions, config)
- Code-level patterns (those go in PATTERNS.md)
- Deployment specifics (those go in deployment docs)
- Feature lists (those are in concept.md)

### 5. Style Guidelines

- Clear and definitive (this is the architecture)
- Explain "why" behind major decisions
- Use diagrams by reference, don't redraw
- Future-proof (avoid version numbers, specific tools)
- Concise (3-5 pages maximum)

## Document Structure

```markdown
# Architecture

## Overview

[2-3 sentence summary of the system architecture]

See [Concept Document](design/concept.md) for problem statement and solution overview.

## Architectural Principles

### [Principle 1]
[Why this principle and what it means for the system]

### [Principle 2]
[Why this principle and what it means for the system]

## System Components

### [Component Name]
**Responsibility:** [What this component does]
**Boundaries:** [What it does NOT do]

### [Component Name]
**Responsibility:** [What this component does]
**Boundaries:** [What it does NOT do]

See [Architecture Diagram](design/diagrams/architecture.md) for visual representation.

## Integration Patterns

### Internal Communication
[How components talk to each other]

### External Integrations
[How system integrates with external services]

### Data Flow
[How data moves through the system]

See [Data Flow Diagram](design/diagrams/data-flow.md) for details.

## Technology Stack (High-Level)

### Data Storage
- **[Category]:** [Why this choice]

### Communication
- **[Category]:** [Why this choice]

### Processing
- **[Category]:** [Why this choice]

## Key Architectural Decisions

### Decision: [Decision Title]
**Context:** [Why this decision was needed]
**Decision:** [What was decided]
**Rationale:** [Why this approach]
**Trade-offs:** [What was considered and rejected]

### Decision: [Decision Title]
**Context:** [Why this decision was needed]
**Decision:** [What was decided]
**Rationale:** [Why this approach]

## Constraints and Requirements

- [Constraint or requirement and its architectural impact]
- [Constraint or requirement and its architectural impact]

## Design References

- **[Concept](design/concept.md)** - System overview and problem statement
- **[Through-Line](design/through-line.md)** - MVP critical path
- **[Architecture Diagram](design/diagrams/architecture.md)** - Visual architecture
- **[Parking Lot](design/parking-lot.md)** - Future enhancements
```

## Example Section

```markdown
## System Components

### Content Discovery Engine
**Responsibility:** Identifies trending topics and research sources relevant to nutrition
**Boundaries:** Does NOT generate content or publish results; only discovers and curates topics

### Content Generation Service
**Responsibility:** Transforms curated topics into draft blog articles using AI
**Boundaries:** Does NOT publish or distribute; produces drafts for review

### Publishing Service
**Responsibility:** Handles final publishing to target platforms (Medium, blog, etc.)
**Boundaries:** Does NOT modify content; only handles distribution

See [Architecture Diagram](design/diagrams/nutrition-blog-architecture.md) for visual representation.
```

## Key Principles

1. **Architectural, not implementation** - Focus on structure and decisions
2. **Reference, don't repeat** - Point to design docs instead of duplicating
3. **Explain decisions** - Always include rationale
4. **Define boundaries** - Clear component responsibilities
5. **Stay current** - This is the living architectural truth

## After Creating

Once ARCHITECTURE.md is saved:
- Show a summary of key architectural decisions
- Ask: "Does this capture the architecture correctly?"
- Suggest: "Next we can create PATTERNS.md for development patterns"
