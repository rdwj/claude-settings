# Review Proposal Command

Please review the proposal document at `{{file}}` for architectural compliance and security concerns.

## CRITICAL: Sequential Execution Required

**DO NOT launch both subagents in parallel.** Both subagents will edit the same proposal file, which will cause file corruption and data loss if they run simultaneously.

## Phase 1: Architecture Review

Launch the **architecture-reviewer** subagent to validate the proposal.

**IMPORTANT**: Wait for the architecture-reviewer to complete its work and return results before proceeding to Phase 2.

## Phase 2: Security Review

**ONLY AFTER** the architecture review is complete, launch the **security-reviewer** subagent to analyze the same proposal document for potential security vulnerabilities, compliance issues, and security best practices.

## Process Requirements

**YOU MUST**:
- Launch architecture-reviewer first
- Wait for it to complete and return its findings
- Then launch security-reviewer second
- Wait for it to complete and return its findings

**DO NOT**:
- Launch both subagents in the same tool call batch
- Start security-reviewer before architecture-reviewer finishes
- Allow parallel execution of these subagents

**Reason**: Both subagents will modify the proposal file by adding their review findings. Parallel execution will result in race conditions and file corruption.
