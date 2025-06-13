#!/usr/bin/env bash
# Setup script for task documentation protocol enforcement
# Creates git hooks and validation tools

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_status $BLUE "🔧 Setting up Task Documentation Protocol Enforcement"
echo ""

# Create scripts directory if it doesn't exist
mkdir -p scripts

# Make scripts executable
print_status $BLUE "📝 Making scripts executable..."
chmod +x scripts/create-task.sh 2>/dev/null || true
chmod +x scripts/validate-task-dates.sh 2>/dev/null || true

# Create git hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
print_status $BLUE "🪝 Creating pre-commit hook..."
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
# Pre-commit hook for task documentation protocol enforcement

# Check if task validation script exists
if [ -f "scripts/validate-task-dates.sh" ]; then
    echo "🔍 Validating task documentation dates..."
    
    # Run validation script
    if ! ./scripts/validate-task-dates.sh; then
        echo ""
        echo "❌ Task documentation validation failed!"
        echo "Please fix the issues above before committing."
        echo ""
        echo "To bypass this check (not recommended):"
        echo "  git commit --no-verify"
        echo ""
        exit 1
    fi
    
    echo "✅ Task documentation validation passed"
else
    echo "⚠️  Task validation script not found, skipping validation"
fi

# Continue with other pre-commit checks
exit 0
EOF

chmod +x .git/hooks/pre-commit

# Create commit-msg hook for task file validation
print_status $BLUE "📝 Creating commit-msg hook..."
cat > .git/hooks/commit-msg << 'EOF'
#!/usr/bin/env bash
# Commit message hook to suggest task documentation

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Check if this is a significant commit that should have task documentation
if [[ $COMMIT_MSG =~ ^(feat|fix|refactor|docs|style|test|chore|perf|ci|build)(\(.+\))?: ]]; then
    # Check if there are any task files in doing directory
    DOING_TASKS=$(find .ai/tasks/doing -name "*.md" 2>/dev/null | wc -l)
    
    if [ "$DOING_TASKS" -eq 0 ]; then
        echo ""
        echo "💡 Suggestion: Consider creating task documentation for this change"
        echo "   Run: ./scripts/create-task.sh \"your-task-name\""
        echo ""
    fi
fi

exit 0
EOF

chmod +x .git/hooks/commit-msg

# Create justfile for easy task management
print_status $BLUE "⚡ Creating justfile for task management..."
cat > justfile << 'EOF'
# Task Documentation Management Commands

# Create a new task with proper date and template
create-task task-name title="":
    ./scripts/create-task.sh "{{task-name}}" "{{title}}"

# Validate all task file dates and naming conventions
validate-tasks:
    ./scripts/validate-task-dates.sh

# Move a task from doing to done
complete-task task-file:
    #!/usr/bin/env bash
    if [ -f ".ai/tasks/doing/{{task-file}}" ]; then
        mv ".ai/tasks/doing/{{task-file}}" ".ai/tasks/done/{{task-file}}"
        echo "✅ Task moved to done: {{task-file}}"
    else
        echo "❌ Task file not found: .ai/tasks/doing/{{task-file}}"
        exit 1
    fi

# List all current tasks
list-tasks:
    #!/usr/bin/env bash
    echo "📋 Current Tasks:"
    echo ""
    echo "🔄 In Progress:"
    find .ai/tasks/doing -name "*.md" 2>/dev/null | sort | sed 's|.ai/tasks/doing/||' | sed 's|^|  • |' || echo "  (none)"
    echo ""
    echo "✅ Completed:"
    find .ai/tasks/done -name "*.md" 2>/dev/null | sort | tail -5 | sed 's|.ai/tasks/done/||' | sed 's|^|  • |' || echo "  (none)"
    echo ""
    echo "📝 Backlog:"
    find .ai/tasks/backlog -name "*.md" 2>/dev/null | sort | sed 's|.ai/tasks/backlog/||' | sed 's|^|  • |' || echo "  (none)"

