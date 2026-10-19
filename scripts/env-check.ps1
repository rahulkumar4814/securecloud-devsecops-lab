<#
  env-check.ps1 - SecureCloud DevSecOps Lab, Step 0.1
  READ-ONLY environment check. Installs nothing and changes no settings.
  Only action: writes the results to reports\env-check.txt inside this lab folder.
#>
$ErrorActionPreference = 'Continue'
$root      = Split-Path -Parent $PSScriptRoot
$reportDir = Join-Path $root 'reports'
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$outFile   = Join-Path $reportDir 'env-check.txt'

$result = & {
    "=== SecureCloud DevSecOps Lab - Step 0.1 environment check ==="
    "Run at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"

    "`n--- 1. PowerShell version ---"
    $PSVersionTable.PSVersion.ToString()

    "`n--- 2. Windows edition / version / architecture ---"
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture | Format-List | Out-String

    "--- 3. Hardware ---"
    "RAM (GB):          {0:N1}" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    "C: free space (GB): {0:N1}" -f ((Get-PSDrive C).Free / 1GB)
    "CPU:               " + (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
    "Virtualization enabled in firmware: " + ((Get-CimInstance Win32_Processor | Select-Object -First 1).VirtualizationFirmwareEnabled)

    "`n--- 4. Script execution policy ---"
    Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-String

    "--- 5. Lab tools ---"
    $tools = 'winget','git','python','py','pip','docker','wsl','code','gh','aws','terraform','trivy','gitleaks','semgrep','checkov'
    foreach ($t in $tools) {
        $c = Get-Command $t -ErrorAction SilentlyContinue
        if ($c) {
            $v = "$(& $t --version 2>&1 | Select-Object -First 1)" -replace "`0", ''
            "{0,-10} FOUND    {1}`n           version: {2}" -f $t, $c.Source, $v
        } else {
            "{0,-10} MISSING" -f $t
        }
    }

    "`n--- 6. WSL distributions (if WSL is present) ---"
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        ((wsl -l -v 2>&1) | Out-String) -replace "`0", ''
    } else { "WSL command not found" }

    "=== End of check ==="
} 2>&1 | Out-String

$result | Set-Content -Path $outFile -Encoding UTF8
Write-Host $result
Write-Host "Saved to: $outFile" -ForegroundColor Green
