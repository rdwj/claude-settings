---
description: Explore and ideate on project concepts through iterative dialog
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input: $ARGUMENTS

# Imagine - Project Ideation and Exploration

## Purpose

This command supports the organic, iterative process of formulating project ideas. Like having a series of coffee conversations over days or weeks, it helps you explore problems, envision solutions, and refine thinking before committing to formal proposals.

**This is the first step in the workflow** - use this before `/pitch`, `/brief`, or `/propose`.

## Process

### Step 1: Understand Context

**Check the current working directory:**

1. **Empty directory**: Starting a brand new project - proceed to fresh start
2. **Has `ideas/` directory**: We have existing ideation work - ask which project or if starting new
3. **Monorepo with multiple projects**: Ask which project we're ideating on
4. **Regular repo with existing code**: Ask: "Are we starting a fresh idea, or iterating on this existing project?"

**If continuing existing ideation:**
- Read all files in `ideas/[project-name]/`
- Summarize current thinking: "Welcome back! Here's where we left off..."
- List recent conversation dates
- Highlight open questions from `next-steps.md`
- Ask: "What new thoughts have you had since we last talked?"

**If starting fresh:**
- Proceed to Step 2

### Step 2: Initial Research (New Projects Only)

Before diving into ideation, ask: **"What are you calling this project for now? (We can change the name later as ideas evolve)"**

Use the provided name to:

1. **Search GitHub** for similar projects, relevant libraries, and related tools
2. Present findings conversationally:
   - "I found these similar projects..."
   - "Here are some libraries that might be relevant..."
   - "This organization is doing something related..."
3. Ask: **"Should we leverage any of these, or are we intentionally doing something different?"**

Capture findings in `ideas/[project-name]/research.md`

**For existing projects:** Ask if they want fresh research: "Want me to search GitHub again to see if anything new has emerged?"

### Step 3: Market Research (When Appropriate)

After GitHub research, ask: **"Would you like me to do broader market research beyond GitHub?"**

If yes, search for:
- Commercial products in this space
- Market trends and analysis
- User needs and pain points being discussed
- Industry solutions and approaches

Add findings to `research.md` under a "Market Research" section.

### Step 4: Exploratory Dialog

Have a natural, coffee-conversation style dialog covering these areas. **Don't make this feel like a questionnaire** - let it flow naturally based on what the user shares:

**The Spark**
- What got you thinking about this?
- What's the frustration or opportunity you see?

**The Problem Space**
- Who's experiencing pain? What specifically hurts?
- What's the current state? What do people do today?
- What sucks about existing solutions?
- What's the impact of this problem?

**The Vision**
- What would be amazing? What changes?
- What does the ideal end state look like?
- What becomes possible that isn't today?

**Who Benefits**
- Who are the users/stakeholders?
- What do they need? What do they care about?
- Who else is affected (positively or negatively)?

**Success Metrics**
- How do we know this worked?
- What would make you say "yes, this is exactly what we needed"?

**Scope Boundaries**
- What's in scope for this project?
- What are we explicitly NOT doing? (at least not now)
- Where do the boundaries lie?

**Requirements (HIGH LEVEL ONLY)**
- What are the must-haves? (e.g., "Needs 508 compliance", "Must integrate with Active Directory")
- What constraints matter? (e.g., "Has to run in FIPS mode", "Response time under 100ms")
- **CRITICAL**: Keep requirements DECLARATIVE and HIGH LEVEL
- **DO NOT** include implementation details, pseudocode, or technical solutions
- **DO NOT** specify classes, functions, or architectural patterns
- Requirements should be things like:
  - "Must support 10,000 concurrent users"
  - "Has to have a button that goes beep"
  - "Needs to export to PDF"
  - "Must comply with HIPAA"

**NOT** like:
  - "Implement a UserService class with authenticate() method"
  - "Use Redis for session management"
  - "Create a REST API with these endpoints..."

**Gut Checks**
- What excites you about this?
- What worries you?
- What's uncertain or unclear?
- What assumptions are we making?

**Constraints**
- Timeline or urgency?
- Budget considerations?
- Compliance requirements?
- Integration points or dependencies?
- Scale considerations?

### Step 5: Capture and Organize Thoughts

Create or update files in `ideas/[project-name]/`:

**Always create/update:**
- `README.md` - Project overview and current thinking (for someone new)
- `conversation-YYYYMMDD-HHMMSS.md` - Today's dialog notes with timestamp
- `next-steps.md` - Open questions and things to explore next

**Create/update as relevant:**
- `problem.md` - Problem space exploration
- `vision.md` - Desired end state, what success looks like
- `research.md` - GitHub and market research findings
- `requirements.md` - HIGH LEVEL, DECLARATIVE requirements only
- `scope.md` - What's in and out of scope
- `constraints.md` - Limitations, timeline, compliance needs
- `stakeholders.md` - Who benefits, who's affected, user personas
- `assumptions.md` - What we're assuming to be true
- `risks.md` - What could go wrong, uncertainties
- `name-ideas.md` - Potential names for the project (if discussed)

