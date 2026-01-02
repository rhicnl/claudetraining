# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a boiler plate Next.js application to use as a template for future projects. Built with Next.js 16, React 19, TypeScript, Tailwind CSS, and Supabase.

## Repository Structure

The repository uses a standard `.gitignore` that excludes:
- Editor/IDE files (.vscode, .idea, etc.)
- Environment variables (.env files)
- Common dependency directories (node_modules, __pycache__)
- Build outputs (dist/, build/)
- Logs and temporary files

## Development Workflow

This is a fresh repository without established build, test, or lint commands. When code is added to this project, update this file with:
- Build/test/lint commands specific to the technology stack
- Architecture patterns and design decisions
- Key integration points or conventions

## Code style
- Use TypeScript strict mode
- Follow Next.js 16 App Router patterns
- Server Components by default
- Use Tailwind CSS for styling
- Follow Supabase authentication patterns with `@supabase/ssr`


## Commands
- `npm run dev` - Start development server
- `npm run test` - Run test suite
- `npm run lint` - Run ESLint linter
- `npm run type-check` - Run TypeScript type checking

## MCP Server Configuration

This project supports MCP (Model Context Protocol) servers to extend Claude Code's capabilities with external tools, databases, and APIs.

### Setup

1. **Copy the sample configuration**:
   ```bash
   cp .mcp.json.sample .mcp.json
   ```

2. **Edit `.mcp.json`** and keep only the servers you need

3. **Set required environment variables** in `.env.local`:
   ```bash
   # GitHub MCP Server
   GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token

   # Supabase Database Connection
   SUPABASE_DB_URL=postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

   # Firecrawl API
   FIRECRAWL_API_KEY=your_firecrawl_key
   ```

4. **Authenticate Supabase MCP server** (OAuth):
   - Start Claude Code
   - Type `/mcp` in the conversation
   - Select Supabase and follow the browser authentication flow

5. **Restart Claude Code** to load the configuration

### Available MCP Servers

This project uses the following MCP servers:

- **GitHub** (`@modelcontextprotocol/server-github`) - Repository management, PRs, issues, code reviews
- **Playwright** (`@modelcontextprotocol/server-playwright`) - Browser automation and E2E testing
- **Firecrawl** (`firecrawl-mcp`) - Advanced web scraping and crawling
- **Supabase** (OAuth) - Supabase platform integration and management
- **PostgreSQL** (`@modelcontextprotocol/server-postgres`) - Direct database access for queries and operations
- **Desktop Commander** (`@modelcontextprotocol/server-desktop-commander`) - Desktop automation and system commands
- **Toolbox** (`@modelcontextprotocol/server-toolbox`) - Collection of development utility tools

### Usage

Once configured, you can interact with MCP servers through:
- **Tools**: Claude automatically calls MCP functions when needed
- **Resources**: Reference with `@servername:resource://path`
- **Prompts**: Use slash commands like `/mcp__github__list_prs`

Type `@` to see available resources or `/` to see available commands.

### Security Notes

- Never commit `.mcp.json` with hardcoded credentials
- Always use environment variables for sensitive data
- Add `.mcp.json` to `.gitignore` if it contains secrets
- Keep `.mcp.json.sample` as the template in version control
