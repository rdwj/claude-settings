---
description: Choose frameworks, databases, and major technologies based on architectural sketch
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input: $ARGUMENTS

# Tech Stack - Technology Selection

## Purpose

Based on the architectural sketch, choose specific frameworks, databases, and major technologies for each component. This is where we make concrete technology decisions through dialog, considering:
- Your global CLAUDE.md preferences
- Existing codebase patterns
- Project requirements
- Trade-offs for this specific use case

## Process

### Step 1: Load Context

**Required inputs:**
1. Read `ideas/[project-name]/` - especially requirements.md, constraints.md, vision.md
2. Read `sketches/[project-name]-sketch.md` - the architecture we're implementing

**If user provided project name in $ARGUMENTS:**
- Use that project name

**If no project name provided:**
1. List all directories in `sketches/`
2. If only one sketch exists, use it
3. If multiple exist, ask which project
4. If no sketches exist, error: "No architectural sketch found. Run `/sketch` first."

**Present context to user:**

"Based on your sketch, we have these components to choose technology for:
- [Component 1]: [Brief description from sketch]
- [Component 2]: [Brief description from sketch]
- [Component 3]: [Brief description from sketch]

I'll help you choose the right frameworks and technologies for each."

### Step 2: Check Existing Codebase

**If we're in a repository with existing code:**

1. Check for dependency manifests:
   - `package.json` / `package-lock.json`
   - `requirements.txt` / `pyproject.toml`
   - `pom.xml` / `build.gradle`
   - `go.mod`
   - `Cargo.toml`

2. Check for configuration files that reveal frameworks:
   - `.streamlit/` or `streamlit_app.py`
   - `next.config.js` or `nuxt.config.js`
   - Django settings, Flask app factory
   - `docker-compose.yml` or `podman-compose.yml`

3. Analyze imports in source files to see what's actually being used

**Present findings:**

"I found these frameworks already in use:
- [Framework 1]: [Version, usage pattern]
- [Framework 2]: [Version, usage pattern]

Should we continue with these, or are we reconsidering the tech stack?"

**If user wants consistency:**
- Recommend sticking with existing frameworks for new components
- Flag any new choices that diverge from established patterns

**If user wants to change:**
- Understand why: "What's not working with the current stack?"
- Proceed with new selections
- Flag the divergence later

### Step 3: Review CLAUDE.md Preferences

Read CLAUDE.md (both `~/.claude/CLAUDE.md` and project-level if it exists) and identify relevant preferences.

**Present applicable preferences:**

"Your CLAUDE.md specifies these standards:
- Container Runtime: Podman (not Docker)
- Base Images: Red Hat UBI 9
- Python Framework: FastAPI (preferred over Flask)
- Database: PostgreSQL (for relational)
- Testing: pytest
- Deployment: OpenShift

I'll apply these unless you need to make an exception for this project."

**If user wants exception:**
1. Ask: "Which standard do you want to override?"
2. Ask: "Why is this exception needed?" (brief explanation)
3. Document the exception and rationale
4. Ask: "Should we update CLAUDE.md to allow this exception globally, or is this project-specific?"
5. If global: Offer to update CLAUDE.md with the new guidance

### Step 4: Technology Selection Dialog

For each component in the sketch, discuss technology choices. Use GitHub search and web research to find current, actively-maintained options.

#### Component: [UI Layer]

**Options to consider:**

Present 2-4 realistic options with pros/cons:

**A. Streamlit**
- **Pros**: Rapid prototyping, Python-native, built-in components, data-focused
- **Cons**: Less UI flexibility, harder to customize deeply
- **Best for**: Internal tools, data dashboards, analytics apps, ML demos
- **CLAUDE.md**: No specific preference
- **Learning curve**: Low for Python developers
- **Current in codebase**: [Yes/No]

**B. React/Next.js**
- **Pros**: Maximum flexibility, huge ecosystem, SSR/SSG, professional UIs
- **Cons**: Requires JavaScript/TypeScript knowledge, more setup
- **Best for**: Customer-facing apps, complex interactions, SEO-critical sites
- **CLAUDE.md**: Preferred for production web apps (if noted)
- **Learning curve**: Medium to high
- **Current in codebase**: [Yes/No]

