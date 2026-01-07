---
description: Create a detailed technical proposal using ideas, sketch, and tech-stack decisions
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input: $ARGUMENTS

# Propose - Create Technical Proposal

## Purpose

Create a comprehensive technical proposal for implementing the project, building on:
- Ideas from `/imagine` (requirements, vision, constraints)
- Architecture from `/sketch` (components, data flows, deployment)
- Technology decisions from `/tech-stack` (frameworks, databases, tools)

The proposal is where we get specific about implementation approach, APIs, data models, and deployment strategy - but we still leave specific package choices to the implementation phase.

## Process

### Step 1: Locate Context

**If user provided a project name in $ARGUMENTS:**
- Use that project name

**If no project name provided:**
1. Check for `ideas/` directory
2. List projects that have both sketch and tech-stack
3. If only one complete project, use it
4. If multiple, ask which one
5. If none complete, error with guidance

**Verify required context exists:**
- `ideas/[project]/` - ✓ Required (at minimum: README.md, requirements.md)
- `sketches/[project]-sketch.md` - ✓ Required
- `tech-stack/[project]-tech-stack.md` - ✓ Required

**If any missing:**
"Cannot create proposal without complete context:
- Missing ideas? Run `/imagine` first
- Missing sketch? Run `/sketch` first
- Missing tech-stack? Run `/tech-stack` first

Complete the upstream steps before running `/propose`."

### Step 2: Check for Context7 MCP

**Check if Context7 MCP is available:**

Look for `mcp__context7__*` tools in the available tools list.

**If available:**
- Note: "Context7 MCP detected - will use for framework documentation lookup"
- This helps avoid outdated API usage from training data

**If not available:**
- Note: "Context7 MCP not detected - will use best judgment for current APIs"
- Recommend installing Context7 MCP for better results

### Step 3: Launch Proposal Writer

Use the Task tool to launch the proposal-writer subagent with comprehensive instructions:

