unit NimbusForms.HexEditor.Theme;

interface

uses
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette;

type
  THexTheme = class
  public
    BackColor: TThemeColor;
    ForeColor: TThemeColor;
    BorderColor: TThemeColor;
    HeaderBackColor: TThemeColor;
    HeaderForeColor: TThemeColor;
    GutterBackColor: TThemeColor;
    GutterForeColor: TThemeColor;
    CellBackColor: TThemeColor;
    CellForeColor: TThemeColor;
    AsciiForeColor: TThemeColor;
    GridLineColor: TThemeColor;
    SelectionBackColor: TThemeColor;
    SelectionForeColor: TThemeColor;
    CaretColor: TThemeColor;
    BookmarkColor: TThemeColor;
    SearchHighlightBackColor: TThemeColor;
    SearchHighlightForeColor: TThemeColor;
    DisabledForeColor: TThemeColor;
    AlternateRowBackColor: TThemeColor;
    CursorRowBackColor: TThemeColor;
    ActiveColumnBackColor: TThemeColor;
    ActiveHeaderBackColor: TThemeColor;
    TabColor: TThemeColor;
    SpaceColor: TThemeColor;
    NullByteColor: TThemeColor;
    ControlByteBackColor: TThemeColor;
    EofBackColor: TThemeColor;
    ModifiedByteBackColor: TThemeColor;
    ModifiedByteForeColor: TThemeColor;
    LineBreakBackColor: TThemeColor;
    LineBreakForeColor: TThemeColor;
    ScrollBarTrackColor: TThemeColor;
    ScrollBarThumbColor: TThemeColor;
    ScrollBarThumbHoverColor: TThemeColor;
    class function FromPalette(const APalette: TThemePalette): THexTheme; static;
  end;

implementation

const
  CMagenta = TThemeColor($FFFF00FF);
  CLimeGreen = TThemeColor($FF32CD32);
  COrange = TThemeColor($FFFFA500);
  CBlack = TThemeColor($FF000000);

function Blend(const AFirst, ASecond: TThemeColor; const AAmount: Single): TThemeColor;
var
  LAmount: Single;
  LA, LR, LG, LB: Integer;
begin
  LAmount := AAmount;
  if LAmount < 0 then
    LAmount := 0;
  if LAmount > 1 then
    LAmount := 1;
  LA := Trunc(ThemeColorAlpha(AFirst) + (ThemeColorAlpha(ASecond) - ThemeColorAlpha(AFirst)) * LAmount);
  LR := Trunc(ThemeColorRed(AFirst) + (ThemeColorRed(ASecond) - ThemeColorRed(AFirst)) * LAmount);
  LG := Trunc(ThemeColorGreen(AFirst) + (ThemeColorGreen(ASecond) - ThemeColorGreen(AFirst)) * LAmount);
  LB := Trunc(ThemeColorBlue(AFirst) + (ThemeColorBlue(ASecond) - ThemeColorBlue(AFirst)) * LAmount);
  Result := ThemeColor(Byte(LA), Byte(LR), Byte(LG), Byte(LB));
end;

