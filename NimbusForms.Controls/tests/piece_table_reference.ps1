param([ValidateSet('fixtures', 'delete-cycle')][string]$Case = 'fixtures')
$ErrorActionPreference = 'Stop'
$ptRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (-not (Test-Path -LiteralPath (Join-Path $ptRoot 'NimbusForms.Controls\src') -PathType Container)) { throw 'Controls source directory not found' }
$ptOutput = Join-Path $ptRoot 'NimbusForms.Controls\build\piece-table-reference'
$ptProbe = $ptOutput
while (-not (Test-Path -LiteralPath $ptProbe)) { $ptProbe = [IO.Path]::GetDirectoryName($ptProbe) }
foreach ($ptDirectory in @($ptProbe, $PSScriptRoot)) {
  $ptCheck = Get-Item -LiteralPath $ptDirectory
  while ($null -ne $ptCheck -and $ptCheck.FullName.Length -ge $ptRoot.Length) {
    if ($ptCheck.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked project path' }
    $ptCheck = $ptCheck.Parent
  }
}
$ptSources = @(
  (Join-Path $ptRoot 'NimbusFormsC#\Controls\VsIDE\CodeEditor\Document\CodeDocumentPosition.cs'),
  (Join-Path $ptRoot 'NimbusFormsC#\Controls\VsIDE\CodeEditor\Document\CodePieceTable.cs')
)
foreach ($ptSource in $ptSources) {
  $ptCheck = Get-Item -LiteralPath $ptSource
  while ($null -ne $ptCheck -and $ptCheck.FullName.Length -ge $ptRoot.Length) {
    if ($ptCheck.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked reference path' }
    $ptCheck = $ptCheck.Parent
  }
}
New-Item -ItemType Directory -Path $ptOutput -Force | Out-Null
$ptTemp = Join-Path $ptOutput 'temp'
New-Item -ItemType Directory -Path $ptTemp -Force | Out-Null
$ptOldTemp = $env:TEMP
$ptOldTmp = $env:TMP
$ptOldDotnetHome = $env:DOTNET_CLI_HOME
$ptOldTelemetry = $env:DOTNET_CLI_TELEMETRY_OPTOUT
try {
  $env:TEMP = $ptTemp
  $env:TMP = $ptTemp
  $env:DOTNET_CLI_HOME = $ptOutput
  $env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
  $ptHash = ((Get-FileHash -LiteralPath $ptSources[0] -Algorithm SHA256).Hash + (Get-FileHash -LiteralPath $ptSources[1] -Algorithm SHA256).Hash)
  $ptAssembly = Join-Path $ptOutput ('reference-' + $ptHash + '.dll')
  if (-not (Test-Path -LiteralPath $ptAssembly) -or (Get-Item -LiteralPath $ptAssembly).Length -eq 0) {
    $ptSDK = Get-ChildItem -LiteralPath 'C:\Program Files\dotnet\sdk' -Directory | Sort-Object Name -Descending | Select-Object -First 1
    $ptCompiler = Join-Path $ptSDK.FullName 'Roslyn\bincore\csc.dll'
    $ptFramework = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319'
    & 'C:\Program Files\dotnet\dotnet.exe' $ptCompiler '/nologo' '/noconfig' '/nostdlib+' '/target:library' ('/out:' + $ptAssembly) ('/r:' + (Join-Path $ptFramework 'mscorlib.dll')) ('/r:' + (Join-Path $ptFramework 'System.dll')) ('/r:' + (Join-Path $ptFramework 'System.Core.dll')) $ptSources
    if ($LASTEXITCODE -ne 0) { throw 'C# reference compilation failed' }
  }
  [Reflection.Assembly]::LoadFrom($ptAssembly) | Out-Null
  $ptTable = New-Object NimbusForms.Controls.VsIDE.CodeEditor.Document.CodePieceTable
  if ($Case -eq 'delete-cycle') {
    $ptTable.Text = ('a' * (8192 * 15))
    $ptFlags = [Reflection.BindingFlags]::Instance -bor [Reflection.BindingFlags]::NonPublic
    $ptNode = $ptTable.GetType().GetField('_root', $ptFlags).GetValue($ptTable)
    $ptStack = New-Object 'System.Collections.Generic.Stack[object]'
    $ptStack.Push($ptNode)
    $ptTarget = $null
    while ($ptStack.Count -gt 0) {
      $ptNode = $ptStack.Pop()
      if ($null -ne $ptNode.Left -and $null -ne $ptNode.Right -and $null -ne $ptNode.Right.Left) { $ptTarget = $ptNode; break }
      if ($null -ne $ptNode.Left) { $ptStack.Push($ptNode.Left) }
      if ($null -ne $ptNode.Right) { $ptStack.Push($ptNode.Right) }
    }
    if ($null -eq $ptTarget) { throw 'No deletion case found' }
    Write-Output ('C# deletion case: offset=' + $ptTarget.Start + ', length=' + $ptTarget.Length + '; successor is deeper than the right child')
    $ptTable.Delete($ptTarget.Start, $ptTarget.Length) | Out-Null
    Write-Output 'C# deletion returned'
    exit
  }
  $ptSteps = New-Object 'System.Collections.Generic.List[object]'
  function Record-Step([string]$Op, [int]$Offset, [int]$Count, [string]$Value) {
    $ptRemoved = ''
    switch ($Op) {
      'set' { $ptTable.Text = $Value }
      'insert' { $ptTable.Insert($Offset, $Value) }
      'delete' { $ptRemoved = $ptTable.Delete($Offset, $Count) }
    }
    $ptLines = $ptTable.GetLineArray()
    $ptStarts = @()
    $ptLengths = @()
    for ($ptLine = 0; $ptLine -lt $ptLines.Length; $ptLine++) {
      $ptStarts += $ptTable.GetLineStartOffset($ptLine)
      $ptLengths += $ptTable.GetLineLength($ptLine)
    }
    $ptOffsets = @(0, 1, 2, 7, 8191, 8192, 8193, 65535, 65536, 65537, ($ptTable.Length - 1), $ptTable.Length) | Sort-Object -Unique
    $ptPositions = @()
    foreach ($ptOffset in $ptOffsets) {
      $ptPosition = $ptTable.GetPositionFromOffset($ptOffset)
      $ptPositions += @{ offset=$ptOffset; line=$ptPosition.LineIndex; column=$ptPosition.ColumnIndex; roundTrip=$ptTable.GetOffsetFromPosition($ptPosition) }
    }
    $ptSteps.Add(@{ op=$Op; offset=$Offset; count=$Count; value=$Value; removed=$ptRemoved; text=$ptTable.Text; lines=@($ptLines); starts=@($ptStarts); lengths=@($ptLengths); positions=@($ptPositions) })
  }
  Record-Step 'set' 0 0 "alpha`r`nbeta`rgamma`n"
  Record-Step 'insert' 2 0 "X`nY"
  Record-Step 'set' 0 0 'abc'
  Record-Step 'delete' 1 1 ''
  Record-Step 'delete' 0 100 ''
  Record-Step 'insert' -10 0 "A`nB"
  Record-Step 'insert' 999 0 'tail'
  Record-Step 'set' 0 0 ('x' * 8191 + "`n" + 'y' * 8191 + "`r`n" + 'z' * 65537)
  Record-Step 'insert' 8192 0 'piece boundary'
  Record-Step 'insert' 65536 0 "chunk`nfragment"
  Record-Step 'set' 0 0 ''
  Record-Step 'insert' 0 0 ('q' * 65535 + "`n" + 'r' * 65537 + "`r`n")
  Record-Step 'insert' $ptTable.Length 0 'append'
  Record-Step 'set' 0 0 'seed'
  for ($ptI = 0; $ptI -lt 120; $ptI++) { Record-Step 'insert' $ptTable.Length 0 ('v' + $ptI) }
  for ($ptI = 0; $ptI -lt 10; $ptI++) { Record-Step 'delete' ($ptTable.Length - 1) 1 '' }
  $ptFixture = Join-Path $PSScriptRoot 'piece_table_reference.json'
  [IO.File]::WriteAllText($ptFixture, (ConvertTo-Json -InputObject @($ptSteps.ToArray()) -Depth 8), (New-Object Text.UTF8Encoding($false)))
  Write-Output ('C# original executed unchanged; ' + $ptSteps.Count + ' fixture steps written to ' + $ptFixture)
} finally {
  $env:TEMP = $ptOldTemp
  $env:TMP = $ptOldTmp
  $env:DOTNET_CLI_HOME = $ptOldDotnetHome
  $env:DOTNET_CLI_TELEMETRY_OPTOUT = $ptOldTelemetry
}
