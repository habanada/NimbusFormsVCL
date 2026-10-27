unit NimbusForms.HexEditor.Session;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.Pieces;

type
  THexBookmarkData = class
  private
    FOffset: Int64;
    FArgb: Integer;
    FName: string;
  public
    function Clone: THexBookmarkData;
    property Offset: Int64 read FOffset write FOffset;
    property Argb: Integer read FArgb write FArgb;
    property Name: string read FName write FName;
  end;

  THexSessionData = class
  private
    FOriginalFilePath: string;
    FCreateBackup: Boolean;
    FMemoryBuffer: TBytes;
    FPieces: TObjectList<THexPieceInfo>;
    FUndoStack: TObjectList<THexEditOperation>;
    FRedoStack: TObjectList<THexEditOperation>;
    FCursorOffset: Int64;
    FSelectionStart: Int64;
    FSelectionLength: Int64;
    FBookmarks: TObjectList<THexBookmarkData>;
  public
    constructor Create;
    destructor Destroy; override;
    property OriginalFilePath: string read FOriginalFilePath write FOriginalFilePath;
    property CreateBackup: Boolean read FCreateBackup write FCreateBackup;
    property MemoryBuffer: TBytes read FMemoryBuffer write FMemoryBuffer;
    property Pieces: TObjectList<THexPieceInfo> read FPieces;
    property UndoStack: TObjectList<THexEditOperation> read FUndoStack;
    property RedoStack: TObjectList<THexEditOperation> read FRedoStack;
    property CursorOffset: Int64 read FCursorOffset write FCursorOffset;
    property SelectionStart: Int64 read FSelectionStart write FSelectionStart;
    property SelectionLength: Int64 read FSelectionLength write FSelectionLength;
    property Bookmarks: TObjectList<THexBookmarkData> read FBookmarks;
  end;

  THexProjectData = class
  private
    FProjectName: string;
    FApplicationName: string;
    FFormatName: string;
    FFormatVersion: Integer;
    FCreatedUtc: TDateTime;
    FSavedUtc: TDateTime;
    FSession: THexSessionData;
    function GetHasSession: Boolean;
    function GetHasOriginalFile: Boolean;
    procedure SetSession(const AValue: THexSessionData);
  public
    constructor Create;
    destructor Destroy; override;
    property ProjectName: string read FProjectName write FProjectName;
    property ApplicationName: string read FApplicationName write FApplicationName;
    property FormatName: string read FFormatName write FFormatName;
    property FormatVersion: Integer read FFormatVersion write FFormatVersion;
    property CreatedUtc: TDateTime read FCreatedUtc write FCreatedUtc;
    property SavedUtc: TDateTime read FSavedUtc write FSavedUtc;
    property Session: THexSessionData read FSession write SetSession;
    property HasSession: Boolean read GetHasSession;
    property HasOriginalFile: Boolean read GetHasOriginalFile;
  end;

implementation

function THexBookmarkData.Clone: THexBookmarkData;
begin
  Result := THexBookmarkData.Create;
  Result.FOffset := FOffset;
  Result.FArgb := FArgb;
  Result.FName := FName;
end;

constructor THexSessionData.Create;
begin
  inherited Create;
  FPieces := TObjectList<THexPieceInfo>.Create(True);
  FUndoStack := TObjectList<THexEditOperation>.Create(True);
  FRedoStack := TObjectList<THexEditOperation>.Create(True);
  FBookmarks := TObjectList<THexBookmarkData>.Create(True);
end;

destructor THexSessionData.Destroy;
begin
  FPieces.Free;
  FUndoStack.Free;
  FRedoStack.Free;
  FBookmarks.Free;
  inherited Destroy;
end;

constructor THexProjectData.Create;
begin
  inherited Create;
  FProjectName := '';
  FApplicationName := 'NimbusForms';
  FFormatName := 'NimbusForms Hex Project';
  FFormatVersion := 1;
  FCreatedUtc := Now;
  FSavedUtc := Now;
  FSession := THexSessionData.Create;
end;

destructor THexProjectData.Destroy;
begin
  FSession.Free;
  inherited Destroy;
end;

function THexProjectData.GetHasSession: Boolean;
begin
  Result := FSession <> nil;
end;

function THexProjectData.GetHasOriginalFile: Boolean;
begin
  Result := (FSession <> nil) and (FSession.OriginalFilePath <> '');
end;

procedure THexProjectData.SetSession(const AValue: THexSessionData);
begin
  if FSession = AValue then
    Exit;
  FSession.Free;
  FSession := AValue;
end;

end.