**C. Electron**
- **Pros**: Native desktop app, offline-first, OS integration
- **Cons**: Large bundle size, platform quirks, distribution complexity
- **Best for**: Desktop tools, offline requirements, system integration
- **CLAUDE.md**: No specific preference
- **Learning curve**: Medium (web tech + native APIs)
- **Current in codebase**: [Yes/No]

**D. FastAPI + Jinja2 Templates (Server-side rendering)**
- **Pros**: Simple, fast, Python-native, no complex frontend build
- **Cons**: Less interactive, limited real-time features
- **Best for**: Admin panels, CRUD apps, simple forms
- **CLAUDE.md**: FastAPI is standard
- **Learning curve**: Low
- **Current in codebase**: [Yes/No]

**GitHub research**: [Show actively maintained projects, stars, recent commits]

**Question**: "Which UI approach fits your needs? Or should we consider something else?"

#### Component: [Backend/API Layer]

**Options to consider:**

**A. FastAPI**
- **Pros**: Modern async, automatic OpenAPI docs, type hints, fast
- **Cons**: Newer ecosystem than Flask/Django
- **CLAUDE.md**: ✓ Preferred Python framework
- **Current in codebase**: [Yes/No]

**B. Flask**
- **Pros**: Mature, huge plugin ecosystem, well-understood
- **Cons**: Older patterns, not async by default
- **CLAUDE.md**: ✗ Not preferred (FastAPI preferred)
- **Current in codebase**: [Yes/No]

**C. Django + DRF**
- **Pros**: Batteries included, admin panel, ORM, auth
- **Cons**: Heavier, opinionated, more overhead for APIs
- **CLAUDE.md**: Not mentioned
- **Current in codebase**: [Yes/No]

**GitHub research**: [Current activity, latest releases]

**Recommendation**: "Based on CLAUDE.md preference and the sketch requirements, FastAPI is the best fit."

**Question**: "Shall we go with FastAPI, or do you have a reason to choose differently?"

#### Component: [Database]

**Options based on sketch requirements:**

**A. PostgreSQL**
- **Pros**: Robust, proven, JSON support, extensions (PGVector)
- **Cons**: More complex than SQLite, needs management
- **CLAUDE.md**: ✓ Standard relational database
- **Best for**: Production apps, complex queries, scaling
- **Current in codebase**: [Yes/No]

**B. MongoDB**
- **Pros**: Flexible schema, good for rapid iteration
- **Cons**: No joins, eventual consistency concerns
- **CLAUDE.md**: Acceptable for document stores
- **Best for**: Unstructured data, flexible schemas
- **Current in codebase**: [Yes/No]

**C. Neo4j**
- **Pros**: Native graph operations, relationship queries
- **Cons**: Specialized, learning curve, deployment complexity
- **CLAUDE.md**: Acceptable for graph use cases
- **Best for**: Connected data, recommendation engines
- **Current in codebase**: [Yes/No]

**Question**: "What data access patterns does the sketch suggest? Relational, document, or graph?"

#### Component: [Vector Database / Embeddings]

(If applicable based on requirements)

**A. PGVector (PostgreSQL extension)**
- **Pros**: Integrated with PostgreSQL, one database to manage
- **Cons**: Not as optimized as specialized vector DBs
- **CLAUDE.md**: Preferred if using PostgreSQL
- **Current in codebase**: [Yes/No]

**B. Milvus**
- **Pros**: Purpose-built, high performance, scalable
- **Cons**: Separate service to manage
- **CLAUDE.md**: Acceptable
- **Current in codebase**: [Yes/No]

**C. Weaviate**
- **Pros**: Built-in ML models, hybrid search
- **Cons**: Opinionated, heavier
- **CLAUDE.md**: Acceptable
- **Current in codebase**: [Yes/No]

#### Component: [Agent Framework]

(If applicable)

**A. LangGraph**
- **Pros**: Complex workflows, state management, graph-based, adversarial patterns
- **Cons**: Learning curve, LangChain dependency
- **Best for**: Multi-agent systems, stateful workflows, complex branching
- **Current in codebase**: [Yes/No]

**B. Swarm (OpenAI)**
- **Pros**: Lightweight, simple handoffs, minimal abstraction
- **Cons**: Limited state management, OpenAI-centric
- **Best for**: Simple agent handoffs, lightweight coordination
- **Current in codebase**: [Yes/No]

**C. LlamaStack**
- **Pros**: Meta-backed, integrated tooling
- **Cons**: Newer, smaller ecosystem
- **Best for**: Llama models, Meta ecosystem
- **Current in codebase**: [Yes/No]

