unit NimbusForms.HexEditor.FindReplaceAdapter;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  Vcl.Forms,
  NimbusForms.HexEditor.FindReplaceTypes,
  NimbusForms.HexEditor.FindReplaceDialog;

type
  THexFindReplaceAdapter = class
  private
    FHost: IHexFindReplaceHost;
    FDialog: THexFindReplaceDialog;
    FLastFindPattern: TBytes;
    FLastReplacePattern: TBytes;
    FLastFindText: string;
    FLastReplaceText: string;
    FLastWasHexMode: Boolean;
    function GetIsVisible: Boolean;
    function EnsureDialog: THexFindReplaceDialog;
    procedure ShowDialog(const AOwner: TCustomForm; const ADialog: THexFindReplaceDialog);
    procedure ApplyDialogTheme;
    procedure DetachDialog;
    procedure DialogFindNextRequested(ASender: TObject; const AArgs: THexFindReplaceEventArgs);
    procedure DialogFindPreviousRequested(ASender: TObject; const AArgs: THexFindReplaceEventArgs);
    procedure DialogReplaceRequested(ASender: TObject; const AArgs: THexFindReplaceEventArgs);
    procedure DialogReplaceAllRequested(ASender: TObject; const AArgs: THexFindReplaceEventArgs);
    procedure DialogClosed(ASender: TObject);
    function Find(const AOptions: THexFindReplaceOptions; const ADown: Boolean;
      const AArgs: THexFindReplaceEventArgs): Boolean;
    function ReplaceCurrent(const AOptions: THexFindReplaceOptions; const AArgs: THexFindReplaceEventArgs): Boolean;
    function ReplaceAll(const AOptions: THexFindReplaceOptions; const AArgs: THexFindReplaceEventArgs): Integer;
    function TryCreateFindPattern(const AOptions: THexFindReplaceOptions; out APattern: TBytes;
      out AHexMode: Boolean; const AArgs: THexFindReplaceEventArgs): Boolean;
    function TryCreateReplacePattern(const AOptions: THexFindReplaceOptions; const AHexMode: Boolean;
      out APattern: TBytes; const AArgs: THexFindReplaceEventArgs): Boolean;
    function GetFindStartOffset(const APatternLength: Integer; const ADown: Boolean): Int64;
    function FindForward(const APattern: TBytes; AStartOffset: Int64; const AWrap: Boolean): Int64;
    function FindBackward(const APattern: TBytes; AStartOffset: Int64; const AWrap: Boolean): Int64;
    function FindForwardWithin(const APattern: TBytes; const AStartOffset, AEndOffset: Int64): Int64;
    function FindBackwardWithin(const APattern: TBytes; const AStartOffset, ALowerBound: Int64): Int64;
    function CurrentSelectionMatches(const APattern: TBytes): Boolean;
    function IgnoreCase: Boolean;
    function CreateOptionsFromLast(const ADirection: THexFindDirection): THexFindReplaceOptions;
    class function Matches(const ABuffer: TBytes; const AIndex: Integer; const APattern: TBytes;
      const AIgnoreCase: Boolean): Boolean; static;
    class function ToAsciiUpper(const AValue: Byte): Byte; static;
    class function LooksLikeHexInput(const AText: string): Boolean; static;
    class function TryParseHexBytes(const AText: string; out ABytes: TBytes): Boolean; static;
    class procedure SetMessage(const AArgs: THexFindReplaceEventArgs; const AMessage: string;
      const ASuccess: Boolean); static;
  public
    constructor Create(const AHost: IHexFindReplaceHost);
    destructor Destroy; override;
    procedure ShowFind(const AOwner: TCustomForm);
    procedure ShowReplace(const AOwner: TCustomForm);
    function FindNext: Boolean;
    function FindPrevious: Boolean;
    procedure RefreshTheme;
    property IsVisible: Boolean read GetIsVisible;
  end;

implementation