**IMPORTANT**: Files should feel like notes from a conversation, not formal documentation. Use casual language, capture uncertainties, include "we're not sure about X yet" statements.

### Step 6: Directory Structure

Create this structure:

```bash
ideas/
└── [project-name]/
    ├── README.md
    ├── conversation-YYYYMMDD-HHMMSS.md
    ├── next-steps.md
    ├── problem.md
    ├── vision.md
    ├── research.md
    ├── requirements.md
    ├── scope.md
    ├── constraints.md
    ├── stakeholders.md
    └── [other files as needed]
```

Use bash commands to check for existing directories before creating them to ensure non-destructive execution.

### Step 7: Wrap Up and Encourage Reflection

End the session with:

1. **Summary of what we captured:**
   ```
   Great session! Here's what we explored today:
   - Updated: problem.md, vision.md, requirements.md
   - Added: conversation-20251001-143022.md
   ```

2. **Open questions to think about:**
   ```
   Open questions to ponder:
   - How should we handle authentication?
   - Cloud or on-prem deployment?
   - What's the pricing model?
   ```

3. **Offer to continue OR encourage stepping away:**
   ```
   Want to keep going and explore more?

   Or, take some time away from this - some of the best ideas come
   when you step back and let your mind work on it. Come back fresh
   when new thoughts hit you. Sometimes the best projects take days
   or weeks of this kind of iterative thinking.
   ```

4. **Next steps when ready:**
   ```
   When you're ready to move forward:
   - `/imagine` again - Continue exploring and refining ideas
   - `/pitch` - Create a persuasive pitch for investors/management
   - `/brief` - Create a structured briefing document
   - `/propose` - Create a detailed technical proposal
   ```

## Supporting Project Renaming

If the user wants to rename the project:

1. **Ask for the new name**: "What should we call this project now?"
2. **Rename the directory**: Move `ideas/[old-name]/` to `ideas/[new-name]/`
3. **Update README.md**: Change project name references
4. **Add note to conversation file**: Document the rename decision
5. **Confirm**: "Renamed project from [old-name] to [new-name]"

User can request rename by saying things like:
- "Let's call this [new-name] instead"
- "Rename this project to [new-name]"
- "I want to change the name to [new-name]"

## Handling Multiple Ideation Sessions

Each time `/imagine` runs on the same project:

1. Read all existing files
2. Show a brief summary of previous conversations
3. Highlight what's been discussed and what's open
4. Ask what they want to explore today
5. Build on previous thinking, don't start over
6. Create a new `conversation-YYYYMMDD-HHMMSS.md` file for this session

## Example Dialog Flow

**Assistant**: I notice you have an empty directory. Are we starting a new project idea from scratch?

**User**: Yes, I want to build a system to help developers track technical debt.

**Assistant**: Love it. Before we dive in, what should we call this project for now? (We can always change it later)

**User**: Let's call it TechDebtTracker for now.

**Assistant**: Perfect. Let me search GitHub to see if there are similar projects we should know about...

[Searches and presents findings]

I found several issue trackers and code quality tools, but nothing specifically focused on technical debt tracking with the context and prioritization features you might envision.

Should we leverage any existing libraries, or are we building something intentionally different?

**User**: We're building something different - existing tools treat tech debt like bugs, but it needs its own workflow.

**Assistant**: Great insight. So what got you thinking about this? What's frustrating about how technical debt is handled today?

**User**: Teams know they have tech debt but can't articulate the cost or prioritize it against features. It's just this vague cloud of "we should refactor that someday."

**Assistant**: That's a real pain point. Who feels this most - developers, managers, or both?

[Conversation continues naturally...]

**Assistant**: This has been a great session. Here's what we captured:

Created:
- ideas/TechDebtTracker/README.md
- ideas/TechDebtTracker/problem.md
- ideas/TechDebtTracker/vision.md
- ideas/TechDebtTracker/requirements.md
- ideas/TechDebtTracker/research.md
- ideas/TechDebtTracker/conversation-20251001-143022.md
- ideas/TechDebtTracker/next-steps.md

Some questions to think about:
- How do we quantify the cost of technical debt?
- Should this integrate with existing project management tools?
- What's the minimum viable version?

Want to keep exploring, or take some time to think about it?

**User**: I'll think about it and come back.

**Assistant**: Sounds good. Some of the best projects evolve over days or weeks of thinking. Come back when new ideas hit you. When you're ready:
- `/imagine` to continue exploring
- `/pitch` to create an investor/approval pitch
- `/brief` to create a structured briefing
- `/propose` to dive into technical details

## Important Notes

- Keep the tone conversational and exploratory, like talking over coffee
- Don't rush to solutions - embrace uncertainty and open questions
- Requirements stay HIGH LEVEL and DECLARATIVE - no implementation details
- Capture what's uncertain or assumed, not just what's decided
- Support iteration over days/weeks - the best ideas take time
- Files should read like smart notes, not formal documentation
- Encourage stepping away and returning fresh with new insights
