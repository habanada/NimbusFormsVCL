unit NimbusForms.Grid.FormatStyleModel;

interface

uses
  NimbusForms.Theming.Types,
  NimbusForms.Grid.FormatStyle;

type
  TThemedGridFormatStyleModel = class
  private
    FBackColor: string;
    FForeColor: string;
    FBorderColor: string;
    FSelectionBackColor: string;
    FSelectionForeColor: string;
    FHoverBackColor: string;
    FHoverForeColor: string;
    FCurrentBorderColor: string;
    FBold: Boolean;
    FItalic: Boolean;
  public
    class function FromStyle(const AStyle: TThemedGridFormatStyle): TThemedGridFormatStyleModel; static;
    function ToStyle: TThemedGridFormatStyle;
    property BackColor: string read FBackColor write FBackColor;
    property ForeColor: string read FForeColor write FForeColor;
    property BorderColor: string read FBorderColor write FBorderColor;
    property SelectionBackColor: string read FSelectionBackColor write FSelectionBackColor;
    property SelectionForeColor: string read FSelectionForeColor write FSelectionForeColor;
    property HoverBackColor: string read FHoverBackColor write FHoverBackColor;
    property HoverForeColor: string read FHoverForeColor write FHoverForeColor;
    property CurrentBorderColor: string read FCurrentBorderColor write FCurrentBorderColor;
    property Bold: Boolean read FBold write FBold;
    property Italic: Boolean read FItalic write FItalic;
  end;

implementation

uses
  System.SysUtils,
  NimbusForms.Grid.ColorValue;

function ToHex(const AHasColor: Boolean; const AColor: TThemeColor): string;
begin
  if not AHasColor then
    Exit('');
  if ThemeColorAlpha(AColor) = 255 then
    Result := '#' + IntToHex(ThemeColorRed(AColor), 2) + IntToHex(ThemeColorGreen(AColor), 2) +
      IntToHex(ThemeColorBlue(AColor), 2)
  else
    Result := '#' + IntToHex(ThemeColorAlpha(AColor), 2) + IntToHex(ThemeColorRed(AColor), 2) +
      IntToHex(ThemeColorGreen(AColor), 2) + IntToHex(ThemeColorBlue(AColor), 2);
end;

function TryParseColor(const AText: string; out AColor: TThemeColor): Boolean;
var
  LText: string;
  LArgb: Integer;
  LLongArgb: Int64;
begin
  AColor := TThemeColor(0);
  if AText = '' then
    Exit(False);
  LText := Trim(AText);
  if (LText <> '') and (LText[1] = '#') then
    LText := Copy(LText, 2, Length(LText) - 1);
  if (Length(LText) = 6) and TryStrToInt('$' + LText, LArgb) then
  begin
    AColor := ThemeColor(255, Byte((LArgb shr 16) and $FF), Byte((LArgb shr 8) and $FF), Byte(LArgb and $FF));
    Exit(True);
  end;
  if (Length(LText) = 8) and TryStrToInt64('$' + LText, LLongArgb) then
  begin
    AColor := ThemeColor(Byte((LLongArgb shr 24) and $FF), Byte((LLongArgb shr 16) and $FF),
      Byte((LLongArgb shr 8) and $FF), Byte(LLongArgb and $FF));
    Exit(True);
  end;
  Result := TThemedGridColorValue.TryFromName(LText, AColor);
end;

class function TThemedGridFormatStyleModel.FromStyle(const AStyle: TThemedGridFormatStyle): TThemedGridFormatStyleModel;
begin
  if AStyle = nil then
    Exit(nil);
  Result := TThemedGridFormatStyleModel.Create;
  Result.FBackColor := ToHex(AStyle.HasBackColor, AStyle.BackColor);
  Result.FForeColor := ToHex(AStyle.HasForeColor, AStyle.ForeColor);
  Result.FBorderColor := ToHex(AStyle.HasBorderColor, AStyle.BorderColor);
  Result.FSelectionBackColor := ToHex(AStyle.HasSelectionBackColor, AStyle.SelectionBackColor);
  Result.FSelectionForeColor := ToHex(AStyle.HasSelectionForeColor, AStyle.SelectionForeColor);
  Result.FHoverBackColor := ToHex(AStyle.HasHoverBackColor, AStyle.HoverBackColor);
  Result.FHoverForeColor := ToHex(AStyle.HasHoverForeColor, AStyle.HoverForeColor);
  Result.FCurrentBorderColor := ToHex(AStyle.HasCurrentBorderColor, AStyle.CurrentBorderColor);
  Result.FBold := AStyle.Bold;
  Result.FItalic := AStyle.Italic;
end;

function TThemedGridFormatStyleModel.ToStyle: TThemedGridFormatStyle;
var
  LColor: TThemeColor;
begin
  Result := TThemedGridFormatStyle.Create;
  if TryParseColor(FBackColor, LColor) then
    Result.BackColor := LColor;
  if TryParseColor(FForeColor, LColor) then
    Result.ForeColor := LColor;
  if TryParseColor(FBorderColor, LColor) then
    Result.BorderColor := LColor;
  if TryParseColor(FSelectionBackColor, LColor) then
    Result.SelectionBackColor := LColor;
  if TryParseColor(FSelectionForeColor, LColor) then
    Result.SelectionForeColor := LColor;
  if TryParseColor(FHoverBackColor, LColor) then
    Result.HoverBackColor := LColor;
  if TryParseColor(FHoverForeColor, LColor) then
    Result.HoverForeColor := LColor;
  if TryParseColor(FCurrentBorderColor, LColor) then
    Result.CurrentBorderColor := LColor;
  Result.Bold := FBold;
  Result.Italic := FItalic;
end;

end.
