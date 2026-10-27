unit NimbusForms.Grid.CellRenderers;

{$SCOPEDENUMS ON}

interface

uses
  NimbusForms.Grid.Types,
  NimbusForms.Grid.CellRendererIntf;

type
  TThemedGridCellRenderers = class
  private
    FText: IThemedGridCellRenderer;
    FCheckBox: IThemedGridCellRenderer;
    FToggle: IThemedGridCellRenderer;
    FProgressBar: IThemedGridCellRenderer;
    FSlider: IThemedGridCellRenderer;
    FColorSwatch: IThemedGridCellRenderer;
    FButton: IThemedGridCellRenderer;
    FImage: IThemedGridCellRenderer;
    FIcon: IThemedGridCellRenderer;
    FBadge: IThemedGridCellRenderer;
    FLink: IThemedGridCellRenderer;
    FRating: IThemedGridCellRenderer;
  public
    constructor Create;
    function GetRenderer(const ARenderKind: TThemedGridCellRenderKind): IThemedGridCellRenderer;
  end;

implementation

uses
  NimbusForms.Grid.CellRenderer,
  NimbusForms.Grid.CellRenderers.Input,
  NimbusForms.Grid.CellRenderers.Visual,
  NimbusForms.Grid.CellRenderers.Content;

constructor TThemedGridCellRenderers.Create;
begin
  inherited Create;
  FText := TThemedGridCellRenderer.Create;
  FCheckBox := TThemedGridCheckBoxCellRenderer.Create;
  FToggle := TThemedGridToggleCellRenderer.Create;
  FProgressBar := TThemedGridProgressBarCellRenderer.Create;
  FSlider := TThemedGridSliderCellRenderer.Create;
  FColorSwatch := TThemedGridColorSwatchCellRenderer.Create;
  FButton := TThemedGridButtonCellRenderer.Create;
  FImage := TThemedGridImageCellRenderer.Create;
  FIcon := TThemedGridIconCellRenderer.Create;
  FBadge := TThemedGridBadgeCellRenderer.Create;
  FLink := TThemedGridLinkCellRenderer.Create;
  FRating := TThemedGridRatingCellRenderer.Create;
end;

function TThemedGridCellRenderers.GetRenderer(const ARenderKind: TThemedGridCellRenderKind): IThemedGridCellRenderer;
begin
  case ARenderKind of
    TThemedGridCellRenderKind.CheckBox: Result := FCheckBox;
    TThemedGridCellRenderKind.Toggle: Result := FToggle;
    TThemedGridCellRenderKind.ProgressBar: Result := FProgressBar;
    TThemedGridCellRenderKind.Slider: Result := FSlider;
    TThemedGridCellRenderKind.ColorSwatch: Result := FColorSwatch;
    TThemedGridCellRenderKind.Button,
    TThemedGridCellRenderKind.Command: Result := FButton;
    TThemedGridCellRenderKind.Image: Result := FImage;
    TThemedGridCellRenderKind.Icon: Result := FIcon;
    TThemedGridCellRenderKind.Badge: Result := FBadge;
    TThemedGridCellRenderKind.Link: Result := FLink;
    TThemedGridCellRenderKind.Rating: Result := FRating;
  else
    Result := FText;
  end;
end;

end.
