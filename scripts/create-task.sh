#!/usr/bin/env bash
# Task Creation Script - Enforces Task Documentation Protocol
# Usage: ./scripts/create-task.sh "action-target-specifics" ["brief-title"]

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Validate input
if [ $# -lt 1 ]; then
    print_status $RED "Error: Task name is required"
    echo "Usage: $0 \"action-target-specifics\" [\"brief-title\"]"
    echo "Example: $0 \"implement-user-authentication\" \"User Authentication System\""
    exit 1
fi

TASK_NAME="$1"
BRIEF_TITLE="${2:-$TASK_NAME}"

# Get current date reliably
print_status $BLUE "🕒 Retrieving current date..."
CURRENT_DATE=$(date +%Y-%m-%d 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$CURRENT_DATE" ]; then
    print_status $RED "Error: Failed to retrieve current date using 'date' command"
    print_status $YELLOW "Please ensure the 'date' command is available or manually specify the date"
    exit 1
fi

print_status $GREEN "✓ Current date: $CURRENT_DATE"

# Validate date format
if [[ ! $CURRENT_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    print_status $RED "Error: Invalid date format: $CURRENT_DATE"
    print_status $YELLOW "Expected format: YYYY-MM-DD"
    exit 1
fi

# Create directory structure if it doesn't exist
TASKS_DIR=".ai/tasks"
DOING_DIR="$TASKS_DIR/doing"

print_status $BLUE "📁 Creating directory structure..."
mkdir -p "$DOING_DIR"
mkdir -p "$TASKS_DIR/done"
mkdir -p "$TASKS_DIR/backlog"

# Generate filename
TASK_FILE="$DOING_DIR/${CURRENT_DATE} ${TASK_NAME}.md"

# Check if file already exists
if [ -f "$TASK_FILE" ]; then
    print_status $YELLOW "⚠️  Warning: Task file already exists: $TASK_FILE"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status $BLUE "Operation cancelled"
        exit 0
    fi
fi

# Create task file with template
print_status $BLUE "📝 Creating task file..."

cat > "$TASK_FILE" << EOF
# Task: $BRIEF_TITLE

**Created**: $CURRENT_DATE  
**Status**: In Progress  
**Date Retrieved**: \`date +%Y-%m-%d\` command executed at $(date '+%Y-%m-%d %H:%M:%S')

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

### $(date '+%Y-%m-%d %H:%M:%S') - Task Created
- Task file created using automated script
- Date verified: $CURRENT_DATE
- Template applied successfully

## Completion Checklist
- [ ] Objective clearly defined
- [ ] Target scope identified
- [ ] Technical approach documented
- [ ] Repository patterns analyzed
- [ ] Implementation completed
- [ ] Testing completed
- [ ] Documentation updated
- [ ] Task moved to done/ directory
EOF

print_status $GREEN "✅ Task file created successfully: $TASK_FILE"

# Validate the created file
print_status $BLUE "🔍 Validating created file..."

if [ ! -f "$TASK_FILE" ]; then
    print_status $RED "Error: Failed to create task file"
    exit 1
fi

# Check file size
FILE_SIZE=$(wc -c < "$TASK_FILE")
if [ "$FILE_SIZE" -lt 100 ]; then
    print_status $RED "Error: Task file appears to be too small (${FILE_SIZE} bytes)"
    exit 1
fi

print_status $GREEN "✓ File validation passed"

# Display next steps
print_status $BLUE "📋 Next Steps:"
echo "1. Edit the task file to fill in the template sections"
echo "2. Update Progress Notes as work progresses"
echo "3. Move to .ai/tasks/done/ when completed"
echo ""
print_status $BLUE "📂 File location: $TASK_FILE"

# Optionally open the file in editor
if command -v code >/dev/null 2>&1; then
    read -p "Open in VS Code? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        code "$TASK_FILE"
    fi
elif [ -n "$EDITOR" ]; then
    read -p "Open in $EDITOR? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $EDITOR "$TASK_FILE"
    fi
fi

print_status $GREEN "🎉 Task creation completed successfully!"
