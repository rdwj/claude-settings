# Approve Story

Approve the story at `{{file}}` and move it to the done directory.

## Process

1. **Verify location**: Confirm the story is currently in `ready-for-human-review/`
   - If not, explain that stories must be in ready-for-human-review before approval

2. **Promote to done**: Use the promotion script to move the story:
   ```bash
   ./project-management/scripts/promote.sh [filename] done
   ```

3. **Confirm**: Provide a brief confirmation message that the story has been approved and moved to done

## Note

This command should typically be used by humans after reviewing completed work. If you're an AI assistant being asked to approve work, first verify that:
- All acceptance criteria are met
- Code review has been performed
- Tests are passing
- The human has explicitly requested approval
