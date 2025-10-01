# Post-Implementation Review

Please perform a thorough code review of the implementation for the story at `{{file}}`.

## Process

1. **Read the story**: Review the user story file to understand the acceptance criteria and implementation requirements

2. **Identify changed files**: Based on the story description and implementation notes, identify all files that were modified or created

3. **Code review**: Use the **senior-code-reviewer** subagent to review the implementation:
   - Check for breaking changes
   - Identify code duplication
   - Verify architectural compliance
   - Review documentation quality
   - Assess test coverage
   - Check for potential bugs or edge cases

4. **Update story**: Add a "## Code Review" section to the story file with findings:
   - List any issues discovered
   - Note positive aspects of the implementation
   - Recommend improvements if needed

5. **Status decision**:
   - If critical issues found: Move story to `blocked` and document what needs fixing
   - If minor issues found: Document them but story can proceed to review
   - If implementation looks good: Story stays in current status for human review

## Output

Provide a summary of:
- Files reviewed
- Key findings (issues, improvements, positive notes)
- Recommendation on whether the story is ready for human review
