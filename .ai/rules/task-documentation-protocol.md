# Task Documentation Protocol for AI Assistant

Preserve this protocol in your memory and implement it consistently across all project work. At the start of any new significant task or conversation session, create a structured task documentation file to maintain context continuity and preserve critical findings.

## Implementation Process

### 1. File Creation Requirements
- **Location**: `.ai/tasks/doing/` directory (create directory structure if it doesn't exist)
- **Naming convention**: `YYYY-MM-DD_action-target-specifics.md`
- **Use current date and descriptive action verbs**: implement, fix, refactor, analyze, debug, enhance, etc.
- **Examples**: 
  - `2025-01-15 implement-user-authentication.md`
  - `2025-01-15 fix-database-connection-pooling.md`

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

## Purpose

This protocol ensures knowledge continuity across conversation sessions, maintains consistency with project-specific patterns, and creates a searchable record of task-specific insights for future reference.
