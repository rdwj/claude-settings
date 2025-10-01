---
description: Create a proposal document for implementing a feature or working a user story using the proposal-writer subagent.
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

1. Use the Task tool to launch the proposal-writer subagent with the following information:
   - The user's request or user story: $ARGUMENTS
   - Request that the proposal be created in the `proposals/` directory
   - The proposal should follow standard proposal format with:
     * Problem statement
     * Proposed solution
     * Technical approach
     * Implementation considerations
     * Testing strategy
     * Timeline/effort estimate

2. The proposal-writer subagent will handle:
   - Analyzing the feature or user story requirements
   - Researching relevant codebase context
   - Creating a comprehensive proposal document
   - Placing the proposal in the proposals/ directory with an appropriate filename

Context for proposal generation: $ARGUMENTS