class function THexTheme.FromPalette(const APalette: TThemePalette): THexTheme;
begin
  Result := THexTheme.Create;

  if APalette = nil then
  begin
    Result.BackColor := TThemeColor($FFFFFFFF);
    Result.ForeColor := CBlack;
    Result.BorderColor := TThemeColor($FFA0A0A0);
    Result.HeaderBackColor := TThemeColor($FFF0F0F0);
    Result.HeaderForeColor := CBlack;
    Result.GutterBackColor := TThemeColor($FFF0F0F0);
    Result.GutterForeColor := TThemeColor($FF808080);
    Result.CellBackColor := TThemeColor($FFFFFFFF);
    Result.CellForeColor := CBlack;
    Result.AsciiForeColor := CBlack;
    Result.GridLineColor := TThemeColor($FFE3E3E3);
    Result.SelectionBackColor := TThemeColor($FF3399FF);
    Result.SelectionForeColor := TThemeColor($FFFFFFFF);
    Result.CaretColor := CBlack;
    Result.BookmarkColor := ThemeColor(255, 255, 196, 64);
    Result.SearchHighlightBackColor := ThemeColor(255, 255, 232, 128);
    Result.SearchHighlightForeColor := CBlack;
    Result.DisabledForeColor := TThemeColor($FF808080);
    Result.AlternateRowBackColor := ThemeColor(255, 248, 248, 248);
    Result.CursorRowBackColor := ThemeColor(255, 232, 242, 255);
    Result.ActiveColumnBackColor := ThemeColor(255, 238, 246, 255);
    Result.ActiveHeaderBackColor := ThemeColor(255, 218, 235, 255);
    Result.TabColor := ThemeColor(255, 128, 80, 160);
    Result.SpaceColor := ThemeColor(255, 120, 120, 120);
    Result.NullByteColor := ThemeColor(255, 0, 128, 96);
    Result.ControlByteBackColor := ThemeColor(255, 232, 232, 232);
    Result.EofBackColor := ThemeColor(255, 244, 244, 244);
    Result.ModifiedByteBackColor := ThemeColor(255, 255, 245, 210);
    Result.ModifiedByteForeColor := ThemeColor(255, 170, 90, 0);
    Result.LineBreakBackColor := ThemeColor(255, 230, 245, 255);
    Result.LineBreakForeColor := ThemeColor(255, 0, 110, 180);
    Result.ScrollBarTrackColor := ThemeColor(255, 240, 240, 240);
    Result.ScrollBarThumbColor := ThemeColor(255, 193, 193, 193);
    Result.ScrollBarThumbHoverColor := ThemeColor(255, 120, 160, 210);
    Exit;
  end;

  Result.BackColor := APalette.ControlBackColor;
  Result.ForeColor := APalette.ControlForeColor;
  Result.BorderColor := APalette.ControlBorderColor;
  Result.HeaderBackColor := APalette.PanelBackColor;
  Result.HeaderForeColor := APalette.ControlForeColor;
  Result.GutterBackColor := APalette.PanelBackColor;
  Result.GutterForeColor := APalette.MutedForeColor;
  Result.CellBackColor := APalette.InputBackColor;
  Result.CellForeColor := APalette.InputForeColor;
  Result.AsciiForeColor := APalette.MutedForeColor;
  Result.GridLineColor := APalette.SeparatorColor;
  Result.SelectionBackColor := APalette.SelectedBackColor;
  Result.SelectionForeColor := APalette.SelectedForeColor;
  Result.CaretColor := APalette.FocusBorderColor;
  Result.BookmarkColor := APalette.AccentColor;
  Result.SearchHighlightBackColor := APalette.HoverBackColor;
  Result.SearchHighlightForeColor := APalette.ControlForeColor;
  Result.DisabledForeColor := APalette.DisabledForeColor;
  Result.AlternateRowBackColor := Blend(APalette.InputBackColor, APalette.PanelBackColor, 0.20);
  Result.CursorRowBackColor := Blend(APalette.InputBackColor, APalette.AccentColor, 0.16);
  Result.ActiveColumnBackColor := Blend(APalette.InputBackColor, APalette.AccentColor, 0.10);
  Result.ActiveHeaderBackColor := Blend(APalette.PanelBackColor, APalette.AccentColor, 0.20);
  Result.TabColor := Blend(APalette.AccentColor, CMagenta, 0.35);
  Result.SpaceColor := APalette.MutedForeColor;
  Result.NullByteColor := Blend(APalette.AccentColor, CLimeGreen, 0.45);
  Result.ControlByteBackColor := Blend(APalette.InputBackColor, APalette.ControlForeColor, 0.10);
  Result.EofBackColor := Blend(APalette.InputBackColor, APalette.PanelBackColor, 0.35);
  Result.ModifiedByteBackColor := Blend(APalette.InputBackColor, COrange, 0.24);
  Result.ModifiedByteForeColor := Blend(APalette.InputForeColor, COrange, 0.40);
  Result.LineBreakBackColor := Blend(APalette.InputBackColor, APalette.AccentColor, 0.14);
  Result.LineBreakForeColor := Blend(APalette.InputForeColor, APalette.AccentColor, 0.45);
  Result.ScrollBarTrackColor := APalette.PanelBackColor;
  Result.ScrollBarThumbColor := Blend(APalette.PanelBackColor, APalette.MutedForeColor, 0.45);
  Result.ScrollBarThumbHoverColor := Blend(APalette.PanelBackColor, APalette.AccentColor, 0.55);
end;

end.