uses
  NimbusForms.HexEditor.Strings,
  NimbusForms.HexEditor.Theme;

const
  CChunkSize = 65536;
  CMaxReplaceCount = 100000;

type
  TStr = HexFindReplaceTexts;

constructor THexFindReplaceAdapter.Create(const AHost: IHexFindReplaceHost);
begin
  inherited Create;
  if AHost = nil then
    raise EArgumentNilException.Create('AHost');
  FHost := AHost;
  FLastFindText := '';
  FLastReplaceText := '';
end;

destructor THexFindReplaceAdapter.Destroy;
begin
  DetachDialog;
  FHost := nil;
  inherited Destroy;
end;

procedure THexFindReplaceAdapter.DetachDialog;
var
  LDialog: THexFindReplaceDialog;
begin
  if FDialog = nil then
    Exit;
  LDialog := FDialog;
  FDialog := nil;
  LDialog.OnFindNextRequested := nil;
  LDialog.OnFindPreviousRequested := nil;
  LDialog.OnReplaceRequested := nil;
  LDialog.OnReplaceAllRequested := nil;
  LDialog.OnDialogClosed := nil;
  LDialog.Free;
end;

function THexFindReplaceAdapter.GetIsVisible: Boolean;
begin
  Result := (FDialog <> nil) and FDialog.Visible;
end;

function THexFindReplaceAdapter.EnsureDialog: THexFindReplaceDialog;
begin
  if FDialog <> nil then
    Exit(FDialog);
  FDialog := THexFindReplaceDialog.CreateDialog(nil, FHost.GetPixelsPerInch);
  FDialog.OnFindNextRequested := DialogFindNextRequested;
  FDialog.OnFindPreviousRequested := DialogFindPreviousRequested;
  FDialog.OnReplaceRequested := DialogReplaceRequested;
  FDialog.OnReplaceAllRequested := DialogReplaceAllRequested;
  FDialog.OnDialogClosed := DialogClosed;
  ApplyDialogTheme;
  Result := FDialog;
end;

procedure THexFindReplaceAdapter.ApplyDialogTheme;
var
  LTheme: THexTheme;
begin
  if FDialog = nil then
    Exit;
  LTheme := FHost.GetTheme;
  if LTheme = nil then
    Exit;
  FDialog.ApplyColors(LTheme.BackColor, LTheme.ForeColor, LTheme.CellBackColor, LTheme.CellForeColor);
end;

procedure THexFindReplaceAdapter.RefreshTheme;
begin
  ApplyDialogTheme;
end;

procedure THexFindReplaceAdapter.ShowDialog(const AOwner: TCustomForm; const ADialog: THexFindReplaceDialog);
begin
  if ADialog.Visible then
  begin
    ADialog.BringToFront;
    ADialog.FocusFindText;
    Exit;
  end;
  if AOwner <> nil then
  begin
    ADialog.PopupMode := pmExplicit;
    ADialog.PopupParent := AOwner;
  end;
  ADialog.Show;
  ADialog.FocusFindText;
end;

procedure THexFindReplaceAdapter.ShowFind(const AOwner: TCustomForm);
var
  LDialog: THexFindReplaceDialog;
begin
  LDialog := EnsureDialog;
  LDialog.Mode := hfmFind;
  ShowDialog(AOwner, LDialog);
end;

procedure THexFindReplaceAdapter.ShowReplace(const AOwner: TCustomForm);
var
  LDialog: THexFindReplaceDialog;
begin
  LDialog := EnsureDialog;
  LDialog.Mode := hfmReplace;
  ShowDialog(AOwner, LDialog);
end;

function THexFindReplaceAdapter.FindNext: Boolean;
begin
  if Length(FLastFindPattern) = 0 then
  begin
    ShowFind(FHost.GetOwnerForm);
    Exit(False);
  end;
  Result := Find(CreateOptionsFromLast(hfdDown), True, nil);
end;

