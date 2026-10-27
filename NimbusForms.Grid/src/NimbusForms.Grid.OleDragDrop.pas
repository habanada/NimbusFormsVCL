unit NimbusForms.Grid.OleDragDrop;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Generics.Collections;

type
  TThemedGridDataObject = class(TInterfacedObject, IDataObject)
  private
    type
      TEntry = record
        Format: Word;
        Data: TBytes;
      end;
  private
    FEntries: TList<TEntry>;
    function FindEntry(const AFormat: Word): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetBytes(const AFormat: Word; const AData: TBytes);
    procedure SetUnicodeText(const AText: string);
    procedure SetAnsiText(const AText: string);
    function GetData(const AFormatIn: TFormatEtc; out AMedium: TStgMedium): HResult; stdcall;
    function GetDataHere(const AFormat: TFormatEtc; out AMedium: TStgMedium): HResult; stdcall;
    function QueryGetData(const AFormat: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const AFormat: TFormatEtc; out AFormatOut: TFormatEtc): HResult; stdcall;
    function SetData(const AFormat: TFormatEtc; var AMedium: TStgMedium; AFRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(ADirection: Longint; out AEnum: IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const AFormat: TFormatEtc; AAdvf: Longint; const AAdvSink: IAdviseSink;
      out AConnection: Longint): HResult; stdcall;
    function DUnadvise(AConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out AEnum: IEnumStatData): HResult; stdcall;
  end;

  TThemedGridDropSource = class(TInterfacedObject, IDropSource)
  public
    function QueryContinueDrag(AEscapePressed: BOOL; AKeyState: Longint): HResult; stdcall;
    function GiveFeedback(AEffect: Longint): HResult; stdcall;
  end;

  TThemedGridOleDropEvent = procedure(const AData: IDataObject; const AKeyState: Integer;
    const APoint: TPoint; var AEffect: Integer) of object;

  TThemedGridDropTarget = class(TInterfacedObject, IDropTarget)
  private
    FData: IDataObject;
    FOnEnter: TThemedGridOleDropEvent;
    FOnOver: TThemedGridOleDropEvent;
    FOnDrop: TThemedGridOleDropEvent;
    FOnLeave: TNotifyEvent;
  public
    function DragEnter(const ADataObject: IDataObject; AKeyState: Longint; APoint: TPoint;
      var AEffect: Longint): HResult; stdcall;
    function DragOver(AKeyState: Longint; APoint: TPoint; var AEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const ADataObject: IDataObject; AKeyState: Longint; APoint: TPoint;
      var AEffect: Longint): HResult; stdcall;
    property OnEnter: TThemedGridOleDropEvent read FOnEnter write FOnEnter;
    property OnOver: TThemedGridOleDropEvent read FOnOver write FOnOver;
    property OnDrop: TThemedGridOleDropEvent read FOnDrop write FOnDrop;
    property OnLeave: TNotifyEvent read FOnLeave write FOnLeave;
  end;

  TThemedGridOle = class sealed
  public
    class function RegisterFormat(const AName: string): Word; static;
    class function HasFormat(const AData: IDataObject; const AFormat: Word): Boolean; static;
    class function TryGetBytes(const AData: IDataObject; const AFormat: Word; out ABytes: TBytes): Boolean; static;
    class function TryGetUnicodeText(const AData: IDataObject; out AText: string): Boolean; static;
    class function TryGetAnsiText(const AData: IDataObject; out AText: string): Boolean; static;
    class function TryGetFileDrop(const AData: IDataObject; out AFiles: TArray<string>): Boolean; static;
  end;

implementation

uses
  Winapi.ShellAPI,
  Winapi.ShlObj;

function ThemedGridCreateStdEnumFmtEtc(ACount: UINT; AFormats: PFormatEtc; out AEnum: IEnumFormatEtc): HResult; stdcall;
  external 'shell32.dll' name 'SHCreateStdEnumFmtEtc';

var
  GOleInitialized: Boolean;

function MakeFormat(const AFormat: Word): TFormatEtc;
begin
  Result.cfFormat := AFormat;
  Result.ptd := nil;
  Result.dwAspect := DVASPECT_CONTENT;
  Result.lindex := -1;
  Result.tymed := TYMED_HGLOBAL;
end;

constructor TThemedGridDataObject.Create;
begin
  inherited Create;
  FEntries := TList<TEntry>.Create;
end;

destructor TThemedGridDataObject.Destroy;
begin
  FEntries.Free;
  inherited Destroy;
end;

function TThemedGridDataObject.FindEntry(const AFormat: Word): Integer;
var
  I: Integer;
begin
  for I := 0 to FEntries.Count - 1 do
    if FEntries[I].Format = AFormat then
      Exit(I);
  Result := -1;
end;

procedure TThemedGridDataObject.SetBytes(const AFormat: Word; const AData: TBytes);
var
  LEntry: TEntry;
  LIndex: Integer;
begin
  LEntry.Format := AFormat;
  LEntry.Data := Copy(AData, 0, Length(AData));
  LIndex := FindEntry(AFormat);
  if LIndex >= 0 then
    FEntries[LIndex] := LEntry
  else
    FEntries.Add(LEntry);
end;

procedure TThemedGridDataObject.SetUnicodeText(const AText: string);
var
  LBytes: TBytes;
  LSize: Integer;
begin
  LSize := (Length(AText) + 1) * SizeOf(Char);
  SetLength(LBytes, LSize);
  FillChar(LBytes[0], LSize, 0);
  if Length(AText) > 0 then
    Move(PChar(AText)^, LBytes[0], Length(AText) * SizeOf(Char));
  SetBytes(CF_UNICODETEXT, LBytes);
end;

procedure TThemedGridDataObject.SetAnsiText(const AText: string);
var
  LAnsi: AnsiString;
  LBytes: TBytes;
begin
  LAnsi := AnsiString(AText);
  SetLength(LBytes, Length(LAnsi) + 1);
  FillChar(LBytes[0], Length(LBytes), 0);
  if Length(LAnsi) > 0 then
    Move(PAnsiChar(LAnsi)^, LBytes[0], Length(LAnsi));
  SetBytes(CF_TEXT, LBytes);
end;

function TThemedGridDataObject.GetData(const AFormatIn: TFormatEtc; out AMedium: TStgMedium): HResult;
var
  LIndex: Integer;
  LHandle: HGLOBAL;
  LTarget: Pointer;
  LData: TBytes;
begin
  FillChar(AMedium, SizeOf(AMedium), 0);
  if (AFormatIn.dwAspect <> DVASPECT_CONTENT) then
    Exit(DV_E_DVASPECT);
  if (AFormatIn.tymed and TYMED_HGLOBAL) = 0 then
    Exit(DV_E_TYMED);
  LIndex := FindEntry(AFormatIn.cfFormat);
  if LIndex < 0 then
    Exit(DV_E_FORMATETC);
  LData := FEntries[LIndex].Data;
  LHandle := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, Length(LData) + 1);
  if LHandle = 0 then
    Exit(E_OUTOFMEMORY);
  LTarget := GlobalLock(LHandle);
  if LTarget = nil then
  begin
    GlobalFree(LHandle);
    Exit(E_OUTOFMEMORY);
  end;
  try
    if Length(LData) > 0 then
      Move(LData[0], LTarget^, Length(LData));
  finally
    GlobalUnlock(LHandle);
  end;
  AMedium.tymed := TYMED_HGLOBAL;
  AMedium.hGlobal := LHandle;
  AMedium.unkForRelease := nil;
  Result := S_OK;
