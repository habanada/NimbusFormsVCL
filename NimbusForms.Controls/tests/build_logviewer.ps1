param([ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32')
$ErrorActionPreference = 'Stop'
$logProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (-not (Test-Path -LiteralPath (Join-Path $logProjectRoot 'NimbusForms.Controls\src') -PathType Container)) { throw 'Controls source directory not found' }
$logOutput = [IO.Path]::GetFullPath((Join-Path $logProjectRoot ('NimbusForms.Controls\build\logviewer-tests\' + $Platform)))
if (-not $logOutput.StartsWith($logProjectRoot + '\NimbusForms.Controls\build\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid output path' }
$logProbe = $logOutput
while (-not (Test-Path -LiteralPath $logProbe)) { $logProbe = [IO.Path]::GetDirectoryName($logProbe) }
$logItem = Get-Item -LiteralPath $logProbe
while ($null -ne $logItem -and $logItem.FullName.Length -ge $logProjectRoot.Length) {
  if ($logItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked build path' }
  $logItem = $logItem.Parent
}
$logStudio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$logCompilerName = 'dcc32.exe'
$logLibrary = 'win32'
if ($Platform -eq 'Win64') { $logCompilerName = 'dcc64.exe'; $logLibrary = 'win64' }
$logCompiler = Join-Path $logStudio ('bin\' + $logCompilerName)
if (-not (Test-Path -LiteralPath $logCompiler)) { throw 'Compiler unavailable' }
New-Item -ItemType Directory -Path $logOutput -Force | Out-Null
$logTemp = Join-Path $logOutput 'temp'
New-Item -ItemType Directory -Path $logTemp -Force | Out-Null
$logUnits = @(
  (Join-Path $logProjectRoot 'NimbusForms.Controls\src'),
  (Join-Path $logProjectRoot 'NimbusForms.Theming\src'),
  (Join-Path $logStudio ('lib\' + $logLibrary + '\release'))
) -join ';'
$logOldTemp = $env:TEMP
$logOldTmp = $env:TMP
$logStarted = [DateTime]::UtcNow
$logExe = Join-Path $logOutput 'NimbusLogViewerTests.exe'
try {
  $env:TEMP = $logTemp
  $env:TMP = $logTemp
  $logCompilerOutput = & $logCompiler '-Q' '-B' ('-N0' + $logOutput) ('-E' + $logOutput) ('-U' + $logUnits) (Join-Path $PSScriptRoot 'NimbusLogViewerTests.pas') 2>&1
  $logExit = $LASTEXITCODE
  $logCompilerOutput | ForEach-Object { Write-Output $_ }
  if (($logCompilerOutput | Out-String) -match 'does not support command line compiling') { throw 'Compiler license rejects command line compilation; no build succeeded' }
  if ($logExit -ne 0) { throw "Compiler failed: $logExit" }
  if (-not (Test-Path -LiteralPath $logExe)) { throw 'No executable generated' }
  if ((Get-Item -LiteralPath $logExe).LastWriteTimeUtc -lt $logStarted) { throw 'Stale executable' }
  & $logExe
  if ($LASTEXITCODE -ne 0) { throw 'LogViewer tests failed' }
} finally {
  $env:TEMP = $logOldTemp
  $env:TMP = $logOldTmp
}