function THexFindReplaceAdapter.FindPrevious: Boolean;
begin
  if Length(FLastFindPattern) = 0 then
  begin
    ShowFind(FHost.GetOwnerForm);
    Exit(False);
  end;
  Result := Find(CreateOptionsFromLast(hfdUp), False, nil);
end;

procedure THexFindReplaceAdapter.DialogClosed(ASender: TObject);
begin
  FDialog := nil;
end;

procedure THexFindReplaceAdapter.DialogFindNextRequested(ASender: TObject; const AArgs: THexFindReplaceEventArgs);
begin
  if AArgs = nil then
    Exit;
  AArgs.Handled := True;
  AArgs.Success := Find(AArgs.Options, True, AArgs);
end;

procedure THexFindReplaceAdapter.DialogFindPreviousRequested(ASender: TObject;
  const AArgs: THexFindReplaceEventArgs);
begin
  if AArgs = nil then
    Exit;
  AArgs.Handled := True;
  AArgs.Success := Find(AArgs.Options, False, AArgs);
end;

procedure THexFindReplaceAdapter.DialogReplaceRequested(ASender: TObject; const AArgs: THexFindReplaceEventArgs);
begin
  if AArgs = nil then
    Exit;
  AArgs.Handled := True;
  AArgs.Success := ReplaceCurrent(AArgs.Options, AArgs);
end;

procedure THexFindReplaceAdapter.DialogReplaceAllRequested(ASender: TObject;
  const AArgs: THexFindReplaceEventArgs);
var
  LCount: Integer;
begin
  if AArgs = nil then
    Exit;
  AArgs.Handled := True;
  LCount := ReplaceAll(AArgs.Options, AArgs);
  AArgs.Success := LCount > 0;
end;

function THexFindReplaceAdapter.Find(const AOptions: THexFindReplaceOptions; const ADown: Boolean;
  const AArgs: THexFindReplaceEventArgs): Boolean;
var
  LPattern: TBytes;
  LHexMode: Boolean;
  LStart: Int64;
  LFound: Int64;
begin
  if not TryCreateFindPattern(AOptions, LPattern, LHexMode, AArgs) then
    Exit(False);
  FLastFindPattern := Copy(LPattern, 0, Length(LPattern));
  FLastFindText := AOptions.FindText;
  FLastWasHexMode := LHexMode;
  LStart := GetFindStartOffset(Length(LPattern), ADown);
  if ADown then
    LFound := FindForward(LPattern, LStart, AOptions.WrapSearch)
  else
    LFound := FindBackward(LPattern, LStart, AOptions.WrapSearch);
  if LFound < 0 then
  begin
    SetMessage(AArgs, TStr.FindNotFound, False);
    Exit(False);
  end;
  FHost.GoToOffset(LFound, Length(LPattern));
  SetMessage(AArgs, TStr.FindFoundPrefix + Format(TStr.OffsetFormat, [LFound]), True);
  Result := True;
end;

function THexFindReplaceAdapter.ReplaceCurrent(const AOptions: THexFindReplaceOptions;
  const AArgs: THexFindReplaceEventArgs): Boolean;
var
  LFindPattern: TBytes;
  LReplacePattern: TBytes;
  LHexMode: Boolean;
  LOffset: Int64;
