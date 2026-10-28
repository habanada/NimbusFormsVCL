program NimbusTextLayoutTests;

{$APPTYPE CONSOLE}

uses Winapi.Windows, System.SysUtils, System.Types, System.Math, System.UITypes,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.Menus,
  NimbusForms.Rendering.Canvas, NimbusForms.Rendering.Types,
  NimbusForms.Rendering.PopupMenu, NimbusForms.Controls.ThemedLabel;

procedure Check(const Value: Boolean; const MessageText: string);
begin
  if not Value then raise Exception.Create(MessageText);
end;

function SamePixels(const A, B: TBitmap): Boolean;
var Y: Integer;
begin
  Result := (A.Width = B.Width) and (A.Height = B.Height);
  if not Result then Exit;
  for Y := 0 to A.Height - 1 do
    if not CompareMem(A.ScanLine[Y], B.ScanLine[Y], A.Width * 4) then Exit(False);
end;

procedure RenderText(const Bitmap: TBitmap; const Font: TFont; const Text: string;
  const Bounds: TRect; const Flags: TNimbusTextFlags);
var Canvas: INimbusRenderCanvas;
begin
  Canvas := TNimbusRenderCanvas.Create;
  Canvas.BeginRender(Bitmap.Canvas);
  try
    Canvas.Clear($FFFFFFFF, Rect(0, 0, Bitmap.Width, Bitmap.Height));
    Canvas.DrawText(Text, Font, $FF000000, Bounds, Flags);
  finally
    Canvas.EndRender;
  end;
end;

procedure TextChecks;
const Captions: array[0..5] of string = ('mycaption', 'Financial overview',
  '&File', 'Save && Close', 'Italic overhang fj', 'Chart legend 123.45');
  PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var A, B: TBitmap; Font: TFont; Canvas: INimbusRenderCanvas;
  Size, Trimmed: TSize; Bounds: TRect; Flags: TNimbusTextFlags;
  Caption: string; PPI, Style, Alignment: Integer;
begin
  A := TBitmap.Create;
  B := TBitmap.Create;
  Font := TFont.Create;
  try
    A.PixelFormat := pf32bit; A.SetSize(1000, 100);
    B.PixelFormat := pf32bit; B.SetSize(1000, 100);
    Font.Name := 'Segoe UI';
    Canvas := TNimbusRenderCanvas.Create;
    for PPI in PPIs do
    begin
      Font.PixelsPerInch := PPI;
      Font.Height := -MulDiv(12, PPI, 96);
      for Style := 0 to 2 do
      begin
        case Style of
          0: Font.Style := [];
          1: Font.Style := [fsBold];
          2: Font.Style := [fsItalic];
        end;
        for Caption in Captions do
        begin
          Canvas.BeginRender(A.Canvas);
          try
            Size := Canvas.MeasureText(Caption, Font, 0, [ntfSingleLine]);
            Trimmed := Canvas.MeasureText(Caption, Font, Max(1, Size.cx div 2), [ntfSingleLine]);
            Bounds := Rect(0, 0, Trimmed.cx, Trimmed.cy);
            Trimmed := Canvas.MeasureText(Caption, Font, Max(1, Size.cx div 2), [ntfSingleLine, ntfEndEllipsis]);
            Check((Trimmed.cx = Bounds.Width) and (Trimmed.cy = Bounds.Height), 'ellipsis must not change measured size');
          finally
            Canvas.EndRender;
          end;
          for Alignment := 0 to 2 do
          begin
            Flags := [ntfSingleLine, ntfVCenter];
            if Alignment = 1 then Include(Flags, ntfCenter);
            if Alignment = 2 then Include(Flags, ntfRight);
            Bounds := Rect(4, 4, 4 + Size.cx, 4 + Size.cy);
            RenderText(A, Font, Caption, Bounds, Flags);
            Include(Flags, ntfEndEllipsis);
            RenderText(B, Font, Caption, Bounds, Flags);
            Check(SamePixels(A, B), 'measured text must fit without ellipsis: ' + Caption);
          end;
        end;
      end;
    end;
    Bounds := Rect(4, 4, 60, 60);
    RenderText(A, Font, 'A caption much wider than its bounds', Bounds, [ntfSingleLine, ntfNoPrefix]);
    RenderText(B, Font, 'A caption much wider than its bounds', Bounds, [ntfSingleLine, ntfNoPrefix, ntfEndEllipsis]);
    Check(not SamePixels(A, B), 'constrained text must still use ellipsis');
    Canvas.BeginRender(A.Canvas);
    try
      Size := Canvas.MeasureText('A wrapped caption with several words', Font, 100, [ntfWordWrap, ntfNoPrefix]);
      Trimmed := Canvas.MeasureText('A wrapped caption with several words', Font, 100, [ntfWordWrap, ntfNoPrefix, ntfEndEllipsis]);
      Check((Size.cx = Trimmed.cx) and (Size.cy = Trimmed.cy), 'wrapped measurement must ignore ellipsis');
    finally
      Canvas.EndRender;
    end;
  finally
    Canvas := nil;
    Font.Free; B.Free; A.Free;
  end;
