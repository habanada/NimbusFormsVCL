unit NimbusForms.Grid.SvgRenderer;

interface

uses
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.SvgXml,
  NimbusForms.Grid.SvgValues,
  NimbusForms.Grid.SvgDocument;

type
  TThemedSvgRenderOptions = record
    PreserveAspectRatio: Boolean;
    Center: Boolean;
    DefaultStrokeWidth: Single;
    DefaultOpacity: Single;
    PixelSnapBounds: Boolean;
    ForceCurrentColor: Boolean;
    CurrentColorOverridesFill: Boolean;
    CurrentColorOverridesStroke: Boolean;
    class function Standard: TThemedSvgRenderOptions; static;
  end;

  TThemedSvgAffine = record
    A, B, C, D, E, F: Double;
    class function Identity: TThemedSvgAffine; static;
    class function Make(const AA, AB, AC, AD, AE, AF: Double): TThemedSvgAffine; static;
    function Multiply(const AOther: TThemedSvgAffine): TThemedSvgAffine;
    function Invert(out AResult: TThemedSvgAffine): Boolean;
    procedure Apply(const AX, AY: Double; out AResultX, AResultY: Double);
    function ToMatrix: TGPMatrix;
  end;

  TThemedSvgRenderer = class sealed
  private
    type
      TState = record
        Fill: TThemedSvgPaint;
        Stroke: TThemedSvgPaint;
        StrokeWidth: Double;
        Opacity: Double;
        FillOpacity: Double;
        StrokeOpacity: Double;
        EvenOdd: Boolean;
        LineCap: string;
        LineJoin: string;
        MiterLimit: Double;
        Dash: string;
        DashOffset: Double;
        Color: TThemeColor;
        FontFamily: string;
        FontSize: Double;
        Bold: Boolean;
        Italic: Boolean;
        Anchor: string;
      end;
      TStop = record
        Offset: Double;
        Color: TThemeColor;
      end;
      TSpread = (spPad, spReflect, spTile);
  private
    FDocument: TThemedSvgDocument;
    FGraphics: TGPGraphics;
    FDepth: Integer;
    FOptions: TThemedSvgRenderOptions;
    FCurrentColor: TThemeColor;
    class function ParseTransform(const AText: string): TThemedSvgAffine; static;
    function ReadProperty(const ANode: TThemedSvgNode; const AName: string; out AValue: string): Boolean;
    function ApplyNode(const ANode: TThemedSvgNode; const AState: TState): TState;
    function IsHidden(const ANode: TThemedSvgNode): Boolean;
    procedure ApplyTransform(const AText: string);
    procedure DrawNode(const ANode: TThemedSvgNode; const AState: TState);
    procedure DrawChildren(const ANode: TThemedSvgNode; const AState: TState);
    procedure DrawUse(const ANode: TThemedSvgNode; const AState: TState);
    procedure DrawText(const ANode: TThemedSvgNode; const AState: TState);
    function CollectText(const ANode: TThemedSvgNode): string;
    function BuildShape(const ANode: TThemedSvgNode; const AState: TState): TGPGraphicsPath;
    procedure DrawShape(const APath: TGPGraphicsPath; const AState: TState);
    function EffectiveFill(const AState: TState): TThemedSvgPaint;
    function EffectiveStroke(const AState: TState): TThemedSvgPaint;
    function ColorWithAlpha(const AColor: TThemeColor; const AFactor: Double): TGPColor;
    procedure FillSolid(const APath: TGPGraphicsPath; const AColor: TThemeColor; const AFactor: Double);
    function FillPaint(const APath: TGPGraphicsPath; const APaint: TThemedSvgPaint; const AFactor: Double;
      const AState: TState): Boolean;
    function ResolveGradientAttribute(const ANode: TThemedSvgNode; const AName: string; const ASameKind: Boolean;
      out AValue: string): Boolean;
    function GradientValue(const ANode: TThemedSvgNode; const AName: string; const ADefaultFraction: Double;
      const AUserSpace: Boolean; const AReference: Double): Double;
    function IsUserSpace(const ANode: TThemedSvgNode): Boolean;
    function GradientSpread(const ANode: TThemedSvgNode): TSpread;
    function GradientMatrix(const ANode: TThemedSvgNode; const AUserSpace: Boolean;
      const ABounds: TGPRectF): TThemedSvgAffine;
    procedure BuildBlend(const AStops: TList<TStop>; const AFactor: Double; const ASpread: TSpread;
      const AStart, AEnd: Double; out AColors: TArray<TGPColor>; out APositions: TArray<Single>);
    function SolidLastStop(const AStops: TList<TStop>; const AFactor: Double): TGPBrush;
    function CreateLinearBrush(const ANode: TThemedSvgNode; const AStops: TList<TStop>; const AFactor: Double;
      const APath: TGPGraphicsPath): TGPBrush;
    function CreateRadialBrush(const ANode: TThemedSvgNode; const AStops: TList<TStop>; const AFactor: Double;
      const APath: TGPGraphicsPath; out AEllipse: TGPGraphicsPath; out AOuter: TGPColor): TGPBrush;
    procedure CollectStops(const ANode: TThemedSvgNode; const AStops: TList<TStop>; const ADepth: Integer;
      const AState: TState);
    function CreatePen(const AState: TState; const AColor: TThemeColor): TGPPen;
    procedure Execute(const ABounds: TRect);
    function ReferenceWidth: Double;
    function ReferenceHeight: Double;
  public
    class procedure Render(const ADocument: TThemedSvgDocument; const AGraphics: TGPGraphics;
      const ABounds: TRect; const ACurrentColor: TThemeColor); overload; static;
    class procedure Render(const ADocument: TThemedSvgDocument; const AGraphics: TGPGraphics;
      const ABounds: TRect; const ACurrentColor: TThemeColor; const AOptions: TThemedSvgRenderOptions); overload; static;
    class function RenderToBitmap(const ADocument: TThemedSvgDocument; const AWidth, AHeight: Integer;
      const ACurrentColor: TThemeColor): TGPBitmap; overload; static;
    class function RenderToBitmap(const ADocument: TThemedSvgDocument; const AWidth, AHeight: Integer;
      const ACurrentColor: TThemeColor; const AOptions: TThemedSvgRenderOptions): TGPBitmap; overload; static;
  end;

implementation

uses
  System.Math,
  NimbusForms.Grid.VisualStrings,
  NimbusForms.Grid.SvgPath;

const
  CMaxDepth = 24;
  CMaxTileSegments = 64;
  CDefaultFontSize = 12;
  CTextLayoutExtent = 20000;

function ClampValue(const AValue, AMin, AMax: Double): Double;
begin
  if AValue < AMin then
    Result := AMin
  else if AValue > AMax then
    Result := AMax
  else
    Result := AValue;
end;

class function TThemedSvgRenderOptions.Standard: TThemedSvgRenderOptions;
begin
  Result.PreserveAspectRatio := True;
  Result.Center := True;
  Result.DefaultStrokeWidth := 1;
  Result.DefaultOpacity := 1;
  Result.PixelSnapBounds := False;
  Result.ForceCurrentColor := False;
  Result.CurrentColorOverridesFill := False;
  Result.CurrentColorOverridesStroke := False;
end;

class function TThemedSvgAffine.Identity: TThemedSvgAffine;
begin
  Result := Make(1, 0, 0, 1, 0, 0);
end;

class function TThemedSvgAffine.Make(const AA, AB, AC, AD, AE, AF: Double): TThemedSvgAffine;
begin
  Result.A := AA;
  Result.B := AB;
  Result.C := AC;
  Result.D := AD;
  Result.E := AE;
  Result.F := AF;
end;

