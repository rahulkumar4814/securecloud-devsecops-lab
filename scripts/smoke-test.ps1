<#
  smoke-test.ps1 - SecureCloud DevSecOps Lab, Step 1.4
  Starts the API on 127.0.0.1:8000 (localhost only), calls each endpoint,
  stops the server. Uses a throwaway DB at reports\smoke.db (git-ignored).
  Writes results to reports\smoke-test.txt
#>
$ErrorActionPreference = 'Continue'
$root      = Split-Path -Parent $PSScriptRoot
$reportDir = Join-Path $root 'reports'
$outFile   = Join-Path $reportDir 'smoke-test.txt'
$py        = Join-Path $root '.venv\Scripts\python.exe'
$base      = 'http://127.0.0.1:8000'
$dbFile    = Join-Path $reportDir 'smoke.db'

function Call($method, $path, $body) {
    try {
        $p = @{ Uri = "$base$path"; Method = $method; UseBasicParsing = $true }
        if ($null -ne $body) { $p.Body = ($body | ConvertTo-Json -Compress); $p.ContentType = 'application/json' }
        $r = Invoke-WebRequest @p
        "{0,-5} {1,-14} -> {2}  {3}" -f $method, $path, [int]$r.StatusCode, $r.Content
    } catch {
        $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 'NO RESPONSE' }
        "{0,-5} {1,-14} -> {2}  (error response)" -f $method, $path, $code
    }
}

$result = & {
    "=== Step 1.4 smoke test ==="
    "Run at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
    "Git branch: $(git -C $root branch --show-current)"

    "`n--- 1. Virtual environment ---"
    if (-not (Test-Path $py)) { "ERROR: .venv not found - run the Step 1.4 setup commands first"; return }
    & $py -c "import sys; print('venv python:', sys.executable); print('version:', sys.version.split()[0])"
    & $py -m pip list --format=freeze 2>$null | Select-String -Pattern '^(fastapi|uvicorn|pydantic|starlette)=='

    "`n--- 2. requirements.txt check ---"
    $req = Join-Path $root 'requirements.txt'
    if (Test-Path $req) {
        $b = [System.IO.File]::ReadAllBytes($req)
        if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { "WARNING: requirements.txt is UTF-16 (will break Linux CI)" } else { "Encoding OK (not UTF-16)" }
        "Pinned lines: $((Get-Content $req | Where-Object { $_ -match '==' }).Count)"
        Get-Content $req
    } else { "ERROR: requirements.txt missing" }

    "`n--- 3. Start API (127.0.0.1 only) ---"
    Remove-Item $dbFile -ErrorAction SilentlyContinue
    $env:NOTES_DB_PATH = $dbFile
    $proc = Start-Process -FilePath $py -ArgumentList '-m','uvicorn','app.main:app','--host','127.0.0.1','--port','8000' `
            -WorkingDirectory $root -PassThru -WindowStyle Hidden `
            -RedirectStandardError (Join-Path $reportDir 'uvicorn.log')
    $up = $false
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Seconds 1
        try { Invoke-WebRequest "$base/health" -UseBasicParsing -TimeoutSec 2 | Out-Null; $up = $true; break } catch {}
    }
    "Server started: $up (PID $($proc.Id))"

    if ($up) {
        "`n--- 4. Endpoint tests (expected status in brackets) ---"
        "[200]";            Call GET  '/health'
        "[201]";            Call POST '/notes' @{ title = 'First note'; body = 'Hello SecureCloud' }
        "[200]";            Call GET  '/notes'
        "[200]";            Call GET  '/notes/1'
        "[404 not found]";  Call GET  '/notes/9999'
        "[422 validation]"; Call POST '/notes' @{ title = ''; body = 'empty title must be rejected' }
        "[422 validation]"; Call GET  '/notes/abc'
    } else {
        "Server did not start. Last log lines:"
        Get-Content (Join-Path $reportDir 'uvicorn.log') -Tail 20
    }

    "`n--- 5. Stop API ---"
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    "Server stopped"
    "=== End ==="
} 2>&1 | Out-String

$result | Set-Content -Path $outFile -Encoding UTF8
Write-Host $result
Write-Host "Saved to: $outFile" -ForegroundColor Green
