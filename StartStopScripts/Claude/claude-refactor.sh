#!/bin/bash

echo "Claude Refactor initiated..."
echo "Analyzing repository for documentation updates needed..."

# Check git status to see what files have changed
echo "=== Git Status ==="
git status --porcelain

echo ""
echo "=== Recent Changes ==="
git diff --name-only HEAD~5..HEAD 2>/dev/null || echo "No recent commits to compare"

echo ""
echo "=== Directory Structure Analysis ==="
echo "Current directory structure:"
find . -type d -name ".*" -prune -o -type d -print | head -20

echo ""
echo "Claude should now:"
echo "1. Review the above changes and directory structure"
echo "2. Check if README.md and CLAUDE.md files need updates"
echo "3. Ask for permission before making any changes"
echo ""
echo "Triggering Claude analysis..."

# This is where Claude would be notified to start the analysis
# For now, we'll just output a message that Claude can see
echo "CR_COMMAND_EXECUTED" > /tmp/claude-refactor-trigger