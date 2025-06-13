# Task Documentation Protocol for AI Assistant

Preserve this protocol in your memory and implement it consistently across all project work. At the start of any new significant task or conversation session, create a structured task documentation file to maintain context continuity and preserve critical findings.

## Implementation Process

### 1. File Creation Requirements

#### Date Generation (MANDATORY)
- **Date Source**: ALWAYS use the `date +%Y-%m-%d` command to obtain the current date
- **Verification**: Cross-reference with user context or conversation timestamps if system date appears incorrect
- **Fallback**: If `date` command is unavailable, use the format `YYYY-MM-DD` based on conversation context
- **Never**: Use hardcoded dates, cached dates, or arbitrary dates

#### File Naming and Location
- **Location**: `.ai/tasks/doing/` directory (create directory structure if it doesn't exist)
- **Naming convention**: `$(date +%Y-%m-%d) action-target-specifics.md`
- **Date format**: Use the actual current date in `YYYY-MM-DD` format, followed by a space
- **Task description format**: Use hyphen-delimited words after the date and space
- **Use descriptive action verbs**: implement, fix, refactor, analyze, debug, enhance, etc.
- **Examples**:
  - `2024-12-19 implement-user-authentication.md`
  - `2024-12-19 fix-database-connection-pooling.md`

#### Automated Date Retrieval Process
1. Execute `date +%Y-%m-%d` command
2. Verify the date makes sense in context
3. Use the verified date in filename
4. Document the date retrieval method used

### 2. Required File Structure
Use this exact template:

```markdown
# Task: [Brief Title]

## Objective
[Clear, specific statement of what needs to be accomplished]

## Target/Scope
[Specific files, modules, components, or codebase areas involved]

## Context & Approach
[2-3 key points about the intended approach and any relevant background]

## Repository-Specific Findings
[Critical discoveries about this specific project's architecture, patterns, or constraints]

## Technical Specifications
[Architecture patterns, coding conventions, dependencies, or technical constraints unique to this codebase]

## Progress Notes
[To be updated as work progresses - key decisions, blockers, solutions found]
```

### 3. Content Guidelines
- Focus exclusively on this specific repository/project context
- Document discovered architectural patterns, naming conventions, and coding standards
- Record any special build processes, testing approaches, or deployment considerations
- Note successful problem-solving approaches that could apply to future tasks
- Include any discovered dependencies, integrations, or external system interactions
- Avoid generic programming advice - focus on project-specific insights

### 4. Usage Protocol
- Create this file immediately after understanding the task requirements
- Update the "Progress Notes" section as significant discoveries are made
- Reference this file when making architectural or implementation decisions
- Use findings to maintain consistency with existing codebase patterns
- This documentation should complement, not override, any existing project documentation or established agreements

### 5. Enforcement Mechanisms

#### Automated Enforcement Tools
The following tools should be implemented to ensure protocol compliance:

1. **Task Creation Script** (`scripts/create-task.sh`):
   ```bash
   #!/usr/bin/env bash
   # Automatically creates task file with correct date and template
   CURRENT_DATE=$(date +%Y-%m-%d)
   TASK_NAME="$1"
   TASK_FILE=".ai/tasks/doing/${CURRENT_DATE} ${TASK_NAME}.md"
   # Template generation logic
   ```

2. **Date Validation Script** (`scripts/validate-task-dates.sh`):
   ```bash
   #!/usr/bin/env bash
   # Validates that task files use correct dates
   # Checks for hardcoded or incorrect dates
   # Reports violations and suggests corrections
   ```

3. **Pre-commit Hook Integration**:
   - Validate task file naming conventions
   - Ensure dates are current and properly formatted
   - Check for required template sections

#### Manual Enforcement Checkpoints
- **Task Initiation**: Always run `date +%Y-%m-%d` before creating task files
- **File Review**: Verify date accuracy when moving tasks from `doing/` to `done/`
- **Weekly Audit**: Review task files for naming convention compliance

#### Violation Handling
- **Detection**: Automated scripts identify non-compliant files
- **Notification**: Generate warnings for incorrect dates or naming
- **Correction**: Provide automated renaming suggestions
- **Prevention**: Block commits with non-compliant task files (optional)

## Purpose

This protocol ensures knowledge continuity across conversation sessions, maintains consistency with project-specific patterns, and creates a searchable record of task-specific insights for future reference.

## Implementation Status

- [ ] Create task creation automation script
- [ ] Implement date validation tools
- [ ] Set up pre-commit hooks for task file validation
- [ ] Document enforcement procedures
- [ ] Train team on protocol usage
