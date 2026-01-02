# Claude Code Permissions Configuration Guide

This document explains each permission setting in `.claude/settings.json` and why it's configured the way it is.

## Table of Contents

- [Permission System Overview](#permission-system-overview)
- [Allow Permissions](#allow-permissions)
- [Ask Permissions](#ask-permissions)
- [Deny Permissions](#deny-permissions)
- [Security Best Practices](#security-best-practices)
- [Customizing for Your Project](#customizing-for-your-project)

---

## Permission System Overview

Claude Code uses a **three-tier permission system**:

| Rule Type | Behavior | Use Case |
|-----------|----------|----------|
| **allow** | Automatically permits without prompting | Safe, frequently-used operations |
| **ask** | Always prompts for confirmation | Operations that modify environment or have side effects |
| **deny** | Blocks completely (highest precedence) | Dangerous operations and sensitive data access |

### Precedence Rules

1. **deny** takes highest precedence - blocks even if in allow list
2. **ask** takes second precedence - prompts even if in allow list
3. **allow** takes lowest precedence - auto-approves if not denied or asked

### Pattern Matching

- Bash rules use **prefix matching**: `Bash(git add:*)` matches any command starting with `git add`
- File paths support **glob patterns**: `Read(./secrets/**)` matches all files in secrets directory
- The `:*` suffix means "match anything after this prefix"

---

## Allow Permissions

These operations are **auto-approved without prompting**. They're safe, commonly used, and have minimal risk.

### Git Operations

```json
"Bash(git add:*)",          // Stage files for commit
"Bash(git commit:*)",       // Create commits
"Bash(git push:*)",         // Push to remote (but force push requires confirmation)
"Bash(git pull:*)",         // Pull from remote
"Bash(git branch:*)",       // Create, list, delete branches
"Bash(git checkout:*)",     // Switch branches or restore files
"Bash(git merge:*)",        // Merge branches
"Bash(git remote:*)",       // Manage remote repositories
"Bash(git diff:*)",         // View differences
"Bash(git status)",         // Check repository status
"Bash(git log:*)",          // View commit history
"Bash(git show:*)",         // Show commit details
"Bash(git fetch:*)"         // Fetch from remote
```

**Why allowed:** Git operations are core to development workflow and are generally safe. They don't modify system state outside the repository.

### Node.js / JavaScript Package Managers

```json
"Bash(npm run test:*)",     // Run test scripts
"Bash(npm run build:*)",    // Run build scripts
"Bash(npm run lint:*)",     // Run linting
"Bash(npm run dev:*)",      // Run development server
"Bash(npm test:*)",         // Run tests (shorthand)
"Bash(npm run:*)",          // Run any npm script

"Bash(yarn test:*)",        // Yarn test scripts
"Bash(yarn build:*)",       // Yarn build scripts
"Bash(yarn run:*)",         // Any yarn script

"Bash(pnpm test:*)",        // pnpm test scripts
"Bash(pnpm build:*)",       // pnpm build scripts
"Bash(pnpm run:*)"          // Any pnpm script
```

**Why allowed:** These commands execute scripts defined in `package.json` without modifying dependencies. They're safe for development workflow.

**Note:** `npm install`, `yarn install`, `pnpm install` are in the **ask** list because they modify `node_modules`.

### Python Testing & Development

```json
"Bash(python -m pytest:*)",     // Run pytest tests
"Bash(pytest:*)",               // Run pytest (direct)
"Bash(python -m unittest:*)",   // Run unittest tests
"Bash(python manage.py test:*)" // Django test runner
```

**Why allowed:** Running tests is a read-only operation that doesn't modify the environment.

### Rust (Cargo)

```json
"Bash(cargo test:*)",   // Run Rust tests
"Bash(cargo build:*)",  // Build Rust project
"Bash(cargo run:*)"     // Run Rust application
```

**Why allowed:** Standard Rust development commands that compile and test code.

### Go

```json
"Bash(go test:*)",   // Run Go tests
"Bash(go build:*)",  // Build Go binary
"Bash(go run:*)"     // Compile and run Go code
```

**Why allowed:** Standard Go development workflow commands.

### Java Build Tools

```json
"Bash(mvn test:*)",     // Maven test
"Bash(mvn clean:*)",    // Maven clean
"Bash(gradle test:*)"   // Gradle test
```

**Why allowed:** Standard Java build and test operations.

### Make

```json
"Bash(make test:*)",   // Run make test target
"Bash(make build:*)"   // Run make build target
```

**Why allowed:** Common build automation commands defined in Makefiles.

### Docker (Read-Only Operations)

```json
"Bash(docker-compose ps)",  // List containers
"Bash(docker ps:*)",        // List running containers
"Bash(docker logs:*)"       // View container logs
```

**Why allowed:** These are read-only Docker commands that don't start/stop containers or modify images.

**Note:** `docker run`, `docker build`, `docker-compose up/down` are in the **ask** list.

### Common Shell Utilities (Read-Only)

```json
"Bash(ls:*)",      // List directory contents
"Bash(pwd)",       // Print working directory
"Bash(echo:*)",    // Print text
"Bash(cat:*)",     // Display file contents
"Bash(head:*)",    // Show beginning of file
"Bash(tail:*)",    // Show end of file
"Bash(grep:*)",    // Search text
"Bash(find:*)",    // Find files
"Bash(which:*)",   // Locate command
"Bash(whoami)"     // Show current user
```

**Why allowed:** These are read-only commands that help Claude understand the codebase and environment without making changes.

---

## Ask Permissions

These operations **require your explicit confirmation** before executing. They modify the environment or have potential side effects.

### Package Installation

```json
"Bash(npm install:*)",      // Install Node.js packages
"Bash(npm ci:*)",           // Clean install (deletes node_modules)
"Bash(yarn install:*)",     // Install with Yarn
"Bash(pnpm install:*)",     // Install with pnpm
"Bash(pip install:*)",      // Install Python packages
"Bash(pip3 install:*)",     // Install Python 3 packages
"Bash(poetry install:*)",   // Install Python packages with Poetry
"Bash(cargo install:*)",    // Install Rust packages
"Bash(go get:*)"            // Install Go packages
```

**Why ask:** These commands modify your dependencies and can:
- Download code from the internet
- Change your lock files
- Modify `node_modules`, `venv`, etc.
- Potentially introduce security vulnerabilities

### Docker Operations (Modification)

```json
"Bash(docker:*)",               // Any docker command not specifically allowed
"Bash(docker-compose up:*)",    // Start containers
"Bash(docker-compose down:*)",  // Stop containers
"Bash(docker build:*)",         // Build images
"Bash(docker run:*)"            // Run containers
```

**Why ask:** These commands:
- Consume system resources
- Can expose ports
- Modify container state
- Run untrusted images

### Dangerous Git Operations

```json
"Bash(git reset:*)",            // Reset commits (can lose work)
"Bash(git rebase:*)",           // Rewrite history
"Bash(git push --force:*)",     // Force push (overwrites remote)
"Bash(git push -f:*)"           // Force push (short form)
```

**Why ask:** These commands can:
- Lose uncommitted or committed work
- Overwrite remote repository history
- Break collaboration workflows
- Cause conflicts for team members

### File System Modifications

```json
"Bash(chmod:*)",    // Change file permissions
"Bash(chown:*)",    // Change file ownership
"Bash(mv:*)",       // Move/rename files
"Bash(cp:*)",       // Copy files
"Bash(mkdir:*)",    // Create directories
"Bash(touch:*)"     // Create empty files or update timestamps
```

**Why ask:** These commands modify the file system structure. While not necessarily dangerous, you should be aware when Claude is creating, moving, or changing permissions on files.

---

## Deny Permissions

These operations are **completely blocked** and cannot be executed, even with confirmation. This protects sensitive data and prevents destructive operations.

### Sensitive File Access

```json
"Read(./.env)",                         // Environment variables
"Read(./.env.*)",                       // All .env variants (.env.local, .env.production, etc.)
"Read(./secrets/**)",                   // Secrets directory
"Read(./**/secrets/**)",                // Secrets directories anywhere in project
"Read(./config/credentials.json)",      // Credentials file
"Read(./**/*credentials*.json)",        // Any credentials JSON file
"Read(./**/*secret*.json)",             // Any secret JSON file
"Read(./**/*password*.txt)",            // Any password text file
"Read(~/.ssh/**)",                      // SSH keys
"Read(~/.aws/**)",                      // AWS credentials
"Read(~/.config/gcloud/**)",            // Google Cloud credentials
"Read(.git/config)"                     // Git config (may contain tokens)
```

**Why deny:** These files contain sensitive information:
- API keys and tokens
- Database credentials
- OAuth secrets
- SSH private keys
- Cloud provider credentials

**Important:** Preventing Claude from reading these files ensures they're never accidentally:
- Logged in conversation history
- Included in code suggestions
- Sent to Anthropic's servers

### Destructive File Operations

```json
"Bash(rm -rf:*)",   // Force recursive delete
"Bash(rm -fr:*)"    // Force recursive delete (alternate order)
```

**Why deny:** These commands can permanently delete entire directories without confirmation. This is too dangerous to allow.

**Note:** Regular `rm` without `-rf` flags would still prompt for confirmation via the `ask` list if you add it there.

### System Administration Commands

```json
"Bash(sudo:*)",         // Execute with root privileges
"Bash(shutdown:*)",     // Shutdown system
"Bash(reboot:*)",       // Reboot system
"Bash(kill:*)",         // Kill processes
"Bash(killall:*)",      // Kill all processes by name
"Bash(pkill:*)"         // Kill processes by pattern
```

**Why deny:** These commands:
- Require administrative privileges
- Can crash your system
- Can terminate important processes
- Could disrupt your work environment

### Network Download Commands

```json
"Bash(curl:*)",     // Download from URL
"Bash(wget:*)"      // Download from URL
```

**Why deny:** These commands can:
- Download malicious code
- Exfiltrate data to external servers
- Bypass package manager security

**Security note:** If Claude needs to fetch web content, it should use the `WebFetch` tool instead, which has better security controls.

### Disk Operations

```json
"Bash(dd:*)",       // Low-level disk copy (can destroy data)
"Bash(mkfs:*)",     // Format file system (destroys data)
"Bash(fdisk:*)",    // Partition disk (can destroy data)
"Bash(format:*)"    // Format disk (destroys data)
```

**Why deny:** These commands directly manipulate disks and can cause catastrophic data loss.

---

## Security Best Practices

### 1. Principle of Least Privilege

Only allow what's necessary. Start restrictive and add permissions as needed.

```json
// ✓ Good: Specific, safe operations
"allow": ["Bash(npm run test)", "Bash(git status)"]

// ✗ Bad: Too broad
"allow": ["Bash(*)", "Read(./**)"]
```

### 2. Deny Takes Precedence

Use deny rules to create hard boundaries, even if something is in the allow list.

```json
{
  "allow": ["Bash(git:*)"],
  "deny": ["Bash(git push --force:*)"]  // Still blocks force push
}
```

### 3. Protect Secrets First

Always add deny rules for sensitive files before allowing broad read access.

```json
{
  "deny": [
    "Read(./.env)",
    "Read(./**/*secret*)",
    "Read(~/.ssh/**)"
  ]
}
```

### 4. Use Ask for Ambiguous Operations

If you're unsure whether an operation should be auto-approved, use `ask`.

```json
{
  "ask": ["Bash(npm install:*)"]  // Better safe than sorry
}
```

### 5. Regular Audits

Periodically review your permissions:
- Remove unused allow rules
- Check if ask rules can be promoted to allow (if they're safe and frequent)
- Ensure all sensitive paths are in deny rules

---

## Customizing for Your Project

### For a Python Project

Add Python-specific patterns:

```json
{
  "allow": [
    "Bash(python -m pytest:*)",
    "Bash(python manage.py runserver)",
    "Bash(python -m black:*)",
    "Bash(python -m flake8:*)"
  ],
  "ask": [
    "Bash(pip install:*)",
    "Bash(python manage.py migrate:*)"
  ],
  "deny": [
    "Read(./.env)",
    "Read(./venv/**)",
    "Read(./**/*settings_local.py)"
  ]
}
```

### For a Frontend Project

Add frontend-specific patterns:

```json
{
  "allow": [
    "Bash(npm run dev)",
    "Bash(npm run build)",
    "Bash(npx vite:*)",
    "Bash(npx webpack:*)"
  ],
  "deny": [
    "Read(./.env.local)",
    "Read(./dist/**)",
    "Read(./build/**)"
  ]
}
```

### For a Monorepo

Add workspace-specific patterns:

```json
{
  "allow": [
    "Bash(npm run test -w:*)",
    "Bash(lerna run test:*)",
    "Bash(turbo run test:*)"
  ]
}
```

---

## Understanding Pattern Matching

### Bash Patterns

Bash patterns use **prefix matching**:

```json
"Bash(git add:*)"
```

**Matches:**
- `git add file.txt` ✓
- `git add .` ✓
- `git add -A` ✓

**Doesn't match:**
- `git status` ✗
- `GIT_DIR=. git add file.txt` ✗ (environment variable prefix)

### File Path Patterns

File patterns support glob syntax:

```json
"Read(./secrets/**)"
```

**Matches:**
- `./secrets/api-key.txt` ✓
- `./secrets/db/password.json` ✓

**Doesn't match:**
- `./config/secrets.json` ✗ (not in secrets directory)

### Absolute vs Relative Paths

```json
"//home/user/file"     // Absolute filesystem path (note: double slash)
"~/Documents/*.pdf"    // From home directory
".env"                 // Relative to project root
"src/**/*.ts"          // Relative to project root with glob
```

---

## Additional Configuration Options

### Default Mode

If you want to avoid ALL prompts for file edits (less secure):

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

Options:
- `default` - Normal prompting behavior
- `acceptEdits` - Auto-approve file edits (but still prompt for bash)
- `plan` - Always plan before executing
- `bypassPermissions` - Bypass all permission checks (very dangerous!)

### Per-User Overrides

Create `.claude/settings.local.json` for machine-specific overrides:

```json
{
  "permissions": {
    "allow": [
      "Bash(custom-script.sh)"  // Only on this machine
    ]
  }
}
```

---

## Troubleshooting

### Claude keeps asking for permission

**Problem:** You want to auto-approve an operation.

**Solution:** Add it to the `allow` list in `settings.json`.

### Claude can't access a file I need

**Problem:** A legitimate file is in the `deny` list.

**Solution:** Remove it from `deny` or add a more specific deny pattern.

### Too many permissions are allowed

**Problem:** You want more control.

**Solution:** Move items from `allow` to `ask`, or remove them entirely.

---

## Further Reading

- [Official Claude Code Permissions Documentation](https://code.claude.com/docs/en/iam.md)
- [Security Best Practices](https://code.claude.com/docs/en/security.md)
- [MCP Server Permissions](https://code.claude.com/docs/en/mcp.md#mcp-permissions)

---

**Last Updated:** 2026-01-02
**Configuration Version:** Comprehensive Multi-Language Setup
