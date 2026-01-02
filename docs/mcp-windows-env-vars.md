# MCP on Windows: set required environment variables (persistent)

Some MCP servers read credentials from **environment variables** at startup. If those variables are missing, Claude/Cursor shows warnings like “Missing environment variables …”.

This repo’s `.mcp.json` expects:

- `GITHUB_PERSONAL_ACCESS_TOKEN` (GitHub MCP server)
- `FIRECRAWL_API_KEY` (Firecrawl MCP server)
- `SUPABASE_DB_URL` (used for Postgres connection string)

> Note: Keeping `.env` files blocked in `.claude/settings.json` is fine. MCP servers don’t need Claude to read `.env` files; they need the variables present in the **process environment**.

## Set variables for your user (persistent)

Run these in **PowerShell** (not as admin). Replace the values with your own:

```powershell
[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN","<your_token_here>","User")
[Environment]::SetEnvironmentVariable("FIRECRAWL_API_KEY","<your_key_here>","User")
[Environment]::SetEnvironmentVariable("SUPABASE_DB_URL","postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres","User")
```

Then **fully restart Cursor/Claude** (close all windows, reopen). Environment variables are read when the app process starts.

## If Claude Code is running in WSL (/mnt/… paths)

If the MCP screen shows paths like `/mnt/d/...` and config/log locations under `/root/...`, your Claude Code process is running in a **Linux environment (WSL)**. In that case, setting variables in PowerShell won’t help—set them in WSL instead.

### Set variables in WSL for the current shell (temporary)

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="<your_token_here>"
export FIRECRAWL_API_KEY="<your_key_here>"
export SUPABASE_DB_URL="postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres"
```

#### Verify in WSL

Check that the variables are set in your current WSL shell:

```bash
echo "$GITHUB_PERSONAL_ACCESS_TOKEN"
echo "$FIRECRAWL_API_KEY"
echo "$SUPABASE_DB_URL"
```

Or check which ones are present (without printing values):

```bash
printenv | grep -E '^(GITHUB_PERSONAL_ACCESS_TOKEN|FIRECRAWL_API_KEY|SUPABASE_DB_URL)='
```

If the `echo` commands print blank lines, the variables are **not set in that shell**. After verifying, restart Claude Code from that same WSL environment.

### Persist variables in WSL (recommended)

Append them to your shell profile (most commonly `~/.profile` or `~/.bashrc`):

```bash
printf '\nexport GITHUB_PERSONAL_ACCESS_TOKEN="%s"\nexport FIRECRAWL_API_KEY="%s"\nexport SUPABASE_DB_URL="%s"\n' \
  "<your_token_here>" "<your_key_here>" "postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres" \
  >> ~/.profile
```

Then restart Claude Code (or start a new WSL shell and relaunch it) so it picks up the variables. Use the verification commands above to confirm they're set in a new shell.

### Verify in PowerShell (Windows native setup)

If you set variables in PowerShell for Windows native usage, verify in a **new PowerShell window**:

```powershell
$env:GITHUB_PERSONAL_ACCESS_TOKEN
$env:FIRECRAWL_API_KEY
$env:SUPABASE_DB_URL
```

## Set variables for the current session only (temporary)

This lasts only until you close that PowerShell (and only affects programs launched from it):

```powershell
$env:GITHUB_PERSONAL_ACCESS_TOKEN="<your_token_here>"
$env:FIRECRAWL_API_KEY="<your_key_here>"
$env:SUPABASE_DB_URL="postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres"
```

Verify in the same PowerShell session:

```powershell
$env:GITHUB_PERSONAL_ACCESS_TOKEN
$env:FIRECRAWL_API_KEY
$env:SUPABASE_DB_URL
```

## Remove a variable (optional)

```powershell
[Environment]::SetEnvironmentVariable("FIRECRAWL_API_KEY",$null,"User")
```

## If you don’t use a server

If you don’t plan to use GitHub/Firecrawl/Postgres MCP in this repo, you can remove that server block from `.mcp.json` to eliminate the warning.

