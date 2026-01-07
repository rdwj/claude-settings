---
description: Create a persuasive pitch document from project ideas for investors or management approval
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input: $ARGUMENTS

# Pitch - Create Investment/Approval Presentation

## Purpose

Transform exploratory project ideas into a persuasive pitch document suitable for:
- Presenting to investors for funding
- Requesting management approval and budget
- Getting executive sponsorship
- Securing resources and team allocation

This command reads from `ideas/[project]/` and creates a compelling narrative focused on value, opportunity, and return.

## Process

### Step 1: Locate Project Ideas

**If user provided a project name in $ARGUMENTS:**
- Use that project name
- Look for `ideas/[project-name]/`

**If no project name provided:**
1. List all directories in `ideas/`
2. If only one project exists, use it
3. If multiple projects exist, ask: "Which project should I create a pitch for?"
4. If no ideas directory exists, error: "No project ideas found. Run `/imagine` first to explore your project concept."

### Step 2: Read and Synthesize Ideas

Read all files in `ideas/[project-name]/`:
- README.md
- problem.md
- vision.md
- requirements.md
- stakeholders.md
- constraints.md
- research.md
- All conversation files to understand the evolution

Synthesize the thinking into a coherent narrative focused on:
- **Problem significance** - Why this matters, what's the pain
- **Opportunity size** - Market potential, number of users affected
- **Competitive advantage** - What makes this different/better
- **Value proposition** - What stakeholders gain
- **Feasibility** - Why this is achievable
- **Return on investment** - Time, money, or impact

### Step 3: Create Pitch Document

Create `pitches/[project-name]-pitch.md` with this structure:

```markdown
# [Project Name]: [Compelling One-Line Description]

**Pitch Date:** [Current Date]
**Status:** Draft / Ready for Review / Presented
**Audience:** [Investors / Executive Leadership / Department Heads / etc.]

---

## Executive Summary

[2-3 paragraphs that tell the complete story in brief. This should be compelling enough to stand alone. Cover: the problem, the solution, why now, and what you're asking for.]

---

## The Problem

### Current State

[Describe the painful status quo. What's broken? Who's affected? What's the cost of doing nothing?]

### Impact

[Quantify the problem where possible:
- Number of people/teams affected
- Time wasted
- Money lost
- Opportunities missed
- Risk or compliance concerns]

### Why Now

[Why is this problem urgent? What's changed? Why can't we wait?]

---

## The Solution

### Vision

[Paint a picture of the desired end state. What becomes possible? What changes for users?]

### How It Works

[High-level description of the solution approach - NOT technical implementation. Explain in terms a non-technical stakeholder can understand.]

### Key Capabilities

- [Capability 1 and the value it provides]
- [Capability 2 and the value it provides]
- [Capability 3 and the value it provides]

---

## Why This Wins

### Competitive Landscape

[What exists today? What are people using? What's inadequate about current solutions?]

### Our Advantage

[What makes this solution different or better?
- Unique approach
- Better user experience
- Lower cost
- Faster implementation
- Strategic fit with existing systems
- Proprietary knowledge or capability]

### Market Validation

[Evidence this is needed:
- User research findings
- Similar successful projects elsewhere
- Growing market trends
- Stakeholder feedback]

---

## Who Benefits

### Primary Users

[Who will use this day-to-day? What do they gain?]

### Stakeholders

[Who else benefits?
- Management: [benefits]
- Customers: [benefits]
- Other teams: [benefits]
- Organization: [benefits]]

---

## Return on Investment

### Value Delivered

[Quantify benefits where possible:
- Time savings: X hours per week per user
- Cost reduction: $Y annually
- Revenue opportunity: $Z
- Risk mitigation: [describe]
- Efficiency gains: [percentage improvement]
- Compliance achievement: [requirements met]]

### Resource Requirements

[What's needed to make this happen:
- Team size and composition
- Timeline estimate
- Budget (if known)
- Infrastructure or tools
- External dependencies]

### Break-Even Analysis

[When does this pay for itself? Or why is this strategic beyond pure ROI?]

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|---------|-----------|
| [Risk 1] | Low/Med/High | Low/Med/High | [How we address it] |
| [Risk 2] | Low/Med/High | Low/Med/High | [How we address it] |

---

## Implementation Approach

### Phased Rollout

[If applicable, show how this can be delivered incrementally:
- Phase 1: [Minimum viable implementation - delivers X value]
- Phase 2: [Enhanced capabilities - delivers Y additional value]
- Phase 3: [Full vision - delivers complete solution]]

### Timeline

[Rough timeline:
- Design and planning: X weeks
- Phase 1 delivery: Y weeks
- Phase 2 delivery: Z weeks
- Full deployment: N months]

### Success Criteria

[How will we measure success?
- Adoption metrics
- Performance metrics
- Business metrics
- User satisfaction indicators]

---

## The Ask

[Be specific about what you need:
- Approval to proceed with [phase/project]
- Budget allocation of $X
- Team resources: Y developers, Z analysts
- Executive sponsorship from [role]
- Timeline commitment to start by [date]]

---

## Appendix

### Research Summary

[Key findings from market research and competitive analysis]

### Constraints

[Important limitations or requirements:
- Compliance needs
- Integration requirements
- Timeline constraints
- Budget limitations]

### Open Questions

[What still needs to be explored or decided]

---

**Next Steps:**

After approval:
1. Run `/brief` to create a detailed project briefing
2. Run `/propose` to create technical proposal
3. Begin Phase 1 planning and team formation
```

### Step 4: Tailor to Audience

Before finalizing, ask the user: **"Who is the primary audience for this pitch?"**

Options:
- **Venture Capital / Investors**: Emphasize market size, competitive advantage, scalability, return
- **Executive Leadership**: Focus on strategic alignment, organizational benefit, risk mitigation
- **Department Management**: Highlight operational efficiency, team productivity, cost savings
- **Technical Leadership**: Balance business value with technical feasibility and innovation

Adjust tone, emphasis, and metrics based on audience.

### Step 5: Present and Iterate

Show the user:
1. Path to the created pitch document
2. Brief summary of the narrative arc
3. Suggestions for strengthening the pitch

Ask: **"Would you like me to adjust anything? I can strengthen certain sections, add more data, or change the emphasis based on your audience."**

### Step 6: Suggest Next Steps

```
Pitch created: pitches/[project-name]-pitch.md

When you're ready:
- Review and refine the pitch based on your audience
- Run `/brief` to create a structured project briefing
- Run `/propose` to develop the technical proposal
- Present to stakeholders and gather feedback
- Return to `/imagine` if you need to explore aspects further

Good luck with your pitch!
```

## Example Output

For a "TechDebtTracker" project explored via `/imagine`:

```
Created: pitches/TechDebtTracker-pitch.md

Key narrative:
- Problem: Teams can't prioritize technical debt, costing 20-30% of dev capacity
- Solution: Visual debt tracking with cost quantification and prioritization
- Value: Recover 15% of engineering time, reduce system risk, improve planning
- Ask: Approve 6-week Phase 1 with 3-person team for MVP

The pitch emphasizes ROI through recovered engineering time and reduced
system risk. Tailored for engineering leadership approval.

Want me to adjust anything before you present this?
```

## Notes

- Keep the pitch focused on value and opportunity, not technical details
- Use clear, non-technical language for broader audiences
- Quantify benefits wherever possible (even rough estimates are helpful)
- Address risks honestly but show you've thought about mitigation
- Make the ask specific and achievable
- Show you've done your homework (research, competitive analysis)
- Tell a compelling story: problem → opportunity → solution → value
