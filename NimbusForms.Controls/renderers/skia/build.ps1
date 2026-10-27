param([ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32', [string]$SkiaRuntimePath = '')
$ErrorActionPreference = 'Stop'
$bridgeRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$bridgeSource = Join-Path $bridgeRoot 'NimbusForms.Controls\src'
$bridgeOutput = Join-Path $bridgeRoot ('NimbusForms.Controls\build\skia-renderer\' + $Platform)
function AssertBridgePath([string]$Path) {
  $full = [IO.Path]::GetFullPath($Path)
  if (-not $full.StartsWith($bridgeRoot + '\NimbusForms.Controls\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Bridge path outside Controls' }
  $probe = $full
  while (-not (Test-Path -LiteralPath $probe)) { $probe = [IO.Path]::GetDirectoryName($probe) }
  $item = Get-Item -LiteralPath $probe
  while ($null -ne $item -and $item.FullName.Length -ge $bridgeRoot.Length) {
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked bridge path' }
    $item = $item.Parent
  }
}
AssertBridgePath $PSScriptRoot
AssertBridgePath $bridgeSource
AssertBridgePath $bridgeOutput
$bridgeStudio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$bridgeCompiler = Join-Path $bridgeStudio 'bin\dcc32.exe'
$bridgeLib = Join-Path $bridgeStudio 'lib\Win32\release'
if ($Platform -eq 'Win64') {
  $bridgeCompiler = Join-Path $bridgeStudio 'bin\dcc64.exe'
  $bridgeLib = Join-Path $bridgeStudio 'lib\Win64\release'
}
if (-not (Test-Path -LiteralPath $bridgeCompiler)) { throw 'Delphi compiler unavailable' }
New-Item -ItemType Directory -Path $bridgeOutput -Force | Out-Null
$bridgeTemp = Join-Path $bridgeOutput 'temp'
New-Item -ItemType Directory -Path $bridgeTemp -Force | Out-Null
$bridgeOldTemp = $env:TEMP
$bridgeOldTmp = $env:TMP
$bridgeStarted = [DateTime]::UtcNow
try {
  $env:TEMP = $bridgeTemp
  $env:TMP = $bridgeTemp
  $bridgeResult = & $bridgeCompiler '--no-config' '-Q' '-B' ('-U' + $bridgeSource + ';' + $bridgeLib) ('-N0' + $bridgeOutput) ('-E' + $bridgeOutput) (Join-Path $PSScriptRoot 'NimbusCodeEditorSkia.dpr') 2>&1
  $bridgeExit = $LASTEXITCODE
  $bridgeResult | ForEach-Object { Write-Output $_ }
  if (($bridgeResult | Out-String) -match 'does not support command line compiling') { throw 'Delphi license rejects command-line compilation; no renderer DLL was built' }
  if ($bridgeExit -ne 0) { throw "Renderer DLL build failed: $bridgeExit" }
  $bridgeDLL = Join-Path $bridgeOutput 'NimbusCodeEditorSkia.dll'
  if (-not (Test-Path -LiteralPath $bridgeDLL) -or (Get-Item -LiteralPath $bridgeDLL).LastWriteTimeUtc -lt $bridgeStarted) { throw 'No newly built renderer DLL found' }
  if ($SkiaRuntimePath -ne '') {
    $runtime = [IO.Path]::GetFullPath($SkiaRuntimePath)
    $runtimeProbe = Get-Item -LiteralPath $runtime
    while ($null -ne $runtimeProbe) {
      if ($runtimeProbe.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked runtime path' }
      $runtimeProbe = $runtimeProbe.Parent
    }
    if ([IO.Path]::GetFileName($runtime) -ne 'sk4d.dll') { throw 'Skia runtime must be sk4d.dll from the matching Skia4Delphi version and architecture' }
    Copy-Item -LiteralPath $runtime -Destination (Join-Path $bridgeOutput 'sk4d.dll')
  }
  Write-Output "Built renderer DLL: $bridgeDLL"
  if (-not (Test-Path -LiteralPath (Join-Path $bridgeOutput 'sk4d.dll'))) {
    Write-Output 'Place the matching sk4d.dll beside the renderer DLL before loading it. Runtime tests were not run.'
  } else {
    $bridgeTests = Join-Path $bridgeRoot 'NimbusForms.Controls\tests\NimbusSkiaBridgeTests.pas'
    AssertBridgePath $bridgeTests
    $testStarted = [DateTime]::UtcNow
    $testResult = & $bridgeCompiler '--no-config' '-Q' '-B' ('-U' + $bridgeSource + ';' + $bridgeLib) ('-N0' + $bridgeOutput) ('-E' + $bridgeOutput) $bridgeTests 2>&1
    $testExit = $LASTEXITCODE
    $testResult | ForEach-Object { Write-Output $_ }
    if ($testExit -ne 0 -or ($testResult | Out-String) -match 'does not support command line compiling') { throw 'Skia bridge test build failed' }
    $testExe = Join-Path $bridgeOutput 'NimbusSkiaBridgeTests.exe'
    if (-not (Test-Path -LiteralPath $testExe) -or (Get-Item -LiteralPath $testExe).LastWriteTimeUtc -lt $testStarted) { throw 'No newly built bridge test executable' }
    & $testExe $bridgeDLL
    if ($LASTEXITCODE -ne 0) { throw 'Skia bridge runtime tests failed' }
  }
} finally {
  $env:TEMP = $bridgeOldTemp
  $env:TMP = $bridgeOldTmp
}
