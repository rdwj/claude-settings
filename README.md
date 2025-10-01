# Claude Code Workflow & Configuration

A comprehensive, proposal-driven development workflow using Claude Code subagents and slash commands. This repository contains specialized AI subagents and workflow automation commands that accelerate high-quality software development through structured processes.

## Overview

This workflow system provides:

- **Specialized AI Subagents**: Domain-focused assistants with dedicated context windows
- **Slash Commands**: Workflow automation for common development tasks
- **File-based Project Management**: Trackable progress through directory-based state
- **Proposal-driven Development**: Structured approach from design to implementation

## The Complete Workflow

### 1. Ideation Phase

**`/imagine [project-name]`** - Explore and formulate project ideas

- Interactive dialog to explore problem space and vision
- GitHub and market research for similar projects
- Creates evolving documentation in `ideas/[project]/`
- Supports iterative thinking over days/weeks
- Multiple conversation files with timestamps
- Keeps requirements HIGH LEVEL and DECLARATIVE
- Supports project renaming as ideas evolve
- Ends with encouragement to take time away and return fresh

**`/pitch {{file}}`** - Create investor/management pitch (optional)

- Reads from `ideas/[project]/`
- Persuasive document for funding or approval
- Focus on value, opportunity, ROI
- Audience-aware formatting

**`/brief {{file}}`** - Create structured project briefing (optional)

- Reads from `ideas/[project]/`
- Formal documentation for stakeholders and governance
- The "what and why" before the technical "how"
- Professional tone with structured sections

### 2. Architecture Phase

**`/sketch [project-name]`** - Create architectural sketch

- Based on ideas, creates visual architecture
- Component diagrams, data flows, deployment boundaries
- Single evolving document (not versions)
- Mermaid diagrams and text diagrams
- Can analyze existing codebase with repomix
- Sketch-level detail, not over-engineered
- Ends with suggestion to run `/tech-stack`

**`/tech-stack [project-name]`** - Choose frameworks and technologies

- Based on sketch, select specific technologies
- Interactive dialog presenting options with pros/cons
- Reviews CLAUDE.md preferences, allows exceptions
- Analyzes existing codebase for consistency
- Flags divergence from established patterns
- Documents rationale for each decision
- Includes optional domain experts and UAT user sections
- Single evolving document
- Ends with suggestion to run `/propose`

### 3. Design Phase

**`/propose [project-name]`** - Create detailed technical proposal

- Reads from `ideas/`, `sketch`, and `tech-stack`
- Uses Context7 MCP if available for current API docs
- Generates comprehensive design document in `proposals/` directory
- Includes API specs, data models, deployment strategy
- Leaves specific packages to implementation
- Respects technology locked in by tech-stack
- Ignores sections marked `<!-- IGNORE_IN_PROPOSE -->`

**`/review {{file}}`** - Validate the proposal

- Uses `architecture-reviewer` to check architectural compliance
- Uses `security-reviewer` to identify security concerns
- Appends review feedback to the proposal document

**`/revise {{file}}`** - Update proposal based on reviews

- Addresses architecture and security issues
- Maintains review history
- Documents what was changed and why

**`/simplify {{file}}`** - Reduce proposal complexity interactively

- For when proposals are comprehensive but the need is simple
- Interactive dialog to understand actual requirements
- Creates simplified proposal with deferred features documented
- Preserves original proposal for future reference

**`/break-into-phases {{file}}`** - Break large proposals into discrete phases

- For complex proposals that need incremental delivery
- Offers 6 phasing strategies (vertical slice, feature-by-feature, risk-first, etc.)
- Interactive dialog to determine optimal breakdown
- Creates phase directory with individual phase documents
- Each phase can be independently converted to user stories

### 4. Planning Phase

**`/write-stories {{file}}`** - Break proposal into atomic user stories

- Creates stories in `project-management/backlog/`
- Each story is small enough for parallel work
- Includes YAML frontmatter for tracking
- Identifies dependencies between stories

### 5. Implementation Phase

**`/implement-story {{file}}`** - Two-phase implementation

- **Phase 1**: Uses `story-scaffolder` to create code structure and stubs
  - This keeps the context manageable and lets Claude do its best work deciding what classes and functions are needed, and what inputs/outputs we will want for those.
  - Good docstrings at this stage set us up for success in the next step