**D. Custom / No Framework**
- **Pros**: Maximum control, no dependencies
- **Cons**: More code to maintain, reinventing patterns
- **Best for**: Simple use cases, specific constraints
- **Current in codebase**: [Yes/No]

**Question**: "Based on the agent complexity in your sketch, which approach fits?"

#### Component: [MCP Servers]

**Based on sketch, identify needed MCP capabilities:**

From requirements and sketch, determine:
1. What tools/capabilities need MCP servers?
2. Which are custom vs. existing servers?

**Custom MCP Servers to Build:**
- [Server 1]: [Purpose, tools needed, priority]
- [Server 2]: [Purpose, tools needed, priority]

**Existing MCP Servers to Use:**
- [Search for relevant servers on GitHub/npm/PyPI]

**Transport Protocol:**
- **STDIO**: For local development, command-line tools
- **HTTP (streamable-http)**: For web deployment, production (per CLAUDE.md, SSE deprecated)

#### Additional Components

Continue dialog for each component in the sketch:
- Message queues (Redis, RabbitMQ, Kafka)
- Caching (Redis, in-memory)
- Authentication (OAuth2/OIDC, LDAP, custom)
- Real-time (WebSockets, SSE, polling)
- Monitoring (Prometheus, OpenTelemetry)

### Step 5: Flag Inconsistencies

**If new choices diverge from existing codebase:**

"⚠️  **Divergence Alert**

You've chosen [New Framework] for [Component], but the existing codebase uses [Existing Framework].

This creates inconsistency:
- Team needs to maintain multiple frameworks
- Different patterns in different parts of the system
- Potential integration friction

**Is this intentional?** If so, document the reasoning. If not, should we stick with [Existing Framework]?"

**If user confirms divergence is intentional:**
- Document rationale
- Note migration path or coexistence strategy
- Flag for review during propose

### Step 6: Optional Sections

**Ask the user:**

"Would you like to include information about:
1. **Domain experts** who should review specific aspects (e.g., ML scientists, security experts)
2. **User types** for UAT (user acceptance testing)

These won't affect technical implementation but can help with review and testing planning."

**If yes, add sections marked with:**
```markdown
<!-- IGNORE_IN_PROPOSE -->
## Domain Experts for Review

- **Machine Learning**: [Name/Role] - Review model selection and training approach
- **Security**: [Name/Role] - Review authentication and data protection
- **[Domain]**: [Name/Role] - Review [specific aspect]

## User Types for UAT

- **Power Users**: [Description] - Test advanced features
- **Casual Users**: [Description] - Test basic workflows
- **Administrators**: [Description] - Test admin functions
<!-- /IGNORE_IN_PROPOSE -->
```

### Step 7: Create Tech Stack Document

Create `tech-stack/[project-name]-tech-stack.md` as a **single evolving document**.

**Structure:**

