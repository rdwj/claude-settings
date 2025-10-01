# Claude Code Workflow & Configuration

A comprehensive, proposal-driven development workflow using Claude Code subagents and slash commands. This repository contains specialized AI subagents and workflow automation commands that accelerate high-quality software development through structured processes.

## Overview

This workflow system provides:

- **Specialized AI Subagents**: Domain-focused assistants with dedicated context windows
- **Slash Commands**: Workflow automation for common development tasks
- **File-based Project Management**: Trackable progress through directory-based state
- **Proposal-driven Development**: Structured approach from design to implementation

## The Complete Workflow

### 1. Design Phase

**`/propose [description]`** - Create a technical proposal

- Uses the `proposal-writer` subagent
- Generates comprehensive design document in `proposals/` directory
- Includes problem statement, solution, technical approach, testing strategy
- As the developer, you need to review this proposal and make any edits you need
  - You can use Claude to help with this task

**`/review {{file}}`** - Validate the proposal

- Uses `architecture-reviewer` to check architectural compliance
- Uses `security-reviewer` to identify security concerns
- Appends review feedback to the proposal document

**`/revise {{file}}`** - Update proposal based on reviews

- Addresses architecture and security issues
- Maintains review history
- Documents what was changed and why

### 2. Planning Phase

**`/write-stories {{file}}`** - Break proposal into atomic user stories

- Creates stories in `project-management/backlog/`
- Each story is small enough for parallel work
- Includes YAML frontmatter for tracking
- Identifies dependencies between stories

### 3. Implementation Phase

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

### 4. Utility Commands

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
- **Development**: story-scaffolder, scaffold-filler, senior-code-reviewer, claude-worker, codebase-master (think of codebase-master like a property master on a movie set - this person knows where every important thing is at all times)
- **Testing**: test-execution-analyst
- **Documentation**: documentation-architect
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

- **`/scaffold-pm`** - Set up project management directory structure (DO THIS FIRST)
- **`/propose`** - Create a technical proposal document
- **`/review`** - Run architecture and security reviews on a proposal
- **`/revise`** - Update proposal based on review feedback
- **`/write-stories`** - Generate atomic user stories from a proposal
- **`/implement-story`** - Execute two-phase implementation (scaffold + fill)
- **`/post-review`** - Perform code review after implementation
- **`/approve`** - Approve and move story to done
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

### When to Use Each Command

1. **Starting a new feature**: `/propose` → `/review` → `/revise` → `/write-stories`
2. **Implementing stories**: `/implement-story` → `/post-review` → `/approve`
3. **Complex ad-hoc tasks**: `/ds` to decompose and delegate
4. **Code quality checks**: Invoke subagents explicitly (security-compliance-scanner, senior-code-reviewer)

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