function TThemedSvgAffine.Multiply(const AOther: TThemedSvgAffine): TThemedSvgAffine;
begin
  Result.A := A * AOther.A + C * AOther.B;
  Result.B := B * AOther.A + D * AOther.B;
  Result.C := A * AOther.C + C * AOther.D;
  Result.D := B * AOther.C + D * AOther.D;
  Result.E := A * AOther.E + C * AOther.F + E;
  Result.F := B * AOther.E + D * AOther.F + F;
end;

function TThemedSvgAffine.Invert(out AResult: TThemedSvgAffine): Boolean;
var
  LDeterminant: Double;
begin
  LDeterminant := A * D - B * C;
  if Abs(LDeterminant) < 1.0E-12 then
  begin
    AResult := Identity;
    Exit(False);
  end;
  AResult.A := D / LDeterminant;
  AResult.B := -B / LDeterminant;
  AResult.C := -C / LDeterminant;
  AResult.D := A / LDeterminant;
  AResult.E := (C * F - D * E) / LDeterminant;
  AResult.F := (B * E - A * F) / LDeterminant;
  Result := True;
end;

procedure TThemedSvgAffine.Apply(const AX, AY: Double; out AResultX, AResultY: Double);
begin
  AResultX := A * AX + C * AY + E;
  AResultY := B * AX + D * AY + F;
end;

function TThemedSvgAffine.ToMatrix: TGPMatrix;
begin
  Result := TGPMatrix.Create(Single(A), Single(B), Single(C), Single(D), Single(E), Single(F));
end;

class procedure TThemedSvgRenderer.Render(const ADocument: TThemedSvgDocument; const AGraphics: TGPGraphics;
  const ABounds: TRect; const ACurrentColor: TThemeColor);
begin
  Render(ADocument, AGraphics, ABounds, ACurrentColor, TThemedSvgRenderOptions.Standard);
end;

class procedure TThemedSvgRenderer.Render(const ADocument: TThemedSvgDocument; const AGraphics: TGPGraphics;
  const ABounds: TRect; const ACurrentColor: TThemeColor; const AOptions: TThemedSvgRenderOptions);
var
  LRenderer: TThemedSvgRenderer;
begin
  if (ADocument = nil) or (AGraphics = nil) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  LRenderer := TThemedSvgRenderer.Create;
  try
    LRenderer.FDocument := ADocument;
    LRenderer.FGraphics := AGraphics;
    LRenderer.FOptions := AOptions;
    LRenderer.FCurrentColor := ACurrentColor;
    LRenderer.Execute(ABounds);
  finally
    LRenderer.Free;
  end;
end;

class function TThemedSvgRenderer.RenderToBitmap(const ADocument: TThemedSvgDocument; const AWidth, AHeight: Integer;
  const ACurrentColor: TThemeColor): TGPBitmap;
begin
  Result := RenderToBitmap(ADocument, AWidth, AHeight, ACurrentColor, TThemedSvgRenderOptions.Standard);
end;

class function TThemedSvgRenderer.RenderToBitmap(const ADocument: TThemedSvgDocument; const AWidth, AHeight: Integer;
  const ACurrentColor: TThemeColor; const AOptions: TThemedSvgRenderOptions): TGPBitmap;
var
  LGraphics: TGPGraphics;
begin
  Result := TGPBitmap.Create(Max(1, AWidth), Max(1, AHeight), PixelFormat32bppPARGB);
  LGraphics := TGPGraphics.Create(Result);
  try
    Render(ADocument, LGraphics, Rect(0, 0, Max(1, AWidth), Max(1, AHeight)), ACurrentColor, AOptions);
  finally
    LGraphics.Free;
  end;
end;

procedure TThemedSvgRenderer.Execute(const ABounds: TRect);
var
  LState: TState;
  LSaved: GraphicsState;
  LBounds: TRect;
  LViewX, LViewY, LViewWidth, LViewHeight, LScale, LScaleX, LScaleY, LOffsetX, LOffsetY: Double;
begin
  if FDocument.HasViewBox then
  begin
    LViewX := FDocument.ViewBoxX;
    LViewY := FDocument.ViewBoxY;
    LViewWidth := FDocument.ViewBoxWidth;
    LViewHeight := FDocument.ViewBoxHeight;
  end
  else
  begin
    LViewX := 0;
    LViewY := 0;
    LViewWidth := FDocument.Width;
    LViewHeight := FDocument.Height;
  end;
  if (LViewWidth <= 0) or (LViewHeight <= 0) then
    Exit;
  LBounds := ABounds;
  if FOptions.PixelSnapBounds then
    LBounds := Rect(ABounds.Left, ABounds.Top, ABounds.Left + Max(1, ABounds.Width),
      ABounds.Top + Max(1, ABounds.Height));
  LState := Default(TState);
  LState.Fill := TThemedSvgPaint.FromColor(TThemeColor($FF000000));
  LState.Stroke := TThemedSvgPaint.None;
  if FOptions.DefaultStrokeWidth > 0 then
    LState.StrokeWidth := FOptions.DefaultStrokeWidth
  else
    LState.StrokeWidth := 1;
  LState.Opacity := ClampValue(FOptions.DefaultOpacity, 0, 1);
  LState.FillOpacity := 1;
  LState.StrokeOpacity := 1;
  LState.MiterLimit := 4;
  LState.LineCap := 'butt';
  LState.LineJoin := 'miter';
  LState.Color := FCurrentColor;
  LState.FontFamily := ThemedGridVisualStrings.SvgFontSans;
  LState.FontSize := CDefaultFontSize;
  LState.Anchor := 'start';
  LSaved := FGraphics.Save;
  try
    FGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
    FGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    FGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    FGraphics.SetCompositingQuality(CompositingQualityHighQuality);
    FGraphics.SetTextRenderingHint(TextRenderingHintAntiAliasGridFit);
    FGraphics.SetClip(MakeRect(LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height), CombineModeIntersect);
    LScaleX := LBounds.Width / LViewWidth;
    LScaleY := LBounds.Height / LViewHeight;
    LOffsetX := LBounds.Left;
    LOffsetY := LBounds.Top;
    if FOptions.PreserveAspectRatio then
    begin
      LScale := Min(LScaleX, LScaleY);
      if FOptions.Center then
      begin
        LOffsetX := LOffsetX + (LBounds.Width - LViewWidth * LScale) / 2;
        LOffsetY := LOffsetY + (LBounds.Height - LViewHeight * LScale) / 2;
      end;
      LScaleX := LScale;
      LScaleY := LScale;
    end;
    FGraphics.TranslateTransform(Single(LOffsetX - LViewX * LScaleX), Single(LOffsetY - LViewY * LScaleY));
    FGraphics.ScaleTransform(Single(LScaleX), Single(LScaleY));
    DrawNode(FDocument.Root, LState);
  finally
    FGraphics.Restore(LSaved);
  end;
end;

function TThemedSvgRenderer.ReferenceWidth: Double;
begin
  if FDocument.HasViewBox then
    Result := FDocument.ViewBoxWidth
  else
    Result := FDocument.Width;
end;

function TThemedSvgRenderer.ReferenceHeight: Double;
begin
  if FDocument.HasViewBox then
    Result := FDocument.ViewBoxHeight
  else
    Result := FDocument.Height;
end;

function TThemedSvgRenderer.ReadProperty(const ANode: TThemedSvgNode; const AName: string; out AValue: string): Boolean;
begin
  Result := FDocument.TryGetProperty(ANode, AName, AValue);
end;

function TThemedSvgRenderer.IsHidden(const ANode: TThemedSvgNode): Boolean;
var
  LValue: string;
