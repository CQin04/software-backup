@echo off
setlocal
set "CHATGPT_ADMIN_LAUNCHER=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$file = $env:CHATGPT_ADMIN_LAUNCHER; $content = [IO.File]::ReadAllText($file); $marker = '#<POWERSHELL_PAYLOAD>'; $start = $content.LastIndexOf($marker); if ($start -lt 0) { throw 'Embedded PowerShell payload was not found.' }; $code = $content.Substring($start + $marker.Length); & ([scriptblock]::Create($code)) $code"
if errorlevel 1 (
  echo.
  echo Failed to launch ChatGPT as administrator.
  pause
  exit /b 1
)
endlocal
exit /b 0
#<POWERSHELL_PAYLOAD>
$ErrorActionPreference = 'Stop'
$isAdmin = $false

try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdmin = $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if (-not $isAdmin) {
        if ($args.Count -lt 1 -or [string]::IsNullOrWhiteSpace([string]$args[0])) {
            throw 'Embedded PowerShell payload was not passed to the launcher.'
        }
        $payload = [string]$args[0]
        Write-Host 'Requesting administrator privileges...'
        $powershellPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $encodedPayload = [Convert]::ToBase64String(
            [Text.Encoding]::Unicode.GetBytes($payload)
        )

        $elevatedProcess = Start-Process `
            -FilePath $powershellPath `
            -Verb RunAs `
            -ArgumentList @(
                '-NoProfile',
                '-ExecutionPolicy', 'Bypass',
                '-EncodedCommand', $encodedPayload
            ) `
            -PassThru `
            -Wait

        exit $elevatedProcess.ExitCode
    }

    Write-Host '[OK] Launcher is elevated.'

    $pkg = Get-AppxPackage -Name OpenAI.Codex |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if (-not $pkg) {
        throw 'OpenAI.Codex MSIX package was not found for the current user.'
    }

    Write-Host 'Package:'
    Write-Host "  $($pkg.PackageFullName)"

    $candidates = @(
        (Join-Path $pkg.InstallLocation 'app\ChatGPT.exe'),
        (Join-Path $pkg.InstallLocation 'app\Codex.exe'),
        (Join-Path $pkg.InstallLocation 'app\Codex (Beta).exe')
    )

    $exe = $candidates |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1

    if (-not $exe) {
        throw 'Cannot find ChatGPT.exe or Codex.exe in the installed package.'
    }

    Write-Host 'Executable:'
    Write-Host "  $exe"
    Write-Host 'Stopping existing ChatGPT / Codex processes...'

    Get-Process -Name 'ChatGPT', 'Codex' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -eq $exe } |
        Stop-Process -Force -ErrorAction Stop

    Start-Sleep -Milliseconds 800

    Write-Host ''
    Write-Host 'Launching ChatGPT with the elevated token...'
    Start-Process -FilePath $exe -ArgumentList @('--do-not-de-elevate')

    Write-Host ''
    Write-Host 'Launch requested. Verify the ChatGPT, codex.exe, and command-shell tokens in Task Manager.'
}
catch {
    Write-Host ''
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    if ($isAdmin) {
        [void](Read-Host 'Press Enter to close this window')
    }
    exit 1
}