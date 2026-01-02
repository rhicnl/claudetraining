#!/bin/bash
# Fix multiple Claude CLI installations
# This script removes the native installation and updates config to use npm-global

echo "Step 1: Checking current Claude installation..."
which claude || echo "Claude not found in PATH (this is expected if config is wrong)"

echo ""
echo "Step 2: Checking if native installation exists..."
if [ -f /root/.local/bin/claude ]; then
    echo "Found native installation at /root/.local/bin/claude"
    echo "Removing it (keeping npm-global installation)..."
    rm /root/.local/bin/claude
    echo "✓ Native installation removed"
else
    echo "No native installation found (already removed)"
fi

echo ""
echo "Step 3: Updating configuration to use npm-global..."
# Try to use npm-global claude directly to change config
if [ -f /root/.npm-global/bin/claude ]; then
    echo "Using npm-global claude to update config..."
    /root/.npm-global/bin/claude config set --global installMethod npm-global
    echo "✓ Configuration updated"
else
    echo "Warning: npm-global claude not found at /root/.npm-global/bin/claude"
    echo "You may need to manually edit ~/.claude/settings.json"
fi

echo ""
echo "Step 4: Verifying fix..."
if [ -f /root/.npm-global/bin/claude ]; then
    /root/.npm-global/bin/claude diagnostics
else
    echo "Please ensure npm-global installation exists, then run: claude diagnostics"
fi
