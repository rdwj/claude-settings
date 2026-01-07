---
description: Break a large proposal into discrete phases through interactive dialog
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input: $ARGUMENTS

# Break Proposal Into Phases

## Purpose

Large proposals can be overwhelming and difficult to implement in one go. This command helps break a comprehensive proposal into manageable phases through interactive dialog, allowing incremental delivery and reducing risk.

## Process

### Step 1: Locate and Analyze the Proposal

If the user provided a proposal file path in $ARGUMENTS, use that. Otherwise:
1. List all files in the `proposals/` directory
2. If there's only one proposal, use it
3. If there are multiple proposals, ask the user which one to break into phases
4. If no proposals directory exists, inform the user and ask for the proposal file path

Once you have the proposal:
1. Read and analyze its full scope
2. Identify major components, features, infrastructure requirements, and concerns
3. Assess complexity and interdependencies

### Step 2: Present Phasing Strategy Options (Dimensionality)

Explain that there are different ways to phase a project, and present these options:

**A. Vertical Slice (Breadth-First)**
- Build one complete thread through the entire system for a minimal feature
- Phase 1: One feature working end-to-end (data layer → business logic → UI)
- Phase 2: Add more features using the same stack
- Phase 3+: Enterprise concerns (security, resilience, monitoring)
- **Best for**: Proving the architecture works, getting feedback early, reducing technical risk

**B. Horizontal Layers (Depth-First)**
- Build complete infrastructure layers before moving up the stack
- Phase 1: Complete data layer for all features
- Phase 2: Complete business logic for all features
- Phase 3: Complete UI for all features
- Phase 4+: Cross-cutting concerns
- **Best for**: When you have clear requirements, need complete foundations, or have specialized teams

**C. Feature-by-Feature (Component-Based)**
- Implement one complete feature at a time (all layers, enterprise-ready)
- Phase 1: Feature A (complete with security, error handling, tests)
- Phase 2: Feature B (complete)
- Phase 3: Feature C (complete)
- **Best for**: Independent features, parallel team work, incremental delivery to users

**D. Risk-First (Technical Complexity)**
- Tackle highest-risk/most-uncertain items first
- Phase 1: Proof of concepts for risky technical decisions
- Phase 2: Core complex features
- Phase 3: Simpler features
- Phase 4: Polish and optimization
- **Best for**: Projects with significant technical unknowns or new technologies

**E. Value-First (Business Priority)**
- Deliver highest business value features first
- Phase 1: Must-have MVP features
- Phase 2: High-value features
- Phase 3: Nice-to-have features
- Phase 4: Optimization and enhancement
- **Best for**: Tight deadlines, need to demonstrate value quickly, business-driven projects

**F. Hybrid Approach**
- Combine strategies (e.g., vertical slice for Phase 1, then feature-by-feature)
- Custom phasing based on specific project needs
- **Best for**: Complex projects that don't fit a single pattern

Ask the user: "Which phasing strategy (A-F) best fits your needs, or would you like a hybrid approach? You can also describe your own phasing preference."

### Step 3: Suggest Number of Phases

Based on the proposal's complexity and the chosen strategy, suggest an appropriate number of phases:

- Analyze the proposal's scope (features, infrastructure, concerns)
- Suggest 2-5 phases typically (more than 5 becomes harder to manage)
- Explain the rationale for the suggested number
- Provide brief descriptions of what each suggested phase might contain

Ask the user: "I suggest [N] phases for this project. Would you like to use this number, or do you have a different number in mind?"

### Step 4: Define Phase Breakdown

Based on the user's chosen strategy and number of phases:

1. **Propose a concrete breakdown**: Create a detailed outline of what goes in each phase
2. **Show the breakdown to the user** with:
   - Phase number and name
   - Goals and deliverables
   - Key features/components included
   - Dependencies on previous phases
   - Estimated complexity (relative)
3. **Ask for feedback**: "Does this breakdown work for you? Would you like to adjust what goes in each phase?"
4. **Iterate**: Adjust based on user feedback until they're satisfied

### Step 5: Create Phase Directory Structure

Once the user approves the breakdown:

1. Extract the proposal's base name (e.g., `auth-system-proposal.md` → `auth-system`)
2. Create directory structure:
   ```
   proposals/
   ├── auth-system-proposal.md (original)
   └── auth-system-phases/
       ├── phase-1-[short-name].md
       ├── phase-2-[short-name].md
       ├── phase-3-[short-name].md
       └── README.md
   ```

**IMPORTANT**: Use bash commands to check for existing directories before creating them to ensure non-destructive execution.

### Step 6: Generate Phase Documents

For each phase, create a markdown document with this structure:

