program SvgRenderTest;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  System.SysUtils,
  System.Types,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  NimbusForms.Theming.Types in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Grid.VisualStrings in '..\src\NimbusForms.Grid.VisualStrings.pas',
  NimbusForms.Grid.SvgXml in '..\src\NimbusForms.Grid.SvgXml.pas',
  NimbusForms.Grid.SvgValues in '..\src\NimbusForms.Grid.SvgValues.pas',
  NimbusForms.Grid.SvgPath in '..\src\NimbusForms.Grid.SvgPath.pas',
  NimbusForms.Grid.SvgDocument in '..\src\NimbusForms.Grid.SvgDocument.pas',
  NimbusForms.Grid.SvgRenderer in '..\src\NimbusForms.Grid.SvgRenderer.pas',
  NimbusForms.Grid.SvgIconCache in '..\src\NimbusForms.Grid.SvgIconCache.pas';

type
  SvgRenderTestTexts = class sealed
  public
    const
      FormTitle = 'SVG renderer test';
      RowCached = 'Cached bitmap, ForceCurrentColor, opacity 0.6';
      SampleCount = 14;
      CellSize = 120;
      Names: array[0..SampleCount - 1] of string = (
        'linear bbox',
        'linear gradientTransform',
        'linear userSpace',
        'linear reflect',
        'linear repeat',
        'linear href stops',
        'radial centered',
        'radial focal',
        'radial transform',
        'radial userSpace',
        'stroke gradient',
        'dash + offset',
        'text anchors',
        'currentColor + opacity');
      Svgs: array[0..SampleCount - 1] of string = (
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="g"><stop offset="0" stop-color="#e11"/><stop offset="1" stop-color="#11e"/></linearGradient></defs><rect x="10" y="10" width="80" height="80" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="g" gradientTransform="rotate(45 .5 .5)"><stop offset="0" stop-color="#fc0"/><stop offset=".5" stop-color="#0c6"/><stop offset="1" stop-color="#06c"/></linearGradient></defs><rect x="10" y="10" width="80" height="80" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="g" gradientUnits="userSpaceOnUse" x1="20" y1="20" x2="80" y2="80"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#c0c"/></linearGradient></defs><rect x="0" y="0" width="100" height="100" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="g" x1=".4" x2=".6" spreadMethod="reflect"><stop offset="0" stop-color="#e11"/><stop offset="1" stop-color="#ff0"/></linearGradient></defs><rect x="5" y="5" width="90" height="90" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="g" x1=".4" x2=".6" spreadMethod="repeat"><stop offset="0" stop-color="#0a5"/><stop offset="1" stop-color="#fff"/></linearGradient></defs><rect x="5" y="5" width="90" height="90" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="base"><stop offset="0" stop-color="#222"/><stop offset="1" stop-color="#9cf"/></linearGradient><linearGradient id="g" href="#base" x1="0" y1="0" x2="0" y2="1"/></defs><circle cx="50" cy="50" r="40" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><radialGradient id="g"><stop offset="0" stop-color="#fff"/><stop offset=".6" stop-color="#4af"/><stop offset="1" stop-color="#013"/></radialGradient></defs><rect x="5" y="5" width="90" height="90" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><radialGradient id="g" cx=".5" cy=".5" r=".5" fx=".25" fy=".25"><stop offset="0" stop-color="#ff0"/><stop offset="1" stop-color="#c00"/></radialGradient></defs><circle cx="50" cy="50" r="45" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><radialGradient id="g" gradientTransform="scale(1 .5) translate(0 .5)"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#0a8"/></radialGradient></defs><rect x="5" y="5" width="90" height="90" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><radialGradient id="g" gradientUnits="userSpaceOnUse" cx="30" cy="30" r="40"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#808"/></radialGradient></defs><rect x="5" y="5" width="90" height="90" fill="url(#g)"/></svg>',
        '<svg viewBox="0 0 100 100"><defs><linearGradient id="g"><stop offset="0" stop-color="#e11"/><stop offset="1" stop-color="#11e"/></linearGradient></defs><path d="M15 80 L50 15 L85 80 Z" fill="none" stroke="url(#g)" stroke-width="10" stroke-linejoin="round"/></svg>',
        '<svg viewBox="0 0 100 100"><path d="M10 30 H90" stroke="#333" stroke-width="6" stroke-dasharray="12 6"/><path d="M10 60 H90" stroke="#333" stroke-width="6" stroke-dasharray="12 6" stroke-dashoffset="9"/><path d="M10 85 H90" stroke="#e11" stroke-width="6" stroke-linecap="round" stroke-dasharray="1 12"/></svg>',
        '<svg viewBox="0 0 100 100"><path d="M50 0 V100" stroke="#999" stroke-width="1"/><text x="50" y="25" font-size="14" text-anchor="middle" fill="#111">middle</text><text x="50" y="55" font-size="14" text-anchor="end" font-weight="bold" fill="#e11">end</text><text x="50" y="85" font-size="14" font-style="italic" fill="#11e">start</text></svg>',
        '<svg viewBox="0 0 100 100" color="#e11"><g opacity=".5"><circle cx="38" cy="50" r="30" fill="currentColor"/><circle cx="62" cy="50" r="30" fill="#11e"/></g><rect x="10" y="10" width="80" height="80" fill="none" stroke="currentColor" stroke-width="3"/></svg>');
  end;

  TSvgTestForm = class(TForm)
  private
    FCache: TThemedSvgIconCache;
  protected
    procedure Paint; override;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
  end;

