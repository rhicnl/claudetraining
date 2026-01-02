# PowerShell script to verify Docker Supabase Postgres setup
# Usage: .\verify-docker-postgres.ps1

Write-Host "=== Docker Supabase Postgres Verification ===" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed and running
Write-Host "1. Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker is installed: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Docker is not installed or not in PATH" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ Docker command not found" -ForegroundColor Red
    exit 1
}

# Check if Docker daemon is running
Write-Host "`n2. Checking Docker daemon..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Docker daemon is running" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Docker daemon is not running" -ForegroundColor Red
        Write-Host "     Start Docker Desktop or Docker service" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ✗ Cannot connect to Docker daemon" -ForegroundColor Red
    exit 1
}

# Check for Supabase containers
Write-Host "`n3. Checking Supabase containers..." -ForegroundColor Yellow
$containers = docker ps --format "{{.Names}}\t{{.Status}}\t{{.Ports}}" | Where-Object { $_ -match "supabase|postgres" }
if ($containers) {
    Write-Host "   Found containers:" -ForegroundColor Green
    $containers | ForEach-Object {
        Write-Host "     $_" -ForegroundColor White
    }
} else {
    Write-Host "   ⚠ No Supabase/Postgres containers found" -ForegroundColor Yellow
    Write-Host "     Checking all running containers..." -ForegroundColor Gray
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Find Postgres container specifically
Write-Host "`n4. Finding Postgres container..." -ForegroundColor Yellow
$postgresContainers = docker ps --filter "name=postgres" --format "{{.Names}}"
$supabaseDbContainers = docker ps --filter "name=supabase.*db" --format "{{.Names}}"
$allContainers = docker ps --format "{{.Names}}" | Where-Object { $_ -match "db|postgres" }

if ($postgresContainers -or $supabaseDbContainers -or $allContainers) {
    $dbContainer = if ($postgresContainers) { $postgresContainers.Split("`n")[0].Trim() }
                    elseif ($supabaseDbContainers) { $supabaseDbContainers.Split("`n")[0].Trim() }
                    else { ($allContainers | Select-Object -First 1).Trim() }
    
    Write-Host "   ✓ Found Postgres container: $dbContainer" -ForegroundColor Green
    
    # Get container details
    Write-Host "`n5. Container details..." -ForegroundColor Yellow
    $containerInfo = docker inspect $dbContainer --format "{{.Name}} | Status: {{.State.Status}} | Image: {{.Config.Image}}"
    Write-Host "   $containerInfo" -ForegroundColor White
    
    # Check port mappings
    Write-Host "`n6. Checking port mappings..." -ForegroundColor Yellow
    $ports = docker port $dbContainer 2>&1
    if ($LASTEXITCODE -eq 0 -and $ports) {
        Write-Host "   Port mappings:" -ForegroundColor Green
        $ports | ForEach-Object {
            Write-Host "     $_" -ForegroundColor White
        }
        
        # Extract host port for 5432
        $hostPort = ($ports | Where-Object { $_ -match "5432" }) -replace ".*:(\d+)->5432.*", '$1'
        if ($hostPort) {
            Write-Host "   ✓ Postgres is accessible on host port: $hostPort" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Could not determine host port for 5432" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠ No port mappings found or container not accessible" -ForegroundColor Yellow
    }
    
    # Test connection from inside container
    Write-Host "`n7. Testing Postgres connection from inside container..." -ForegroundColor Yellow
    $testQuery = docker exec $dbContainer psql -U postgres -d postgres -c "SELECT version();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Connection successful from inside container" -ForegroundColor Green
        $testQuery | Select-Object -First 3 | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ✗ Connection failed from inside container" -ForegroundColor Red
        Write-Host "     Error: $testQuery" -ForegroundColor Red
    }
    
    # Check if we can get the password from environment
    Write-Host "`n8. Checking Postgres environment variables..." -ForegroundColor Yellow
    $envVars = docker exec $dbContainer env 2>&1 | Where-Object { $_ -match "POSTGRES" }
    if ($envVars) {
        Write-Host "   Found Postgres environment variables:" -ForegroundColor Green
        $envVars | ForEach-Object {
            $var = $_.Split('=')[0]
            $value = $_.Split('=', 2)[1]
            if ($var -match "PASSWORD") {
                Write-Host "     $var=***" -ForegroundColor Gray
            } else {
                Write-Host "     $var=$value" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "   ⚠ Could not read environment variables" -ForegroundColor Yellow
    }
    
    # Test connection from host using .NET (like our script does)
    Write-Host "`n9. Testing connection from host machine using .NET..." -ForegroundColor Yellow
    
    # Try to get password from .env.local
    $envFile = ".env.local"
    $postgresPassword = $null
    $postgresUser = $null
    if (Test-Path $envFile) {
        $content = Get-Content $envFile
        foreach ($line in $content) {
            if ($line -match '^\s*POSTGRES_PASSWORD=(.+)$') {
                $postgresPassword = $matches[1].Trim() -replace '^["'']|["'']$', ''
            }
            if ($line -match '^\s*POSTGRES_USER=(.+)$') {
                $postgresUser = $matches[1].Trim() -replace '^["'']|["'']$', ''
            }
        }
    }
    
    if (-not $postgresUser) {
        $postgresUser = "postgres"  # Default
    }
    
    if ($postgresPassword) {
        Write-Host "   Testing with user: $postgresUser" -ForegroundColor Cyan
        
        # Quick test using Test-NetConnection to check if port is open
        Write-Host "   Checking if port 5432 is accessible..." -ForegroundColor Cyan
        $portTest = Test-NetConnection -ComputerName localhost -Port 5432 -WarningAction SilentlyContinue
        if ($portTest.TcpTestSucceeded) {
            Write-Host "   ✓ Port 5432 is open and accessible" -ForegroundColor Green
        } else {
            Write-Host "   ✗ Port 5432 is not accessible from host" -ForegroundColor Red
            Write-Host "     This might be a firewall issue" -ForegroundColor Yellow
        }
        
        Write-Host "`n   Connection details for .env.local (Supabase recommended):" -ForegroundColor Cyan
        Write-Host "     POSTGRES_HOST=127.0.0.1" -ForegroundColor White
        Write-Host "     POSTGRES_PORT=5432" -ForegroundColor White
        Write-Host "     POSTGRES_DB=postgres" -ForegroundColor White
        Write-Host "     POSTGRES_USER=$postgresUser" -ForegroundColor White
        Write-Host "     POSTGRES_PASSWORD=***" -ForegroundColor White
        Write-Host "`n   Or use connection string format (Supabase's exact format):" -ForegroundColor Cyan
        $connString = "postgresql://$postgresUser`:***@127.0.0.1:5432/postgres"
        Write-Host "     POSTGRES_CONNECTION_STRING=$connString" -ForegroundColor White
        Write-Host "`n   Note: Port 5432 is exposed via supabase-pooler container" -ForegroundColor Gray
        Write-Host "         Use 127.0.0.1 as recommended by Supabase for direct connection" -ForegroundColor Gray
        
    } else {
        Write-Host "   ⚠ Could not find POSTGRES_PASSWORD in .env.local" -ForegroundColor Yellow
        Write-Host "     Add these to .env.local (Supabase recommended format):" -ForegroundColor Yellow
        Write-Host "       POSTGRES_HOST=127.0.0.1" -ForegroundColor White
        Write-Host "       POSTGRES_PORT=5432" -ForegroundColor White
        Write-Host "       POSTGRES_DB=postgres" -ForegroundColor White
        Write-Host "       POSTGRES_USER=postgres" -ForegroundColor White
        Write-Host "       POSTGRES_PASSWORD=your-super-secret-and-long-postgres-password" -ForegroundColor White
    }
    
} else {
    Write-Host "   ✗ No Postgres container found" -ForegroundColor Red
    Write-Host "`n   Troubleshooting:" -ForegroundColor Yellow
    Write-Host "     - Make sure Supabase Docker containers are running" -ForegroundColor White
    Write-Host "     - Check: docker ps -a" -ForegroundColor White
    Write-Host "     - Start Supabase: docker-compose up -d (in Supabase directory)" -ForegroundColor White
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "If all checks passed, you should be able to connect using:" -ForegroundColor White
Write-Host "  .\connect-postgres.ps1" -ForegroundColor Green
Write-Host ""
