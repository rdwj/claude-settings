---
description: Create a structured project briefing document for presenting to an audience
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input: $ARGUMENTS

# Brief - Create Structured Project Briefing

## Purpose

Transform exploratory project ideas into a formal briefing document suitable for:
- Presenting to project stakeholders
- Briefing new team members
- Documentation for governance or compliance
- Project initiation documentation
- Cross-functional alignment meetings

This is more structured than `/imagine` output but less technical than `/propose`. It's the "what and why" before the "how".

## Process

### Step 1: Locate Project Ideas

**If user provided a project name in $ARGUMENTS:**
- Use that project name
- Look for `ideas/[project-name]/`

**If no project name provided:**
1. List all directories in `ideas/`
2. If only one project exists, use it
3. If multiple projects exist, ask: "Which project should I create a briefing for?"
4. If no ideas directory exists, error: "No project ideas found. Run `/imagine` first to explore your project concept."

### Step 2: Read and Synthesize Ideas

Read all files in `ideas/[project-name]/`:
- All markdown files
- All conversation files to understand the evolution
- Pay special attention to requirements.md, scope.md, constraints.md

Synthesize into a clear, structured briefing that maintains the exploratory spirit while adding organizational clarity.

### Step 3: Create Briefing Document

Create `briefs/[project-name]-brief.md` with this structure:

```markdown
# Project Brief: [Project Name]

**Date:** [Current Date]
**Status:** Draft / Under Review / Approved
**Version:** 1.0
**Author:** [Leave blank for user to fill]
**Approver:** [Leave blank for user to fill]

---

## Document Purpose

This briefing document provides a comprehensive overview of the [Project Name] initiative, including objectives, scope, requirements, and constraints. It serves as the foundation for technical planning and implementation proposals.

---

## Executive Summary

[2-3 paragraphs summarizing the entire brief. Should be readable in 2 minutes and give a complete picture of what this project is about.]

---

## Background and Context

### Current Situation

[What exists today? What are people doing now? What systems are in place?]

### Problem Statement

[Clear articulation of the problem this project addresses. Who experiences it? What's the impact?]

### Business Driver

[Why are we doing this? What business need, opportunity, or mandate is driving this work?
- Regulatory compliance
- Market opportunity
- Operational efficiency
- Risk reduction
- Strategic initiative
- Customer demand]

---

## Project Objectives

### Primary Objective

[The main goal - what success looks like in one sentence]

### Secondary Objectives

1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

### Success Metrics

[How we measure whether objectives are achieved:
- Quantitative metrics (numbers, percentages, timelines)
- Qualitative indicators (user satisfaction, capability achieved)]

---

## Scope

### In Scope

[What this project WILL deliver:]

- [Item 1]
- [Item 2]
- [Item 3]

### Out of Scope

[What this project will NOT address (at least in initial phases):]

- [Item 1]
- [Item 2]
- [Item 3]

### Future Considerations

[Things that are out of scope now but may be addressed later:]

- [Future enhancement 1]
- [Future enhancement 2]

---

## Requirements

### Functional Requirements

[HIGH LEVEL, DECLARATIVE requirements describing what the system must do:]

1. **[Requirement Category 1]**
   - [Specific requirement]
   - [Specific requirement]

2. **[Requirement Category 2]**
   - [Specific requirement]
   - [Specific requirement]

**CRITICAL REMINDER**: Requirements should stay high-level and declarative:
- ✓ "Must support 10,000 concurrent users"
- ✓ "Must integrate with Active Directory for authentication"
- ✓ "Must export reports to PDF format"
- ✗ NOT "Implement a UserController class with login() method"
- ✗ NOT "Use Redis for session caching"

### Non-Functional Requirements

[Quality attributes and constraints:]

- **Performance**: [Response time, throughput, capacity requirements]
- **Security**: [Authentication, authorization, data protection needs]
- **Compliance**: [Regulations, standards, policies that must be met]
- **Availability**: [Uptime requirements, disaster recovery]
- **Scalability**: [Growth projections, scaling needs]
- **Usability**: [Accessibility requirements, user experience standards]
- **Maintainability**: [Supportability, documentation needs]

### Integration Requirements

[Systems, APIs, or services this must integrate with:]

- [System 1]: [Integration purpose and requirements]
- [System 2]: [Integration purpose and requirements]

---

## Stakeholders

### Primary Stakeholders

[People/groups with direct interest and decision-making authority:]

| Stakeholder | Role | Interest | Decision Authority |
|------------|------|----------|-------------------|
| [Name/Group] | [Role] | [What they care about] | [What they approve/decide] |

### End Users

[Who will actually use this system:]

- **[User Group 1]**: [Their needs and how they'll use it]
- **[User Group 2]**: [Their needs and how they'll use it]

### Impacted Parties

[Others who will be affected but aren't primary users:]

- [Group 1]: [How they're affected]
- [Group 2]: [How they're affected]

---

## Constraints and Assumptions

### Constraints

[Hard limitations that cannot be changed:]

- **Timeline**: [Fixed dates or deadlines]
- **Budget**: [Financial limitations]
- **Technical**: [Platform requirements, technology restrictions]
- **Regulatory**: [Compliance mandates]
- **Resource**: [Team size, skill limitations]
- **Infrastructure**: [Existing systems that must be used]

### Assumptions

[Things we're assuming to be true (but should validate):]

- [Assumption 1]
- [Assumption 2]
- [Assumption 3]

**NOTE**: If assumptions prove false, project scope or approach may need adjustment.

---

## Dependencies

### Upstream Dependencies

[Things that must be completed before this project can proceed:]

- [Dependency 1]: [Current status]
- [Dependency 2]: [Current status]

### Downstream Dependencies

[Projects or initiatives that depend on this being completed:]

- [Dependent project 1]
- [Dependent project 2]

### External Dependencies

[Outside factors beyond our control:]

- [External dependency 1]
- [External dependency 2]

---

## Risks and Issues

### Known Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|---------|-------------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [How we plan to address] |
| [Risk 2] | High/Med/Low | High/Med/Low | [How we plan to address] |

### Open Issues

[Questions or concerns that need resolution:]

1. [Issue 1]: [What needs to be decided/resolved]
2. [Issue 2]: [What needs to be decided/resolved]

---

## High-Level Approach

[Brief description of the general approach or strategy for solving this problem. This is NOT detailed technical design - that comes in `/propose`.]

### Guiding Principles

[Key principles that should guide implementation:]

- [Principle 1]: [Why this matters]
- [Principle 2]: [Why this matters]

### Phasing Strategy (if applicable)

[If this will be delivered in phases:]

- **Phase 1**: [Minimal viable capability - what it delivers]
- **Phase 2**: [Enhanced capabilities - what it adds]
- **Phase 3**: [Full vision - what it completes]

---

## Resource Requirements

### Team Composition (Estimated)

[Rough team needs - not specific people yet:]

- [Role 1]: [Number needed, skills required]
- [Role 2]: [Number needed, skills required]

### Infrastructure and Tools

[Systems, platforms, or tools that will be needed:]

- [Infrastructure need 1]
- [Tool need 1]

### Budget Considerations

[Rough order of magnitude for budget needs:]

- Personnel: [Estimate]
- Infrastructure: [Estimate]
- Tools/Licenses: [Estimate]
- External services: [Estimate]

---

## Timeline Estimate

[Very rough timeline - details come later:]

- **Discovery and Design**: [Timeframe]
- **Phase 1 Implementation**: [Timeframe]
- **Phase 2 Implementation**: [Timeframe]
- **Testing and Rollout**: [Timeframe]

**Total Estimated Duration**: [Timeframe]

**NOTE**: This is a preliminary estimate. Detailed planning will refine these timelines.

---

## Next Steps

### Immediate Actions

1. [Action 1 - who and when]
2. [Action 2 - who and when]
3. [Action 3 - who and when]

### Approval Process

[What approvals are needed to proceed:]

- [Approval 1]: [Approver name/role]
- [Approval 2]: [Approver name/role]

### Transition to Planning

After approval, the next steps are:

1. **Technical Proposal** (`/propose`): Develop detailed technical design and implementation plan
2. **User Story Breakdown** (`/write-stories`): Create atomic work items for implementation
3. **Team Formation**: Assign resources and roles
4. **Kickoff**: Begin Phase 1 planning and execution

---

## Appendix

### Research Summary

[Key findings from `/imagine` research phase:]

- [Finding 1]
- [Finding 2]
- Similar projects: [List]
- Market analysis: [Summary]

### Glossary

[Define any domain-specific terms or acronyms used in this brief:]

- **[Term 1]**: [Definition]
- **[Term 2]**: [Definition]

### Reference Materials

[Related documents, research, or resources:]

- Ideas directory: `ideas/[project-name]/`
- Related initiatives: [Links if applicable]
- Industry standards: [References if applicable]

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Author] | Initial draft |

---

**Questions or feedback on this brief?**

Contact: [Leave blank for user to fill]
```

