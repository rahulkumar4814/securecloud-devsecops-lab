<#
  verify-tools.ps1 - SecureCloud DevSecOps Lab, Step 1.2
  Verifies the tools found in Step 1.1 actually work. Installs nothing.
  Actions: starts Docker Desktop if it is not running, runs the tiny
  'hello-world' test container (downloads ~10 KB image, removed after run).
  Writes results to reports\verify-tools.txt
#>
$ErrorActionPreference = 'Continue'
$root    = Split-Path -Parent $PSScriptRoot
$outFile = Join-Path $root 'reports\verify-tools.txt'

$result = & {
    "=== Step 1.2 tool verification ==="
    "Run at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"

    "`n--- 1. Hypervisor (explains 'Virtualization: False' in Step 1.1) ---"
    (systeminfo | Select-String -Pattern 'hypervisor|Hyper-V|Virtualization' | ForEach-Object { $_.Line.Trim() }) -join "`n"

    "`n--- 2. Git identity (name/email used on commits) ---"
    "user.name : $(git config --global --get user.name)"
    "user.email: $(git config --global --get user.email)"
    "default branch: $(git config --global --get init.defaultBranch)"

    "`n--- 3. Docker engine ---"
    docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        "Docker engine not running - starting Docker Desktop (waits up to 3 minutes)..."
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        for ($i = 0; $i -lt 36; $i++) {
            Start-Sleep -Seconds 5
            docker info *> $null
            if ($LASTEXITCODE -eq 0) { break }
        }
    }
    docker version --format 'Client: {{.Client.Version}}  Server: {{.Server.Version}}  OS/Arch: {{.Server.Os}}/{{.Server.Arch}}' 2>&1 | Out-String
    "--- 4. Test container ---"
    (docker run --rm hello-world 2>&1 | Select-String -Pattern 'Hello from Docker|error|Error' | ForEach-Object { $_.Line }) -join "`n"

    "`n--- 5. Python venv support ---"
    python -c "import sys, venv, ssl; print('Python', sys.version.split()[0], '| venv OK | SSL', ssl.OPENSSL_VERSION)" 2>&1

    "`n=== End ==="
} 2>&1 | Out-String

$result | Set-Content -Path $outFile -Encoding UTF8
Write-Host $result
Write-Host "Saved to: $outFile" -ForegroundColor Green