- **Phase 2**: Uses `scaffold-filler` to implement actual logic
  - This depends heavily on the quality of the work done by the story-scaffolder
- Updates story checklist items as work progresses
- Promotes story through workflow states

**`/post-review {{file}}`** - Code review after implementation

- Uses `senior-code-reviewer` subagent
- Checks for breaking changes, duplication, architectural compliance
- Adds review findings to the story file

**`/approve {{file}}`** - Finalize completed work

- Promotes story from `ready-for-human-review` to `done`
- Confirms all acceptance criteria are met

### 6. Utility Commands

**`/ds [complex task]`** - Decompose and solve

- Breaks complex tasks into manageable sub-problems
- Uses `claude-worker` subagent to preserve main context
- Delegates to specialized subagents as needed
- Aggregates results and presents solution

## Project Management System

File-based workflow with automatic state tracking:

```
project-management/
├── backlog/              # Work items not yet started
├── in-progress/          # Currently being worked on
├── ready-for-human-review/  # Completed, awaiting approval
├── done/                 # Completed and approved
├── blocked/              # Blocked by dependencies or issues
└── scripts/
    └── promote.sh        # Script to move items between states
```

### Using the Promotion Script

```bash
# Start working on a backlog item
./project-management/scripts/promote.sh story-123.md in-progress

# Mark as ready for review after completion
./project-management/scripts/promote.sh story-123.md ready-for-human-review

# Approve and move to done
./project-management/scripts/promote.sh story-123.md done

# Mark as blocked if issues arise
./project-management/scripts/promote.sh story-123.md blocked
```

The script automatically updates YAML frontmatter with status and timestamp history.

## Subagents

### What are Subagents?

Subagents are specialized AI assistants in Claude Code that:

- **Operate independently** in their own context window for better focus
- **Automatically or explicitly invoked** based on the task at hand
- **Have specialized tools and expertise** tailored to specific domains
- **Preserve context** and maintain specialized knowledge
- **Are reusable** across projects and team members

Each subagent is defined as a Markdown file with YAML frontmatter configuration, specifying its name, description, available tools, and system prompt.

### Available Subagents

This collection includes specialized subagents for:

- **Architecture & Design**: solution-architect, proposal-writer, architecture-reviewer, microservices-architect
- **Security**: security-compliance-scanner, security-reviewer
- **Business & Documentation**: pitch-writer, brief-writer, documentation-architect, research-analyst
- **Development**: story-scaffolder, scaffold-filler, senior-code-reviewer, claude-worker, codebase-master
- **Testing**: test-execution-analyst
- **Deployment**: openshift-deployment-engineer, gitops-argocd-specialist
- **Technology-specific**: react-nextjs-architect, react-native-ux-designer, streamlit-app-developer, langgraph-adversarial-architect
- **Specialized**: dependency-analyzer-python, mcp-protocol-expert, neo4j-graphrag-architect, llama-prompt-engineer, granite-prompt-engineer

See `agents/` directory for complete list and details.

### Installing Subagents

Subagents can be installed at two levels:

- **User-level** (`~/.claude/agents/`): Available across all your projects
- **Project-level** (`.claude/agents/`): Available only within a specific project

#### Quick start (User-level)

```bash
mkdir -p ~/.claude/agents
cp -R agents/* ~/.claude/agents/
```

#### Project-level installation

```bash
mkdir -p .claude/agents
cp -R agents/* .claude/agents/
```

### Managing Subagents

- **Interactive management**: Use the `/agents` command in Claude Code to create, edit, and delete subagents
- **Manual updates**: Edit the Markdown files directly and changes take effect immediately
- **File naming**: The filename determines how the subagent appears in Claude Code

### How Subagents are Invoked

1. **Automatic Delegation**: Claude Code proactively selects the appropriate subagent based on:

   - The task description and context
   - The subagent's configured expertise area
   - Available tools needed for the task
2. **Explicit Invocation**: You can directly request a specific subagent:

   - "Use the security-compliance-scanner subagent to review this code"
   - "Ask the documentation-architect to create API docs"
   - "Have the test-execution-analyst design tests for this module"

### Benefits of Using Subagents