end;

function TThemedGridDataObject.GetDataHere(const AFormat: TFormatEtc; out AMedium: TStgMedium): HResult;
begin
  FillChar(AMedium, SizeOf(AMedium), 0);
  Result := E_NOTIMPL;
end;

function TThemedGridDataObject.QueryGetData(const AFormat: TFormatEtc): HResult;
begin
  if AFormat.dwAspect <> DVASPECT_CONTENT then
    Exit(DV_E_DVASPECT);
  if (AFormat.tymed and TYMED_HGLOBAL) = 0 then
    Exit(DV_E_TYMED);
  if FindEntry(AFormat.cfFormat) < 0 then
    Exit(DV_E_FORMATETC);
  Result := S_OK;
end;

function TThemedGridDataObject.GetCanonicalFormatEtc(const AFormat: TFormatEtc;
  out AFormatOut: TFormatEtc): HResult;
begin
  AFormatOut := AFormat;
  AFormatOut.ptd := nil;
  Result := DATA_S_SAMEFORMATETC;
end;

function TThemedGridDataObject.SetData(const AFormat: TFormatEtc; var AMedium: TStgMedium;
  AFRelease: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TThemedGridDataObject.EnumFormatEtc(ADirection: Longint; out AEnum: IEnumFormatEtc): HResult;
var
  LFormats: array of TFormatEtc;
  I: Integer;
begin
  AEnum := nil;
  if ADirection <> DATADIR_GET then
    Exit(E_NOTIMPL);
  SetLength(LFormats, FEntries.Count);
  for I := 0 to FEntries.Count - 1 do
    LFormats[I] := MakeFormat(FEntries[I].Format);
  if Length(LFormats) = 0 then
    Exit(E_FAIL);
  Result := ThemedGridCreateStdEnumFmtEtc(Length(LFormats), @LFormats[0], AEnum);
end;

function TThemedGridDataObject.DAdvise(const AFormat: TFormatEtc; AAdvf: Longint; const AAdvSink: IAdviseSink;
  out AConnection: Longint): HResult;
begin
  AConnection := 0;
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TThemedGridDataObject.DUnadvise(AConnection: Longint): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TThemedGridDataObject.EnumDAdvise(out AEnum: IEnumStatData): HResult;
begin
  AEnum := nil;
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TThemedGridDropSource.QueryContinueDrag(AEscapePressed: BOOL; AKeyState: Longint): HResult;
begin
  if AEscapePressed then
    Exit(DRAGDROP_S_CANCEL);
  if (AKeyState and MK_LBUTTON) = 0 then
    Exit(DRAGDROP_S_DROP);
  Result := S_OK;
end;

function TThemedGridDropSource.GiveFeedback(AEffect: Longint): HResult;
begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;

function TThemedGridDropTarget.DragEnter(const ADataObject: IDataObject; AKeyState: Longint; APoint: TPoint;
  var AEffect: Longint): HResult;
var
  LEffect: Integer;
begin
  FData := ADataObject;
  LEffect := AEffect;
  try
    if Assigned(FOnEnter) then
      FOnEnter(FData, AKeyState, APoint, LEffect);
  except
    LEffect := DROPEFFECT_NONE;
  end;
  AEffect := LEffect;
  Result := S_OK;
end;

function TThemedGridDropTarget.DragOver(AKeyState: Longint; APoint: TPoint; var AEffect: Longint): HResult;
var
  LEffect: Integer;
begin
  LEffect := AEffect;
  try
    if Assigned(FOnOver) then
      FOnOver(FData, AKeyState, APoint, LEffect);
  except
    LEffect := DROPEFFECT_NONE;
  end;
  AEffect := LEffect;
  Result := S_OK;
end;

function TThemedGridDropTarget.DragLeave: HResult;
begin
  try
    if Assigned(FOnLeave) then
      FOnLeave(Self);
  finally
    FData := nil;
  end;
  Result := S_OK;
end;

function TThemedGridDropTarget.Drop(const ADataObject: IDataObject; AKeyState: Longint; APoint: TPoint;
  var AEffect: Longint): HResult;
var
  LEffect: Integer;
begin
  FData := ADataObject;
  LEffect := AEffect;
  try
    try
      if Assigned(FOnDrop) then
        FOnDrop(FData, AKeyState, APoint, LEffect);
    except
      LEffect := DROPEFFECT_NONE;
    end;
  finally
    FData := nil;
  end;
  AEffect := LEffect;
  Result := S_OK;
end;

class function TThemedGridOle.RegisterFormat(const AName: string): Word;
begin
  Result := Word(RegisterClipboardFormat(PChar(AName)));
end;

class function TThemedGridOle.HasFormat(const AData: IDataObject; const AFormat: Word): Boolean;
var
  LFormat: TFormatEtc;
begin
  if AData = nil then
    Exit(False);
  LFormat := MakeFormat(AFormat);
  Result := AData.QueryGetData(LFormat) = S_OK;
end;

class function TThemedGridOle.TryGetBytes(const AData: IDataObject; const AFormat: Word;
  out ABytes: TBytes): Boolean;
var
  LFormat: TFormatEtc;
  LMedium: TStgMedium;
  LSource: Pointer;
  LSize: SIZE_T;
begin
  Result := False;
  SetLength(ABytes, 0);
  if AData = nil then
    Exit;
  LFormat := MakeFormat(AFormat);
  if AData.QueryGetData(LFormat) <> S_OK then
    Exit;
  if AData.GetData(LFormat, LMedium) <> S_OK then
    Exit;
  try
    if (LMedium.tymed <> TYMED_HGLOBAL) or (LMedium.hGlobal = 0) then
      Exit;
    LSize := GlobalSize(LMedium.hGlobal);
    LSource := GlobalLock(LMedium.hGlobal);
    if LSource = nil then
      Exit;
    try
      SetLength(ABytes, LSize);
      if LSize > 0 then
        Move(LSource^, ABytes[0], LSize);
      Result := True;
    finally
      GlobalUnlock(LMedium.hGlobal);
    end;
  finally
    ReleaseStgMedium(LMedium);
  end;
end;

class function TThemedGridOle.TryGetUnicodeText(const AData: IDataObject; out AText: string): Boolean;
var
  LBytes: TBytes;
  LCount: Integer;
begin
  AText := '';
  Result := False;
  if not TryGetBytes(AData, CF_UNICODETEXT, LBytes) then
    Exit;
  LCount := Length(LBytes) div SizeOf(Char);
  if LCount > 0 then
  begin
    SetString(AText, PChar(@LBytes[0]), LCount);
    LCount := Pos(#0, AText);
    if LCount > 0 then
      SetLength(AText, LCount - 1);
  end;
  Result := True;
end;

class function TThemedGridOle.TryGetAnsiText(const AData: IDataObject; out AText: string): Boolean;
var
  LBytes: TBytes;
  LAnsi: AnsiString;
  LPos: Integer;
begin
  AText := '';
  Result := False;
  if not TryGetBytes(AData, CF_TEXT, LBytes) then
    Exit;
  if Length(LBytes) > 0 then
  begin
    SetString(LAnsi, PAnsiChar(@LBytes[0]), Length(LBytes));
    LPos := Pos(#0, string(LAnsi));
    if LPos > 0 then
      SetLength(LAnsi, LPos - 1);
    AText := string(LAnsi);
  end;
  Result := True;
end;

class function TThemedGridOle.TryGetFileDrop(const AData: IDataObject; out AFiles: TArray<string>): Boolean;
var
  LFormat: TFormatEtc;
  LMedium: TStgMedium;
  LCount, I, LLength: Integer;
  LName: string;
begin
  SetLength(AFiles, 0);
  Result := False;
  if AData = nil then
    Exit;
  LFormat := MakeFormat(CF_HDROP);
  if AData.QueryGetData(LFormat) <> S_OK then
    Exit;
  if AData.GetData(LFormat, LMedium) <> S_OK then
    Exit;
  try
    if (LMedium.tymed <> TYMED_HGLOBAL) or (LMedium.hGlobal = 0) then
      Exit;
    LCount := Integer(DragQueryFile(LMedium.hGlobal, $FFFFFFFF, nil, 0));
    if LCount <= 0 then
      Exit;
    SetLength(AFiles, LCount);
    for I := 0 to LCount - 1 do
    begin
      LLength := Integer(DragQueryFile(LMedium.hGlobal, UINT(I), nil, 0));
      SetLength(LName, LLength);
      if LLength > 0 then
        DragQueryFile(LMedium.hGlobal, UINT(I), PChar(LName), UINT(LLength + 1));
      AFiles[I] := LName;
    end;
    Result := True;
  finally
    ReleaseStgMedium(LMedium);
  end;
end;

initialization
  GOleInitialized := Succeeded(OleInitialize(nil));

finalization
  if GOleInitialized then
    OleUninitialize;

end.