begin
  Result := False;
  if ReadProperty(ANode, 'display', LValue) and SameText(Trim(LValue), 'none') then
    Exit(True);
  if ReadProperty(ANode, 'visibility', LValue) and
    (SameText(Trim(LValue), 'hidden') or SameText(Trim(LValue), 'collapse')) then
    Result := True;
end;

function TThemedSvgRenderer.ApplyNode(const ANode: TThemedSvgNode; const AState: TState): TState;
var
  LValue, LFamily: string;
  LColor: TThemeColor;
  LPaint: TThemedSvgPaint;
  LWeight, LSeparator: Integer;
begin
  Result := AState;
  if ReadProperty(ANode, 'color', LValue) and TThemedSvgValues.TryParseColor(LValue, AState.Color, LColor) then
    Result.Color := LColor;
  if ReadProperty(ANode, 'fill', LValue) then
  begin
    LPaint := TThemedSvgValues.ParsePaint(LValue, Result.Color);
    if LPaint.Kind <> TThemedSvgPaintKind.Unset then
      Result.Fill := LPaint;
  end;
  if ReadProperty(ANode, 'stroke', LValue) then
  begin
    LPaint := TThemedSvgValues.ParsePaint(LValue, Result.Color);
    if LPaint.Kind <> TThemedSvgPaintKind.Unset then
      Result.Stroke := LPaint;
  end;
  if ReadProperty(ANode, 'stroke-width', LValue) then
    Result.StrokeWidth := ClampValue(TThemedSvgValues.ParseLength(LValue, Result.StrokeWidth, ReferenceWidth), 0, 1.0E9);
  if ReadProperty(ANode, 'opacity', LValue) then
    Result.Opacity := Result.Opacity * ClampValue(TThemedSvgValues.ParseFraction(LValue, 1), 0, 1);
  if ReadProperty(ANode, 'fill-opacity', LValue) then
    Result.FillOpacity := ClampValue(TThemedSvgValues.ParseFraction(LValue, 1), 0, 1);
  if ReadProperty(ANode, 'stroke-opacity', LValue) then
    Result.StrokeOpacity := ClampValue(TThemedSvgValues.ParseFraction(LValue, 1), 0, 1);
  if ReadProperty(ANode, 'fill-rule', LValue) then
    Result.EvenOdd := SameText(Trim(LValue), 'evenodd');
  if ReadProperty(ANode, 'stroke-linecap', LValue) then
    Result.LineCap := LowerCase(Trim(LValue));
  if ReadProperty(ANode, 'stroke-linejoin', LValue) then
    Result.LineJoin := LowerCase(Trim(LValue));
  if ReadProperty(ANode, 'stroke-miterlimit', LValue) then
    Result.MiterLimit := ClampValue(TThemedSvgValues.ParseNumber(LValue, Result.MiterLimit), 1, 1.0E9);
  if ReadProperty(ANode, 'stroke-dasharray', LValue) then
    Result.Dash := Trim(LValue);
  if ReadProperty(ANode, 'stroke-dashoffset', LValue) then
    Result.DashOffset := TThemedSvgValues.ParseLength(LValue, 0, ReferenceWidth);
  if ReadProperty(ANode, 'font-family', LValue) then
  begin
    LSeparator := Pos(',', LValue);
    if LSeparator > 0 then
      LFamily := Copy(LValue, 1, LSeparator - 1)
    else
      LFamily := LValue;
    LFamily := Trim(LFamily).Trim(['"', '''', ' ']);
    if SameText(LFamily, ThemedGridVisualStrings.SvgGenericSansSerif) then
      LFamily := ThemedGridVisualStrings.SvgFontSans
    else if SameText(LFamily, ThemedGridVisualStrings.SvgGenericSerif) then
      LFamily := ThemedGridVisualStrings.SvgFontSerif
    else if SameText(LFamily, ThemedGridVisualStrings.SvgGenericMonospace) then
      LFamily := ThemedGridVisualStrings.SvgFontMono;
    if LFamily <> '' then
      Result.FontFamily := LFamily;
  end;
  if ReadProperty(ANode, 'font-size', LValue) then
    Result.FontSize := TThemedSvgValues.ParseLength(LValue, Result.FontSize, ReferenceHeight);
  if ReadProperty(ANode, 'font-weight', LValue) then
  begin
    LValue := LowerCase(Trim(LValue));
    if TryStrToInt(LValue, LWeight) then
      Result.Bold := LWeight >= 600
    else
      Result.Bold := (LValue = 'bold') or (LValue = 'bolder');
  end;
  if ReadProperty(ANode, 'font-style', LValue) then
  begin
    LValue := LowerCase(Trim(LValue));
    Result.Italic := (LValue = 'italic') or (LValue = 'oblique');
  end;
  if ReadProperty(ANode, 'text-anchor', LValue) then
    Result.Anchor := LowerCase(Trim(LValue));
end;

class function TThemedSvgRenderer.ParseTransform(const AText: string): TThemedSvgAffine;
var
  LText, LName, LArgs: string;
  LOpen, LClose: Integer;
  LNumbers: TArray<Double>;
  LOperation: TThemedSvgAffine;
  LHasOperation: Boolean;
  LCos, LSin, LAngle: Double;

  function Arg(const AIndex: Integer; const ADefault: Double): Double;
  begin
    if AIndex < Length(LNumbers) then
      Result := LNumbers[AIndex]
    else
      Result := ADefault;
  end;

begin
  Result := TThemedSvgAffine.Identity;
  LText := AText;
  while True do
  begin
    LOpen := Pos('(', LText);
    if LOpen = 0 then
      Break;
    LClose := Pos(')', LText, LOpen);
    if LClose = 0 then
      Break;
    LName := LowerCase(Trim(Copy(LText, 1, LOpen - 1)).Trim([',', ' ']));
    LArgs := Copy(LText, LOpen + 1, LClose - LOpen - 1);
    LText := Copy(LText, LClose + 1, MaxInt);
    LNumbers := TThemedSvgValues.SplitNumbers(LArgs);
    LHasOperation := True;
    LOperation := TThemedSvgAffine.Identity;
    if LName = 'matrix' then
    begin
      if Length(LNumbers) >= 6 then
        LOperation := TThemedSvgAffine.Make(LNumbers[0], LNumbers[1], LNumbers[2], LNumbers[3], LNumbers[4],
          LNumbers[5])
      else
        LHasOperation := False;
    end
    else if LName = 'translate' then
      LOperation := TThemedSvgAffine.Make(1, 0, 0, 1, Arg(0, 0), Arg(1, 0))
    else if LName = 'scale' then
      LOperation := TThemedSvgAffine.Make(Arg(0, 1), 0, 0, Arg(1, Arg(0, 1)), 0, 0)
    else if LName = 'rotate' then
    begin
      LAngle := DegToRad(Arg(0, 0));
      LCos := Cos(LAngle);
      LSin := Sin(LAngle);
      if Length(LNumbers) >= 3 then
        LOperation := TThemedSvgAffine.Make(LCos, LSin, -LSin, LCos,
          LNumbers[1] - LCos * LNumbers[1] + LSin * LNumbers[2],
          LNumbers[2] - LSin * LNumbers[1] - LCos * LNumbers[2])
      else
        LOperation := TThemedSvgAffine.Make(LCos, LSin, -LSin, LCos, 0, 0);
    end
    else if LName = 'skewx' then
      LOperation := TThemedSvgAffine.Make(1, 0, Tan(DegToRad(Arg(0, 0))), 1, 0, 0)
    else if LName = 'skewy' then
      LOperation := TThemedSvgAffine.Make(1, Tan(DegToRad(Arg(0, 0))), 0, 1, 0, 0)
    else
      LHasOperation := False;
    if LHasOperation then
      Result := Result.Multiply(LOperation);
  end;
end;

procedure TThemedSvgRenderer.ApplyTransform(const AText: string);
var
  LMatrix: TGPMatrix;
begin
  LMatrix := ParseTransform(AText).ToMatrix;
  try
    FGraphics.MultiplyTransform(LMatrix);
  finally
    LMatrix.Free;
  end;
end;

procedure TThemedSvgRenderer.DrawChildren(const ANode: TThemedSvgNode; const AState: TState);
var
  LChild: TThemedSvgNode;
begin
  for LChild in ANode.Children do
    DrawNode(LChild, AState);
end;

procedure TThemedSvgRenderer.DrawUse(const ANode: TThemedSvgNode; const AState: TState);
var
  LReference, LValue: string;
  LTarget: TThemedSvgNode;
  LSaved: GraphicsState;
  LX, LY: Double;
begin
  LReference := ANode.GetAttribute('href');
  if (LReference = '') or (LReference[1] <> '#') then
    Exit;
  LTarget := FDocument.FindById(Copy(LReference, 2, MaxInt));
  if (LTarget = nil) or (FDepth >= CMaxDepth) then
    Exit;
  LX := 0;
  LY := 0;
  if ANode.TryGetAttribute('x', LValue) then
    LX := TThemedSvgValues.ParseLength(LValue, 0, ReferenceWidth);
  if ANode.TryGetAttribute('y', LValue) then
    LY := TThemedSvgValues.ParseLength(LValue, 0, ReferenceHeight);
  LSaved := FGraphics.Save;
  try
    FGraphics.TranslateTransform(Single(LX), Single(LY));
    Inc(FDepth);
    try
      if (LTarget.Name = 'symbol') or (LTarget.Name = 'svg') then
        DrawChildren(LTarget, ApplyNode(LTarget, AState))
      else
        DrawNode(LTarget, AState);
    finally
      Dec(FDepth);
    end;
  finally
    FGraphics.Restore(LSaved);
  end;
end;

function TThemedSvgRenderer.CollectText(const ANode: TThemedSvgNode): string;
var
  LBuilder: TStringBuilder;
  LPrevious: Char;
  I: Integer;
  LText: string;

  procedure Walk(const AItem: TThemedSvgNode);
  var
    LChild: TThemedSvgNode;
  begin
    LBuilder.Append(AItem.Text);
    for LChild in AItem.Children do
      if (LChild.Name = 'tspan') or (LChild.Name = 'textPath') then
        Walk(LChild);
  end;

begin
  LBuilder := TStringBuilder.Create;
  try
    Walk(ANode);
    LText := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
  LBuilder := TStringBuilder.Create;
  try
    LPrevious := ' ';
    for I := 1 to Length(LText) do
    begin
      if (LText[I] = #13) or (LText[I] = #10) or (LText[I] = #9) then
        LText[I] := ' ';
      if (LText[I] = ' ') and (LPrevious = ' ') then
        Continue;
      LBuilder.Append(LText[I]);
      LPrevious := LText[I];
    end;
    Result := Trim(LBuilder.ToString);
  finally
    LBuilder.Free;
  end;
end;

procedure TThemedSvgRenderer.DrawText(const ANode: TThemedSvgNode; const AState: TState);
var
  LText, LValue: string;
  LNumbers: TArray<Double>;
  LX, LY, LSize, LAscent, LOpacity: Double;
  LFill: TThemedSvgPaint;
  LColor: TThemeColor;
  LFont: TGPFont;
  LFamily: TGPFontFamily;
  LFormat: TGPStringFormat;
  LBrush: TGPSolidBrush;
  LLayout: TGPRectF;
  LStyle: Integer;
  LEmHeight: Integer;
begin
  LText := CollectText(ANode);
  if LText = '' then
    Exit;
  LFill := EffectiveFill(AState);
  if LFill.Kind = TThemedSvgPaintKind.Color then
    LColor := LFill.Color
  else if (LFill.Kind = TThemedSvgPaintKind.Reference) and LFill.HasFallback then
    LColor := LFill.FallbackColor
  else
    Exit;
  LOpacity := AState.FillOpacity * AState.Opacity;
  if LOpacity <= 0 then
    Exit;
  LX := 0;
  LY := 0;
  if ANode.TryGetAttribute('x', LValue) then
  begin
    LNumbers := TThemedSvgValues.SplitNumbers(LValue);
    if Length(LNumbers) > 0 then
      LX := LNumbers[0];
  end;
  if ANode.TryGetAttribute('y', LValue) then
  begin
    LNumbers := TThemedSvgValues.SplitNumbers(LValue);
    if Length(LNumbers) > 0 then
      LY := LNumbers[0];
  end;
  LSize := AState.FontSize;
  if LSize <= 0 then
    LSize := CDefaultFontSize;
  LStyle := FontStyleRegular;
  if AState.Bold then
    LStyle := LStyle or FontStyleBold;
  if AState.Italic then
    LStyle := LStyle or FontStyleItalic;
  LFont := TGPFont.Create(AState.FontFamily, Single(LSize), LStyle, UnitPixel);
  if LFont.GetLastStatus <> Ok then
  begin
    LFont.Free;
    LFont := TGPFont.Create(ThemedGridVisualStrings.SvgFontSans, Single(LSize), LStyle, UnitPixel);
  end;
  try
    LAscent := LSize * 0.8;
    LFamily := TGPFontFamily.Create;
    try
      if LFont.GetFamily(LFamily) = Ok then
      begin
        LEmHeight := LFamily.GetEmHeight(LStyle);
        if LEmHeight > 0 then
          LAscent := LFamily.GetCellAscent(LStyle) / LEmHeight * LSize;
      end;
    finally
      LFamily.Free;
    end;
    LFormat := TGPStringFormat.Create;
    try
      LFormat.SetFormatFlags(StringFormatFlagsNoFitBlackBox or StringFormatFlagsNoWrap or StringFormatFlagsNoClip);
      LFormat.SetLineAlignment(StringAlignmentNear);
      if AState.Anchor = 'middle' then
      begin
        LFormat.SetAlignment(StringAlignmentCenter);
        LLayout := MakeRect(Single(LX - CTextLayoutExtent / 2), Single(LY - LAscent), Single(CTextLayoutExtent),
          Single(LSize * 3));
      end
      else if AState.Anchor = 'end' then
      begin
        LFormat.SetAlignment(StringAlignmentFar);
        LLayout := MakeRect(Single(LX - CTextLayoutExtent), Single(LY - LAscent), Single(CTextLayoutExtent),
          Single(LSize * 3));
      end
      else
      begin
        LFormat.SetAlignment(StringAlignmentNear);
        LLayout := MakeRect(Single(LX), Single(LY - LAscent), Single(CTextLayoutExtent), Single(LSize * 3));
      end;
      LBrush := TGPSolidBrush.Create(ColorWithAlpha(LColor, LOpacity));
      try
        FGraphics.DrawString(PChar(LText), Length(LText), LFont, LLayout, LFormat, LBrush);
      finally
        LBrush.Free;
      end;
    finally
      LFormat.Free;
    end;
  finally
    LFont.Free;
  end;
end;

procedure TThemedSvgRenderer.DrawNode(const ANode: TThemedSvgNode; const AState: TState);
var
  LState: TState;
  LSaved: GraphicsState;
  LTransform: string;
  LPath: TGPGraphicsPath;
  LName: string;
begin
  if (ANode = nil) or (FDepth > CMaxDepth) then
    Exit;
  LName := ANode.Name;
  if not ((LName = 'g') or (LName = 'a') or (LName = 'svg') or (LName = 'switch') or (LName = 'path') or
    (LName = 'rect') or (LName = 'circle') or (LName = 'ellipse') or (LName = 'line') or
    (LName = 'polyline') or (LName = 'polygon') or (LName = 'use') or (LName = 'text')) then
    Exit;
  if IsHidden(ANode) then
    Exit;
  LState := ApplyNode(ANode, AState);
  LSaved := FGraphics.Save;
  try
    if ReadProperty(ANode, 'transform', LTransform) then
      ApplyTransform(LTransform);
    if (LName = 'g') or (LName = 'a') or (LName = 'svg') or (LName = 'switch') then
    begin
      Inc(FDepth);
      try
        DrawChildren(ANode, LState);
      finally
        Dec(FDepth);
      end;
    end
    else if LName = 'use' then
      DrawUse(ANode, LState)
    else if LName = 'text' then
      DrawText(ANode, LState)
    else
    begin
      LPath := BuildShape(ANode, LState);
      if LPath <> nil then
        try
          DrawShape(LPath, LState);
        finally
          LPath.Free;
        end;
    end;
  finally
    FGraphics.Restore(LSaved);
  end;
end;

function TThemedSvgRenderer.BuildShape(const ANode: TThemedSvgNode; const AState: TState): TGPGraphicsPath;
var
  LName, LValue: string;
  LX, LY, LWidth, LHeight, LRx, LRy, LCx, LCy, LR, LX2, LY2: Double;
  LNumbers: TArray<Double>;
  I: Integer;
  LHasRx, LHasRy: Boolean;

  function Len(const AAttribute: string; const ADefault, AReference: Double): Double;
  var
    LText: string;
  begin
    if ANode.TryGetAttribute(AAttribute, LText) then
      Result := TThemedSvgValues.ParseLength(LText, ADefault, AReference)
    else
      Result := ADefault;
  end;

begin
  Result := nil;
  LName := ANode.Name;
  if LName = 'path' then
  begin
    if ANode.TryGetAttribute('d', LValue) then
      Result := TThemedSvgPathBuilder.Build(LValue, AState.EvenOdd);
    Exit;
  end;
  Result := TGPGraphicsPath.Create;
  if AState.EvenOdd then
    Result.SetFillMode(FillModeAlternate)
  else
    Result.SetFillMode(FillModeWinding);
  if LName = 'rect' then
  begin
    LX := Len('x', 0, ReferenceWidth);
    LY := Len('y', 0, ReferenceHeight);
    LWidth := Len('width', 0, ReferenceWidth);
    LHeight := Len('height', 0, ReferenceHeight);
    if (LWidth <= 0) or (LHeight <= 0) then
      FreeAndNil(Result)
    else
    begin
      LHasRx := ANode.HasAttribute('rx');
      LHasRy := ANode.HasAttribute('ry');
      LRx := Len('rx', 0, ReferenceWidth);
      LRy := Len('ry', 0, ReferenceHeight);
      if LHasRx and not LHasRy then
        LRy := LRx
      else if LHasRy and not LHasRx then
        LRx := LRy;
      TThemedSvgPathBuilder.AddRoundedRectangle(Result, LX, LY, LWidth, LHeight, LRx, LRy);
    end;
  end
  else if LName = 'circle' then
  begin
    LCx := Len('cx', 0, ReferenceWidth);
    LCy := Len('cy', 0, ReferenceHeight);
    LR := Len('r', 0, Min(ReferenceWidth, ReferenceHeight));
    if LR <= 0 then
      FreeAndNil(Result)
    else
      Result.AddEllipse(Single(LCx - LR), Single(LCy - LR), Single(LR * 2), Single(LR * 2));
  end
  else if LName = 'ellipse' then
  begin
    LCx := Len('cx', 0, ReferenceWidth);
    LCy := Len('cy', 0, ReferenceHeight);
    LRx := Len('rx', 0, ReferenceWidth);
    LRy := Len('ry', 0, ReferenceHeight);
    if (LRx <= 0) or (LRy <= 0) then
      FreeAndNil(Result)
    else
      Result.AddEllipse(Single(LCx - LRx), Single(LCy - LRy), Single(LRx * 2), Single(LRy * 2));
  end
  else if LName = 'line' then
  begin
    LX := Len('x1', 0, ReferenceWidth);
    LY := Len('y1', 0, ReferenceHeight);
    LX2 := Len('x2', 0, ReferenceWidth);
    LY2 := Len('y2', 0, ReferenceHeight);
    Result.AddLine(Single(LX), Single(LY), Single(LX2), Single(LY2));
  end
  else if (LName = 'polyline') or (LName = 'polygon') then
  begin
    LNumbers := TThemedSvgValues.SplitNumbers(ANode.GetAttribute('points'));
    if Length(LNumbers) < 4 then
      FreeAndNil(Result)
    else
    begin
      Result.StartFigure;
      I := 0;
      while I + 3 < Length(LNumbers) do
      begin
        Result.AddLine(Single(LNumbers[I]), Single(LNumbers[I + 1]), Single(LNumbers[I + 2]),
          Single(LNumbers[I + 3]));
        Inc(I, 2);
      end;
      if LName = 'polygon' then
        Result.CloseFigure;
    end;
  end
  else
    FreeAndNil(Result);
end;

function TThemedSvgRenderer.ColorWithAlpha(const AColor: TThemeColor; const AFactor: Double): TGPColor;
var
  LAlpha: Integer;
begin
  LAlpha := Max(0, Min(255, Round(ThemeColorAlpha(AColor) * AFactor)));
  Result := TGPColor(Cardinal(ThemeColor(Byte(LAlpha), ThemeColorRed(AColor), ThemeColorGreen(AColor),
    ThemeColorBlue(AColor))));
end;

procedure TThemedSvgRenderer.CollectStops(const ANode: TThemedSvgNode; const AStops: TList<TStop>;
  const ADepth: Integer; const AState: TState);
var
  LChild, LLinked: TThemedSvgNode;
  LStop: TStop;
  LValue, LReference: string;
  LColor: TThemeColor;
  LOpacity: Double;
  LAlpha: Integer;
begin
  if (ANode = nil) or (ADepth > 8) then
    Exit;
  for LChild in ANode.Children do
  begin
    if LChild.Name <> 'stop' then
      Continue;
    LStop.Offset := ClampValue(TThemedSvgValues.ParseFraction(LChild.GetAttribute('offset'), 0), 0, 1);
    if (AStops.Count > 0) and (LStop.Offset < AStops[AStops.Count - 1].Offset) then
      LStop.Offset := AStops[AStops.Count - 1].Offset;
    LColor := TThemeColor($FF000000);
    if FDocument.TryGetProperty(LChild, 'stop-color', LValue) then
      if not TThemedSvgValues.TryParseColor(LValue, AState.Color, LColor) then
        LColor := TThemeColor($FF000000);
    LOpacity := 1;
    if FDocument.TryGetProperty(LChild, 'stop-opacity', LValue) then
      LOpacity := ClampValue(TThemedSvgValues.ParseFraction(LValue, 1), 0, 1);
    LAlpha := Round(ThemeColorAlpha(LColor) * LOpacity);
    LStop.Color := ThemeColor(Byte(LAlpha), ThemeColorRed(LColor), ThemeColorGreen(LColor), ThemeColorBlue(LColor));
    AStops.Add(LStop);
  end;
  if AStops.Count = 0 then
  begin
    LReference := ANode.GetAttribute('href');
    if (LReference <> '') and (LReference[1] = '#') then
    begin
      LLinked := FDocument.FindById(Copy(LReference, 2, MaxInt));
      CollectStops(LLinked, AStops, ADepth + 1, AState);
    end;
  end;
end;

function TThemedSvgRenderer.ResolveGradientAttribute(const ANode: TThemedSvgNode; const AName: string;
  const ASameKind: Boolean; out AValue: string): Boolean;
var
  LCurrent: TThemedSvgNode;
  LDepth: Integer;
  LReference: string;
begin
  Result := False;
  AValue := '';
  LCurrent := ANode;
  LDepth := 0;
  while (LCurrent <> nil) and (LDepth <= 8) do
  begin
    if ((not ASameKind) or (LCurrent.Name = ANode.Name)) and LCurrent.TryGetAttribute(AName, AValue) then
      Exit(True);
    LReference := LCurrent.GetAttribute('href');
    if (LReference = '') or (LReference[1] <> '#') then
      Exit;
    LCurrent := FDocument.FindById(Copy(LReference, 2, MaxInt));
    Inc(LDepth);
  end;
end;

function TThemedSvgRenderer.GradientValue(const ANode: TThemedSvgNode; const AName: string;
  const ADefaultFraction: Double; const AUserSpace: Boolean; const AReference: Double): Double;
var
  LText: string;
begin
  if ResolveGradientAttribute(ANode, AName, True, LText) then
  begin
    if AUserSpace then
      Result := TThemedSvgValues.ParseLength(LText, ADefaultFraction * AReference, AReference)
    else
      Result := TThemedSvgValues.ParseFraction(LText, ADefaultFraction);
  end
  else if AUserSpace then
    Result := ADefaultFraction * AReference
  else
    Result := ADefaultFraction;
end;

function TThemedSvgRenderer.IsUserSpace(const ANode: TThemedSvgNode): Boolean;
var
  LText: string;
begin
  Result := ResolveGradientAttribute(ANode, 'gradientUnits', False, LText) and
    SameText(Trim(LText), 'userSpaceOnUse');
end;

function TThemedSvgRenderer.GradientSpread(const ANode: TThemedSvgNode): TSpread;
var
  LText: string;
begin
  Result := spPad;
  if ResolveGradientAttribute(ANode, 'spreadMethod', False, LText) then
  begin
    LText := LowerCase(Trim(LText));
    if LText = 'reflect' then
      Result := spReflect
    else if LText = 'repeat' then
      Result := spTile;
  end;
end;

function TThemedSvgRenderer.GradientMatrix(const ANode: TThemedSvgNode; const AUserSpace: Boolean;
  const ABounds: TGPRectF): TThemedSvgAffine;
var
  LText: string;
  LBox: TThemedSvgAffine;
begin
  Result := TThemedSvgAffine.Identity;
  if ResolveGradientAttribute(ANode, 'gradientTransform', False, LText) then
    Result := ParseTransform(LText);
  if not AUserSpace then
  begin
    LBox := TThemedSvgAffine.Make(ABounds.Width, 0, 0, ABounds.Height, ABounds.X, ABounds.Y);
    Result := LBox.Multiply(Result);
  end;
end;

procedure TThemedSvgRenderer.BuildBlend(const AStops: TList<TStop>; const AFactor: Double; const ASpread: TSpread;
  const AStart, AEnd: Double; out AColors: TArray<TGPColor>; out APositions: TArray<Single>);
var
  LRaw: TList<TStop>;
  LItem: TStop;
  LSpan, LPosition: Double;
  I, LSegment, LFirst, LLast: Integer;

  procedure Add(const AT: Double; const AColor: TThemeColor);
  var
    LEntry: TStop;
  begin
    LEntry.Offset := AT;
    LEntry.Color := AColor;
    LRaw.Add(LEntry);
  end;

  procedure AddSegment(const AIndex: Integer; const AReverse: Boolean);
  var
    K: Integer;
  begin
    if not AReverse then
    begin
      if AStops[0].Offset > 0 then
        Add(AIndex, AStops[0].Color);
      for K := 0 to AStops.Count - 1 do
        Add(AIndex + AStops[K].Offset, AStops[K].Color);
      if AStops[AStops.Count - 1].Offset < 1 then
        Add(AIndex + 1, AStops[AStops.Count - 1].Color);
    end
    else
    begin
      if AStops[AStops.Count - 1].Offset < 1 then
        Add(AIndex, AStops[AStops.Count - 1].Color);
      for K := AStops.Count - 1 downto 0 do
        Add(AIndex + 1 - AStops[K].Offset, AStops[K].Color);
      if AStops[0].Offset > 0 then
        Add(AIndex + 1, AStops[0].Color);
    end;
  end;

begin
  LRaw := TList<TStop>.Create;
  try
    if ASpread = spPad then
    begin
      if AStart < AStops[0].Offset then
        Add(AStart, AStops[0].Color);
      for I := 0 to AStops.Count - 1 do
        Add(AStops[I].Offset, AStops[I].Color);
      if AEnd > AStops[AStops.Count - 1].Offset then
        Add(AEnd, AStops[AStops.Count - 1].Color);
    end
    else
    begin
      LFirst := Round(AStart);
      LLast := Round(AEnd) - 1;
      for LSegment := LFirst to LLast do
        AddSegment(LSegment, (ASpread = spReflect) and Odd(LSegment));
    end;
    LSpan := AEnd - AStart;
    SetLength(AColors, LRaw.Count);
    SetLength(APositions, LRaw.Count);
    for I := 0 to LRaw.Count - 1 do
    begin
      LItem := LRaw[I];
      LPosition := ClampValue((LItem.Offset - AStart) / LSpan, 0, 1);
      if (I > 0) and (LPosition <= APositions[I - 1]) then
        LPosition := Min(1, APositions[I - 1] + 0.00001);
      AColors[I] := ColorWithAlpha(LItem.Color, AFactor);
      APositions[I] := Single(LPosition);
    end;
    APositions[0] := 0;
    APositions[High(APositions)] := 1;
  finally
    LRaw.Free;
  end;
end;

function TThemedSvgRenderer.SolidLastStop(const AStops: TList<TStop>; const AFactor: Double): TGPBrush;
begin
  Result := TGPSolidBrush.Create(ColorWithAlpha(AStops[AStops.Count - 1].Color, AFactor));
end;

function TThemedSvgRenderer.CreateLinearBrush(const ANode: TThemedSvgNode; const AStops: TList<TStop>;
  const AFactor: Double; const APath: TGPGraphicsPath): TGPBrush;
var
  LBounds: TGPRectF;
  LUserSpace: Boolean;
  LMatrix, LInverse: TThemedSvgAffine;
  LSpread: TSpread;
  LX1, LY1, LX2, LY2, LDX, LDY, LDD, LVX, LVY, LVV: Double;
  LTMin, LTMax, LT, LT0, LT1, LGX, LGY, LQX, LQY, LStartX, LStartY, LEndX, LEndY: Double;
  LCornerX, LCornerY: array[0..3] of Double;
  LColors: TArray<TGPColor>;
  LPositions: TArray<Single>;
  I: Integer;
begin
  APath.GetBounds(LBounds);
  LUserSpace := IsUserSpace(ANode);
  if (not LUserSpace) and ((LBounds.Width <= 0) or (LBounds.Height <= 0)) then
    Exit(SolidLastStop(AStops, AFactor));
  LX1 := GradientValue(ANode, 'x1', 0, LUserSpace, ReferenceWidth);
  LY1 := GradientValue(ANode, 'y1', 0, LUserSpace, ReferenceHeight);
  LX2 := GradientValue(ANode, 'x2', 1, LUserSpace, ReferenceWidth);
  LY2 := GradientValue(ANode, 'y2', 0, LUserSpace, ReferenceHeight);
  LDX := LX2 - LX1;
  LDY := LY2 - LY1;
  LDD := LDX * LDX + LDY * LDY;
  if LDD <= 0 then
    Exit(SolidLastStop(AStops, AFactor));
  LMatrix := GradientMatrix(ANode, LUserSpace, LBounds);
  if not LMatrix.Invert(LInverse) then
    Exit(SolidLastStop(AStops, AFactor));
  LVX := (LInverse.A * LDX + LInverse.B * LDY) / LDD;
  LVY := (LInverse.C * LDX + LInverse.D * LDY) / LDD;
  LVV := LVX * LVX + LVY * LVY;
  if LVV <= 0 then
    Exit(SolidLastStop(AStops, AFactor));
  LCornerX[0] := LBounds.X;
  LCornerY[0] := LBounds.Y;
  LCornerX[1] := LBounds.X + LBounds.Width;
  LCornerY[1] := LBounds.Y;
  LCornerX[2] := LBounds.X;
  LCornerY[2] := LBounds.Y + LBounds.Height;
  LCornerX[3] := LBounds.X + LBounds.Width;
  LCornerY[3] := LBounds.Y + LBounds.Height;
  LTMin := 0;
  LTMax := 1;
  for I := 0 to 3 do
  begin
    LInverse.Apply(LCornerX[I], LCornerY[I], LGX, LGY);
    LT := ((LGX - LX1) * LDX + (LGY - LY1) * LDY) / LDD;
    if I = 0 then
    begin
      LTMin := LT;
      LTMax := LT;
    end
    else
    begin
      LTMin := Min(LTMin, LT);
      LTMax := Max(LTMax, LT);
    end;
  end;
  LSpread := GradientSpread(ANode);
  LT0 := 0;
  LT1 := 1;
  if LSpread <> spPad then
  begin
    LT0 := Floor(LTMin);
    LT1 := Ceil(LTMax);
    if LT1 <= LT0 then
      LT1 := LT0 + 1;
    if LT1 - LT0 > CMaxTileSegments then
      LSpread := spPad;
  end;
  if LSpread = spPad then
  begin
    LT0 := Min(0, LTMin) - 0.001;
    LT1 := Max(1, LTMax) + 0.001;
  end;
  LMatrix.Apply(LX1, LY1, LQX, LQY);
  LStartX := LQX + LVX * LT0 / LVV;
  LStartY := LQY + LVY * LT0 / LVV;
  LEndX := LQX + LVX * LT1 / LVV;
  LEndY := LQY + LVY * LT1 / LVV;
  BuildBlend(AStops, AFactor, LSpread, LT0, LT1, LColors, LPositions);
  Result := TGPLinearGradientBrush.Create(MakePoint(Single(LStartX), Single(LStartY)),
    MakePoint(Single(LEndX), Single(LEndY)), LColors[0], LColors[High(LColors)]);
  TGPLinearGradientBrush(Result).SetInterpolationColors(@LColors[0], @LPositions[0], Length(LColors));
end;

function TThemedSvgRenderer.CreateRadialBrush(const ANode: TThemedSvgNode; const AStops: TList<TStop>;
  const AFactor: Double; const APath: TGPGraphicsPath; out AEllipse: TGPGraphicsPath;
  out AOuter: TGPColor): TGPBrush;
var
  LBounds: TGPRectF;
  LUserSpace: Boolean;
  LMatrix, LInverse: TThemedSvgAffine;
  LMatrixObject: TGPMatrix;
  LText: string;
  LCx, LCy, LR, LFx, LFy, LDistance, LFocalX, LFocalY, LReferenceRadius: Double;
  LSurround: TGPColor;
  LSurroundCount, LCount, LIndex, I: Integer;
  LColors: array of TGPColor;
  LPositions: array of Single;
  LLast: Integer;
begin
  AEllipse := nil;
  AOuter := ColorWithAlpha(AStops[AStops.Count - 1].Color, AFactor);
  APath.GetBounds(LBounds);
  LUserSpace := IsUserSpace(ANode);
  if (not LUserSpace) and ((LBounds.Width <= 0) or (LBounds.Height <= 0)) then
    Exit(SolidLastStop(AStops, AFactor));
  LReferenceRadius := Sqrt((Sqr(ReferenceWidth) + Sqr(ReferenceHeight)) / 2);
  LCx := GradientValue(ANode, 'cx', 0.5, LUserSpace, ReferenceWidth);
  LCy := GradientValue(ANode, 'cy', 0.5, LUserSpace, ReferenceHeight);
  LR := GradientValue(ANode, 'r', 0.5, LUserSpace, LReferenceRadius);
  if LR <= 0 then
    Exit(SolidLastStop(AStops, AFactor));
  if ResolveGradientAttribute(ANode, 'fx', True, LText) then
    LFx := GradientValue(ANode, 'fx', 0.5, LUserSpace, ReferenceWidth)
  else
    LFx := LCx;
  if ResolveGradientAttribute(ANode, 'fy', True, LText) then
    LFy := GradientValue(ANode, 'fy', 0.5, LUserSpace, ReferenceHeight)
  else
    LFy := LCy;
  LDistance := Hypot(LFx - LCx, LFy - LCy);
  if LDistance > LR * 0.98 then
  begin
    LFx := LCx + (LFx - LCx) * LR * 0.98 / LDistance;
    LFy := LCy + (LFy - LCy) * LR * 0.98 / LDistance;
  end;
  LMatrix := GradientMatrix(ANode, LUserSpace, LBounds);
  if not LMatrix.Invert(LInverse) then
    Exit(SolidLastStop(AStops, AFactor));
  AEllipse := TGPGraphicsPath.Create;
  AEllipse.AddEllipse(Single(LCx - LR), Single(LCy - LR), Single(LR * 2), Single(LR * 2));
  LMatrixObject := LMatrix.ToMatrix;
  try
    AEllipse.Transform(LMatrixObject);
  finally
    LMatrixObject.Free;
  end;
  LMatrix.Apply(LFx, LFy, LFocalX, LFocalY);
  LLast := AStops.Count - 1;
  LCount := AStops.Count;
  if AStops[LLast].Offset < 1 then
    Inc(LCount);
  if AStops[0].Offset > 0 then
    Inc(LCount);
  SetLength(LColors, LCount);
  SetLength(LPositions, LCount);
  LIndex := 0;
  if AStops[LLast].Offset < 1 then
  begin
    LColors[LIndex] := ColorWithAlpha(AStops[LLast].Color, AFactor);
    LPositions[LIndex] := 0;
    Inc(LIndex);
  end;
  for I := LLast downto 0 do
  begin
    LColors[LIndex] := ColorWithAlpha(AStops[I].Color, AFactor);
    LPositions[LIndex] := Single(1 - AStops[I].Offset);
    if (LIndex > 0) and (LPositions[LIndex] <= LPositions[LIndex - 1]) then
      LPositions[LIndex] := Min(1, LPositions[LIndex - 1] + 0.00001);
    Inc(LIndex);
  end;
  if AStops[0].Offset > 0 then
  begin
    LColors[LIndex] := ColorWithAlpha(AStops[0].Color, AFactor);
    LPositions[LIndex] := 1;
  end;
  LPositions[0] := 0;
  LPositions[LCount - 1] := 1;
  Result := TGPPathGradientBrush.Create(AEllipse);
  TGPPathGradientBrush(Result).SetCenterPoint(MakePoint(Single(LFocalX), Single(LFocalY)));
  TGPPathGradientBrush(Result).SetCenterColor(ColorWithAlpha(AStops[0].Color, AFactor));
  LSurround := AOuter;
  LSurroundCount := 1;
  TGPPathGradientBrush(Result).SetSurroundColors(@LSurround, LSurroundCount);
  TGPPathGradientBrush(Result).SetInterpolationColors(@LColors[0], @LPositions[0], LCount);
end;

procedure TThemedSvgRenderer.FillSolid(const APath: TGPGraphicsPath; const AColor: TThemeColor;
  const AFactor: Double);
var
  LBrush: TGPSolidBrush;
begin
  LBrush := TGPSolidBrush.Create(ColorWithAlpha(AColor, AFactor));
  try
    FGraphics.FillPath(LBrush, APath);
  finally
    LBrush.Free;
  end;
end;

function TThemedSvgRenderer.FillPaint(const APath: TGPGraphicsPath; const APaint: TThemedSvgPaint;
  const AFactor: Double; const AState: TState): Boolean;
var
  LNode: TThemedSvgNode;
  LStops: TList<TStop>;
  LBrush: TGPBrush;
  LEllipse: TGPGraphicsPath;
  LOuter: TGPColor;
  LSaved: GraphicsState;
  LOuterBrush: TGPSolidBrush;
begin
  Result := False;
  case APaint.Kind of
    TThemedSvgPaintKind.Color:
      begin
        FillSolid(APath, APaint.Color, AFactor);
        Result := True;
      end;
    TThemedSvgPaintKind.Reference:
      begin
        LNode := FDocument.FindById(APaint.ReferenceId);
        if (LNode = nil) or not ((LNode.Name = 'linearGradient') or (LNode.Name = 'radialGradient')) then
          Exit;
        LStops := TList<TStop>.Create;
        try
          CollectStops(LNode, LStops, 0, AState);
          if LStops.Count = 0 then
            Exit;
          if LStops.Count = 1 then
          begin
            FillSolid(APath, LStops[0].Color, AFactor);
            Exit(True);
          end;
          if LNode.Name = 'linearGradient' then
          begin
            LBrush := CreateLinearBrush(LNode, LStops, AFactor, APath);
            try
              FGraphics.FillPath(LBrush, APath);
            finally
              LBrush.Free;
            end;
            Result := True;
          end
          else
          begin
            LBrush := CreateRadialBrush(LNode, LStops, AFactor, APath, LEllipse, LOuter);
            try
              if LEllipse = nil then
                FGraphics.FillPath(LBrush, APath)
              else
              begin
                LSaved := FGraphics.Save;
                try
                  FGraphics.SetClip(LEllipse, CombineModeIntersect);
                  FGraphics.FillPath(LBrush, APath);
                finally
                  FGraphics.Restore(LSaved);
                end;
                LOuterBrush := TGPSolidBrush.Create(LOuter);
                try
                  LSaved := FGraphics.Save;
                  try
                    FGraphics.SetClip(LEllipse, CombineModeExclude);
                    FGraphics.FillPath(LOuterBrush, APath);
                  finally
                    FGraphics.Restore(LSaved);
                  end;
                finally
                  LOuterBrush.Free;
                end;
              end;
            finally
              LEllipse.Free;
              LBrush.Free;
            end;
            Result := True;
          end;
        finally
          LStops.Free;
        end;
      end;
  end;
end;

function TThemedSvgRenderer.EffectiveFill(const AState: TState): TThemedSvgPaint;
begin
  Result := AState.Fill;
  if (Result.Kind <> TThemedSvgPaintKind.None) and
    (FOptions.ForceCurrentColor or FOptions.CurrentColorOverridesFill) then
    Result := TThemedSvgPaint.FromColor(FCurrentColor);
end;

function TThemedSvgRenderer.EffectiveStroke(const AState: TState): TThemedSvgPaint;
begin
  Result := AState.Stroke;
  if (Result.Kind <> TThemedSvgPaintKind.None) and
    (FOptions.ForceCurrentColor or FOptions.CurrentColorOverridesStroke) then
    Result := TThemedSvgPaint.FromColor(FCurrentColor);
end;

function TThemedSvgRenderer.CreatePen(const AState: TState; const AColor: TThemeColor): TGPPen;
var
  LDashes: TArray<Double>;
  LPattern: array of Single;
  I, LCount: Integer;
  LSum: Double;
begin
  Result := TGPPen.Create(ColorWithAlpha(AColor, AState.StrokeOpacity * AState.Opacity), Single(AState.StrokeWidth));
  if AState.LineCap = 'round' then
  begin
    Result.SetStartCap(LineCapRound);
    Result.SetEndCap(LineCapRound);
    Result.SetDashCap(DashCapRound);
  end
  else if AState.LineCap = 'square' then
  begin
    Result.SetStartCap(LineCapSquare);
    Result.SetEndCap(LineCapSquare);
  end;
  if AState.LineJoin = 'round' then
    Result.SetLineJoin(LineJoinRound)
  else if AState.LineJoin = 'bevel' then
    Result.SetLineJoin(LineJoinBevel)
  else
  begin
    Result.SetLineJoin(LineJoinMiter);
    Result.SetMiterLimit(Single(AState.MiterLimit));
  end;
  if (AState.Dash <> '') and not SameText(AState.Dash, 'none') and (AState.StrokeWidth > 0) then
  begin
    LDashes := TThemedSvgValues.SplitNumbers(AState.Dash);
    LSum := 0;
    for I := 0 to High(LDashes) do
      LSum := LSum + LDashes[I];
    if (Length(LDashes) > 0) and (LSum > 0) then
    begin
      LCount := Length(LDashes);
      if Odd(LCount) then
        LCount := LCount * 2;
      SetLength(LPattern, LCount);
      for I := 0 to LCount - 1 do
        LPattern[I] := Single(ClampValue(LDashes[I mod Length(LDashes)] / AState.StrokeWidth, 0.01, 1.0E9));
      Result.SetDashPattern(@LPattern[0], LCount);
      Result.SetDashOffset(Single(AState.DashOffset / AState.StrokeWidth));
    end;
  end;
end;

procedure TThemedSvgRenderer.DrawShape(const APath: TGPGraphicsPath; const AState: TState);
var
  LBounds: TGPRectF;
  LFill, LStroke: TThemedSvgPaint;
  LPen: TGPPen;
  LWide: TGPGraphicsPath;
  LFactor: Double;
begin
  if AState.Opacity <= 0 then
    Exit;
  APath.GetBounds(LBounds);
  if (LBounds.Width <= 0.0001) and (LBounds.Height <= 0.0001) then
    Exit;
  LFill := EffectiveFill(AState);
  if LFill.Kind in [TThemedSvgPaintKind.Color, TThemedSvgPaintKind.Reference] then
  begin
    LFactor := AState.FillOpacity * AState.Opacity;
    if not FillPaint(APath, LFill, LFactor, AState) and LFill.HasFallback then
      FillSolid(APath, LFill.FallbackColor, LFactor);
  end;
  LStroke := EffectiveStroke(AState);
  if not (LStroke.Kind in [TThemedSvgPaintKind.Color, TThemedSvgPaintKind.Reference]) or
    (AState.StrokeWidth <= 0) then
    Exit;
  if LStroke.Kind = TThemedSvgPaintKind.Color then
  begin
    LPen := CreatePen(AState, LStroke.Color);
    try
      FGraphics.DrawPath(LPen, APath);
    finally
      LPen.Free;
    end;
  end
  else
  begin
    LFactor := AState.StrokeOpacity * AState.Opacity;
    LPen := CreatePen(AState, TThemeColor($FF000000));
    try
      LWide := APath.Clone;
      try
        LWide.Widen(LPen);
        if not FillPaint(LWide, LStroke, LFactor, AState) and LStroke.HasFallback then
          FillSolid(LWide, LStroke.FallbackColor, LFactor);
      finally
        LWide.Free;
      end;
    finally
      LPen.Free;
    end;
  end;
end;

end.
