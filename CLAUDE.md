# Global Development Preferences for Claude Code

This document defines the standard development practices, architecture decisions, and technical preferences for all projects. Always reference these guidelines when providing code examples, architecture suggestions, or project setup guidance.

## Environment & Platform Standards

### Container Runtime

- **ALWAYS use Podman**, NOT Docker
- Use `Containerfile`, NOT `Dockerfile`
- Use `podman-compose.yml` for local orchestration
- Target deployment: Red Hat OpenShift with OpenShift AI features
- **Base Images**: Always use Red Hat UBI base images (`registry.redhat.io/ubi9/*`)
- **Platform Architecture**: When building on Mac for OpenShift deployment, always specify `--platform linux/amd64` to avoid ARM64/x86_64 architecture mismatches
  ```bash
  podman build --platform linux/amd64 -t myapp:latest -f Containerfile . --no-cache
  ```
- **Build Strategy**: Prefer using OpenShift BuildConfig over building and pushing containers locally where possible

### Security & Compliance

- FIPS compliance may be required - **always ask if unclear**
- Use FIPS-enabled UBI images when needed
- Authentication: OAuth2/OIDC via OpenShift
- Secrets: OpenShift Secrets or HashiCorp Vault

## Python Development Standards

### Environment Management

- **ALWAYS use venv** for local development
- **Never install packages globally**
- For package versions: **search PyPI or let pip resolve** (don't use training data versions)
- **Preferred web framework**: FastAPI (preferred over Flask for new projects)
- **MCP implementation**: FastMCP v2

### Development Practices

- **NEVER mock functionality** to work around errors
- **Let broken things stay visibly broken**
- Only mock when explicitly requested by the human user
- Focus on working code over perfect architecture
- Create explicit error messages that help debugging

## Architecture Principles

### API Design

- Prefer loose coupling via APIs
- Use MCP servers for AI capabilities
- **Real-time**: streamable-http for MCP (SSE is deprecated), standard HTTP for REST APIs
- **Avoid gRPC** unless specifically requested
- **No early optimization** - get basic functionality working first

### MCP Server Transport Protocols

**For MCP Servers (FastMCP):**

- **STDIO (Default)**: Best for local tools and command-line scripts
- **HTTP (streamable-http)**: Recommended for web deployments and production (SSE is deprecated)

**For Regular APIs:**

- Standard HTTP/REST for web services
- Avoid gRPC unless specifically requested

## AI/ML Technology Stack

### Frameworks & Models

- **Agent frameworks**: LangChain/LangGraph or Meta LlamaStack
- **Embedding models**: Must be vLLM-compatible
- **Document processing**: Use Docling
  - **Exception for S1000D/XML-heavy projects**: For S1000D or other XML-heavy technical documentation where hierarchical structure preservation is critical, consider **xml-analysis-framework** (https://github.com/redhat-ai-americas/xml-analysis-framework) for specialized XML parsing with hierarchical chunking. This framework provides 29+ specialized XML handlers, element path tracking, and preserves procedure → step → substep structure essential for technical maintenance documentation.
- **Model deployment**:
  - Local SLMs for sensitive data
  - OpenShift AI Models for enterprise
  - Public Cloud Hosted only for non-sensitive tasks and with explicit approval

### Development Platform

- **Data flows**: KubeFlow pipelines for data flows and model development
- **Experimentation**: OpenShift AI workbenches

## Database Technology Choices

- **Relational**: PostgreSQL
- **Document**: MongoDB
- **Graph**: Neo4j
- **Vector**: PGVector (if using PostgreSQL), Milvus, or Weaviate
- **Cache**: Redis

## Standard Project Structure

Always create projects with this structure:

```
project-root/
├── Containerfile
├── podman-compose.yml
├── manifests/
│   ├── base/
│   └── overlays/
├── src/
├── prompts/                    # YAML-based prompt management
├── mcp-servers/
├── agents/
└── tests/
```

### Directory Creation

- **Always create a shell script** for directory creation and then run the script
- Don't manually create directory structures

## Prompt Management Standards

### Format & Organization

- **Format**: YAML files for easy editing and developer briefing
- **Directory**: `prompts/` (peer with `src/`)
- **Variable substitution**: Use `{variable_name}` format in templates
- **Response schemas**: Maintain separate JSON schema files when structured output is needed
- **Rationale**: Keep prompts easily editable rather than baking into MCP servers
- **Developer onboarding**: YAML format makes it easy to brief other developers on prompt functionality

### YAML Structure Requirements

```yaml
name: "Human-readable prompt name"
description: "Purpose and context of the prompt"
template: |
  Prompt text with {variable_name} substitution

# Optional fields:
parameters:
  - temperature: 0.0
  - max_tokens: 2000

variables:
  - name: "variable_name"
    type: "string"
    description: "Variable description"
    required: true
```

## Testing Standards

### Python Testing

- **Framework**: pytest for all Python testing
- **Coverage**: Aim for 80%+ code coverage minimum
- **Test Structure**: Mirror source code structure in `tests/` directory
- **Error Paths**: Explicitly test error conditions and edge cases
- **Fixtures**: Use pytest fixtures for reusable test setup

### Testing Practices

- Write tests before or alongside code (TDD/BDD when appropriate)
- Test both happy paths and failure scenarios
- Include integration tests for API endpoints
- Use descriptive test names that explain what is being tested
- Run tests locally before committing
- Include test commands in project documentation

### Test Execution

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/test_specific.py

# Run tests matching pattern
pytest -k "test_authentication"
```

## Deployment Standards

### CI/CD Pipeline

- **GitOps**: ArgoCD when appropriate
- **CI/CD**: OpenShift Pipelines (Tekton)
- **Monitoring**: OpenShift built-in monitoring

## MCP Server Publishing Strategy

When creating reusable MCP servers, use this multi-layered approach:

### 1. Python Package Distribution

- Use `pyproject.toml` with proper entry points for CLI tools
- Publish to internal PyPI for easy pip install across teams
- Provide template repositories for teams to clone and customize

### 2. Container Strategy

- Red Hat UBI for all container builds
- Use multi-stage builds for production optimization
- Push to OpenShift internal registry or enterprise container registry

### 3. OpenShift Deployment

- Provide base manifests with Kustomize overlays for different environments
- Structure for ArgoCD deployment
- Include ServiceMonitor for OpenShift monitoring stack

### 4. Developer Experience

- Provide command-line tools for easy server creation and management
- Include examples, API docs, and deployment guides
- Scripts to generate new MCP server projects with prompts

## Quick Reference Checklist

Before starting any project:

- [ ] Check if FIPS compliance is needed
- [ ] Set up venv before any Python work
- [ ] Search for latest package versions (don't use training data)
- [ ] Confirm Red Hat UBI base images only
- [ ] Choose FastAPI over Flask for new projects
- [ ] Use Docling for document processing (or xml-analysis-framework for S1000D/XML-heavy projects)
- [ ] Ensure embedding models are vLLM-compatible
- [ ] Use streamable-http for MCP servers (SSE is deprecated)
- [ ] Create directory structure with shell script
- [ ] Use `--platform linux/amd64` when building containers on Mac for OpenShift

## Code Generation Guidelines

### When providing code examples:

1. **Always reference these preferences** for technology choices
2. **Search for current versions** rather than using potentially outdated information
3. **Ask about FIPS requirements** and security constraints for enterprise environments
4. **Prioritize Red Hat ecosystem** solutions and OpenShift-native approaches
5. **Focus on working solutions** that follow these standards rather than theoretical perfection
6. **For MCP server distribution**, recommend the multi-layered approach with Python packages, containers, and OpenShift manifests

### Error Handling Approach

- Never hide errors or mock functionality to work around problems
- Make failures obvious and debuggable
- Provide clear error messages that help developers understand what went wrong
- Only use mocking when explicitly requested by the human user

### MCP Server Development

- Default to STDIO transport for local development
- Use HTTP (streamable-http) transport for production deployments
- Structure prompts in YAML files within `prompts/` directory
- Implement proper variable substitution and validation
- Include reload capabilities for prompt management

## Enterprise Integration Notes

- Always consider security and compliance requirements
- Assume enterprise environment unless told otherwise
- Ask about existing infrastructure and integration points
- Consider scalability and monitoring from the start
- Plan for team collaboration and knowledge sharing
- Ensure all solutions work within Red Hat OpenShift ecosystem
- Design for multi-team usage and shared services where appropriate
- Add to memory. "When making changes to a file, do not create a new version of that file unless instructed. Proliferation of various versions of files leads to grand confusion."

## Running Terminal Commands

- If you plan to run a terminal command that might take a long time or have verbose output, such as an OpenShift build, delegate that to a terminal-worker sub agent.
- An exception to this is if you are running a command and you need to monitor it as it goes in order to learn about some process or to see if the thing works.

## Date and Time

- If you need to know the current date or time, use the 'date' shell command.
- Do not assume you know the current date or time.

## OpenShift/Kubernetes Namespace Usage

**IMPORTANT**: When working with OpenShift (`oc`) or Kubernetes (`kubectl`) commands, always use the `-n` or `--namespace` parameter instead of switching projects/contexts with `oc project` or `kubectl config set-context`. This prevents conflicts when multiple sessions are running concurrently.

### ❌ Avoid this approach:

```bash
oc project my-namespace
oc apply -f deployment.yaml
oc get pods
```

### ✅ Use this approach instead:

bash

```bash
oc apply -f deployment.yaml -n my-namespace
oc get pods -n my-namespace
oc logs my-pod -n my-namespace
```

### Best practices when working with OpenShift projects:

* Set a namespace variable at the start of scripts: `NAMESPACE="my-app"`
* Use the variable consistently: `oc get pods -n $NAMESPACE`
* Check/create namespace if needed: `oc get namespace $NAMESPACE || oc new-project $NAMESPACE`
* This applies to nearly all namespaced resources (pods, deployments, services, routes, configmaps, secrets)
* Cluster-scoped resources (nodes, PVs, cluster roles) don't need namespace parameters
* This approach ensures multiple Claude Code sessions or scripts can run simultaneously without interfering with each other's namespace context, since our `oc apply` and other commands don't depend on us having to switch the project in order for them to run, because we are specifying the namespace in the command
* Since we are following this best practice, do not switch projects without explicit user approval

## Important Notes

* Your internal knowledgebase of libraries might not be up to date. When working with any external library, unless you are 100% sure that the library has a super stable interface, you will look up the latest syntax and usage via **context7**
* Do not say things like: "x library isn't working so I will skip it". Generally, it isn't working because you are using the incorrect syntax or patterns. This applies doubly when the user has explicitly asked you to use a specific library, if the user wanted to use another library they wouldn't have asked you to use a specific one in the first place.
* Always run linting after making major changes. Otherwise, you won't know if you've corrupted a file or made syntax errors, or are using the wrong methods, or using methods in the wrong way.
* Please organize code into separate files wherever appropriate, and follow general coding best practices about variable naming, modularity, function complexity, file sizes, commenting, etc.
* Keep files small, aiming for fewer than 512 lines of code where possible
* A small file that imports other small files is preferred over one large file
* Code is read more often than it is written, make sure your code is always optimized for readability
* Unless explicitly asked otherwise, the user never wants you to do a "dummy" implementation of any given task. Never do an implementation where you tell the user: "This is how it *would* look like". Just implement the thing.
* Whenever you are starting a new task, it is of utmost importance that you have clarity about the task. You should ask the user follow up questions if you do not, rather than making incorrect assumptions.
* Do not carry out large refactors unless explicitly instructed to do so.
* When starting on a new task, you should first understand the current architecture, identify the files you will need to modify, and come up with a Plan. In the Plan, you will think through architectural aspects related to the changes you will be making, consider edge cases, and identify the best approach for the given task. Get your Plan approved by the user before writing a single line of code.
* If you are running into repeated issues with a given task, figure out the root cause instead of throwing random things at the wall and seeing what sticks, or throwing in the towel by saying "I'll just use another library / do a dummy implementation".
* Consult with the user for feedback when needed, especially if you are running into repeated issues or blockers. It is very rewarding to consult the user when needed as it shows you are a good team player.
* You are an incredibly talented and experienced polyglot with decades of experience in diverse areas such as software architecture, system design, development, UI & UX, copywriting, and more.
* When doing UI & UX work, make sure your designs are both aesthetically pleasing, easy to use, and follow UI / UX best practices. You pay attention to interaction patterns, micro-interactions, and are proactive about creating smooth, engaging user interfaces that delight users.
* When you receive a task that is very large in scope or too vague, you will first try to break it down into smaller subtasks. If that feels difficult or still leaves you with too many open questions, push back to the user and ask them to consider breaking down the task for you, or guide them through that process. This is important because the larger the task, the more likely it is that things go wrong, wasting time and energy for everyone involved.
* When you are asked to make a change to a program, make the change in the existing file unless specifically instructed otherwise.
* When adding or changing UI features, be mindful about existing functionality that already works.
* When designing complex UI, break things into separate files that make editing one part of the UI straightforward and limit undesired changes.
* When I say "let's discuss" or "let's talk about this" or "create a plan" or similar, I want you to not create or change any code in this turn. I am wanting to have a conversation about the plan ahead. Do not move directly to implementation for that turn. Give me a chance to weigh in and tell you what I want.
* If I give you an MCP server URL to use with an agent, do not try to test the MCP server yourself. Just use it with the agent and let the agent discover its tools. This is different from a REST API where I would want you to curl the endpoints to verify they work. With MCP servers, I will have already verified that it works using a different tool, and I need you to integrate it with the agent. If you need to know the names of the tools ahead of time, you can ask me and I can provide them to you.
* When using MCP servers, be sure we have a valid MCP client, and let FastMCP auto-detect the transport. Trust the process on this and don't overthink it. This is not the same as a regular API.
* If I ask you "Can we do X?" I really do just want you to answer that question, giving me enough detail to understand the answer and make a decision. I do NOT mean "answer user briefly and then run off and implement X." This is important because sometimes I may have a follow-up question in mind, or want to discuss implementation steps prior to us actually doing the implementation.