```
Create a detailed technical proposal for the [project-name] project.

## Required Context to Read

You MUST read these files before creating the proposal:

1. **Ideas Directory**: `ideas/[project-name]/`
   - Read at minimum: README.md, requirements.md, vision.md, scope.md, constraints.md
   - Optionally read conversation files for additional context
   - This provides the requirements and vision

2. **Architectural Sketch**: `sketches/[project-name]-sketch.md`
   - This defines the components, data flows, and system boundaries
   - Use this as the foundation for your technical approach

3. **Technology Stack**: `tech-stack/[project-name]-tech-stack.md`
   - This specifies the frameworks, databases, and major technologies chosen
   - You MUST use these technology choices - do not propose alternatives
   - **IMPORTANT**: Ignore any sections marked with `<!-- IGNORE_IN_PROPOSE -->` tags
   - These sections (like domain experts, UAT users) are for planning, not technical design

## Context7 MCP Usage

[IF AVAILABLE:]
Context7 MCP is available. Use it to look up current documentation for:
- [Framework 1] (version [X])
- [Framework 2] (version [X])
- [Database] (version [X])
- [Other major technologies from tech-stack]

This ensures you're using current APIs and best practices, not outdated patterns from training data.

[IF NOT AVAILABLE:]
Context7 MCP is not available. Use your best judgment for current API usage, but note where documentation lookup would be beneficial.

## Proposal Requirements

Create a proposal in `proposals/[project-name]-proposal.md` with these sections:

### Executive Summary
- Brief overview of what's being built and why
- Key technical decisions
- Implementation timeline estimate

### Problem Statement
- From ideas/ - what problem this solves
- Who it impacts
- Why this solution

### Proposed Solution
- Based on sketch - architectural overview
- How components work together
- Data flows and interactions

### Technical Approach

For each component from the sketch:

**Component Name**: [from sketch]
**Technology**: [from tech-stack]
**Responsibilities**: [from sketch]

**Implementation Details:**
- API design (endpoints, methods, request/response formats)
- Data models and schemas
- Integration points with other components
- State management approach
- Error handling strategy
- Security considerations

**Key Classes/Modules:** (high-level structure, not full implementation)

### Data Architecture
- Database schema design (tables, relationships, indexes)
- Data migration strategy
- Caching strategy
- Data retention policies

### API Specifications
- REST endpoints (or GraphQL schema, etc.)
- Authentication and authorization
- Rate limiting
- Versioning strategy

### Deployment Architecture
- Based on sketch and tech-stack
- Container specifications (Containerfile structure)
- Kustomize manifests structure (base + overlays)
- Environment variables and configuration
- Secrets management
- Health checks and probes

### Security Approach
- Authentication and authorization implementation
- Data encryption (at rest and in transit)
- Secrets management
- Compliance requirements (from ideas/constraints.md)
- Security testing approach

### Observability
- Logging strategy
- Metrics to collect
- Tracing approach
- Monitoring and alerting

### Testing Strategy
- Unit testing approach
- Integration testing
- End-to-end testing
- Performance testing
- Test coverage goals

### Implementation Phases
- Based on any phasing from sketch or ideas
- Phase 1: Minimum viable implementation
- Phase 2: Enhanced features
- Phase 3: Enterprise readiness
- What gets delivered in each phase

### Development Workflow
- Local development setup
- CI/CD pipeline
- Branching strategy
- Code review process

### Timeline and Effort Estimate
- Rough timeline for each phase
- Team size and composition needed
- Major milestones

### Risks and Mitigations
- Technical risks identified
- Mitigation strategies
- Contingency plans

### Open Questions
- What still needs to be decided
- Assumptions that need validation

## Critical Guidelines

**1. Use Technology from tech-stack.md:**
- Do NOT propose alternative frameworks or databases
- The technology decisions have already been made in `/tech-stack`
- Focus on HOW to implement using those choices

**2. Leave Specific Packages to Implementation:**
- Do NOT specify exact package names beyond major frameworks
- Examples of what NOT to include:
  - "Use python-dotenv for environment variables"
  - "Use pytest-cov for coverage"
  - "Use pydantic-settings for config"
- Instead say: "Environment variables will be managed using standard Python practices"
- Add note in proposal: "Specific package selections will be made during implementation based on current best practices and latest stable versions"

**3. Ignore Sections Marked for Exclusion:**
- Skip any content between `<!-- IGNORE_IN_PROPOSE -->` and `<!-- /IGNORE_IN_PROPOSE -->`
- These typically include domain experts lists, UAT user types, etc.
- They're planning information, not technical requirements

**4. Respect CLAUDE.md Standards:**
- The tech-stack has already accounted for CLAUDE.md preferences
- Apply them in your proposal (Podman, UBI images, FastAPI, etc.)

**5. Be Specific But Not Prescriptive:**
- Provide enough detail for implementation to begin
- Don't write the code in the proposal
- Describe what and why, not line-by-line how

**6. Use Diagrams:**
- Include Mermaid diagrams where helpful
- Sequence diagrams for complex interactions
- ER diagrams for data models
- Deployment diagrams

## Output

Place the completed proposal in: `proposals/[project-name]-proposal.md`

Return a summary of:
- What was proposed
- Key technical decisions made
- Any areas that need further exploration
- Path to the proposal file
```

### Step 4: Present Results

After proposal-writer completes:

"Proposal created: proposals/[project-name]-proposal.md

Using context from:
- Ideas: ideas/[project-name]/
- Architecture: sketches/[project-name]-sketch.md
- Tech stack: tech-stack/[project-name]-tech-stack.md

[Context7 MCP: Used / Not available]

Key aspects covered:
- Technical approach for each component
- API specifications
- Data architecture
- Deployment strategy
- Testing approach
- Implementation phases

Next steps:
- Review the proposal for completeness
- Run `/review` to validate against ARCHITECTURE.md and security standards
- After approval, run `/write-stories` to break into implementable work items
- Or run `/break-into-phases` if the proposal is complex and needs phasing"

## Notes

- **Builds on prior work**: Ideas → Sketch → Tech-stack → Propose
- **Technology locked**: Frameworks chosen in tech-stack, not reconsidered here
- **Specific packages deferred**: Only major frameworks in proposal, utilities during implementation
- **Context7 aware**: Uses MCP for current docs if available
- **IGNORE markers respected**: Skips planning sections not relevant to technical design
- **Detailed but not code**: Enough to implement, not actual implementation
- **Fresh context recommended**: Proposal-writer has its own context window for the heavy lifting

## Integration with Workflow

```
/imagine → /sketch → /tech-stack → /propose → /review → /write-stories → /implement-story
                                          ↓
                                    /break-into-phases (if complex)
```

The proposal is where ideas become actionable technical specifications, constrained by the architecture and technology choices made upstream.
