---
name: Start/Stop App
description: Start or stop the Next.js app. Use when you need to run or kill the dev server.
---

# Start/Stop App

Manage the Next.js development server.

## Tools

- `npm run dev` - Start the app with Next.js dev server on port 3001
- Process management - Stop the app by killing the Node.js process running on port 3001

## Usage

```bash
# Start the app
npm run dev

# Stop the app
# On Windows (PowerShell):
# Instruction: replace <<app_name>> with the name of the app
Get-Process -Name node | Where-Object {$_.Path -like "*<<app_name>>*"} | Stop-Process -Force  
# Or find and kill process on port 3001:
netstat -ano | findstr :3001
taskkill /PID <PID> /F



# On macOS/Linux:
lsof -ti:3001 | xargs kill -9
# Or:
pkill -f "next dev"
```