begin
  if not TryCreateFindPattern(AOptions, LFindPattern, LHexMode, AArgs) then
    Exit(False);
  if not TryCreateReplacePattern(AOptions, LHexMode, LReplacePattern, AArgs) then
    Exit(False);
  FLastFindPattern := Copy(LFindPattern, 0, Length(LFindPattern));
  FLastReplacePattern := Copy(LReplacePattern, 0, Length(LReplacePattern));
  FLastFindText := AOptions.FindText;
  FLastReplaceText := AOptions.ReplaceText;
  FLastWasHexMode := LHexMode;
  if not CurrentSelectionMatches(LFindPattern) then
    if not Find(AOptions, AOptions.Direction <> hfdUp, AArgs) then
      Exit(False);
  if not CurrentSelectionMatches(LFindPattern) then
  begin
    SetMessage(AArgs, TStr.ReplaceNoActiveMatch, False);
    Exit(False);
  end;
  LOffset := FHost.GetSelectionStart;
  if not FHost.DeleteBytes(LOffset, Length(LFindPattern)) then
  begin
    SetMessage(AArgs, TStr.ReplaceFailed, False);
    Exit(False);
  end;
  if (Length(LReplacePattern) > 0) and not FHost.InsertBytes(LOffset, LReplacePattern) then
  begin
    SetMessage(AArgs, TStr.ReplaceFailed, False);
    Exit(False);
  end;
  FHost.GoToOffset(LOffset, Length(LReplacePattern));
  SetMessage(AArgs, TStr.ReplaceDone, True);
  Result := True;
end;

function THexFindReplaceAdapter.ReplaceAll(const AOptions: THexFindReplaceOptions;
  const AArgs: THexFindReplaceEventArgs): Integer;
var
  LFindPattern: TBytes;
  LReplacePattern: TBytes;
  LHexMode: Boolean;
  LOffset: Int64;
  LEndOffset: Int64;
  LFound: Int64;
  LUseSelection: Boolean;
begin
  Result := 0;
  if not TryCreateFindPattern(AOptions, LFindPattern, LHexMode, AArgs) then
    Exit;
  if not TryCreateReplacePattern(AOptions, LHexMode, LReplacePattern, AArgs) then
    Exit;
  FLastFindPattern := Copy(LFindPattern, 0, Length(LFindPattern));
  FLastReplacePattern := Copy(LReplacePattern, 0, Length(LReplacePattern));
  FLastFindText := AOptions.FindText;
  FLastReplaceText := AOptions.ReplaceText;
  FLastWasHexMode := LHexMode;
  LUseSelection := (AOptions.Scope = hfsSelection) and FHost.GetHasSelection;
  if LUseSelection then
  begin
    LOffset := FHost.GetSelectionStart;
    LEndOffset := FHost.GetSelectionStart + FHost.GetSelectionLength;
  end
  else
  begin
    LOffset := 0;
    LEndOffset := FHost.GetDataLength;
  end;
  while (LOffset >= 0) and (LOffset < LEndOffset) do
  begin
    LFound := FindForwardWithin(LFindPattern, LOffset, LEndOffset);
    if LFound < 0 then
      Break;
    if not FHost.DeleteBytes(LFound, Length(LFindPattern)) then
      Break;
    if (Length(LReplacePattern) > 0) and not FHost.InsertBytes(LFound, LReplacePattern) then
      Break;
    Inc(Result);
    LOffset := LFound + Max(1, Length(LReplacePattern));
    LEndOffset := LEndOffset - Length(LFindPattern) + Length(LReplacePattern);
    if Result > CMaxReplaceCount then
      Break;
  end;
  if Result > 0 then
    FHost.GoToOffset(Min(FHost.GetDataLength - 1, Max(Int64(0), LOffset)), 0);
  if Result > 0 then
    SetMessage(AArgs, TStr.ReplaceAllDonePrefix + IntToStr(Result), True)
  else
    SetMessage(AArgs, TStr.FindNotFound, False);
end;

function THexFindReplaceAdapter.TryCreateFindPattern(const AOptions: THexFindReplaceOptions; out APattern: TBytes;
  out AHexMode: Boolean; const AArgs: THexFindReplaceEventArgs): Boolean;