- **Context Preservation**: Each subagent maintains its own focused context window, avoiding dilution from unrelated tasks
- **Specialized Expertise**: Purpose-built system prompts and knowledge for specific domains
- **Reusability**: Share proven subagents across projects and with team members
- **Tool Restrictions**: Limit tool access to only what each subagent needs, improving safety and focus
- **Parallel Execution**: Multiple subagents can work on different aspects of a problem simultaneously
- **Team Collaboration**: Version-controlled subagent definitions enable consistent workflows across teams

## Slash Commands

Custom slash commands are defined as Markdown files in the `commands/` directory. Each command automates a specific workflow step and can invoke subagents as needed.

### Available Commands

#### Getting Started
- **`/workflow`** - Show workflow overview and check current project status (run anytime)
- **`/scaffold-pm`** - Set up project management directory structure (for projects)

#### Ideation Phase
- **`/imagine`** - Explore and formulate project ideas through iterative dialog
- **`/pitch`** - Create investor/management pitch from ideas
- **`/brief`** - Create structured project briefing from ideas

#### Architecture Phase
- **`/sketch`** - Create architectural sketch with components and data flows
- **`/tech-stack`** - Choose frameworks and technologies based on sketch

#### Design Phase
- **`/propose`** - Create detailed technical proposal from ideas + sketch + tech-stack
- **`/review`** - Run architecture and security reviews on a proposal
- **`/revise`** - Update proposal based on review feedback
- **`/simplify`** - Reduce proposal complexity through interactive dialog
- **`/break-into-phases`** - Break large proposals into discrete implementation phases

#### Planning & Implementation
- **`/write-stories`** - Generate atomic user stories from a proposal (or phase document)
- **`/implement-story`** - Execute two-phase implementation (scaffold + fill)
- **`/post-review`** - Perform code review after implementation
- **`/approve`** - Approve and move story to done

#### Security & Quality
- **`/pre-commit`** - Check for secrets and ensure .gitignore is configured before committing

#### Utility
- **`/ds`** - Decompose complex task and solve with subagents (OPTIONAL, PER PROMPT)

### Creating Custom Commands

Commands are Markdown files with optional YAML frontmatter. Place them in `~/.claude/commands/` or `.claude/commands/` for project-level commands.

```markdown
---
description: Short description of what the command does
---

# Command Name

Instructions for Claude Code on what to do when this command is invoked.

Can reference:
- $ARGUMENTS - User-provided arguments
- {{file}} - File selected in IDE
```

## Installation & Setup

### Clone this Repository

```bash
cd ~/.claude
git clone <your-repo-url> .
```

### Or Copy Individual Components

```bash
# Install subagents
cp -R agents/* ~/.claude/agents/

# Install commands
cp -R commands/* ~/.claude/commands/

# Copy global configuration
cp CLAUDE.md ~/.claude/CLAUDE.md
```

### Initialize Project Management (per project)

In your project directory:

```bash
# Use the scaffold-pm command
/scaffold-pm

# Or manually create structure
mkdir -p project-management/{backlog,in-progress,ready-for-human-review,done,blocked,scripts}
```

## Best Practices

### Getting Your Bearings

**New to the workflow or returning after time away?**

Run `/workflow` to:
- See the complete workflow overview
- Check what's been done in the current project
- Get clear next steps

This is especially helpful when:
- Onboarding new team members
- Returning to a project after days/weeks
- Working in a shared repository
- Not sure what comes next

### When to Use Each Command

**Complete new project workflow:**
1. `/imagine` - Explore ideas iteratively (days/weeks)
2. `/pitch` or `/brief` - Document for approval (optional)
3. `/sketch` - Create architectural design
4. `/tech-stack` - Choose technologies
5. `/propose` - Detailed technical design
6. `/review` → `/revise` - Validate and refine
7. `/write-stories` - Break into work items
8. `/implement-story` → `/post-review` → `/approve` - Execute

**Simplified workflows:**
- **Quick feature (well-understood)**: `/sketch` → `/tech-stack` → `/propose` → `/write-stories`
- **Large/complex proposals**: After `/propose`, use `/break-into-phases` before `/write-stories`
- **Over-engineered proposals**: After `/review`, use `/simplify` before `/write-stories`
- **Existing project additions**: Start at `/sketch` or `/propose` depending on architectural impact
- **Complex ad-hoc tasks**: `/ds` to decompose and delegate
- **Code quality checks**: Invoke subagents explicitly (security-compliance-scanner, senior-code-reviewer)
- **Before committing**: Run `/pre-commit` to check for secrets and ensure .gitignore is configured

