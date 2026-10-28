param([ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32')
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'NimbusForms.Controls\src') -PathType Container)) { throw 'Controls source directory not found' }
$controlsRoot = Join-Path $projectRoot 'NimbusForms.Controls'
$outputRoot = Join-Path $controlsRoot ('build\text-layout-tests\' + $Platform)
$targetPath = [IO.Path]::GetFullPath($outputRoot)
if (-not $targetPath.StartsWith($controlsRoot.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Build output outside Controls' }
$probePath = $targetPath
while (-not (Test-Path -LiteralPath $probePath)) { $probePath = [IO.Path]::GetDirectoryName($probePath) }
$probe = Get-Item -LiteralPath $probePath
while ($null -ne $probe -and $probe.FullName.Length -ge $projectRoot.Length) {
    if (($probe.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Build path contains a reparse point' }
    $probe = $probe.Parent
}
$compilerName = 'dcc32.exe'
$libraryName = 'win32'
if ($Platform -eq 'Win64') { $compilerName = 'dcc64.exe'; $libraryName = 'win64' }
$studioRoot = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$compiler = Join-Path $studioRoot ('bin\' + $compilerName)
if (-not (Test-Path -LiteralPath $compiler -PathType Leaf)) { throw 'Delphi 12 compiler not installed at the expected location' }
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$tempRoot = Join-Path $outputRoot 'temp'
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
$unitPaths = (Join-Path $controlsRoot 'src') + ';' + (Join-Path $projectRoot 'NimbusForms.Theming\src') + ';' + (Join-Path $studioRoot ('lib\' + $libraryName + '\release'))
$sourceFile = Join-Path $PSScriptRoot 'NimbusTextLayoutTests.pas'
$executable = Join-Path $outputRoot 'NimbusTextLayoutTests.exe'
$previousTemp = $env:TEMP
$previousTmp = $env:TMP
$startTime = [DateTime]::UtcNow
try {
    $env:TEMP = $tempRoot
    $env:TMP = $tempRoot
    $compilerOutput = & $compiler '-Q' '-B' ('-N0' + $outputRoot) ('-E' + $outputRoot) ('-U' + $unitPaths) $sourceFile 2>&1
    $compilerExit = $LASTEXITCODE
    $compilerOutput | ForEach-Object { Write-Output $_ }
    if (($compilerOutput | Out-String) -match 'does not support command line compiling') { throw 'Compiler license does not permit command line compilation; no build succeeded' }
    if ($compilerExit -ne 0) { throw ('Compiler failed with exit code ' + $compilerExit) }
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw 'Compiler returned without generating the test executable' }
    if ((Get-Item -LiteralPath $executable).LastWriteTimeUtc -lt $startTime) { throw 'Test executable is stale' }
    & $executable
    if ($LASTEXITCODE -ne 0) { throw ('Text layout regression tests failed with exit code ' + $LASTEXITCODE) }
} finally {
    $env:TEMP = $previousTemp
    $env:TMP = $previousTmp
}
