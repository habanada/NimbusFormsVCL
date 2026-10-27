unit NimbusForms.Grid.CellMetadata;

interface

uses
  System.Rtti,
  NimbusForms.Grid.Types;

type
  TThemedGridCellMetadata = class
  private
    FTag: TValue;
    FRendererData: TValue;
    FToolTipText: string;
    FErrorText: string;
    FStyle: TValue;
    FRenderKind: TThemedGridCellRenderKind;
    FHasRenderKind: Boolean;
    FEditorKind: TThemedGridEditorKind;
    FHasEditorKind: Boolean;
    FFormatString: string;
    FNullText: string;
    procedure SetRenderKind(const AValue: TThemedGridCellRenderKind);
    procedure SetEditorKind(const AValue: TThemedGridEditorKind);
  public
    procedure ClearRenderKind;
    procedure ClearEditorKind;
    property Tag: TValue read FTag write FTag;
    property RendererData: TValue read FRendererData write FRendererData;
    property ToolTipText: string read FToolTipText write FToolTipText;
    property ErrorText: string read FErrorText write FErrorText;
    property Style: TValue read FStyle write FStyle;
    property RenderKind: TThemedGridCellRenderKind read FRenderKind write SetRenderKind;
    property HasRenderKind: Boolean read FHasRenderKind;
    property EditorKind: TThemedGridEditorKind read FEditorKind write SetEditorKind;
    property HasEditorKind: Boolean read FHasEditorKind;
    property FormatString: string read FFormatString write FFormatString;
    property NullText: string read FNullText write FNullText;
  end;

implementation

procedure TThemedGridCellMetadata.SetRenderKind(const AValue: TThemedGridCellRenderKind);
begin
  FRenderKind := AValue;
  FHasRenderKind := True;
end;

procedure TThemedGridCellMetadata.SetEditorKind(const AValue: TThemedGridEditorKind);
begin
  FEditorKind := AValue;
  FHasEditorKind := True;
end;

procedure TThemedGridCellMetadata.ClearRenderKind;
begin
  FHasRenderKind := False;
end;

procedure TThemedGridCellMetadata.ClearEditorKind;
begin
  FHasEditorKind := False;
end;

end.