begin
  SetLength(APattern, 0);
  AHexMode := False;
  if AOptions.FindText = '' then
  begin
    SetMessage(AArgs, TStr.FindTextRequired, False);
    Exit(False);
  end;
  if AOptions.UseRegex or AOptions.MatchWholeWord then
  begin
    SetMessage(AArgs, TStr.FindOptionNotSupportedByHexAdapter, False);
    Exit(False);
  end;
  if LooksLikeHexInput(AOptions.FindText) then
  begin
    if not TryParseHexBytes(AOptions.FindText, APattern) then
    begin
      SetMessage(AArgs, TStr.FindInvalidHexPattern, False);
      Exit(False);
    end;
    AHexMode := True;
    Exit(Length(APattern) > 0);
  end;
  APattern := TEncoding.UTF8.GetBytes(AOptions.FindText);
  AHexMode := False;
  Result := Length(APattern) > 0;
end;

function THexFindReplaceAdapter.TryCreateReplacePattern(const AOptions: THexFindReplaceOptions;
  const AHexMode: Boolean; out APattern: TBytes; const AArgs: THexFindReplaceEventArgs): Boolean;
begin
  SetLength(APattern, 0);
  if AHexMode then
  begin
    if Trim(AOptions.ReplaceText) = '' then
      Exit(True);
    if not TryParseHexBytes(AOptions.ReplaceText, APattern) then
    begin
      SetMessage(AArgs, TStr.ReplaceInvalidHexPattern, False);
      Exit(False);
    end;
    Exit(True);
  end;
  APattern := TEncoding.UTF8.GetBytes(AOptions.ReplaceText);
  Result := True;
end;

function THexFindReplaceAdapter.GetFindStartOffset(const APatternLength: Integer; const ADown: Boolean): Int64;
var
  LLength: Int64;
begin
  LLength := FHost.GetDataLength;
  if LLength <= 0 then
    Exit(-1);
  if ADown then
  begin
    if FHost.GetHasSelection and (FHost.GetSelectionLength = APatternLength) then
      Exit(Min(LLength - 1, FHost.GetSelectionStart + 1));
    Exit(Max(Int64(0), FHost.GetCursorOffset));
  end;
  if FHost.GetHasSelection and (FHost.GetSelectionLength = APatternLength) then
    Exit(Max(Int64(0), FHost.GetSelectionStart - 1));
  Result := Max(Int64(0), FHost.GetCursorOffset - 1);
end;

function THexFindReplaceAdapter.FindForward(const APattern: TBytes; AStartOffset: Int64;
  const AWrap: Boolean): Int64;
var
  LLength: Int64;
begin
  LLength := FHost.GetDataLength;
  if (LLength <= 0) or (Length(APattern) = 0) then
    Exit(-1);
  if AStartOffset < 0 then
    AStartOffset := 0;
  Result := FindForwardWithin(APattern, AStartOffset, LLength);
  if Result >= 0 then
    Exit;
  if AWrap and (AStartOffset > 0) then
    Exit(FindForwardWithin(APattern, 0, AStartOffset));
  Result := -1;
end;

function THexFindReplaceAdapter.FindBackward(const APattern: TBytes; AStartOffset: Int64;
  const AWrap: Boolean): Int64;
var
  LLength: Int64;
begin
  LLength := FHost.GetDataLength;
  if (LLength <= 0) or (Length(APattern) = 0) then
    Exit(-1);
  if AStartOffset >= LLength then
    AStartOffset := LLength - 1;
  if AStartOffset < 0 then
    Exit(-1);
  Result := FindBackwardWithin(APattern, AStartOffset, 0);
  if Result >= 0 then
    Exit;
  if AWrap and (AStartOffset < LLength - 1) then
    Exit(FindBackwardWithin(APattern, LLength - 1, AStartOffset + 1));
  Result := -1;
end;

function THexFindReplaceAdapter.IgnoreCase: Boolean;
begin
  Result := (not FLastWasHexMode) and (FDialog <> nil) and (not FDialog.MatchCase);
end;

function THexFindReplaceAdapter.FindForwardWithin(const APattern: TBytes; const AStartOffset,
  AEndOffset: Int64): Int64;
