param(
  [ValidateSet('Win32', 'Win64')][string]$Platform = 'Win64',
  [ValidateRange(1, 2147483646)][int]$FirstSeed = 1,
  [ValidateRange(1, 1000000)][int]$Seeds = 128,
  [ValidateRange(1, 10000000)][int]$Steps = 1000,
  [ValidateRange(1, 86400)][int]$TimeoutSeconds = 600
)
$ErrorActionPreference = 'Stop'
$ptRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$ptSource = Join-Path $ptRoot 'NimbusForms.Controls\src'
if (-not (Test-Path -LiteralPath $ptSource -PathType Container)) { throw 'Controls source directory not found' }
$ptOutput = Join-Path $ptRoot ('NimbusForms.Controls\build\piece-table-stress\' + $Platform)
foreach ($ptPath in @($ptOutput, $PSScriptRoot, $ptSource)) {
  $ptProbe = $ptPath
  while (-not (Test-Path -LiteralPath $ptProbe)) { $ptProbe = [IO.Path]::GetDirectoryName($ptProbe) }
  $ptItem = Get-Item -LiteralPath $ptProbe
  while ($null -ne $ptItem -and $ptItem.FullName.Length -ge $ptRoot.Length) {
    if ($ptItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked project path' }
    $ptItem = $ptItem.Parent
  }
}
if ([long]$FirstSeed + $Seeds -gt [int]::MaxValue) { throw 'Seed range overflow' }
$ptStudio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$ptCompilerName = 'dcc64.exe'
$ptLibrary = 'win64'
if ($Platform -eq 'Win32') { $ptCompilerName = 'dcc32.exe'; $ptLibrary = 'win32' }
$ptCompiler = Join-Path $ptStudio ('bin\' + $ptCompilerName)
if (-not (Test-Path -LiteralPath $ptCompiler -PathType Leaf)) { throw 'Compiler unavailable' }
New-Item -ItemType Directory -Path $ptOutput -Force | Out-Null
$ptTemp = Join-Path $ptOutput 'temp'
New-Item -ItemType Directory -Path $ptTemp -Force | Out-Null
$ptUnits = @($PSScriptRoot, $ptSource, (Join-Path $ptStudio ('lib\' + $ptLibrary + '\release'))) -join ';'
$ptStamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ')
$ptPrefix = Join-Path $ptOutput ('run-' + $ptStamp)
$ptReport = [ordered]@{
  platform = $Platform; firstSeed = $FirstSeed; seeds = $Seeds; steps = $Steps
  requestedRandomSteps = [long]$Seeds * $Steps * 2; timeoutSeconds = $TimeoutSeconds
  startedUtc = [DateTime]::UtcNow.ToString('o'); status = 'building'
  sourceHashes = [ordered]@{}; compiler = $ptCompiler
}
foreach ($ptFile in @(
  (Join-Path $ptSource 'NimbusForms.Controls.CodeEditor.PieceTable.pas'),
  (Join-Path $ptSource 'NimbusForms.Controls.CodeEditor.Types.pas'),
  (Join-Path $PSScriptRoot 'NimbusPieceTableStressChecks.pas'),
  (Join-Path $PSScriptRoot 'NimbusPieceTableStress.pas')
)) { $ptReport.sourceHashes[[IO.Path]::GetFileName($ptFile)] = (Get-FileHash -LiteralPath $ptFile -Algorithm SHA256).Hash }
$ptOldTemp = $env:TEMP
$ptOldTmp = $env:TMP
$ptProcess = $null
try {
  $env:TEMP = $ptTemp; $env:TMP = $ptTemp
  $ptStarted = [DateTime]::UtcNow
  $ptCompile = & $ptCompiler '-Q' '-B' '-$R+' '-$Q+' ('-N0' + $ptOutput) ('-E' + $ptOutput) ('-U' + $ptUnits) (Join-Path $PSScriptRoot 'NimbusPieceTableStress.pas') 2>&1
  $ptCompileExit = $LASTEXITCODE
  $ptCompile | Set-Content -LiteralPath ($ptPrefix + '-build.log')
  $ptCompile | ForEach-Object { Write-Output $_ }
  if (($ptCompile | Out-String) -match 'does not support command line compiling') {
    $ptReport.status = 'blocked-license'
    throw 'Compiler license rejects command line compilation; zero native stress tests executed'
  }
  if ($ptCompileExit -ne 0) { throw "Compiler failed: $ptCompileExit" }
  $ptExe = Join-Path $ptOutput 'NimbusPieceTableStress.exe'
  if (-not (Test-Path -LiteralPath $ptExe -PathType Leaf)) { throw 'Compiler did not generate an executable' }
  if ((Get-Item -LiteralPath $ptExe).LastWriteTimeUtc -lt $ptStarted) { throw 'Stale executable' }
  $ptReport.executableHash = (Get-FileHash -LiteralPath $ptExe -Algorithm SHA256).Hash
  $ptReport.status = 'running'
  $ptProcess = Start-Process -FilePath $ptExe -ArgumentList @($FirstSeed, $Seeds, $Steps) -WindowStyle Hidden -PassThru -RedirectStandardOutput ($ptPrefix + '-stdout.log') -RedirectStandardError ($ptPrefix + '-stderr.log')
  $ptTimer = [Diagnostics.Stopwatch]::StartNew()
  while (-not $ptProcess.WaitForExit(1000)) {
    if ($ptTimer.Elapsed.TotalSeconds -gt $TimeoutSeconds) {
      $ptProcess.Kill(); $ptProcess.WaitForExit(); $ptReport.status = 'timeout'
      throw "Stress test timed out; inspect $ptPrefix-stdout.log for last completed seed"
    }
  }
  $ptProcess.WaitForExit()
  $ptReport.exitCode = $ptProcess.ExitCode
  $ptReport.elapsedSeconds = $ptTimer.Elapsed.TotalSeconds
  $ptStdout = Get-Content -LiteralPath ($ptPrefix + '-stdout.log') -Raw
  Write-Output $ptStdout
  if ($ptProcess.ExitCode -ne 0) { throw 'Native piece table stress tests failed' }
  if ($ptStdout -notmatch 'RESULT .*failed_scenarios=0') { throw 'Missing successful test summary' }
  $ptReport.status = 'passed'
} catch {
  if ($ptReport.status -in @('building', 'running')) { $ptReport.status = 'failed' }
  $ptReport.error = $_.Exception.Message
  throw
} finally {
  $env:TEMP = $ptOldTemp; $env:TMP = $ptOldTmp
  if ($null -ne $ptProcess) {
    if (-not $ptProcess.HasExited) { $ptProcess.Kill(); $ptProcess.WaitForExit() }
    $ptProcess.Dispose()
  }
  $ptReport.finishedUtc = [DateTime]::UtcNow.ToString('o')
  $ptReport | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ($ptPrefix + '.json')
  Write-Output ('Report: ' + $ptPrefix + '.json')
}
