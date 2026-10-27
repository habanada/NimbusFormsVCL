param(
  [string]$Project = 'All',
  [ValidateSet('Win32','Win64')][string]$Platform = 'Win32',
  [ValidateSet('Debug','Release')][string]$Configuration = 'Debug',
  [switch]$Packages,
  [switch]$List
)
$ErrorActionPreference = 'Stop'
$demoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $demoRoot '..'))
if (-not (Test-Path -LiteralPath (Join-Path $workspaceRoot 'NimbusForms.Controls\src') -PathType Container)) { throw 'Controls source directory not found' }
function Assert-WorkspacePath([string]$Path) {
  $resolved = [IO.Path]::GetFullPath($Path)
  if ($resolved -ne $workspaceRoot -and -not $resolved.StartsWith($workspaceRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Path outside workspace: $Path" }
  $probe = $resolved
  while (-not (Test-Path -LiteralPath $probe)) { $probe = [IO.Path]::GetDirectoryName($probe) }
  $item = Get-Item -LiteralPath $probe
  while ($null -ne $item -and $item.FullName.Length -ge $workspaceRoot.Length) {
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked path: $Path" }
    $item = $item.Parent
  }
  return $resolved
}
$manifest = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'projects.json') | ConvertFrom-Json
if ($List) { $manifest.projects | Select-Object name,title; return }
if ($Project -ne 'All' -and $Project -notin $manifest.projects.name) { throw "Unknown project: $Project" }
$bin = Assert-WorkspacePath (Join-Path $workspaceRoot 'bin')
New-Item -ItemType Directory -Path $bin -Force | Out-Null
$studio = 'C:\Program Files (x86)\Embarcadero\Studio\23.0'
$compilerName = 'dcc32.exe'
if ($Platform -eq 'Win64') { $compilerName = 'dcc64.exe' }
$compiler = Join-Path $studio ('bin\' + $compilerName)
if (-not (Test-Path -LiteralPath $compiler)) { throw "Compiler unavailable: $compiler" }
$packageDcp = Assert-WorkspacePath (Join-Path $bin ('packages\' + $Platform))
New-Item -ItemType Directory -Path $packageDcp -Force | Out-Null
function Build-Source([string]$Name, [string]$Source, [bool]$IsPackage) {
  $sourcePath = Assert-WorkspacePath $Source
  $obj = Assert-WorkspacePath (Join-Path $bin ('obj\' + $Platform + '\' + $Name))
  $temp = Assert-WorkspacePath (Join-Path $obj 'temp')
  New-Item -ItemType Directory -Path $temp -Force | Out-Null
  $logDirectory = Assert-WorkspacePath (Join-Path $bin 'build-logs')
  New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
  $unitPaths = @((Join-Path $workspaceRoot 'NimbusForms.Controls\src'), (Join-Path $workspaceRoot 'NimbusForms.Theming\src'), $demoRoot, (Join-Path $PSScriptRoot 'Shared'), $packageDcp, (Join-Path $studio ('lib\' + $Platform.ToLowerInvariant() + '\release')))
  $sourceText = Get-Content -Raw -LiteralPath $sourcePath
  if ($sourceText -match 'NimbusForms.Grid\.') { $unitPaths += Join-Path $workspaceRoot 'NimbusForms.Grid\src' }
  if ($sourceText -match 'NimbusForms.HexEditor\.') {
    $unitPaths += Join-Path $workspaceRoot 'NimbusForms.HexEditor\src'
    $unitPaths += Join-Path $workspaceRoot 'NativePattern\src'
  }
  $arguments = @('-Q','-B',('-N0' + $obj),('-E' + $bin),('-U' + ($unitPaths -join ';')),('-LE' + $packageDcp),('-LN' + $packageDcp),'-NSWinapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;System;Xml;Data;Datasnap;Web;Soap')
  if ($Configuration -eq 'Debug') { $arguments += @('-DDEBUG','-$O-','-$R+','-$Q+') } else { $arguments += '-$O+' }
  $arguments += $sourcePath
  $oldTemp = $env:TEMP; $oldTmp = $env:TMP; $started = [DateTime]::UtcNow
  try {
    $env:TEMP = $temp; $env:TMP = $temp
    $result = & $compiler @arguments 2>&1
    $exitCode = $LASTEXITCODE
    $lines = @($result | ForEach-Object { [string]$_ })
    [IO.File]::WriteAllLines((Join-Path $logDirectory ($Name + '.' + $Platform + '.log')), [string[]]$lines, [Text.UTF8Encoding]::new($false))
    $lines | ForEach-Object { Write-Output $_ }
    if (($lines -join "`n") -match 'does not support command line compiling') { throw 'The installed Delphi license rejected CLI compilation; no successful build.' }
    if ($exitCode -ne 0) { throw "Compiler failed for $Name ($exitCode)" }
    $extension = '.exe'; if ($IsPackage) { $extension = '.bpl' }
    $outputDirectory = $bin; if ($IsPackage) { $outputDirectory = $packageDcp }
    $output = Join-Path $outputDirectory ($Name + $extension)
    if (-not (Test-Path -LiteralPath $output) -or (Get-Item -LiteralPath $output).LastWriteTimeUtc -lt $started) { throw "No fresh build output for $Name" }
    Write-Output "Built $output"
  } finally { $env:TEMP = $oldTemp; $env:TMP = $oldTmp }
}
if ($Packages) {
  $packageRoot = Join-Path $workspaceRoot 'NimbusForms.Controls\packages'
  Build-Source 'NimbusFormsRuntime' (Join-Path $packageRoot 'NimbusFormsRuntime.dpk') $true
  if ($Platform -eq 'Win32') { Build-Source 'NimbusFormsDesign' (Join-Path $packageRoot 'NimbusFormsDesign.dpk') $true }
  else { Write-Warning 'The Delphi 12 IDE needs the Win32 design package; only the Win64 runtime package was built.' }
}
foreach ($entry in $manifest.projects) {
  if ($Project -eq 'All' -or $entry.name -eq $Project) { Build-Source $entry.name (Join-Path $PSScriptRoot ($entry.name + '.dpr')) $false }
}
function Copy-AssetDirectory([string]$Source, [string]$Destination) {
  $sourcePath = Assert-WorkspacePath $Source; $destinationPath = Assert-WorkspacePath $Destination
  if (-not (Test-Path -LiteralPath $sourcePath)) { return }
  New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
  foreach ($item in Get-ChildItem -LiteralPath $sourcePath) {
    $itemPath = Assert-WorkspacePath $item.FullName; $target = Assert-WorkspacePath (Join-Path $destinationPath $item.Name)
    if ($item.PSIsContainer) { Copy-AssetDirectory $itemPath $target } else { Copy-Item -LiteralPath $itemPath -Destination $target -Force }
  }
}
foreach ($directory in @('Palettes','ico','avatars')) { Copy-AssetDirectory (Join-Path $demoRoot $directory) (Join-Path $bin $directory) }
foreach ($library in @('NimbusCodeEditorSkia.dll','sk4d.dll')) {
  $source = Assert-WorkspacePath (Join-Path $demoRoot $library)
  if (Test-Path -LiteralPath $source) {
    $stream = [IO.File]::OpenRead($source); $reader = [IO.BinaryReader]::new($stream)
    try { $stream.Position = 60; $peOffset = $reader.ReadInt32(); $stream.Position = $peOffset + 4; $machine = $reader.ReadUInt16() }
    finally { $reader.Dispose() }
    if (($Platform -eq 'Win32' -and $machine -eq 332) -or ($Platform -eq 'Win64' -and $machine -eq 34404)) {
      Copy-Item -LiteralPath $source -Destination (Assert-WorkspacePath (Join-Path $bin $library)) -Force
    } else { Write-Warning "$library does not match $Platform and was not copied." }
  }
}