var
  LOffset: Int64;
  LOverlap: Integer;
  LIgnoreCase: Boolean;
  LRequest: Integer;
  LBuffer: TBytes;
  LLimit: Integer;
  I: Integer;
begin
  if (Length(APattern) = 0) or (AStartOffset < 0) or (AEndOffset <= AStartOffset) then
    Exit(-1);
  LOffset := AStartOffset;
  LOverlap := Max(0, Length(APattern) - 1);
  LIgnoreCase := IgnoreCase;
  while LOffset < AEndOffset do
  begin
    LRequest := Integer(Min(Int64(CChunkSize), AEndOffset - LOffset));
    LBuffer := FHost.ReadBytes(LOffset, LRequest);
    if Length(LBuffer) = 0 then
      Break;
    LLimit := Length(LBuffer) - Length(APattern);
    for I := 0 to LLimit do
      if Matches(LBuffer, I, APattern, LIgnoreCase) then
        Exit(LOffset + I);
    if (Length(LBuffer) < LRequest) or (LOffset + Length(LBuffer) >= AEndOffset) then
      Break;
    Inc(LOffset, Max(1, Length(LBuffer) - LOverlap));
  end;
  Result := -1;
end;

function THexFindReplaceAdapter.FindBackwardWithin(const APattern: TBytes; const AStartOffset,
  ALowerBound: Int64): Int64;
var
  LEndExclusive: Int64;
  LChunkStart: Int64;
  LRequest: Integer;
  LBuffer: TBytes;
  LMaxIndex: Integer;
  LIgnoreCase: Boolean;
  I: Integer;
begin
  if (Length(APattern) = 0) or (AStartOffset < ALowerBound) then
    Exit(-1);
  LEndExclusive := Min(FHost.GetDataLength, AStartOffset + 1);
  LIgnoreCase := IgnoreCase;
  while LEndExclusive > ALowerBound do
  begin
    LChunkStart := Max(ALowerBound, LEndExclusive - CChunkSize);
    LRequest := Integer(LEndExclusive - LChunkStart);
    LBuffer := FHost.ReadBytes(LChunkStart, LRequest);
    if Length(LBuffer) = 0 then
      Break;
    LMaxIndex := Min(Length(LBuffer) - Length(APattern), Integer(AStartOffset - LChunkStart));
    for I := LMaxIndex downto 0 do
      if Matches(LBuffer, I, APattern, LIgnoreCase) then
        Exit(LChunkStart + I);
    if LChunkStart = ALowerBound then
      Break;
    LEndExclusive := LChunkStart + Max(0, Length(APattern) - 1);
  end;
  Result := -1;
end;

function THexFindReplaceAdapter.CurrentSelectionMatches(const APattern: TBytes): Boolean;
var
  LCurrent: TBytes;
begin
  if Length(APattern) = 0 then
    Exit(False);
  if (not FHost.GetHasSelection) or (FHost.GetSelectionLength <> Length(APattern)) then
    Exit(False);
  LCurrent := FHost.ReadBytes(FHost.GetSelectionStart, Length(APattern));
  if Length(LCurrent) <> Length(APattern) then
    Exit(False);
  Result := Matches(LCurrent, 0, APattern, IgnoreCase);
end;

class function THexFindReplaceAdapter.Matches(const ABuffer: TBytes; const AIndex: Integer;
  const APattern: TBytes; const AIgnoreCase: Boolean): Boolean;
var
  I: Integer;
  LLeft: Byte;
  LRight: Byte;
begin
  if (Length(ABuffer) = 0) or (Length(APattern) = 0) or (AIndex < 0) or (AIndex + Length(APattern) > Length(ABuffer)) then
    Exit(False);
  for I := 0 to High(APattern) do
  begin
    LLeft := ABuffer[AIndex + I];
    LRight := APattern[I];
    if AIgnoreCase then
    begin
      LLeft := ToAsciiUpper(LLeft);
      LRight := ToAsciiUpper(LRight);
    end;
    if LLeft <> LRight then
      Exit(False);
  end;
  Result := True;