### Step 4: Maintain Exploratory Context

While the brief is more structured than `/imagine` output, it should:

- Preserve uncertainties and open questions
- Acknowledge assumptions that need validation
- Include "we're not sure yet" statements where appropriate
- Reference the exploratory thinking from `/imagine`
- Not force premature decisions

### Step 5: Present and Iterate

Show the user:
1. Path to the created briefing document
2. Summary of key sections
3. What still needs to be filled in (author names, approvers, etc.)

Ask: **"Would you like me to adjust any sections? I can add more detail, restructure parts, or emphasize different aspects."**

### Step 6: Suggest Next Steps

```
Brief created: briefs/[project-name]-brief.md

This briefing document is ready for:
- Stakeholder review and approval
- Team briefings and alignment
- Governance documentation

Next steps:
- Review and refine sections as needed
- Fill in author and approver information
- Present to stakeholders for feedback
- After approval, run `/propose` for technical design
- Use `/write-stories` to break down into work items

The brief maintains your exploratory thinking while adding structure
for organizational processes.
```

## Notes

- **Purpose**: The brief is the "what and why" before the technical "how"
- **Audience**: Stakeholders, team members, governance bodies
- **Tone**: Professional but clear, structured but not rigid
- **Requirements**: Stay HIGH LEVEL and DECLARATIVE - no implementation details
- **Preserve uncertainty**: Don't force decisions that aren't ready yet
- **Reference `/imagine`**: Link back to exploratory thinking
- **Not a proposal**: This is NOT technical design - that comes in `/propose`
- **Living document**: Version and track changes as thinking evolves
