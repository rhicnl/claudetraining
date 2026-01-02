# Installing Claude Code on Windows

This guide explains how to install Claude Code on Windows using npm, which is the recommended method when the native installer doesn't work properly.

## Prerequisites

Before installing Claude Code, you need:

1. **Node.js 18 or higher** - Download from [nodejs.org](https://nodejs.org/)
2. **npm** (comes with Node.js) - Verify installation:
   ```powershell
   node --version
   npm --version
   ```

## Why Use npm Instead of the Native Installer?

The native Windows installer (`irm https://claude.ai/install.ps1 | iex`) has a known issue where it may:
- Report success but fail to create the `claude.exe` file
- Leave the installation directory empty
- Create a zero-byte executable file

**Solution**: Use npm to install globally, which is more reliable and easier to manage.

## If You Previously Used the Native Installer (Recommended Cleanup)

If you ever ran the native installer (`irm https://claude.ai/install.ps1 | iex`), remove it first so Windows doesn’t pick the wrong `claude` from PATH.

1. **See which `claude` you’re currently running:**

```powershell
where.exe claude
Get-Command claude -All | Format-Table -AutoSize CommandType, Source
```

2. **Uninstall the native app (if present):**
   - Windows: **Settings → Apps → Installed apps** (or “Apps & features”)
   - Uninstall **Claude Code** (or similar)

3. **Remove leftover native binaries (if they exist):**

```powershell
Remove-Item -Force "$env:USERPROFILE\.local\bin\claude.exe" -ErrorAction SilentlyContinue
Remove-Item -Force "$env:USERPROFILE\.local\bin\claude" -ErrorAction SilentlyContinue
```

4. **Restart your terminal** and confirm `where.exe claude` points to your npm global directory (usually `%APPDATA%\npm\claude.cmd`).

## Installation Steps

### Step 1: Install Claude Code via npm

Open PowerShell (as a regular user, admin not required) and run:

```powershell
npm install -g @anthropic-ai/claude-code
```

You should see output like:
```
added 16 packages in 1s
```

### Step 2: Verify Installation

Check that Claude Code is installed and accessible:

```powershell
# Check if the command is found
where.exe claude

# Verify the version
claude --version
```

Expected output:
```
C:\Users\YourUsername\AppData\Roaming\npm\claude
C:\Users\YourUsername\AppData\Roaming\npm\claude.cmd
2.0.76 (Claude Code)
```

### Step 3: Configure Authentication

Run the configuration command:

```powershell
claude config
```

Follow the prompts to complete authentication setup.

If you see warnings about the install method (for example after removing a native install), set it explicitly:

```powershell
# Current versions don't support `claude config set -g ...`.
# Set installMethod by editing the config file directly (see below).
```

Manual fix:
- Edit `%USERPROFILE%\.config\claude\config.json`
- Set `"installMethod": "npm-global"`

## Installation Location

When installed via npm, Claude Code is located at:
```
C:\Users\YourUsername\AppData\Roaming\npm\
```

This directory is **automatically added to your PATH** when Node.js is installed, so you don't need to manually configure it.

## Troubleshooting

### Issue: "claude is not recognized"

**Solution**: 
1. Ensure Node.js is installed and npm is in your PATH
2. Verify npm global prefix: `npm prefix -g`
3. Check if the path is in your PATH: `$env:Path -split ";" | Where-Object { $_ -like "*npm*" }`
4. Restart your PowerShell/terminal window

### Issue: Permission errors during installation

**Solution**: 
- Don't run PowerShell as Administrator for npm global installs (can cause permission issues)
- If you must use admin, configure npm to use a different directory:
  ```powershell
  npm config set prefix "$env:APPDATA\npm"
  ```

### Issue: Old version after update

**Solution**: 
- Update via npm: `npm install -g @anthropic-ai/claude-code@latest`
- Clear npm cache if needed: `npm cache clean --force`

## Updating Claude Code

To update to the latest version:

```powershell
npm install -g @anthropic-ai/claude-code@latest
```

Or simply:
```powershell
npm install -g @anthropic-ai/claude-code
```

## Uninstalling

If you need to uninstall:

```powershell
npm uninstall -g @anthropic-ai/claude-code
```

## Alternative: Native Installer (If It Works)

**Note**: The native installer may work for some users, but it's unreliable. If you want to try it:

```powershell
irm https://claude.ai/install.ps1 | iex
```

**Common issues with native installer:**
- Reports success but creates empty directory
- Creates zero-byte `claude.exe` file
- Installation directory: `%USERPROFILE%\.local\bin\` may not be in PATH

If the native installer fails, use the npm method described above instead.

## Next Steps

After installation:

1. **Configure MCP servers** - See `docs/mcp-windows-env-vars.md`
2. **Set up environment variables** for MCP servers that require them
3. **Restart Cursor/Claude Code** to pick up the new installation

## Verification Checklist

- [ ] Node.js 18+ installed
- [ ] npm available in PATH
- [ ] Claude Code installed via npm
- [ ] `claude --version` works
- [ ] `claude config` completed successfully
- [ ] `claude` command accessible from any PowerShell window

---

**Last Updated**: 2026-01-02  
**Recommended Method**: npm global installation  
**Tested On**: Windows 10/11 with Node.js 22.15.0
