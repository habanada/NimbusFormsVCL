unit NimbusForms.HexEditor.Options;

interface

uses
  System.SysUtils,
  NimbusForms.HexEditor.Types;

type
  THexEditorOptions = class
  private
    FBytesPerRow: Integer;
    FByteGroupSize: Integer;
    FShowHeader: Boolean;
    FShowGutter: Boolean;
    FShowAscii: Boolean;
    FShowGridLines: Boolean;
    FShowBookmarks: Boolean;
    FShowByteGroups: Boolean;
    FShowAlternateRows: Boolean;
    FShowCursorRowHighlight: Boolean;
    FShowActiveColumnHighlight: Boolean;
    FShowActiveHeaderHighlight: Boolean;
    FShowEofShade: Boolean;
    FHighlightTabs: Boolean;
    FHighlightSpaces: Boolean;
    FHighlightNullBytes: Boolean;
    FHighlightControlByteBackground: Boolean;
    FShowModifiedByteHighlight: Boolean;
    FHighlightLineBreaks: Boolean;
    FShowSpecialByteLabels: Boolean;
    FShowHoverHighlight: Boolean;
    FShowByteToolTip: Boolean;
    FReadOnly: Boolean;
    FOffsetFormat: THexOffsetFormat;
    procedure SetBytesPerRow(const AValue: Integer);
    procedure SetByteGroupSize(const AValue: Integer);
  public
    constructor Create;
    property BytesPerRow: Integer read FBytesPerRow write SetBytesPerRow;
    property ByteGroupSize: Integer read FByteGroupSize write SetByteGroupSize;
    property ShowByteGroups: Boolean read FShowByteGroups write FShowByteGroups;
    property OffsetFormat: THexOffsetFormat read FOffsetFormat write FOffsetFormat;
    property ShowHeader: Boolean read FShowHeader write FShowHeader;
    property ShowGutter: Boolean read FShowGutter write FShowGutter;
    property ShowAscii: Boolean read FShowAscii write FShowAscii;
    property ShowGridLines: Boolean read FShowGridLines write FShowGridLines;
    property ShowBookmarks: Boolean read FShowBookmarks write FShowBookmarks;
    property ShowAlternateRows: Boolean read FShowAlternateRows write FShowAlternateRows;
    property ShowCursorRowHighlight: Boolean read FShowCursorRowHighlight write FShowCursorRowHighlight;
    property ShowActiveColumnHighlight: Boolean read FShowActiveColumnHighlight write FShowActiveColumnHighlight;
    property ShowActiveHeaderHighlight: Boolean read FShowActiveHeaderHighlight write FShowActiveHeaderHighlight;
    property ShowEofShade: Boolean read FShowEofShade write FShowEofShade;
    property HighlightTabs: Boolean read FHighlightTabs write FHighlightTabs;
    property HighlightSpaces: Boolean read FHighlightSpaces write FHighlightSpaces;
    property HighlightNullBytes: Boolean read FHighlightNullBytes write FHighlightNullBytes;
    property HighlightControlByteBackground: Boolean read FHighlightControlByteBackground write FHighlightControlByteBackground;
    property ShowModifiedByteHighlight: Boolean read FShowModifiedByteHighlight write FShowModifiedByteHighlight;
    property HighlightLineBreaks: Boolean read FHighlightLineBreaks write FHighlightLineBreaks;
    property ShowSpecialByteLabels: Boolean read FShowSpecialByteLabels write FShowSpecialByteLabels;
    property ShowHoverHighlight: Boolean read FShowHoverHighlight write FShowHoverHighlight;
    property ShowByteToolTip: Boolean read FShowByteToolTip write FShowByteToolTip;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

implementation

constructor THexEditorOptions.Create;
begin
  inherited Create;
  FBytesPerRow := 16;
  FByteGroupSize := 4;
  FShowHeader := True;
  FShowGutter := True;
  FShowAscii := True;
  FShowGridLines := True;
  FShowBookmarks := True;
  FShowByteGroups := True;
  FShowAlternateRows := True;
  FShowCursorRowHighlight := True;
  FShowActiveColumnHighlight := True;
  FShowActiveHeaderHighlight := True;
  FShowEofShade := True;
  FHighlightTabs := True;
  FHighlightSpaces := True;
  FHighlightNullBytes := True;
  FHighlightControlByteBackground := True;
  FShowModifiedByteHighlight := True;
  FHighlightLineBreaks := True;
  FShowSpecialByteLabels := True;
  FShowHoverHighlight := True;
  FShowByteToolTip := True;
  FOffsetFormat := hofHex8;
end;

procedure THexEditorOptions.SetBytesPerRow(const AValue: Integer);
begin
  if (AValue < 1) or (AValue > 64) then
    raise EArgumentOutOfRangeException.Create('BytesPerRow');
  FBytesPerRow := AValue;
  if FByteGroupSize > FBytesPerRow then
    FByteGroupSize := FBytesPerRow;
end;

procedure THexEditorOptions.SetByteGroupSize(const AValue: Integer);
begin
  if (AValue < 1) or (AValue > 16) then
    raise EArgumentOutOfRangeException.Create('ByteGroupSize');
  FByteGroupSize := AValue;
end;

end.
