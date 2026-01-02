# Troubleshooting Claude CLI Installation Issues

## Multiple Installations Warning

If you see a warning about multiple installations of the Claude CLI, you have two installations detected on your system. This can cause confusion about which version is being used.

### Symptoms

```
Warning: Multiple installations found
- npm-global at /root/.npm-global/bin/claude
- native at /root/.local/bin/claude
```

### Solution: Remove Duplicate Installation

Since the `npm-global` installation is currently active and working, remove the native installation:

1. **Check which installation is currently being used:**
   ```bash
   which claude
   ```
   This should show `/root/.npm-global/bin/claude`

2. **Verify the native installation exists:**
   ```bash
   ls -la /root/.local/bin/claude
   ```

3. **Remove the native installation:**
   ```bash
   rm /root/.local/bin/claude
   ```

4. **Update configuration to use npm-global:**
   If you get an error like "installMethod is native, but claude command not found", you need to update the configuration. Use the npm-global installation directly:
   ```bash
   /root/.npm-global/bin/claude config set --global installMethod npm-global
   ```
   
   **Alternative:** If that doesn't work, manually edit the configuration file:
   ```bash
   # Check if config file exists
   ls -la ~/.claude/settings.json
   
   # Edit the file and change installMethod to "npm-global"
   nano ~/.claude/settings.json
   # Look for "installMethod": "native" and change it to "installMethod": "npm-global"
   ```

5. **Verify the fix:**
   ```bash
   claude diagnostics
   ```
   The warning should no longer appear, and claude should work correctly.

### Alternative: Keep Native Installation

If you prefer to use the native installation instead:

1. **Uninstall the npm-global version:**
   ```bash
   npm uninstall -g @anthropic-ai/claude
   ```

2. **Ensure your PATH prioritizes the native installation:**
   Check your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.) and ensure `/root/.local/bin` comes before `/root/.npm-global/bin` in the PATH:
   ```bash
   echo $PATH | grep -o '[^:]*' | grep -E '(npm-global|local/bin)'
   ```

3. **Restart your shell** or reload your configuration:
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

### Recommended Setup

For Ubuntu/WSL, the **npm-global** installation method is recommended because:
- It's easier to update via npm
- It integrates well with Node.js tooling
- It's the method shown in the official Claude CLI documentation

### Error: "installMethod is native, but claude command not found"

If you removed the native installation and get this error, the configuration still references the native method. Fix it by:

1. **Use npm-global claude directly to update config:**
   ```bash
   /root/.npm-global/bin/claude config set --global installMethod npm-global
   ```

2. **Or manually edit the config file:**
   ```bash
   # Edit the config file
   nano ~/.claude/settings.json
   # Find "installMethod": "native" and change to "installMethod": "npm-global"
   # Save and exit (Ctrl+X, then Y, then Enter)
   ```

3. **Verify:**
   ```bash
   claude diagnostics
   ```

### Prevention

To avoid this issue in the future:
- Use only one installation method (either npm-global or native)
- If installing via npm, avoid installing the native version
- Check your PATH variable to ensure only one installation directory is present
- Before removing an installation, update the config first using: `claude config set --global installMethod <method>`