end;

procedure LabelChecks;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var LabelControl: TThemedLabel; Bitmap: TBitmap; Canvas: INimbusRenderCanvas;
  Size: TSize; PPI, OriginalWidth, RightEdge: Integer;
  procedure CheckSize;
  var Flags: TNimbusTextFlags; MaxWidth: Integer;
  begin
    Flags := [];
    MaxWidth := 0;
    if LabelControl.WordWrap then
    begin
      Include(Flags, ntfWordWrap);
      MaxWidth := LabelControl.Width;
    end
    else Include(Flags, ntfSingleLine);
    if not LabelControl.ShowAccelChar then Include(Flags, ntfNoPrefix);
    Canvas.BeginRender(Bitmap.Canvas);
    try
      Size := Canvas.MeasureText(LabelControl.Caption, LabelControl.Font, MaxWidth, Flags);
    finally
      Canvas.EndRender;
    end;
    Check(LabelControl.Width >= Size.cx, 'AutoSize width must cover renderer width');
    Check(LabelControl.Height >= Size.cy, 'AutoSize height must cover renderer height');
  end;
begin
  LabelControl := TThemedLabel.Create(nil);
  Bitmap := TBitmap.Create;
  try
    Bitmap.SetSize(1, 1);
    Canvas := TNimbusRenderCanvas.Create;
    LabelControl.Font.Name := 'Segoe UI';
    for PPI in PPIs do
    begin
      LabelControl.Font.PixelsPerInch := PPI;
      LabelControl.Font.Height := -MulDiv(12, PPI, 96);
      LabelControl.Caption := 'mycaption';
      LabelControl.WordWrap := False;
      LabelControl.Alignment := taLeftJustify;
      LabelControl.ShowAccelChar := True;
      CheckSize;
      OriginalWidth := LabelControl.Width;
      LabelControl.Caption := 'mycaption much longer';
      Check(LabelControl.Width > OriginalWidth, 'caption change must grow AutoSize label');
      CheckSize;
      LabelControl.Alignment := taRightJustify;
      RightEdge := LabelControl.Left + LabelControl.Width;
      LabelControl.Caption := 'short';
      Check(LabelControl.Left + LabelControl.Width = RightEdge, 'right-aligned AutoSize must preserve right edge');
      CheckSize;
      LabelControl.Caption := '&File && chart';
      CheckSize;
      LabelControl.ShowAccelChar := False;
      CheckSize;
      LabelControl.Font.Style := [fsBold, fsItalic];
      CheckSize;
      LabelControl.Font.Style := [];
      LabelControl.AutoSize := False;
      LabelControl.Width := MulDiv(100, PPI, 96);
      LabelControl.WordWrap := True;
      LabelControl.Caption := 'A wrapped caption with several words for two or more lines';
      LabelControl.AutoSize := True;
      CheckSize;
    end;
  finally
    Canvas := nil;
    Bitmap.Free; LabelControl.Free;
  end;
end;

procedure MenuChecks;
var Bitmap: TBitmap; Font: TFont; Item: TMenuItem;
  Canvas: INimbusRenderCanvas; NormalWidth, NormalHeight, BoldWidth, BoldHeight: Integer;
begin
  Bitmap := TBitmap.Create; Font := TFont.Create; Item := TMenuItem.Create(nil);
  try
    Bitmap.SetSize(1, 1);
    Font.Name := 'Segoe UI'; Font.Height := -16;
    Item.Caption := 'MMMMMMMMMMMMMMMMMMMM';
    Item.ShortCut := ShortCut(Ord('S'), [ssCtrl]);
    Canvas := TNimbusRenderCanvas.Create;
    Canvas.BeginRender(Bitmap.Canvas);
    try
      TThemedPopupMenuRenderer.MeasureItem(Canvas, Font, Item, 96, NormalWidth, NormalHeight);
      Item.Default := True;
      TThemedPopupMenuRenderer.MeasureItem(Canvas, Font, Item, 96, BoldWidth, BoldHeight);
      Check(BoldWidth > NormalWidth, 'default menu caption must reserve bold width');
      Check(Font.Style = [], 'menu measurement must restore font style');
    finally
      Canvas.EndRender;
    end;
  finally
    Canvas := nil;
    Item.Free; Font.Free; Bitmap.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TextChecks;
    LabelChecks;
    MenuChecks;
    Writeln('Text layout regression checks passed');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
