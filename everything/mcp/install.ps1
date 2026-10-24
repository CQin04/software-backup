[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$PythonPath)
$ErrorActionPreference = 'Stop'
$packageRoot = $PSScriptRoot
$pythonResolved = (Resolve-Path -LiteralPath $PythonPath).Path
& $pythonResolved -c 'import sys; assert sys.version_info[:2] == (3, 12), "Use Python 3.12 for this locked environment"'
if ($LASTEXITCODE -ne 0) { throw 'Python 3.12 is required for the recorded dependency lock.' }

foreach ($line in Get-Content -LiteralPath (Join-Path $packageRoot 'SHA256SUMS') -Encoding UTF8) {
    if ($line -notmatch '^([0-9a-fA-F]{64})\s+(.+)$') { continue }
    $expectedHash = $Matches[1]
    $artifact = [IO.Path]::GetFullPath((Join-Path $packageRoot $Matches[2]))
    if (-not $artifact.StartsWith([IO.Path]::GetFullPath($packageRoot).TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Artifact path is outside this package.' }
    if ((Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash -ne $expectedHash) { throw "Hash mismatch: $artifact" }
}
$venvPython = Join-Path $packageRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    & $pythonResolved -m venv (Join-Path $packageRoot '.venv')
    if ($LASTEXITCODE -ne 0) { throw 'Cannot create virtual environment.' }
}
Push-Location -LiteralPath $packageRoot
try {
    & $venvPython -m pip install --disable-pip-version-check --only-binary :all: -r requirements.lock.txt
    if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
    Expand-Archive -LiteralPath (Join-Path $packageRoot 'packages\ES-1.1.1.39.x64.zip') -DestinationPath (Join-Path $packageRoot 'bin') -Force
    & (Join-Path $packageRoot 'bin\es.exe') -get-everything-version
    if ($LASTEXITCODE -ne 0) { throw 'Everything is not running or does not expose IPC. Use the standard or portable edition.' }
} finally { Pop-Location }
Write-Output 'MCP dependencies installed. Follow README.md to register with Codex.'

