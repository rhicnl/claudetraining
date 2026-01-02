#!/bin/bash
# Fix multiple Claude CLI installations
# This script removes the native installation, keeping the npm-global one

echo "Checking current Claude installation..."
which claude

echo ""
echo "Checking if native installation exists..."
if [ -f /root/.local/bin/claude ]; then
    echo "Found native installation at /root/.local/bin/claude"
    echo "Removing it (keeping npm-global installation)..."
    rm /root/.local/bin/claude
    echo "✓ Native installation removed"
else
    echo "No native installation found"
fi

echo ""
echo "Verifying fix..."
claude diagnostics