constructor TSvgTestForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := SvgRenderTestTexts.FormTitle;
  Color := clWhite;
  DoubleBuffered := True;
  Position := poScreenCenter;
  ClientWidth := (SvgRenderTestTexts.SampleCount div 2) * (SvgRenderTestTexts.CellSize + 8) + 8;
  ClientHeight := 2 * (SvgRenderTestTexts.CellSize + 64) + 56;
  FCache := TThemedSvgIconCache.Create;
end;

destructor TSvgTestForm.Destroy;
begin
  FCache.Free;
  inherited Destroy;
end;

procedure TSvgTestForm.Paint;
var
  LGraphics: TGPGraphics;
  LDocument: TThemedSvgDocument;
  LBitmap: TGPBitmap;
  LOptions: TThemedSvgRenderOptions;
  LRow, LColumn, LIndex, LX, LY, LPerRow: Integer;
begin
  inherited Paint;
  LPerRow := SvgRenderTestTexts.SampleCount div 2;
  LOptions := TThemedSvgRenderOptions.Standard;
  LOptions.ForceCurrentColor := True;
  LOptions.DefaultOpacity := 0.6;
  LGraphics := TGPGraphics.Create(Canvas.Handle);
  try
    for LIndex := 0 to SvgRenderTestTexts.SampleCount - 1 do
    begin
      LRow := LIndex div LPerRow;
      LColumn := LIndex mod LPerRow;
      LX := 8 + LColumn * (SvgRenderTestTexts.CellSize + 8);
      LY := 24 + LRow * (SvgRenderTestTexts.CellSize + 64);
      LDocument := FCache.GetDocumentFromString(SvgRenderTestTexts.Names[LIndex],
        SvgRenderTestTexts.Svgs[LIndex]);
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := clBlack;
      Canvas.TextOut(LX, LY - 18, SvgRenderTestTexts.Names[LIndex]);
      Canvas.Pen.Color := $00C0C0C0;
      Canvas.Rectangle(LX - 1, LY - 1, LX + SvgRenderTestTexts.CellSize + 1, LY + SvgRenderTestTexts.CellSize + 1);
      if LDocument = nil then
      begin
        Canvas.TextOut(LX + 4, LY + 4, FCache.LastError);
        Continue;
      end;
      TThemedSvgRenderer.Render(LDocument, LGraphics, Rect(LX, LY, LX + SvgRenderTestTexts.CellSize,
        LY + SvgRenderTestTexts.CellSize), TThemeColor($FF202020));
      LBitmap := FCache.GetBitmap(SvgRenderTestTexts.Names[LIndex], LDocument,
        TSize.Create(SvgRenderTestTexts.CellSize div 2, SvgRenderTestTexts.CellSize div 2), TThemeColor($FF2060C0),
        1.0, LOptions);
      if LBitmap <> nil then
        LGraphics.DrawImage(LBitmap, LX, LY + SvgRenderTestTexts.CellSize + 6);
    end;
  finally
    LGraphics.Free;
  end;
  Canvas.TextOut(8, ClientHeight - 18, SvgRenderTestTexts.RowCached);
end;

var
  LForm: TSvgTestForm;
begin
  Application.Initialize;
  Application.Title := SvgRenderTestTexts.FormTitle;
  LForm := TSvgTestForm.CreateNew(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end.
