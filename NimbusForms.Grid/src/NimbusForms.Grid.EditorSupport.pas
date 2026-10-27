unit NimbusForms.Grid.EditorSupport;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  System.Rtti,
  System.TypInfo,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Types;

type
  TThemedGridEditorSupport = class sealed
  public
    class function AllowNull(const AValueType: PTypeInfo; const AOriginal: TValue): Boolean; static;
    class function RoundAway(const AValue: Extended): Extended; static;
    class function ConvertNumber(const AValue: Extended; const AValueType: PTypeInfo): TValue; static;
    class function ToAlignment(const AAlignment: TThemedGridContentAlignment): TAlignment; static;
    class function ValuesEqual(const ALeft, ARight: TValue): Boolean; static;
    class function IsDirectInlineKind(const AKind: TThemedGridCellRenderKind): Boolean; static;
    class function IsCommandKind(const AKind: TThemedGridCellRenderKind): Boolean; static;
    class procedure ApplyInputColors(const AControl: TControl; const APalette: TThemePalette); static;
  end;

implementation

uses
  NimbusForms.Grid.ValueConverter;

type
  TControlCracker = class(TControl)
  public
    property Color;
    property Font;
  end;

class function TThemedGridEditorSupport.AllowNull(const AValueType: PTypeInfo; const AOriginal: TValue): Boolean;
begin
  if AValueType = nil then
    Exit(True);
  if not TThemedGridValueConverter.IsValueType(AValueType) then
    Exit(True);
  Result := TThemedGridValueConverter.IsNull(AOriginal);
end;

class function TThemedGridEditorSupport.RoundAway(const AValue: Extended): Extended;
begin
  if AValue >= 0 then
    Result := Int(AValue + 0.5)
  else
    Result := Int(AValue - 0.5);
end;

class function TThemedGridEditorSupport.ConvertNumber(const AValue: Extended; const AValueType: PTypeInfo): TValue;
var
  LNumber: Extended;
  LConverted: TValue;
begin
  LNumber := AValue;
  if AValueType = nil then
    Exit(TValue.From<Extended>(LNumber));
  if AValueType.Kind in [tkInteger, tkInt64] then
    LNumber := RoundAway(LNumber);
  if TThemedGridValueConverter.TryConvert(TValue.From<Extended>(LNumber), AValueType, LConverted) and
    (LConverted.TypeInfo <> nil) then
    Exit(LConverted);
  Result := TValue.From<Extended>(LNumber);
end;

class function TThemedGridEditorSupport.ToAlignment(const AAlignment: TThemedGridContentAlignment): TAlignment;
begin
  case AAlignment of
    TThemedGridContentAlignment.TopRight,
    TThemedGridContentAlignment.MiddleRight,
    TThemedGridContentAlignment.BottomRight:
      Result := taRightJustify;
    TThemedGridContentAlignment.TopCenter,
    TThemedGridContentAlignment.MiddleCenter,
    TThemedGridContentAlignment.BottomCenter:
      Result := taCenter;
  else
    Result := taLeftJustify;
  end;
end;

class function TThemedGridEditorSupport.ValuesEqual(const ALeft, ARight: TValue): Boolean;
var
  LCompare: Integer;
  LLeftNull, LRightNull: Boolean;
begin
  LLeftNull := TThemedGridValueConverter.IsNull(ALeft);
  LRightNull := TThemedGridValueConverter.IsNull(ARight);
  if LLeftNull and LRightNull then
    Exit(True);
  if LLeftNull or LRightNull then
    Exit(False);
  if TThemedGridValueConverter.TryCompare(ALeft, ARight, LCompare) then
    Exit(LCompare = 0);
  Result := (ALeft.TypeInfo = ARight.TypeInfo) and
    (TThemedGridValueConverter.ToTextInvariant(ALeft) = TThemedGridValueConverter.ToTextInvariant(ARight));
end;

class function TThemedGridEditorSupport.IsDirectInlineKind(const AKind: TThemedGridCellRenderKind): Boolean;
begin
  Result := AKind in [TThemedGridCellRenderKind.Rating, TThemedGridCellRenderKind.Toggle,
    TThemedGridCellRenderKind.CheckBox, TThemedGridCellRenderKind.Slider];
end;

class function TThemedGridEditorSupport.IsCommandKind(const AKind: TThemedGridCellRenderKind): Boolean;
begin
  Result := AKind in [TThemedGridCellRenderKind.Command, TThemedGridCellRenderKind.Button,
    TThemedGridCellRenderKind.Link, TThemedGridCellRenderKind.Image, TThemedGridCellRenderKind.Icon];
end;

class procedure TThemedGridEditorSupport.ApplyInputColors(const AControl: TControl; const APalette: TThemePalette);
begin
  if (AControl = nil) or (APalette = nil) then
    Exit;
  TControlCracker(AControl).Color := ThemeColorToColor(APalette.InputBackColor);
  TControlCracker(AControl).Font.Color := ThemeColorToColor(APalette.InputForeColor);
end;

end.
