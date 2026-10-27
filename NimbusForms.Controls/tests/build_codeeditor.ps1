param(
  [ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32',
  [ValidateSet('All', 'Structure')][string]$Suite = 'All'
)
$ErrorActionPreference = 'Stop'
$ceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (-not (Test-Path -LiteralPath (Join-Path $ceRoot 'NimbusForms.Controls\src') -PathType Container)) { throw 'Controls source directory not found' }
$ceOutput = Join-Path $ceRoot ('NimbusForms.Controls\build\codeeditor-tests\' + $Platform)
$ceProbe = $ceOutput
while (-not (Test-Path -LiteralPath $ceProbe)) { $ceProbe = [IO.Path]::GetDirectoryName($ceProbe) }
$ceItem = Get-Item -LiteralPath $ceProbe
while ($null -ne $ceItem -and $ceItem.FullName.Length -ge $ceRoot.Length) {
  if ($ceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked output path' }
  $ceItem = $ceItem.Parent
}
$ceStudio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$ceCompilerName = 'dcc32.exe'
$ceLibrary = 'win32'
if ($Platform -eq 'Win64') { $ceCompilerName = 'dcc64.exe'; $ceLibrary = 'win64' }
$ceCompiler = Join-Path $ceStudio ('bin\' + $ceCompilerName)
if (-not (Test-Path -LiteralPath $ceCompiler)) { throw 'Compiler unavailable' }
New-Item -ItemType Directory -Path $ceOutput -Force | Out-Null
$ceTemp = Join-Path $ceOutput 'temp'
New-Item -ItemType Directory -Path $ceTemp -Force | Out-Null
$ceUnits = @((Join-Path $ceRoot 'NimbusForms.Controls\src'), (Join-Path $ceRoot 'NimbusForms.Theming\src'), (Join-Path $ceStudio ('lib\' + $ceLibrary + '\release'))) -join ';'
$ceOldTemp = $env:TEMP
$ceOldTmp = $env:TMP
$ceStarted = [DateTime]::UtcNow
$ceProgram = 'NimbusCodeEditorTests'
if ($Suite -eq 'Structure') { $ceProgram = 'NimbusCodeStructureTests' }
try {
  $env:TEMP = $ceTemp
  $env:TMP = $ceTemp
  $ceResult = & $ceCompiler '-Q' '-B' '-$R+' '-$Q+' ('-N0' + $ceOutput) ('-E' + $ceOutput) ('-U' + $ceUnits) (Join-Path $PSScriptRoot ($ceProgram + '.pas')) 2>&1
  $ceExit = $LASTEXITCODE
  $ceResult | ForEach-Object { Write-Output $_ }
  if (($ceResult | Out-String) -match 'does not support command line compiling') { throw 'Compiler license rejects command line compilation; no build succeeded' }
  if ($ceExit -ne 0) { throw "Compiler failed: $ceExit" }
  $ceExe = Join-Path $ceOutput ($ceProgram + '.exe')
  if (-not (Test-Path -LiteralPath $ceExe)) { throw 'Compiler did not generate an executable' }
  if ((Get-Item -LiteralPath $ceExe).LastWriteTimeUtc -lt $ceStarted) { throw 'Stale executable' }
  & $ceExe
  if ($LASTEXITCODE -ne 0) { throw 'CodeEditor tests failed' }
} finally {
  $env:TEMP = $ceOldTemp
  $env:TMP = $ceOldTmp
}
