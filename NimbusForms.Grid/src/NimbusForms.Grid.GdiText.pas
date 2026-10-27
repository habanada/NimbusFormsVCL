unit NimbusForms.Grid.GdiText;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Types,
  System.Math,
  Vcl.Graphics,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.RenderContext;

type
  TThemedGridGdiText = class
  public
    class function CreateFont(const AContext: TThemedGridRenderContext; const AFont: TFont): TGPFont; static;
    class procedure DrawText(const AContext: TThemedGridRenderContext; const AText: string;
      const AFont: TFont; const ABounds: TRect; const AColor: TThemeColor;
      const AAlignment: TThemedGridContentAlignment; const AEllipsis: Boolean); static;
    class function MeasureText(const AContext: TThemedGridRenderContext; const AText: string;
      const AFont: TFont): TSize; static;
  end;

implementation

class function TThemedGridGdiText.CreateFont(const AContext: TThemedGridRenderContext;
  const AFont: TFont): TGPFont;
begin
  Result := TGPFont.Create(AContext.DC, AFont.Handle);
end;

class procedure TThemedGridGdiText.DrawText(const AContext: TThemedGridRenderContext;
  const AText: string; const AFont: TFont; const ABounds: TRect; const AColor: TThemeColor;
  const AAlignment: TThemedGridContentAlignment; const AEllipsis: Boolean);
var
  LFont: TGPFont;
  LFormat: TGPStringFormat;
  LLayout: TGPRectF;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (AText = '') then
    Exit;
  LFont := CreateFont(AContext, AFont);
  LFormat := AContext.CreateStringFormat(AAlignment, AEllipsis);
  try
    LLayout := MakeRect(Single(ABounds.Left), Single(ABounds.Top),
      Single(ABounds.Width), Single(ABounds.Height));
    AContext.Graphics.DrawString(PChar(AText), Length(AText), LFont, LLayout, LFormat,
      TThemedGridGdiCache.Brush(AColor));
  finally
    LFormat.Free;
    LFont.Free;
  end;
end;

class function TThemedGridGdiText.MeasureText(const AContext: TThemedGridRenderContext;
  const AText: string; const AFont: TFont): TSize;
var
  LFont: TGPFont;
  LFormat: TGPStringFormat;
  LLayout, LBounding: TGPRectF;
begin
  Result := TSize.Create(0, 0);
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  LFont := CreateFont(AContext, AFont);
  LFormat := TGPStringFormat.Create;
  try
    LFormat.SetFormatFlags(StringFormatFlagsNoWrap);
    LLayout := MakeRect(0.0, 0.0, 100000.0, 100000.0);
    AContext.Graphics.MeasureString(PChar(AText), Length(AText), LFont, LLayout, LFormat, LBounding);
    Result := TSize.Create(Ceil(LBounding.Width), Ceil(LBounding.Height));
  finally
    LFormat.Free;
    LFont.Free;
  end;
end;

end.
