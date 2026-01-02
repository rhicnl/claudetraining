---
description: Prime agent with user-management DB context via psql
allowed-tools: Read, Glob, Grep, Bash

---

# Prime: User Management Database

Connect to the user-management postgres database and understand the schema.

## Database Connection

```bash
export PGPASSWORD=$(grep DB_PASS .env | cut -d'=' -f2)
psql -h localhost -p 5432 -U app_user -d user_mgmt
```

## Schema Overview

### users

| column | type | constraints |
|---|---|---|
| id | UUID | PRIMARY KEY |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |
| created_at | TIMESTAMP | DEFAULT now() |
| updated_at | TIMESTAMP | |

### roles

| column | type | constraints |
|---|---|---|
| id | SERIAL | PRIMARY KEY |
| name | VARCHAR(50) | UNIQUE |
| permissions | JSONB | DEFAULT '[]' |

### user_roles

| column | type | constraints |
|---|---|---|
| user_id | UUID | FK -> users.id |
| role_id | INT | FK -> roles.id |

## Useful Commands

```bash
# List all users
psql -c "SELECT id, email, created_at FROM users;"

# Check user roles
psql -c "SELECT u.email, r.name FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id;"

# Recent signups
psql -c "SELECT * FROM users
WHERE created_at > now() - interval '7 days';"
```

## Workflow

1. READ .env for DB credentials
2. Verify connection with psql -c "SELECT 1;"
3. Query schema as needed for the task
4. Cross-reference with modules/schemas.py
