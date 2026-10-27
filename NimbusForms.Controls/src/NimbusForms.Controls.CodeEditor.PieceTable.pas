{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.PieceTable;

interface

uses System.SysUtils, System.Generics.Collections, NimbusForms.Controls.CodeEditor.Types;

type
  TCodePieceSource = (cpsOriginal, cpsAdd);
  TCodePieceNode = class
  public
    Source: TCodePieceSource;
    Start, Length, LineFeedCount, TotalLength, TotalLineFeedCount: Integer;
    Red: Boolean;
    LineFeedOffsets: TArray<Integer>;
    Parent, Left, Right: TCodePieceNode;
  end;
  TCodeChunkedAppendBuffer = class
  private
    FChunkSize, FLength: Integer;
    FReadOnly: Boolean;
    FChunks: TList<TCharArray>;
    procedure AppendChar(const Value: Char);
  public
    constructor Create(const ChunkSize: Integer);
    destructor Destroy; override;
    function Append(const Text: string): Integer;
    function AppendNormalized(const Text, NewLine: string; out AppendedLength: Integer): Integer;
    function GetChar(const Offset: Integer): Char;
    procedure AppendTo(Builder: TStringBuilder; const Offset, Count: Integer);
    function CountLineFeeds(const Offset, Count: Integer): Integer;
    function FindLineFeed(const Offset, Count, LineFeedIndex: Integer): Integer;
    function Snapshot: TCodeChunkedAppendBuffer;
    procedure Clear;
    property Length: Integer read FLength;
  end;
  TCodePieceTable = class
  private
    FAddBuffer: TCodeChunkedAppendBuffer;
    FOriginalBuffer, FNewLine: string;
    FRoot: TCodePieceNode;
    FLength, FPieceCount: Integer;
    FReadOnly: Boolean;
    function GetTextValue: string;
    procedure SetText(const Value: string);
    function GetLineCount: Integer;
    procedure EnsureWritable;
    procedure ClearTree(Node: TCodePieceNode);
    function CloneTree(Node, Parent: TCodePieceNode): TCodePieceNode;
    function CreateNode(const Source: TCodePieceSource; const Start, Count: Integer): TCodePieceNode;
    function CreatePieceNodes(const Source: TCodePieceSource; const Start, Count: Integer): TList<TCodePieceNode>;
    procedure InsertNodesAt(const Offset: Integer; Nodes: TList<TCodePieceNode>);
    procedure FindNode(const Offset: Integer; out Node: TCodePieceNode; out LocalOffset: Integer);
    procedure SplitAt(const Offset: Integer);
    function SplitNode(Node: TCodePieceNode; const LeftLength: Integer): TCodePieceNode;
    function FindBoundaryNodes(const Offset: Integer; out Previous, Next: TCodePieceNode): Boolean;
    function TryExtendAddPieceAtOffset(const Offset, AddStart, InsertedLength: Integer): Boolean;
    procedure InsertBefore(Target, Node: TCodePieceNode);
    procedure InsertAfter(Target, Node: TCodePieceNode);
    procedure InsertFixup(Node: TCodePieceNode);
    procedure DeleteNode(Node: TCodePieceNode);
    procedure DeleteFixup(Node, Parent: TCodePieceNode);
    procedure RotateLeft(Node: TCodePieceNode);
    procedure RotateRight(Node: TCodePieceNode);
    procedure Transplant(OldNode, NewNode: TCodePieceNode);
    function Minimum(Node: TCodePieceNode): TCodePieceNode;
    function Maximum(Node: TCodePieceNode): TCodePieceNode;
    function Successor(Node: TCodePieceNode): TCodePieceNode;
    function Predecessor(Node: TCodePieceNode): TCodePieceNode;
    procedure Update(Node: TCodePieceNode);
    procedure UpdateUpwards(Node: TCodePieceNode);
    function TotalLength(Node: TCodePieceNode): Integer;
    function TotalLineFeeds(Node: TCodePieceNode): Integer;
    function IsRed(Node: TCodePieceNode): Boolean;
    function IsBlack(Node: TCodePieceNode): Boolean;
    function CountLineFeeds(const Source: TCodePieceSource; const Start, Count: Integer): Integer;
    procedure IndexLineFeeds(Node: TCodePieceNode);
    function FindLineFeedInPiece(Node: TCodePieceNode; const Index: Integer): Integer;
    function FindLineFeedOffset(const Index: Integer): Integer;
    function CountLineFeedsBefore(const Offset: Integer): Integer;
    function SourceChar(const Source: TCodePieceSource; const Offset: Integer): Char;
    procedure AppendPieceText(Builder: TStringBuilder; Node: TCodePieceNode; const LocalOffset, Count: Integer);
  public
    constructor Create(const NewLine: string = #13#10);
    destructor Destroy; override;
    procedure Insert(const Offset: Integer; const Text: string);
    function Delete(const Offset, Count: Integer): string;
    function GetText(const Offset, Count: Integer): string;
    function GetCharAt(const Offset: Integer): Char;
    function GetLineText(const LineIndex: Integer): string;
    function GetLineLength(const LineIndex: Integer): Integer;
    function GetLineStartOffset(const LineIndex: Integer): Integer;
    function GetOffsetFromPosition(const Position: TCodeDocumentPosition): Integer;
    function GetPositionFromOffset(const Offset: Integer): TCodeDocumentPosition;
    function GetLineArray: TArray<string>;
    function CreateSnapshot: TCodePieceTable;
    procedure ValidateStructure;
    property Text: string read GetTextValue write SetText;
    property Length: Integer read FLength;
    property LineCount: Integer read GetLineCount;
    property PieceCount: Integer read FPieceCount;
  end;

implementation

uses System.Math;

const CodeAddBufferChunkSize = 64 * 1024; CodeMaximumPieceLength = 8 * 1024;

constructor TCodeChunkedAppendBuffer.Create(const ChunkSize: Integer);
begin
  inherited Create;
  if ChunkSize <= 0 then raise EArgumentOutOfRangeException.Create('ChunkSize');
  FChunkSize := ChunkSize; FChunks := TList<TCharArray>.Create;
end;
destructor TCodeChunkedAppendBuffer.Destroy;
begin FChunks.Free; inherited; end;
procedure TCodeChunkedAppendBuffer.Clear;
begin if FReadOnly then raise EInvalidOpException.Create('Append buffer snapshot is read only'); FChunks.Clear; FLength := 0; end;
procedure TCodeChunkedAppendBuffer.AppendChar(const Value: Char);
var Index, Offset: Integer; Chunk: TCharArray;
begin
  if FLength = MaxInt then raise EOutOfMemory.Create('Piece table append buffer exceeds Integer capacity');
  Index := FLength div FChunkSize; Offset := FLength mod FChunkSize;
  if Index = FChunks.Count then begin SetLength(Chunk, FChunkSize); FChunks.Add(Chunk); end;
  Chunk := FChunks[Index]; Chunk[Offset] := Value; Inc(FLength);
end;
function TCodeChunkedAppendBuffer.Append(const Text: string): Integer;
var SourceIndex, ChunkIndex, ChunkOffset, Take: Integer; Chunk: TCharArray;
begin
  if FReadOnly then raise EInvalidOpException.Create('Append buffer snapshot is read only');
  if System.Length(Text) > MaxInt - FLength then raise EOutOfMemory.Create('Piece table append buffer exceeds Integer capacity');
  Result := FLength; SourceIndex := 0;
  while SourceIndex < System.Length(Text) do
  begin
    ChunkIndex := FLength div FChunkSize; ChunkOffset := FLength mod FChunkSize;
    if ChunkIndex = FChunks.Count then begin Chunk := nil; SetLength(Chunk, FChunkSize); FChunks.Add(Chunk); end;
    Take := Min(FChunkSize - ChunkOffset, System.Length(Text) - SourceIndex); Chunk := FChunks[ChunkIndex];
    Move(Text[SourceIndex + 1], Chunk[ChunkOffset], Take * SizeOf(Char)); Inc(SourceIndex, Take); Inc(FLength, Take);
  end;
end;
function TCodeChunkedAppendBuffer.AppendNormalized(const Text, NewLine: string; out AppendedLength: Integer): Integer;
var I, J: Integer; C: Char;
begin
  if FReadOnly then raise EInvalidOpException.Create('Append buffer snapshot is read only');
  Result := FLength; I := 1;
  while I <= System.Length(Text) do
  begin
    C := Text[I];
    if CharInSet(C, [#13, #10]) then
    begin
      if (C = #13) and (I < System.Length(Text)) and (Text[I + 1] = #10) then Inc(I);
      for J := 1 to System.Length(NewLine) do AppendChar(NewLine[J]);
    end
    else AppendChar(C);
    Inc(I);
  end;
  AppendedLength := FLength - Result;
end;
function TCodeChunkedAppendBuffer.GetChar(const Offset: Integer): Char;
var Chunk: TCharArray;
begin
  if (Offset < 0) or (Offset >= FLength) then Exit(#0);
  Chunk := FChunks[Offset div FChunkSize]; Result := Chunk[Offset mod FChunkSize];
end;
procedure TCodeChunkedAppendBuffer.AppendTo(Builder: TStringBuilder; const Offset, Count: Integer);
var Current, Remaining, Take, ChunkOffset: Integer; Chunk: TCharArray;
begin
  if Builder = nil then raise EArgumentNilException.Create('Builder');
  Current := EnsureRange(Offset, 0, FLength); Remaining := Min(Max(0, Count), FLength - Current);
  while Remaining > 0 do
  begin
    ChunkOffset := Current mod FChunkSize; Take := Min(FChunkSize - ChunkOffset, Remaining);
    Chunk := FChunks[Current div FChunkSize]; Builder.Append(Chunk, ChunkOffset, Take);
    Inc(Current, Take); Dec(Remaining, Take);
  end;
end;
function TCodeChunkedAppendBuffer.CountLineFeeds(const Offset, Count: Integer): Integer;
var Current, Remaining, Take, ChunkOffset, I: Integer; Chunk: TCharArray;
begin
  Result := 0; if (Count <= 0) or (Offset >= FLength) then Exit;
  Current := Max(0, Offset); Remaining := Count;
  if Offset < 0 then Inc(Remaining, Offset);
  Remaining := Min(Remaining, FLength - Current);
  while Remaining > 0 do
  begin
    ChunkOffset := Current mod FChunkSize; Take := Min(FChunkSize - ChunkOffset, Remaining); Chunk := FChunks[Current div FChunkSize];
    for I := ChunkOffset to ChunkOffset + Take - 1 do if Chunk[I] = #10 then Inc(Result);
    Inc(Current, Take); Dec(Remaining, Take);
  end;
end;
function TCodeChunkedAppendBuffer.FindLineFeed(const Offset, Count, LineFeedIndex: Integer): Integer;
var Current, Remaining, Take, ChunkOffset, I, Found, LocalBase: Integer; Chunk: TCharArray;
begin
  Result := -1; if (LineFeedIndex < 0) or (Count <= 0) or (Offset >= FLength) then Exit;
  Current := Max(0, Offset); Remaining := Count;
  if Offset < 0 then Inc(Remaining, Offset);
  Remaining := Min(Remaining, FLength - Current); Found := 0; LocalBase := 0;
  while Remaining > 0 do
  begin
    ChunkOffset := Current mod FChunkSize; Take := Min(FChunkSize - ChunkOffset, Remaining); Chunk := FChunks[Current div FChunkSize];
    for I := ChunkOffset to ChunkOffset + Take - 1 do if Chunk[I] = #10 then
    begin if Found = LineFeedIndex then Exit(LocalBase + I - ChunkOffset); Inc(Found); end;
    Inc(Current, Take); Inc(LocalBase, Take); Dec(Remaining, Take);
  end;
end;
function TCodeChunkedAppendBuffer.Snapshot: TCodeChunkedAppendBuffer;
begin
  Result := TCodeChunkedAppendBuffer.Create(FChunkSize);
  try Result.FChunks.AddRange(FChunks); Result.FLength := FLength; Result.FReadOnly := True; except Result.Free; raise; end;
end;

constructor TCodePieceTable.Create(const NewLine: string);
begin
  inherited Create;
  if (NewLine <> #10) and (NewLine <> #13#10) then raise EArgumentException.Create('NewLine must be LF or CRLF');
  FNewLine := NewLine; FAddBuffer := TCodeChunkedAppendBuffer.Create(CodeAddBufferChunkSize);
end;
destructor TCodePieceTable.Destroy;
begin ClearTree(FRoot); FAddBuffer.Free; inherited; end;
procedure TCodePieceTable.EnsureWritable;
begin if FReadOnly then raise EInvalidOpException.Create('Piece table snapshot is read only'); end;
procedure TCodePieceTable.ClearTree(Node: TCodePieceNode);
begin if Node = nil then Exit; ClearTree(Node.Left); ClearTree(Node.Right); Node.Free; end;
function TCodePieceTable.CloneTree(Node, Parent: TCodePieceNode): TCodePieceNode;
begin
  if Node = nil then Exit(nil); Result := TCodePieceNode.Create;
  try
    Result.Source := Node.Source; Result.Start := Node.Start; Result.Length := Node.Length;
    Result.LineFeedCount := Node.LineFeedCount; Result.TotalLength := Node.TotalLength; Result.TotalLineFeedCount := Node.TotalLineFeedCount;
    Result.Red := Node.Red; Result.Parent := Parent; Result.LineFeedOffsets := Node.LineFeedOffsets;
    Result.Left := CloneTree(Node.Left, Result); Result.Right := CloneTree(Node.Right, Result);
  except ClearTree(Result); raise; end;
end;
function TCodePieceTable.CreateSnapshot: TCodePieceTable;
begin
  Result := TCodePieceTable.Create(FNewLine);
  try
    Result.FOriginalBuffer := FOriginalBuffer; Result.FLength := FLength; Result.FPieceCount := FPieceCount;
    Result.FRoot := CloneTree(FRoot, nil); Result.FAddBuffer.Free; Result.FAddBuffer := nil;
    Result.FAddBuffer := FAddBuffer.Snapshot; Result.FReadOnly := True;
  except Result.Free; raise; end;
end;
function TCodePieceTable.GetTextValue: string;
begin Result := GetText(0, FLength); end;
function TCodePieceTable.GetLineCount: Integer;
begin Result := TotalLineFeeds(FRoot) + 1; end;
procedure TCodePieceTable.SetText(const Value: string);
var Nodes: TList<TCodePieceNode>; Previous: TCodePieceNode; I: Integer; Normalized: string;
begin
  EnsureWritable; Normalized := CodeNormalizeNewLines(Value); if FNewLine <> #10 then Normalized := Normalized.Replace(#10, FNewLine);
  ClearTree(FRoot); FRoot := nil; FPieceCount := 0; FAddBuffer.Clear; FOriginalBuffer := Normalized;
  FLength := System.Length(FOriginalBuffer); if FLength = 0 then Exit;
  Nodes := CreatePieceNodes(cpsOriginal, 0, FLength);
  try
    Previous := nil;
    for I := 0 to Nodes.Count - 1 do begin InsertAfter(Previous, Nodes[I]); Previous := Nodes[I]; end;
  finally Nodes.Free; end;
  if FRoot <> nil then FRoot.Red := False;
end;
function TCodePieceTable.CreateNode(const Source: TCodePieceSource; const Start, Count: Integer): TCodePieceNode;
begin
  Result := TCodePieceNode.Create; Result.Source := Source; Result.Start := Start; Result.Length := Count;
  try IndexLineFeeds(Result); except Result.Free; raise; end; Result.TotalLength := Count;
  Result.TotalLineFeedCount := Result.LineFeedCount; Result.Red := True; Inc(FPieceCount);
end;
function TCodePieceTable.CreatePieceNodes(const Source: TCodePieceSource; const Start, Count: Integer): TList<TCodePieceNode>;
var Current, Remaining, Take: Integer; Node: TCodePieceNode;
begin
  Result := TList<TCodePieceNode>.Create; Current := Start; Remaining := Count;
  try
    while Remaining > 0 do
    begin Take := Min(CodeMaximumPieceLength, Remaining); Result.Add(CreateNode(Source, Current, Take)); Inc(Current, Take); Dec(Remaining, Take); end;
  except for Node in Result do begin Node.Free; Dec(FPieceCount); end; Result.Free; raise; end;
end;
procedure TCodePieceTable.Insert(const Offset: Integer; const Text: string);
var Start, Count, Position: Integer; Nodes: TList<TCodePieceNode>;
begin
  EnsureWritable; if Text = '' then Exit; Position := EnsureRange(Offset, 0, FLength);
  Start := FAddBuffer.AppendNormalized(Text, FNewLine, Count);
  if Count > MaxInt - FLength then raise EOutOfMemory.Create('Piece table exceeds Integer capacity');
  if TryExtendAddPieceAtOffset(Position, Start, Count) then begin Inc(FLength, Count); Exit; end;
  Nodes := CreatePieceNodes(cpsAdd, Start, Count);
  try InsertNodesAt(Position, Nodes); finally Nodes.Free; end;
  Inc(FLength, Count);
end;
function TCodePieceTable.Delete(const Offset, Count: Integer): string;
var Position, Size, Remaining, Local: Integer; Node, Next: TCodePieceNode;
begin
  EnsureWritable; Position := EnsureRange(Offset, 0, FLength); Size := Min(Max(0, Count), FLength - Position);
  Result := GetText(Position, Size); if Size = 0 then Exit;
  SplitAt(Position); SplitAt(Position + Size); Remaining := Size; FindNode(Position, Node, Local);
  while (Node <> nil) and (Remaining > 0) do
  begin Next := Successor(Node); Dec(Remaining, Node.Length); DeleteNode(Node); Node := Next; end;
  Dec(FLength, Size); if FRoot <> nil then FRoot.Red := False;
end;
function TCodePieceTable.GetText(const Offset, Count: Integer): string;
var Position, Remaining, Take, Local: Integer; Node: TCodePieceNode; Builder: TStringBuilder;
begin
  Position := EnsureRange(Offset, 0, FLength); Remaining := Min(Max(0, Count), FLength - Position); if Remaining = 0 then Exit('');
  Builder := TStringBuilder.Create(Remaining);
  try
    FindNode(Position, Node, Local);
    while (Node <> nil) and (Remaining > 0) do
    begin Take := Min(Node.Length - Local, Remaining); AppendPieceText(Builder, Node, Local, Take); Dec(Remaining, Take); Node := Successor(Node); Local := 0; end;
    Result := Builder.ToString;
  finally Builder.Free; end;
end;
procedure TCodePieceTable.FindNode(const Offset: Integer; out Node: TCodePieceNode; out LocalOffset: Integer);
var Current: TCodePieceNode; Index, LeftLength: Integer;
begin
  Node := nil; LocalOffset := 0; if FRoot = nil then Exit;
  if Offset >= FLength then begin Node := Maximum(FRoot); LocalOffset := Node.Length; Exit; end;
  Index := Max(0, Offset); Current := FRoot;
  while Current <> nil do
  begin
    LeftLength := TotalLength(Current.Left);
    if Index < LeftLength then Current := Current.Left
    else if Index < LeftLength + Current.Length then begin Node := Current; LocalOffset := Index - LeftLength; Exit; end
    else begin Dec(Index, LeftLength + Current.Length); Current := Current.Right; end;
  end;
end;
procedure TCodePieceTable.SplitAt(const Offset: Integer);
var Node: TCodePieceNode; Local: Integer;
begin
  if (Offset <= 0) or (Offset >= FLength) then Exit; FindNode(Offset, Node, Local);
  if (Node <> nil) and (Local > 0) and (Local < Node.Length) then SplitNode(Node, Local);
end;
function TCodePieceTable.SplitNode(Node: TCodePieceNode; const LeftLength: Integer): TCodePieceNode;
begin
  Result := CreateNode(Node.Source, Node.Start + LeftLength, Node.Length - LeftLength);
  Node.Length := LeftLength; IndexLineFeeds(Node);
  UpdateUpwards(Node); InsertAfter(Node, Result);
end;
function TCodePieceTable.FindBoundaryNodes(const Offset: Integer; out Previous, Next: TCodePieceNode): Boolean;
var Node: TCodePieceNode; Local: Integer;
begin
  Previous := nil; Next := nil; Result := False; if FRoot = nil then Exit;
  if Offset <= 0 then begin Next := Minimum(FRoot); Exit(True); end;
  if Offset >= FLength then begin Previous := Maximum(FRoot); Exit(True); end;
  FindNode(Offset, Node, Local);
  if Node = nil then begin Previous := Maximum(FRoot); Exit(True); end;
  if Local = 0 then begin Next := Node; Previous := Predecessor(Node); Exit(True); end;
  if Local = Node.Length then begin Previous := Node; Next := Successor(Node); Exit(True); end;
end;
function TCodePieceTable.TryExtendAddPieceAtOffset(const Offset, AddStart, InsertedLength: Integer): Boolean;
var Previous, Next: TCodePieceNode;
begin
  Result := False; if (FRoot = nil) or (InsertedLength <= 0) then Exit;
  if not FindBoundaryNodes(Offset, Previous, Next) or (Previous = nil) then Exit;
  if (Previous.Source <> cpsAdd) or (Previous.Start + Previous.Length <> AddStart) or
    (InsertedLength > CodeMaximumPieceLength - Previous.Length) then Exit;
  Inc(Previous.Length, InsertedLength); IndexLineFeeds(Previous);
  UpdateUpwards(Previous); Result := True;
end;
procedure TCodePieceTable.InsertNodesAt(const Offset: Integer; Nodes: TList<TCodePieceNode>);
var First, Previous, Target: TCodePieceNode; I, Local: Integer;
begin
  if (Nodes = nil) or (Nodes.Count = 0) then Exit; First := Nodes[0];
  if FRoot = nil then begin InsertAfter(nil, First); Previous := First; end
  else if Offset <= 0 then begin InsertBefore(Minimum(FRoot), First); Previous := First; end
  else if Offset >= FLength then begin InsertAfter(Maximum(FRoot), First); Previous := First; end
  else
  begin
    SplitAt(Offset); FindNode(Offset, Target, Local);
    if Target = nil then InsertAfter(Maximum(FRoot), First)
    else if Local = 0 then InsertBefore(Target, First) else InsertAfter(Target, First);
    Previous := First;
  end;
  for I := 1 to Nodes.Count - 1 do begin InsertAfter(Previous, Nodes[I]); Previous := Nodes[I]; end;
  if FRoot <> nil then FRoot.Red := False;
end;
procedure TCodePieceTable.InsertBefore(Target, Node: TCodePieceNode);
var Previous: TCodePieceNode;
begin
  if Target = nil then begin InsertAfter(Maximum(FRoot), Node); Exit; end;
  if Target.Left = nil then begin Target.Left := Node; Node.Parent := Target; end
  else begin Previous := Maximum(Target.Left); Previous.Right := Node; Node.Parent := Previous; end;
  UpdateUpwards(Node.Parent); InsertFixup(Node);
end;
procedure TCodePieceTable.InsertAfter(Target, Node: TCodePieceNode);
var Next: TCodePieceNode;
begin
  if FRoot = nil then begin FRoot := Node; Node.Red := False; Update(Node); Exit; end;
  if Target = nil then Target := Maximum(FRoot);
  if Target.Right = nil then begin Target.Right := Node; Node.Parent := Target; end
  else begin Next := Minimum(Target.Right); Next.Left := Node; Node.Parent := Next; end;
  UpdateUpwards(Node.Parent); InsertFixup(Node);
end;
procedure TCodePieceTable.InsertFixup(Node: TCodePieceNode);
var Uncle: TCodePieceNode;
begin
  while (Node <> FRoot) and IsRed(Node.Parent) do
  begin
    if Node.Parent = Node.Parent.Parent.Left then
    begin
      Uncle := Node.Parent.Parent.Right;
      if IsRed(Uncle) then begin Node.Parent.Red := False; Uncle.Red := False; Node.Parent.Parent.Red := True; Node := Node.Parent.Parent; end
      else
      begin
        if Node = Node.Parent.Right then begin Node := Node.Parent; RotateLeft(Node); end;
        Node.Parent.Red := False; Node.Parent.Parent.Red := True; RotateRight(Node.Parent.Parent);
      end;
    end
    else
    begin
      Uncle := Node.Parent.Parent.Left;
      if IsRed(Uncle) then begin Node.Parent.Red := False; Uncle.Red := False; Node.Parent.Parent.Red := True; Node := Node.Parent.Parent; end
      else
      begin
        if Node = Node.Parent.Left then begin Node := Node.Parent; RotateRight(Node); end;
        Node.Parent.Red := False; Node.Parent.Parent.Red := True; RotateLeft(Node.Parent.Parent);
      end;
    end;
  end;
  if FRoot <> nil then FRoot.Red := False;
end;
procedure TCodePieceTable.DeleteNode(Node: TCodePieceNode);
var Y, X, XParent, OldParent: TCodePieceNode; YWasRed: Boolean;
begin
  Y := Node; YWasRed := Y.Red;
  if Node.Left = nil then
  begin X := Node.Right; XParent := Node.Parent; Transplant(Node, Node.Right); UpdateUpwards(XParent); end
  else if Node.Right = nil then
  begin X := Node.Left; XParent := Node.Parent; Transplant(Node, Node.Left); UpdateUpwards(XParent); end
  else
  begin
    Y := Minimum(Node.Right); YWasRed := Y.Red; X := Y.Right;
    if Y.Parent = Node then XParent := Y
    else
    begin
      OldParent := Y.Parent; Transplant(Y, Y.Right); XParent := OldParent;
      UpdateUpwards(OldParent); Y.Right := Node.Right; Y.Right.Parent := Y;
    end;
    Transplant(Node, Y); Y.Left := Node.Left; Y.Left.Parent := Y; Y.Red := Node.Red; Update(Y); UpdateUpwards(Y.Parent);
  end;
  Node.Left := nil; Node.Right := nil; Node.Parent := nil;
  if not YWasRed then DeleteFixup(X, XParent);
  if FRoot <> nil then FRoot.Red := False;
  Node.Free; Dec(FPieceCount);
end;
procedure TCodePieceTable.DeleteFixup(Node, Parent: TCodePieceNode);
var Sibling: TCodePieceNode;
begin
  while (Node <> FRoot) and IsBlack(Node) do
  begin
    if Parent = nil then Break;
    if Node = Parent.Left then
    begin
      Sibling := Parent.Right;
      if IsRed(Sibling) then begin Sibling.Red := False; Parent.Red := True; RotateLeft(Parent); Sibling := Parent.Right; end;
      if Sibling = nil then begin Node := Parent; Parent := Node.Parent; Continue; end;
      if IsBlack(Sibling.Left) and IsBlack(Sibling.Right) then begin Sibling.Red := True; Node := Parent; Parent := Node.Parent; end
      else
      begin
        if IsBlack(Sibling.Right) then
        begin if Sibling.Left <> nil then Sibling.Left.Red := False; Sibling.Red := True; RotateRight(Sibling); Sibling := Parent.Right; end;
        Sibling.Red := Parent.Red; Parent.Red := False; if Sibling.Right <> nil then Sibling.Right.Red := False;
        RotateLeft(Parent); Node := FRoot; Parent := nil;
      end;
    end
    else
    begin
      Sibling := Parent.Left;
      if IsRed(Sibling) then begin Sibling.Red := False; Parent.Red := True; RotateRight(Parent); Sibling := Parent.Left; end;
      if Sibling = nil then begin Node := Parent; Parent := Node.Parent; Continue; end;
      if IsBlack(Sibling.Left) and IsBlack(Sibling.Right) then begin Sibling.Red := True; Node := Parent; Parent := Node.Parent; end
      else
      begin
        if IsBlack(Sibling.Left) then
        begin if Sibling.Right <> nil then Sibling.Right.Red := False; Sibling.Red := True; RotateLeft(Sibling); Sibling := Parent.Left; end;
        Sibling.Red := Parent.Red; Parent.Red := False; if Sibling.Left <> nil then Sibling.Left.Red := False;
        RotateRight(Parent); Node := FRoot; Parent := nil;
      end;
    end;
  end;
  if Node <> nil then Node.Red := False;
end;
procedure TCodePieceTable.RotateLeft(Node: TCodePieceNode);
var Right: TCodePieceNode;
begin
  Right := Node.Right; Node.Right := Right.Left; if Right.Left <> nil then Right.Left.Parent := Node;
  Right.Parent := Node.Parent;
  if Node.Parent = nil then FRoot := Right else if Node = Node.Parent.Left then Node.Parent.Left := Right else Node.Parent.Right := Right;
  Right.Left := Node; Node.Parent := Right; Update(Node); Update(Right); UpdateUpwards(Right.Parent);
end;
procedure TCodePieceTable.RotateRight(Node: TCodePieceNode);
var Left: TCodePieceNode;
begin
  Left := Node.Left; Node.Left := Left.Right; if Left.Right <> nil then Left.Right.Parent := Node;
  Left.Parent := Node.Parent;
  if Node.Parent = nil then FRoot := Left else if Node = Node.Parent.Right then Node.Parent.Right := Left else Node.Parent.Left := Left;
  Left.Right := Node; Node.Parent := Left; Update(Node); Update(Left); UpdateUpwards(Left.Parent);
end;
procedure TCodePieceTable.Transplant(OldNode, NewNode: TCodePieceNode);
begin
  if OldNode.Parent = nil then FRoot := NewNode else if OldNode = OldNode.Parent.Left then OldNode.Parent.Left := NewNode else OldNode.Parent.Right := NewNode;
  if NewNode <> nil then NewNode.Parent := OldNode.Parent;
end;
function TCodePieceTable.Minimum(Node: TCodePieceNode): TCodePieceNode;
begin Result := Node; if Result <> nil then while Result.Left <> nil do Result := Result.Left; end;
function TCodePieceTable.Maximum(Node: TCodePieceNode): TCodePieceNode;
begin Result := Node; if Result <> nil then while Result.Right <> nil do Result := Result.Right; end;
function TCodePieceTable.Successor(Node: TCodePieceNode): TCodePieceNode;
begin
  if Node = nil then Exit(nil); if Node.Right <> nil then Exit(Minimum(Node.Right));
  Result := Node.Parent; while (Result <> nil) and (Node = Result.Right) do begin Node := Result; Result := Result.Parent; end;
end;
function TCodePieceTable.Predecessor(Node: TCodePieceNode): TCodePieceNode;
begin
  if Node = nil then Exit(nil); if Node.Left <> nil then Exit(Maximum(Node.Left));
  Result := Node.Parent; while (Result <> nil) and (Node = Result.Left) do begin Node := Result; Result := Result.Parent; end;
end;
procedure TCodePieceTable.Update(Node: TCodePieceNode);
begin if Node = nil then Exit; Node.TotalLength := Node.Length + TotalLength(Node.Left) + TotalLength(Node.Right); Node.TotalLineFeedCount := Node.LineFeedCount + TotalLineFeeds(Node.Left) + TotalLineFeeds(Node.Right); end;
procedure TCodePieceTable.UpdateUpwards(Node: TCodePieceNode);
begin while Node <> nil do begin Update(Node); Node := Node.Parent; end; end;
function TCodePieceTable.TotalLength(Node: TCodePieceNode): Integer;
begin if Node = nil then Result := 0 else Result := Node.TotalLength; end;
function TCodePieceTable.TotalLineFeeds(Node: TCodePieceNode): Integer;
begin if Node = nil then Result := 0 else Result := Node.TotalLineFeedCount; end;
function TCodePieceTable.IsRed(Node: TCodePieceNode): Boolean;
begin Result := (Node <> nil) and Node.Red; end;
function TCodePieceTable.IsBlack(Node: TCodePieceNode): Boolean;
begin Result := (Node = nil) or not Node.Red; end;
function TCodePieceTable.CountLineFeeds(const Source: TCodePieceSource; const Start, Count: Integer): Integer;
var I, First, Size: Integer;
begin
  if Source = cpsAdd then Exit(FAddBuffer.CountLineFeeds(Start, Count));
  Result := 0; First := Max(0, Start); Size := Count; if Start < 0 then Inc(Size, Start); Size := Min(Size, System.Length(FOriginalBuffer) - First);
  for I := First to First + Size - 1 do if FOriginalBuffer[I + 1] = #10 then Inc(Result);
end;
procedure TCodePieceTable.IndexLineFeeds(Node: TCodePieceNode);
var Offsets: TArray<Integer>; I, Count: Integer;
begin
  Count := CountLineFeeds(Node.Source, Node.Start, Node.Length); SetLength(Offsets, Count); Count := 0;
  for I := 0 to Node.Length - 1 do
    if SourceChar(Node.Source, Node.Start + I) = #10 then begin Offsets[Count] := I; Inc(Count); end;
  Node.LineFeedOffsets := Offsets; Node.LineFeedCount := Count;
end;
function TCodePieceTable.FindLineFeedInPiece(Node: TCodePieceNode; const Index: Integer): Integer;
begin
  Result := -1; if (Node <> nil) and (Index >= 0) and (Index < Node.LineFeedCount) then Result := Node.LineFeedOffsets[Index];
end;
function TCodePieceTable.FindLineFeedOffset(const Index: Integer): Integer;
var Node: TCodePieceNode; Remaining, Offset, LeftCount, Local: Integer;
begin
  Node := FRoot; Remaining := Index; Offset := 0; Result := -1;
  while Node <> nil do
  begin
    LeftCount := TotalLineFeeds(Node.Left);
    if Remaining < LeftCount then begin Node := Node.Left; Continue; end;
    Inc(Offset, TotalLength(Node.Left)); Dec(Remaining, LeftCount);
    if Remaining < Node.LineFeedCount then begin Local := FindLineFeedInPiece(Node, Remaining); if Local >= 0 then Result := Offset + Local; Exit; end;
    Inc(Offset, Node.Length); Dec(Remaining, Node.LineFeedCount); Node := Node.Right;
  end;
end;
function TCodePieceTable.CountLineFeedsBefore(const Offset: Integer): Integer;
var Node: TCodePieceNode; Index, LeftLength, Low, High, Middle, Local: Integer;
begin
  Result := 0; if (Offset <= 0) or (FRoot = nil) then Exit; Index := Min(Offset, FLength); Node := FRoot;
  while Node <> nil do
  begin
    LeftLength := TotalLength(Node.Left);
    if Index <= LeftLength then begin Node := Node.Left; Continue; end;
    Inc(Result, TotalLineFeeds(Node.Left));
    if Index <= LeftLength + Node.Length then
    begin
      Local := Index - LeftLength; Low := 0; High := Node.LineFeedCount;
      while Low < High do
      begin
        Middle := Low + (High - Low) div 2;
        if Node.LineFeedOffsets[Middle] < Local then Low := Middle + 1 else High := Middle;
      end;
      Inc(Result, Low); Exit;
    end;
    Inc(Result, Node.LineFeedCount); Dec(Index, LeftLength + Node.Length); Node := Node.Right;
  end;
end;
function TCodePieceTable.SourceChar(const Source: TCodePieceSource; const Offset: Integer): Char;
begin
  if Source = cpsAdd then Exit(FAddBuffer.GetChar(Offset));
  if (Offset < 0) or (Offset >= System.Length(FOriginalBuffer)) then Result := #0 else Result := FOriginalBuffer[Offset + 1];
end;
function TCodePieceTable.GetCharAt(const Offset: Integer): Char;
var Node: TCodePieceNode; Local: Integer;
begin
  if (Offset < 0) or (Offset >= FLength) then Exit(#0); FindNode(Offset, Node, Local);
  if Node = nil then Result := #0 else Result := SourceChar(Node.Source, Node.Start + Local);
end;
procedure TCodePieceTable.AppendPieceText(Builder: TStringBuilder; Node: TCodePieceNode; const LocalOffset, Count: Integer);
begin
  if Count <= 0 then Exit;
  if Node.Source = cpsOriginal then Builder.Append(FOriginalBuffer, Node.Start + LocalOffset, Count)
  else FAddBuffer.AppendTo(Builder, Node.Start + LocalOffset, Count);
end;
function TCodePieceTable.GetLineStartOffset(const LineIndex: Integer): Integer;
var Offset: Integer;
begin
  if LineIndex <= 0 then Exit(0); if LineIndex >= GetLineCount then Exit(FLength);
  Offset := FindLineFeedOffset(LineIndex - 1); if Offset < 0 then Result := FLength else Result := Offset + 1;
end;
function TCodePieceTable.GetLineLength(const LineIndex: Integer): Integer;
var Start, Finish: Integer;
begin
  if (LineIndex < 0) or (LineIndex >= GetLineCount) then Exit(0);
  Start := GetLineStartOffset(LineIndex); Finish := GetLineStartOffset(LineIndex + 1);
  if (Finish > Start) and (GetCharAt(Finish - 1) = #10) then Dec(Finish);
  if (Finish > Start) and (GetCharAt(Finish - 1) = #13) then Dec(Finish);
  Result := Max(0, Finish - Start);
end;
function TCodePieceTable.GetLineText(const LineIndex: Integer): string;
begin
  if (LineIndex < 0) or (LineIndex >= GetLineCount) then Exit('');
  Result := GetText(GetLineStartOffset(LineIndex), GetLineLength(LineIndex));
end;
function TCodePieceTable.GetOffsetFromPosition(const Position: TCodeDocumentPosition): Integer;
var Line: Integer;
begin Line := EnsureRange(Position.LineIndex, 0, GetLineCount - 1); Result := GetLineStartOffset(Line) + EnsureRange(Position.ColumnIndex, 0, GetLineLength(Line)); end;
function TCodePieceTable.GetPositionFromOffset(const Offset: Integer): TCodeDocumentPosition;
var Position, Line: Integer;
begin
  Position := EnsureRange(Offset, 0, FLength); Line := CountLineFeedsBefore(Position);
  Result := TCodeDocumentPosition.Create(Line, EnsureRange(Position - GetLineStartOffset(Line), 0, GetLineLength(Line)));
end;
function TCodePieceTable.GetLineArray: TArray<string>;
var I: Integer;
begin SetLength(Result, GetLineCount); for I := 0 to High(Result) do Result[I] := GetLineText(I); end;
procedure TCodePieceTable.ValidateStructure;
var Nodes: Integer;
  function Walk(Node, Parent: TCodePieceNode): Integer;
  var LeftBlack, RightBlack, I, Offset: Integer;
  begin
    if Node = nil then Exit(1); Inc(Nodes);
    if (Node.Parent <> Parent) or (Node.Length <= 0) or (Node.Length > CodeMaximumPieceLength) or
      (Node.TotalLength <> Node.Length + TotalLength(Node.Left) + TotalLength(Node.Right)) or
      (Node.TotalLineFeedCount <> Node.LineFeedCount + TotalLineFeeds(Node.Left) + TotalLineFeeds(Node.Right)) or
      (Node.LineFeedCount <> CountLineFeeds(Node.Source, Node.Start, Node.Length)) then raise EInvalidOpException.Create('Invalid piece tree metadata');
    if System.Length(Node.LineFeedOffsets) <> Node.LineFeedCount then raise EInvalidOpException.Create('Invalid piece line index count');
    for I := 0 to Node.LineFeedCount - 1 do
    begin
      Offset := Node.LineFeedOffsets[I];
      if (Offset < 0) or (Offset >= Node.Length) then raise EInvalidOpException.Create('Invalid piece line index offset');
      if (I > 0) and (Node.LineFeedOffsets[I - 1] >= Offset) then raise EInvalidOpException.Create('Invalid piece line index order');
      if SourceChar(Node.Source, Node.Start + Offset) <> #10 then raise EInvalidOpException.Create('Invalid piece line index source');
    end;
    if Node.Red and (IsRed(Node.Left) or IsRed(Node.Right)) then raise EInvalidOpException.Create('Invalid red piece tree edge');
    LeftBlack := Walk(Node.Left, Node); RightBlack := Walk(Node.Right, Node);
    if LeftBlack <> RightBlack then raise EInvalidOpException.Create('Invalid piece tree black height');
    Result := LeftBlack; if not Node.Red then Inc(Result);
  end;
begin
  if IsRed(FRoot) or (TotalLength(FRoot) <> FLength) then raise EInvalidOpException.Create('Invalid piece tree root');
  Nodes := 0; Walk(FRoot, nil); if Nodes <> FPieceCount then raise EInvalidOpException.Create('Invalid piece count');
end;

end.