### Phasing Strategies for Large Proposals

The `/break-into-phases` command offers six different approaches to breaking down complex projects:

- **Vertical Slice (Breadth-First)**: Build one complete feature through all layers (data → business → UI) first, then add features. Best for proving architecture and reducing technical risk.

- **Horizontal Layers (Depth-First)**: Complete all data layer work, then all business logic, then all UI. Best when you have complete requirements upfront or specialized teams.

- **Feature-by-Feature**: Implement one fully production-ready feature at a time with all enterprise concerns. Best for parallel team work and incremental user delivery.

- **Risk-First**: Tackle the most uncertain/complex items first, easier items later. Best when using new technologies or facing significant unknowns.

- **Value-First**: Deliver highest business value features first, nice-to-haves later. Best for tight deadlines or demonstrating value quickly.

- **Hybrid**: Combine strategies (e.g., vertical slice for Phase 1 MVP, then feature-by-feature). Best for complex projects that don't fit a single pattern.

The command provides interactive dialog to help choose the best strategy and determine the optimal number of phases (typically 2-5).

### Context Management

- Use `/ds` for complex tasks to preserve main context
- Invoke `claude-worker` for general delegation
- Use `codebase-master` before implementing to check for existing code
- Specialized subagents should be invoked when their domain expertise is needed

### Story Workflow

1. Stories start in `backlog/`
2. Promote to `in-progress/` when starting work
3. If blocked, promote to `blocked/` immediately and document why
4. When complete, promote to `ready-for-human-review/`
5. After human approval, promote to `done/`

### Code Reuse

Before implementing new functionality:

- Ask `codebase-master` if similar code exists
- Check existing utilities and helpers
- Review project architecture for patterns

### Security Practices

Before committing or sharing code:

- Run `/pre-commit` to scan for secrets with gitleaks
- Ensure `.gitignore` excludes sensitive files (`.env`, `*.key`, `credentials.json`)
- Use `.gitleaks.toml` to manage false positives (examples, test data)
- Name example files with `.example` suffix (`secrets.yaml.example`)
- Use obvious placeholders (`YOUR_API_KEY_HERE`, `<your-key-here>`)
- Never commit actual credentials, even in "private" repositories

## Directory Structure

```
~/.claude/
├── README.md                    # This file
├── CLAUDE.md                    # Global development preferences
├── .gitignore                   # Ignore personal/sensitive files
├── agents/                      # Specialized subagents
│   ├── README.md               # Subagent documentation
│   ├── proposal-writer.md
│   ├── security-reviewer.md
│   ├── claude-worker.md
│   └── ...
└── commands/                    # Slash commands
    ├── propose.md
    ├── review.md
    ├── implement-story.md
    ├── ds.md
    └── ...
```

## Sharing with Team

This repository is designed to be shared with colleagues:

1. **Fork or clone** this repo
2. **Customize** subagents and commands for your team's needs
3. **Share** the repo URL with colleagues
4. **Contribute back** improvements via pull requests

The `.gitignore` excludes personal files like `file-history/` and session state.

## Contributing

Contributions are welcome:

### For Subagents

- **File format**: All subagents are Markdown files with YAML frontmatter configuration
- Keep files concise and focused; prefer clarity over breadth
- Use consistent headings and imperative, action‑oriented guidance
- Define clear tool restrictions and specialized expertise areas
- Avoid duplication across agents; factor shared guidance into a single agent when possible
- Test your subagents in real scenarios before submitting
- Submit PRs with a short rationale for the changes

### For Commands

- Follow existing command patterns
- Document what the command does and when to use it
- Include usage examples
- Reference appropriate subagents
- Test end-to-end before submitting

## License

This project is licensed under the MIT License. See `LICENSE` for details.

## Acknowledgments

This workflow evolved through extensive trial and error, incorporating best practices from multiple Claude Code users and workflows. Special thanks to the Claude Code community for inspiration and feedback.
