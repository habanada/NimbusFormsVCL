param([ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32')
$ErrorActionPreference = 'Stop'
$hexProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if ($hexProjectRoot.TrimEnd('\') -ne 'E:\Projects\NimbusForms') { throw 'Unexpected project root' }
$hexRoot = Join-Path $hexProjectRoot 'NimbusForms.HexEditor'
$hexOutput = [IO.Path]::GetFullPath((Join-Path $hexRoot ('build\feature-tests\' + $Platform)))
if (-not $hexOutput.StartsWith($hexRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid build output' }
$hexProbe = $hexOutput
while (-not (Test-Path -LiteralPath $hexProbe)) { $hexProbe = [IO.Path]::GetDirectoryName($hexProbe) }
$hexItem = Get-Item -LiteralPath $hexProbe
while ($null -ne $hexItem -and $hexItem.FullName.Length -ge $hexProjectRoot.Length) {
  if ($hexItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked build path' }
  $hexItem = $hexItem.Parent
}
$hexCompilerName = 'dcc32.exe'
$hexLibrary = 'win32'
if ($Platform -eq 'Win64') { $hexCompilerName = 'dcc64.exe'; $hexLibrary = 'win64' }
$hexStudio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$hexCompiler = Join-Path $hexStudio ('bin\' + $hexCompilerName)
if (-not (Test-Path -LiteralPath $hexCompiler)) { throw 'Compiler is not installed' }
New-Item -ItemType Directory -Path $hexOutput -Force | Out-Null
$hexTemp = Join-Path $hexOutput 'temp'
New-Item -ItemType Directory -Path $hexTemp -Force | Out-Null
$hexUnitPaths = @(
  (Join-Path $hexRoot 'src'),
  (Join-Path $hexProjectRoot 'NimbusForms.Controls\src'),
  (Join-Path $hexProjectRoot 'NimbusForms.Theming\src'),
  (Join-Path $hexProjectRoot 'NativePattern\src'),
  (Join-Path $hexStudio ('lib\' + $hexLibrary + '\release'))
) -join ';'
$hexExe = Join-Path $hexOutput 'HexFeatureTests.exe'
$hexOldTemp = $env:TEMP
$hexOldTmp = $env:TMP
$hexStarted = [DateTime]::UtcNow
try {
  $env:TEMP = $hexTemp
  $env:TMP = $hexTemp
  $hexCompilerOutput = & $hexCompiler '-Q' '-B' ('-N0' + $hexOutput) ('-E' + $hexOutput) ('-U' + $hexUnitPaths) (Join-Path $PSScriptRoot 'HexFeatureTests.pas') 2>&1
  $hexExit = $LASTEXITCODE
  $hexCompilerOutput | ForEach-Object { Write-Output $_ }
  if (($hexCompilerOutput | Out-String) -match 'does not support command line compiling') { throw 'Compiler license rejects command line compilation; no build succeeded' }
  if ($hexExit -ne 0) { throw "Compiler failed with exit code $hexExit" }
  if (-not (Test-Path -LiteralPath $hexExe)) { throw 'No test executable was generated' }
  if ((Get-Item -LiteralPath $hexExe).LastWriteTimeUtc -lt $hexStarted) { throw 'The test executable is stale' }
  & $hexExe
  if ($LASTEXITCODE -ne 0) { throw "Tests failed with exit code $LASTEXITCODE" }
} finally {
  $env:TEMP = $hexOldTemp
  $env:TMP = $hexOldTmp
}
