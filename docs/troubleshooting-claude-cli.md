# Troubleshooting Claude Code CLI Installation Issues

This page focuses on fixing **Windows** setups where both the **native installer** and the **npm-global** install exist, and Windows is picking the wrong `claude` on your PATH.

## Prefer npm-global on Windows (recommended)

The recommended Windows setup is:
- Install/update via npm: `npm install -g @anthropic-ai/claude-code@latest`
- Ensure `claude` resolves to your npm global bin (usually `%APPDATA%\npm\claude.cmd`)

## Fix: Remove native install and force npm version

### 1) See every `claude` on your PATH

Run in PowerShell:

```powershell
# Shows all matches in PATH order (first one is what runs)
where.exe claude

# Shows all commands PowerShell can resolve
Get-Command claude -All | Format-Table -AutoSize CommandType, Source
```

**You want the first entry** to be under your npm global directory (commonly `C:\Users\<you>\AppData\Roaming\npm\claude.cmd`).

### 2) Remove the native installation

Do these in this order:

1. **Uninstall the native app**:
   - Windows: **Settings → Apps → Installed apps** (or “Apps & features”)
   - Uninstall **Claude Code** (or similar name if present)

2. **Delete leftover “native” binaries (if they exist)**:

```powershell
# Common native-installer location mentioned in Claude Code docs
Remove-Item -Force "$env:USERPROFILE\.local\bin\claude.exe" -ErrorAction SilentlyContinue
Remove-Item -Force "$env:USERPROFILE\.local\bin\claude" -ErrorAction SilentlyContinue
```

3. **Make sure PATH no longer prefers the native folder**:
   - If `%USERPROFILE%\.local\bin` is on your PATH, remove it (or ensure `%APPDATA%\npm` comes before it).
   - Close/reopen your terminal after changing PATH.

### 3) Ensure the npm version is installed (or reinstall it)

```powershell
npm install -g @anthropic-ai/claude-code@latest
```

### 4) Update Claude Code’s install method (if you see mismatch errors)

If you see errors/warnings like **“installMethod is native”** after removing the native install, set it to npm-global:

```powershell
# Claude Code stores this in a small JSON config file (see below).
# There isn't a `claude config set -g ...` command in current versions.
```

#### Manual fix (recommended)

Edit:
- `%USERPROFILE%\.config\claude\config.json`

Set:

```json
{
  "installMethod": "npm-global"
}
```

### 5) Verify

```powershell
where.exe claude
claude --version

# One of these will exist depending on your CLI version
claude doctor
claude diagnostics
```

## Prevention checklist

- Keep **only one** installation method active (prefer **npm-global** on Windows).
- Use `where.exe claude` after installs/updates to confirm you’re running the expected binary.