```markdown
# Technology Stack: [Project Name]

**Date:** [Current Date]
**Status:** Draft / Approved
**Version:** 1.0
**Based on Sketch:** `sketches/[project-name]-sketch.md`

---

## Decision Summary

| Component | Technology | Version | Rationale |
|-----------|-----------|---------|-----------|
| [Component 1] | [Tech 1] | [Version] | [Brief why] |
| [Component 2] | [Tech 2] | [Version] | [Brief why] |

---

## Detailed Technology Decisions

### [Component 1]: [Technology Chosen]

**Decision:** [Framework/Database/Tool]

**Options Considered:**
- [Option 1] (chosen)
- [Option 2]
- [Option 3]

**Rationale:**
[Why this choice is best for this component and this project]

**Consistency Check:**
- ✓ Matches CLAUDE.md preference
- ✓ Consistent with existing codebase
- ⚠️  Diverges from existing [Framework] - [Reason]

**Trade-offs Accepted:**
- [Trade-off 1]
- [Trade-off 2]

**Key Dependencies:**
```
[package-name] >= [version]
[package-name] >= [version]
```

**Integration Notes:**
[How this integrates with other components]

---

[Repeat for each component]

---

## CLAUDE.md Compliance

**Standards Applied:**
- ✓ [Standard 1]: [How we comply]
- ✓ [Standard 2]: [How we comply]

**Exceptions Requested:**
- ⚠️  [Standard]: [Exception and rationale]
  - **Project-specific**: [Yes/No]
  - **Suggest CLAUDE.md update**: [Yes/No with proposed wording]

---

## Existing Codebase Integration

**Current Frameworks in Use:**
- [Framework 1]: [Where used]
- [Framework 2]: [Where used]

**Our Approach:**
- ✓ Maintaining consistency with [Framework X]
- ⚠️  Introducing [Framework Y] for [Component] - [Migration strategy]

**Coexistence Strategy:**
[If mixing frameworks, explain how they coexist]

---

## MCP Servers

### Custom MCP Servers to Build

**[Server 1 Name]**
- **Purpose**: [What it does]
- **Tools**: [List of tools/capabilities]
- **Transport**: HTTP (streamable-http) / STDIO
- **Priority**: Phase 1 / Phase 2
- **Dependencies**: [Frameworks, APIs needed]

**[Server 2 Name]**
[Same structure]

### Existing MCP Servers to Use

**[Server Name]**
- **Source**: [GitHub/npm/PyPI link]
- **Purpose**: [What we'll use it for]
- **Installation**: [How to install]

---

## Deployment Stack

**Container Platform**: Podman (per CLAUDE.md)
**Container Files**: Containerfile format
**Base Images**: Red Hat UBI 9 (per CLAUDE.md)
**Orchestration**: OpenShift (per CLAUDE.md)
**Configuration**: Kustomize overlays
**CI/CD**: OpenShift Pipelines (Tekton)
**GitOps**: ArgoCD

---

## Development Environment

**Python Environment**: venv (per CLAUDE.md)
**Python Version**: [Version]
**Node Version**: [If applicable]
**Package Management**: pip, npm/pnpm
**Testing Framework**: pytest (per CLAUDE.md)
**Code Quality**: black, ruff, mypy

---

## Deferred Decisions

The following will be decided in `/propose` or during implementation:

- Specific utility libraries (e.g., which PDF parser)
- Minor dependencies and helper packages
- Specific Python packages for [specific tasks]
- Exact component library choices
- Logging framework standardization
- [Other minor choices]

**Note**: Major frameworks are locked here; specific packages within those frameworks will be chosen during implementation based on current best practices.

---

<!-- IGNORE_IN_PROPOSE -->
## Domain Experts for Review

[If user requested this section]

- **[Domain]**: [Name/Role] - [What they should review]

## User Types for UAT

[If user requested this section]

- **[User Type]**: [Description] - [What they should test]
<!-- /IGNORE_IN_PROPOSE -->

---

## Open Questions

[Questions that still need answers before propose]

- [Question 1]
- [Question 2]

---

## Next Steps

1. Review this tech stack with stakeholders if needed
2. Resolve any open questions
3. Update CLAUDE.md if we decided on exceptions to make global
4. Run `/propose` to create detailed technical design using these choices
```

### Step 8: Present and Iterate

Show the user:
1. Path to tech-stack document
2. Summary of key decisions
3. Any CLAUDE.md exceptions flagged
4. Any existing codebase divergences flagged

Ask: "Does this tech stack look right? Any choices you want to reconsider?"

Iterate until user is satisfied.

### Step 9: Completion

When user is satisfied:

"Tech stack defined: tech-stack/[project-name]-tech-stack.md

Key decisions:
- [Component 1]: [Technology]
- [Component 2]: [Technology]
- [Component 3]: [Technology]

CLAUDE.md compliance: [All standards met / X exceptions documented]
Codebase consistency: [All consistent / X divergences documented]

Next step:
Run `/propose` in a fresh session to create a detailed technical proposal.
It will use your ideas, sketch, and this tech stack as the foundation."

**If CLAUDE.md updates were suggested:**

"You requested these CLAUDE.md updates:
- [Update 1]
- [Update 2]

Would you like me to update CLAUDE.md now, or will you do it manually?"

If user says yes, update CLAUDE.md with the new guidance.

## Notes

- **One evolving file** - Update the single tech-stack document, don't create versions
- **Dialog-driven** - Present options, discuss trade-offs, explain reasoning
- **Context-aware** - Consider CLAUDE.md, existing code, sketch requirements
- **Flag divergence** - Make inconsistencies visible and intentional
- **Document rationale** - Future you will want to know why you chose this
- **Major frameworks only** - Specific packages come later
- **Support iteration** - This might take multiple sessions, that's fine
