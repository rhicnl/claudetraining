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

4. **Verify the fix:**
   ```bash
   claude diagnostics
   ```
   The warning should no longer appear.

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

### Prevention

To avoid this issue in the future:
- Use only one installation method (either npm-global or native)
- If installing via npm, avoid installing the native version
- Check your PATH variable to ensure only one installation directory is present