# Clean up old task files (move very old doing tasks to done)
cleanup-tasks:
    #!/usr/bin/env bash
    echo "🧹 Cleaning up old tasks..."
    CURRENT_DATE=$(date +%Y-%m-%d)
    CUTOFF_DATE=$(date -d "30 days ago" +%Y-%m-%d 2>/dev/null || date -v-30d +%Y-%m-%d 2>/dev/null || echo "2024-01-01")
    
    find .ai/tasks/doing -name "*.md" 2>/dev/null | while read -r file; do
        filename=$(basename "$file")
        file_date="${filename:0:10}"
        
        if [[ $file_date < $CUTOFF_DATE ]]; then
            echo "Moving old task to done: $filename"
            mv "$file" ".ai/tasks/done/$filename"
        fi
    done
    
    echo "✅ Cleanup completed"

# Setup task documentation protocol (run once)
setup-protocol:
    ./scripts/setup-task-hooks.sh

# Show task documentation protocol help
help-tasks:
    #!/usr/bin/env bash
    echo "📚 Task Documentation Protocol Help"
    echo ""
    echo "Commands:"
    echo "  just create-task <name> [title]  - Create new task"
    echo "  just validate-tasks              - Validate all task dates"
    echo "  just complete-task <file>        - Move task to done"
    echo "  just list-tasks                  - List all tasks"
    echo "  just cleanup-tasks               - Clean up old tasks"
    echo ""
    echo "Examples:"
    echo "  just create-task \"fix-auth-bug\" \"Authentication Bug Fix\""
    echo "  just complete-task \"2024-12-19 fix-auth-bug.md\""
    echo ""
    echo "File naming convention:"
    echo "  YYYY-MM-DD action-target-specifics.md"
    echo ""
    echo "Directories:"
    echo "  .ai/tasks/doing/   - Active tasks"
    echo "  .ai/tasks/done/    - Completed tasks"
    echo "  .ai/tasks/backlog/ - Future tasks"
EOF

# Create task directories
print_status $BLUE "📁 Creating task directories..."
mkdir -p .ai/tasks/doing
mkdir -p .ai/tasks/done
mkdir -p .ai/tasks/backlog

# Create README for task directory
cat > .ai/tasks/README.md << 'EOF'
# Task Documentation

This directory contains task documentation following the Task Documentation Protocol.

## Directory Structure

- `doing/` - Tasks currently in progress
- `done/` - Completed tasks
- `backlog/` - Future tasks and ideas

## File Naming Convention

All task files must follow this naming pattern:
```
YYYY-MM-DD action-target-specifics.md
```

Examples:
- `2024-12-19 implement-user-auth.md`
- `2024-12-19 fix-database-connection.md`
- `2024-12-19 refactor-api-endpoints.md`

## Usage

### Create New Task
```bash
just create-task "implement-feature-x" "Feature X Implementation"
# or
./scripts/create-task.sh "implement-feature-x" "Feature X Implementation"
```

### Validate Tasks
```bash
just validate-tasks
# or
./scripts/validate-task-dates.sh
```

### Complete Task
```bash
just complete-task "2024-12-19 implement-feature-x.md"
```

### List Tasks
```bash
just list-tasks
```

## Enforcement

- Pre-commit hooks validate task file dates
- Validation scripts check naming conventions
- Automated tools ensure protocol compliance

## Protocol Reference

See `.ai/rules/task-documentation-protocol.md` for complete protocol specification.
EOF

print_status $GREEN "✅ Task documentation protocol enforcement setup complete!"
echo ""
print_status $BLUE "📋 What was created:"
echo "  • Pre-commit hook for task validation"
echo "  • Commit-msg hook for task suggestions"
echo "  • Justfile with task management commands"
echo "  • Task directory structure"
echo "  • README documentation"
echo ""
print_status $BLUE "🚀 Quick start:"
echo "  just create-task \"your-task-name\" \"Task Title\""
echo "  just validate-tasks"
echo "  just list-tasks"
echo "  just help-tasks"
echo ""
print_status $GREEN "🎉 Protocol enforcement is now active!"
