param(
  [ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32',
  [string]$DUnitXPath = '',
  [switch]$BuildOnly
)
$ErrorActionPreference = 'Stop'
$hexTestRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if ($hexTestRoot.TrimEnd('\') -ne 'E:\Projects\NimbusForms') { throw 'Unexpected workspace' }
function Assert-HexTestPath([string]$Path) {
  $hexFullPath = [IO.Path]::GetFullPath($Path)
  if (-not $hexFullPath.StartsWith($hexTestRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Outside workspace: $Path" }
  $hexProbePath = $hexFullPath
  while ($hexProbePath.Length -ge $hexTestRoot.Length) {
    if (Test-Path -LiteralPath $hexProbePath) {
      if ((Get-Item -LiteralPath $hexProbePath).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked path: $hexProbePath" }
    }
    $hexProbePath = [IO.Path]::GetDirectoryName($hexProbePath)
  }
  return $hexFullPath
}
$hexStudio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$hexCompilerName = 'dcc32.exe'
if ($Platform -eq 'Win64') { $hexCompilerName = 'dcc64.exe' }
$hexCompiler = Join-Path $hexStudio ('bin\' + $hexCompilerName)
if (-not (Test-Path -LiteralPath $hexCompiler)) { throw 'Delphi compiler unavailable' }
$hexUnitDirectories = @(
  (Assert-HexTestPath $PSScriptRoot),
  (Assert-HexTestPath (Join-Path $hexTestRoot 'NimbusForms.HexEditor\src')),
  (Assert-HexTestPath (Join-Path $hexTestRoot 'NimbusForms.Controls\src')),
  (Assert-HexTestPath (Join-Path $hexTestRoot 'NimbusForms.Theming\src')),
  (Assert-HexTestPath (Join-Path $hexTestRoot 'NativePattern\src')),
  (Join-Path $hexStudio ('lib\' + $Platform.ToLowerInvariant() + '\release'))
)
if ($DUnitXPath -eq '') {
  foreach ($hexCandidate in @('source\DUnitX\Source', 'source\DUnitX', 'source\ThirdParty\DUnitX\Source')) {
    $hexCandidatePath = Join-Path $hexStudio $hexCandidate
    if (Test-Path -LiteralPath (Join-Path $hexCandidatePath 'DUnitX.TestFramework.pas')) { $DUnitXPath = $hexCandidatePath; break }
  }
}
if ($DUnitXPath -ne '') {
  $DUnitXPath = [IO.Path]::GetFullPath($DUnitXPath)
  if ($DUnitXPath.StartsWith($hexTestRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { $DUnitXPath = Assert-HexTestPath $DUnitXPath }
  elseif (-not $DUnitXPath.StartsWith($hexStudio + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Use DUnitX inside the workspace or the installed RAD Studio toolchain' }
  if (-not (Test-Path -LiteralPath (Join-Path $DUnitXPath 'DUnitX.TestFramework.pas'))) { throw 'DUnitXPath must point to the DUnitX Source directory' }
  $hexUnitDirectories += $DUnitXPath
}
elseif (-not (Test-Path -LiteralPath (Join-Path $hexUnitDirectories[-1] 'DUnitX.TestFramework.dcu'))) {
  throw 'DUnitX not found. Install DUnitX for Delphi 12 or provide -DUnitXPath with its Source directory inside the workspace or RAD Studio installation.'
}
$hexOutput = Assert-HexTestPath (Join-Path $hexTestRoot ('NimbusForms.Controls\build\hexeditor-dunitx\' + $Platform))
$hexObjects = Assert-HexTestPath (Join-Path $hexOutput 'obj')
$hexTemp = Assert-HexTestPath (Join-Path $hexOutput 'temp')
New-Item -ItemType Directory -Path $hexOutput, $hexObjects, $hexTemp -Force | Out-Null
$hexUnitPaths = $hexUnitDirectories -join ';'
$hexPreviousTemp = $env:TEMP
$hexPreviousTmp = $env:TMP
$hexExe = Join-Path $hexOutput 'NimbusHexEditorDUnitXTests.exe'
$hexXml = Join-Path $hexOutput 'NimbusHexEditorDUnitXTests.xml'
try {
  $env:TEMP = $hexTemp
  $env:TMP = $hexTemp
  $hexStarted = [DateTime]::UtcNow
  $hexCompilerOutput = & $hexCompiler '-Q' '-B' '-$R+' '-$Q+' '-DDEBUG;CI' ('-N0' + $hexObjects) ('-E' + $hexOutput) ('-U' + $hexUnitPaths) ('-I' + $hexUnitPaths) (Join-Path $PSScriptRoot 'NimbusHexEditorDUnitXTests.dpr') 2>&1
  $hexCompilerExit = $LASTEXITCODE
  $hexCompilerOutput | Set-Content -LiteralPath (Join-Path $hexOutput 'compile.log') -Encoding UTF8
  $hexCompilerOutput | ForEach-Object { Write-Output $_ }
  if (($hexCompilerOutput | Out-String) -match 'does not support command line compiling') { throw 'Compiler license rejects command line compilation; no build succeeded' }
  if ($hexCompilerExit -ne 0) { throw "Compiler failed with exit code $hexCompilerExit" }
  if (-not (Test-Path -LiteralPath $hexExe)) { throw 'No test executable generated' }
  if ((Get-Item -LiteralPath $hexExe).LastWriteTimeUtc -lt $hexStarted) { throw 'Stale executable; tests were not run' }
  if (-not $BuildOnly) {
    $hexStarted = [DateTime]::UtcNow
    $hexRunOutput = & $hexExe 2>&1
    $hexTestExit = $LASTEXITCODE
    $hexRunOutput | Set-Content -LiteralPath (Join-Path $hexOutput 'tests.log') -Encoding UTF8
    $hexRunOutput | ForEach-Object { Write-Output $_ }
    if ($hexTestExit -ne 0) { throw "DUnitX tests failed with exit code $hexTestExit; inspect $hexXml" }
    if (-not (Test-Path -LiteralPath $hexXml)) { throw 'No NUnit XML report generated' }
    if ((Get-Item -LiteralPath $hexXml).LastWriteTimeUtc -lt $hexStarted) { throw 'Stale test report' }
    [xml]$hexResults = Get-Content -LiteralPath $hexXml -Raw
    if ($hexResults.SelectNodes('//test-case').Count -eq 0) { throw 'No DUnitX test cases executed' }
  }
} finally {
  $env:TEMP = $hexPreviousTemp
  $env:TMP = $hexPreviousTmp
}