end;

class function THexFindReplaceAdapter.ToAsciiUpper(const AValue: Byte): Byte;
begin
  if (AValue >= 97) and (AValue <= 122) then
    Result := AValue - 32
  else
    Result := AValue;
end;

function THexFindReplaceAdapter.CreateOptionsFromLast(const ADirection: THexFindDirection): THexFindReplaceOptions;
begin
  Result.FindText := FLastFindText;
  Result.ReplaceText := FLastReplaceText;
  Result.Direction := ADirection;
  Result.Scope := hfsDocument;
  Result.MatchCase := True;
  Result.MatchWholeWord := False;
  Result.UseRegex := False;
  Result.WrapSearch := True;
end;

class function THexFindReplaceAdapter.LooksLikeHexInput(const AText: string): Boolean;
var
  LValue: string;
begin
  LValue := Trim(AText);
  if LValue = '' then
    Exit(False);
  if LValue.StartsWith(TStr.HexPrefixLong, True) then
    Exit(True);
  if LValue.StartsWith(TStr.HexPrefixShort, True) then
    Exit(True);
  Result := (Pos(' ', LValue) > 0) or (Pos(',', LValue) > 0) or (Pos('-', LValue) > 0);
end;

class function THexFindReplaceAdapter.TryParseHexBytes(const AText: string; out ABytes: TBytes): Boolean;
var
  LValue: string;
  I: Integer;
  LHigh: Integer;
  LLow: Integer;

  function HexDigit(const AChar: Char): Integer;
  begin
    case AChar of
      '0'..'9': Result := Ord(AChar) - Ord('0');
      'a'..'f': Result := Ord(AChar) - Ord('a') + 10;
      'A'..'F': Result := Ord(AChar) - Ord('A') + 10;
    else
      Result := -1;
    end;
  end;

begin
  SetLength(ABytes, 0);
  LValue := Trim(AText);
  if LValue = '' then
    Exit(False);
  if LValue.StartsWith(TStr.HexPrefixLong, True) then
    LValue := Trim(Copy(LValue, Length(TStr.HexPrefixLong) + 1, MaxInt));
  if LValue.StartsWith(TStr.HexPrefixShort, True) then
    LValue := Trim(Copy(LValue, Length(TStr.HexPrefixShort) + 1, MaxInt));
  LValue := StringReplace(LValue, TStr.HexPrefixShort, '', [rfReplaceAll, rfIgnoreCase]);
  LValue := StringReplace(LValue, ' ', '', [rfReplaceAll]);
  LValue := StringReplace(LValue, '-', '', [rfReplaceAll]);
  LValue := StringReplace(LValue, ',', '', [rfReplaceAll]);
  LValue := StringReplace(LValue, #13, '', [rfReplaceAll]);
  LValue := StringReplace(LValue, #10, '', [rfReplaceAll]);
  LValue := StringReplace(LValue, #9, '', [rfReplaceAll]);
  if (LValue = '') or (Length(LValue) mod 2 <> 0) then
    Exit(False);
  SetLength(ABytes, Length(LValue) div 2);
  for I := 0 to High(ABytes) do
  begin
    LHigh := HexDigit(LValue[I * 2 + 1]);
    LLow := HexDigit(LValue[I * 2 + 2]);
    if (LHigh < 0) or (LLow < 0) then
    begin
      SetLength(ABytes, 0);
      Exit(False);
    end;
    ABytes[I] := Byte((LHigh shl 4) or LLow);
  end;
  Result := Length(ABytes) > 0;
end;

class procedure THexFindReplaceAdapter.SetMessage(const AArgs: THexFindReplaceEventArgs; const AMessage: string;
  const ASuccess: Boolean);
begin
  if AArgs = nil then
    Exit;
  AArgs.Message := AMessage;
  AArgs.Success := ASuccess;
end;

end.
