#!/usr/bin/env bash
# Task Date Validation Script - Enforces Task Documentation Protocol
# Validates that task files use correct dates and naming conventions

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

# Get current date for validation
CURRENT_DATE=$(date +%Y-%m-%d 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$CURRENT_DATE" ]; then
    print_status $RED "Error: Failed to retrieve current date"
    exit 1
fi

print_status $BLUE "🔍 Task Date Validation Report"
print_status $BLUE "Current date: $CURRENT_DATE"
echo ""

# Initialize counters
TOTAL_FILES=0
VALID_FILES=0
INVALID_FILES=0
FUTURE_DATES=0
OLD_DATES=0
INVALID_FORMAT=0

# Arrays to store issues
declare -a INVALID_FORMAT_FILES
declare -a FUTURE_DATE_FILES
declare -a OLD_DATE_FILES
declare -a MISSING_DATE_FILES

# Function to validate date format
validate_date_format() {
    local date_str="$1"
    if [[ $date_str =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to compare dates
compare_dates() {
    local file_date="$1"
    local current_date="$2"
    
    # Convert dates to comparable format (remove hyphens)
    local file_date_num=$(echo "$file_date" | tr -d '-')
    local current_date_num=$(echo "$current_date" | tr -d '-')
    
    if [ "$file_date_num" -gt "$current_date_num" ]; then
        return 1  # Future date
    elif [ "$file_date_num" -lt "$current_date_num" ]; then
        return 2  # Past date
    else
        return 0  # Current date
    fi
}

# Function to check if date is too old (more than 30 days)
is_date_too_old() {
    local file_date="$1"
    local current_date="$2"
    
    # Simple check: if year is different or month difference is significant
    local file_year=$(echo "$file_date" | cut -d'-' -f1)
    local file_month=$(echo "$file_date" | cut -d'-' -f2)
    local current_year=$(echo "$current_date" | cut -d'-' -f1)
    local current_month=$(echo "$current_date" | cut -d'-' -f2)
    
    if [ "$file_year" -lt "$current_year" ]; then
        return 0  # Different year, likely too old
    elif [ "$file_year" -eq "$current_year" ] && [ "$((current_month - file_month))" -gt 1 ]; then
        return 0  # More than 1 month difference
    else
        return 1  # Not too old
    fi
}

# Check .ai/tasks directories
TASK_DIRS=(".ai/tasks/doing" ".ai/tasks/done" ".ai/tasks/backlog")

for dir in "${TASK_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        print_status $YELLOW "⚠️  Directory not found: $dir"
        continue
    fi
    
    print_status $BLUE "📁 Checking directory: $dir"
    
    # Find all .md files in the directory
    while IFS= read -r -d '' file; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        filename=$(basename "$file")
        
        # Extract date from filename (first 10 characters should be YYYY-MM-DD)
        if [[ ${#filename} -ge 10 ]]; then
            file_date="${filename:0:10}"
            
            # Validate date format
            if validate_date_format "$file_date"; then
                # Check if date is reasonable
                compare_dates "$file_date" "$CURRENT_DATE"
                date_comparison=$?
                
                case $date_comparison in
                    0)  # Current date
                        VALID_FILES=$((VALID_FILES + 1))
                        print_status $GREEN "  ✓ $filename"
                        ;;
                    1)  # Future date
                        FUTURE_DATES=$((FUTURE_DATES + 1))
                        INVALID_FILES=$((INVALID_FILES + 1))
                        FUTURE_DATE_FILES+=("$file")
                        print_status $RED "  ✗ $filename (future date: $file_date)"
                        ;;
                    2)  # Past date
                        if is_date_too_old "$file_date" "$CURRENT_DATE"; then
                            OLD_DATES=$((OLD_DATES + 1))
                            INVALID_FILES=$((INVALID_FILES + 1))
                            OLD_DATE_FILES+=("$file")
                            print_status $YELLOW "  ⚠ $filename (old date: $file_date)"
                        else
                            VALID_FILES=$((VALID_FILES + 1))
                            print_status $GREEN "  ✓ $filename (recent date: $file_date)"
                        fi
                        ;;
                esac
            else
                INVALID_FORMAT=$((INVALID_FORMAT + 1))
                INVALID_FILES=$((INVALID_FILES + 1))
                INVALID_FORMAT_FILES+=("$file")
                print_status $RED "  ✗ $filename (invalid date format: $file_date)"
            fi
        else
            MISSING_DATE_FILES+=("$file")
            INVALID_FILES=$((INVALID_FILES + 1))
            print_status $RED "  ✗ $filename (no date prefix)"
        fi
    done < <(find "$dir" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null)
    
    echo ""
done

# Print summary
print_status $BLUE "📊 Validation Summary"
echo "Total files checked: $TOTAL_FILES"
echo "Valid files: $VALID_FILES"
echo "Invalid files: $INVALID_FILES"
echo ""

if [ $INVALID_FILES -gt 0 ]; then
    print_status $YELLOW "Issues found:"
    
    if [ $INVALID_FORMAT -gt 0 ]; then
        echo "  • Invalid date format: $INVALID_FORMAT files"
    fi
    
    if [ $FUTURE_DATES -gt 0 ]; then
        echo "  • Future dates: $FUTURE_DATES files"
    fi
    
    if [ $OLD_DATES -gt 0 ]; then
        echo "  • Old dates: $OLD_DATES files"
    fi
    
    echo ""
    
    # Provide correction suggestions
    print_status $BLUE "🔧 Suggested Corrections:"
    
    if [ ${#FUTURE_DATE_FILES[@]} -gt 0 ]; then
        print_status $YELLOW "Future date files (likely system clock issues):"
        for file in "${FUTURE_DATE_FILES[@]}"; do
            filename=$(basename "$file")
            new_filename="${CURRENT_DATE}${filename:10}"
            echo "  mv '$file' '$(dirname "$file")/$new_filename'"
        done
        echo ""
    fi
    
    if [ ${#INVALID_FORMAT_FILES[@]} -gt 0 ]; then
        print_status $YELLOW "Invalid format files:"
        for file in "${INVALID_FORMAT_FILES[@]}"; do
            echo "  Review and rename: $file"
        done
        echo ""
    fi
    
    # Generate fix script
    if [ $INVALID_FILES -gt 0 ]; then
        FIX_SCRIPT="scripts/fix-task-dates.sh"
        print_status $BLUE "💡 Generating fix script: $FIX_SCRIPT"
        
        cat > "$FIX_SCRIPT" << 'EOF'
#!/usr/bin/env bash
# Auto-generated script to fix task date issues
# Review each command before executing

set -e

echo "🔧 Task Date Fix Script"
echo "Review each command before executing!"
echo ""

EOF
        
        # Add fix commands for future dates
        for file in "${FUTURE_DATE_FILES[@]}"; do
            filename=$(basename "$file")
            new_filename="${CURRENT_DATE}${filename:10}"
            echo "# Fix future date: $filename" >> "$FIX_SCRIPT"
            echo "mv '$file' '$(dirname "$file")/$new_filename'" >> "$FIX_SCRIPT"
            echo "" >> "$FIX_SCRIPT"
        done
        
        chmod +x "$FIX_SCRIPT"
        print_status $GREEN "✓ Fix script created: $FIX_SCRIPT"
    fi
    
    exit 1
else
    print_status $GREEN "🎉 All task files have valid dates!"
    exit 0
fi