```markdown
---
proposal: [original-proposal-name]
phase: [N]
phase_name: [Phase Name]
status: not-started
depends_on: [previous phase numbers, or "none"]
estimated_complexity: [low|medium|high]
created_date: [ISO 8601 timestamp]
---

# Phase [N]: [Phase Name]

> Part of: [Original Proposal Name]
> Dependencies: [Phase X must be complete] or [No dependencies]

## Phase Goals

[High-level goals for this phase - what should be achieved?]

## Scope

### In Scope
- [Item 1]
- [Item 2]
- [Item 3]

### Out of Scope
- [Explicitly list what is NOT included in this phase but may come later]

## Deliverables

### Features
- [Feature/capability 1]
- [Feature/capability 2]

### Infrastructure
- [Infrastructure component 1 if applicable]
- [Infrastructure component 2 if applicable]

### Technical Components
- [Component 1 with brief description]
- [Component 2 with brief description]

## Technical Approach

[High-level technical approach for this phase, referencing the original proposal where applicable]

## Dependencies

### Prerequisites
- [What must be completed before starting this phase]

### External Dependencies
- [Any external systems, APIs, or resources needed]

## Implementation Considerations

### Key Decisions
- [Important technical or architectural decisions for this phase]

### Risks & Mitigations
- **Risk**: [Description]
  - **Mitigation**: [How to address it]

### What We're Deferring
- [Things from the original proposal that are intentionally deferred to later phases]

## Testing Strategy

[How this phase will be tested - unit tests, integration tests, manual testing, etc.]

## Success Criteria

- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

## Estimated Effort

[Rough estimate: hours/days/weeks - or story points if using those]

## Notes

[Any additional context, warnings, or information]

## Link to Original Proposal

See: `../[original-proposal-name].md` for complete context and full system design.
```

### Step 7: Create Phase Directory README

Create a `README.md` in the phases directory that:
- Links to the original proposal
- Lists all phases with their status
- Shows dependencies between phases
- Provides a visual representation of the phasing strategy chosen

Example:
```markdown
# [Project Name] - Phased Implementation Plan

## Original Proposal
See: `../[original-proposal-name].md`

## Phasing Strategy
[Brief description of the chosen strategy: vertical slice, feature-by-feature, etc.]

## Phase Overview

| Phase | Name | Status | Dependencies | Complexity |
|-------|------|--------|--------------|------------|
| 1 | [Name] | not-started | None | Medium |
| 2 | [Name] | not-started | Phase 1 | High |
| 3 | [Name] | not-started | Phase 2 | Low |

## Phase Sequence

```
Phase 1: [Name]
    ↓
Phase 2: [Name]
    ↓
Phase 3: [Name]
```

## Implementation Notes

[Any overarching notes about implementing these phases]

## Rationale for Phasing

[Brief explanation of why this phasing approach was chosen]
```

### Step 8: Summarize and Next Steps

Provide the user with:
1. Path to the phases directory
2. List of all phase files created
3. Suggested next steps:
   - Review each phase document
   - Use `/write-stories` on individual phase documents to create user stories
   - Start with Phase 1 using `/implement-story` workflow
4. Reminder that phases can be adjusted as you learn more during implementation

## Example Dialog Flow

**Assistant**: I've analyzed your authentication system proposal. It's comprehensive with OAuth2 implementation, session management, MFA, audit logging, and role-based access control. This is a substantial project.

I see several ways we could break this into phases:

**A. Vertical Slice**: Get basic login working end-to-end first (one complete thread through the system), then add features
**B. Feature-by-Feature**: Complete OAuth2 fully, then sessions, then MFA, etc.
**C. Value-First**: Start with must-have login features, defer nice-to-have features
**D. Risk-First**: Tackle OAuth2 integration uncertainties first

Which approach fits best for your needs?

**User**: I think vertical slice - I want to prove the whole stack works with basic login before adding all the features.

**Assistant**: Great choice. For a vertical slice approach, I'm thinking 3 phases:

- **Phase 1: Basic Login Thread** (Medium complexity)
  - Simple email/password authentication
  - One working path through data → API → UI
  - Basic session management (no Redis yet)
  - Proves architecture works

- **Phase 2: Feature Expansion** (High complexity)
  - OAuth2 providers
  - Redis-based sessions
  - MFA support
  - Account recovery

- **Phase 3: Enterprise Hardening** (Medium complexity)
  - Comprehensive audit logging
  - Fine-grained RBAC
  - Security monitoring
  - Performance optimization

Does this breakdown work for you?

**User**: Yes, but I want to add password reset to Phase 1 since that's critical.

**Assistant**: Good call. I'll move password reset to Phase 1. Let me create the phase documents now...

[Creates directory structure and phase files]

✓ Created `proposals/auth-system-phases/`
✓ Generated 3 phase documents
✓ Created phase overview README

Next steps:
1. Review each phase document
2. When ready, use `/write-stories` on `phase-1-basic-login.md` to create user stories
3. Start implementing stories from Phase 1

## Notes

- Always preserve the original proposal - phases are additive documentation
- Phase documents should reference the original proposal for complete context
- Users can iterate on phases before starting implementation
- Phases can be adjusted based on learnings during implementation
- Not all proposals need phasing - only suggest this for complex projects
