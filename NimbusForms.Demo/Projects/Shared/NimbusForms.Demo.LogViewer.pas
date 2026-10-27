{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.LogViewer;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  System.TypInfo,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  System.Types,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Imaging.jpeg,
  System.UITypes,
  System.Actions,
  NimbusForms.Theming.Types,
  NimbusForms.Controls.LogViewer.Types,
  NimbusForms.Controls.LogViewer.Model,
  NimbusForms.Controls.LogViewer,
  NimbusForms.Rendering.LogViewer,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.TabControl,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Demo.Strings;

type
  TLogViewerDemo = class(TThemedPanel)
  private
    FViewer: TThemedLogViewer;
    FTimer: TTimer;
    FStatus: TThemedLabel;
    FBuilding, FFileMode, FCustomColors, FCustomDraw: Boolean;
    FTick: Integer;
    FMonitorPath: string;
    procedure Build;
    procedure AddSamples;
    procedure LogMarkerClick(Sender: TObject; ALine: TNimbusLogLine; const ASourceIndex, AVisibleIndex: Integer);
    procedure Command(Sender: TObject);
    procedure Tick(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure Error(Sender: TObject; const AMessage: string);
    procedure RowColors(Sender: TObject; const AInfo: TNimbusLogRowInfo; var ABackColor, AForeColor: TThemeColor);
    procedure DrawRow(Sender: TObject; const ACanvas: INimbusRenderCanvas; const AInfo: TNimbusLogRowInfo; var AHandled: Boolean);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;



implementation

constructor TLogViewerDemo.Create(AOwner: TComponent);
begin inherited; Align := alClient; end;

destructor TLogViewerDemo.Destroy;
begin
  if FTimer <> nil then begin FTimer.Enabled := False; FTimer.OnTimer := nil; end;
  inherited;
end;

procedure TLogViewerDemo.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent = nil) or (FViewer <> nil) or FBuilding or (csDestroying in ComponentState) then Exit;
  FBuilding := True; try Build; finally FBuilding := False; end;
end;

procedure TLogViewerDemo.Build;
const Captions: array[0..7] of string = ('Add samples', 'Live feed', 'File monitor feed', 'Color message',
  'Token colors', 'Custom row colors', 'Custom draw row', 'Add 10k lines');
var Header: TThemedPanel; B: TThemedButton; I: Integer;
begin
  Header := TThemedPanel.Create(Self); Header.Parent := Self; Header.Align := alTop; Header.Height := 78;
  for I := 0 to High(Captions) do
  begin
    B := TThemedButton.Create(Self); B.Parent := Header;
    B.SetBounds(12 + (I mod 4) * 170, 6 + (I div 4) * 34, 162, 28);
    B.Caption := Captions[I]; B.Tag := I; B.OnClick := Command;
  end;
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom;
  FStatus.AutoSize := False; FStatus.Height := 28;
  FViewer := TThemedLogViewer.Create(Self); FViewer.Parent := Self; FViewer.Align := alClient;
  FViewer.OnDataChanged := Changed; FViewer.OnViewChanged := Changed;
  FViewer.OnMarkerClick := LogMarkerClick;
  FViewer.OnError := Error; FViewer.OnRowColors := RowColors; FViewer.OnDrawRow := DrawRow;
  FTimer := TTimer.Create(Self); FTimer.Enabled := False; FTimer.Interval := 350; FTimer.OnTimer := Tick;
  AddSamples;
end;

procedure TLogViewerDemo.AddSamples;
const Samples: array[0..11] of string = (
  '2026-10-14 09:12:03.123 [DEBUG] Worker (id=42) started args={"mode":"fast","retries":3}',
  '2026-10-14T09:12:04.005Z [dbg] cache key="user:123" hit=true duration=0.125',
  '14.10.2026 09:12:05 [Info] Connected to service [api] address="localhost:8080"',
  '09:12:06.007 Information Request completed status=200 size=1024 bytes',
  '2026-10-14 09:12:07 [warn] Slow response took 1250.75 ms (threshold=500)',
  '2026-10-14 09:12:08 [WARNING] Disk capacity [data] remaining=12.5%',
  '2026-10-14 09:12:09 [err] Could not read file "C:\Logs\sample.log" code=0x80070005',
  '2026-10-14 09:12:10 ERROR Operation failed details={retry:2,timeout:1.5e3}',
  '2026-10-14 09:12:11 TRACE Heartbeat from process (pid=1234)',
  '2026-10-14 09:12:12 SUCCESS Saved configuration filename=''settings.json''',
  '2026-10-14 09:12:13 CRITICAL Connection pool exhausted limit=128',
  'Continuation line without a level: {} [] () decimals=-12.75 scientific=6.02e23'
);
var S: string;
begin
  FViewer.Model.BeginUpdate;
  try
    for S in Samples do FViewer.AppendLog(S);
    FViewer.AppendLog('Information Unicode sample: Latin=' + Char($00E4) + Char($00F6) + Char($00FC) +
      ' Greek=' + Char($03A9) + ' CJK=' + Char($4E2D) + Char($6587) + ' Emoji=' + Char($D83D) + Char($DE00));
  finally FViewer.Model.EndUpdate; end;
end;

procedure TLogViewerDemo.Tick(Sender: TObject);
const Levels: array[0..5] of string = ('DEBUG', 'Information', 'warn', 'ERROR', 'TRACE', 'SUCCESS');
var S: string; Bytes: TBytes; Stream: TFileStream;
begin
  Inc(FTick);
  S := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + Format(' [%s] Live entry [worker-%d] value=%.3f message="sample %d"',
    [Levels[FTick mod 6], FTick mod 4, FTick / 7.0, FTick]);
  if FTick mod 10 = 0 then S := S + ' Heartbeat';
  if FFileMode then
  begin
    try
      Bytes := TEncoding.UTF8.GetBytes(S + sLineBreak);
      Stream := TFileStream.Create(FMonitorPath, fmOpenReadWrite or fmShareDenyNone);
      try Stream.Seek(0, soEnd); if Length(Bytes) > 0 then Stream.WriteBuffer(Bytes[0], Length(Bytes)); finally Stream.Free; end;
    except on E: Exception do begin FTimer.Enabled := False; Error(Self, E.Message); end; end;
  end
  else FViewer.QueueLog(S);
end;

procedure TLogViewerDemo.Command(Sender: TObject);
var I: Integer; G: TGUID; Level: string;
begin
  case TComponent(Sender).Tag of
    0: AddSamples;
    1:
      begin
        if FFileMode then begin FViewer.StopMonitoring; FFileMode := False; FTimer.Enabled := False; end;
        FTimer.Enabled := not FTimer.Enabled;
      end;
    2:
      if FFileMode then
      begin FTimer.Enabled := False; FViewer.StopMonitoring; FFileMode := False; end
      else
      begin
        if FMonitorPath = '' then
        begin
          CreateGUID(G);
          FMonitorPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'logviewer-demo-' + GUIDToString(G) + '.log');
          TFile.WriteAllText(FMonitorPath, 'Information Demo file stream initialized' + sLineBreak, TEncoding.UTF8);
        end;
        FViewer.StartMonitoring(FMonitorPath, True);
        FFileMode := True; FTimer.Enabled := True;
        FStatus.Caption := 'Monitoring a growing UTF-8 file: ' + FMonitorPath;
      end;
    3: FViewer.Highlights.ColorizeMessageText := not FViewer.Highlights.ColorizeMessageText;
    4: if FViewer.Highlights.Kinds = [] then
        FViewer.Highlights.Kinds := [nltkDateTime, nltkLevel, nltkNumber, nltkString, nltkParenthesis, nltkBracket, nltkBrace]
      else FViewer.Highlights.Kinds := [];
    5: begin FCustomColors := not FCustomColors; FViewer.RefreshView; end;
    6: begin FCustomDraw := not FCustomDraw; FViewer.RefreshView; end;
    7:
      begin
        FViewer.Model.BeginUpdate;
        try
          for I := 1 to 10000 do
          begin
            if I mod 997 = 0 then Level := 'CRITICAL'
            else if I mod 113 = 0 then Level := 'ERROR'
            else if I mod 37 = 0 then Level := 'WARNING'
            else Level := 'DEBUG';
            FViewer.AppendLog(Format('2026-10-14 10:00:00 [%s] Batch line %d (worker=42) amount=%.2f', [Level, I, I / 100.0]));
          end;
        finally FViewer.Model.EndUpdate; end;
      end;
  end;
end;

procedure TLogViewerDemo.Changed(Sender: TObject);
begin
  if csDestroying in ComponentState then Exit;
  FStatus.Caption := Format('Data/view event: %d records, %d visible, %d matches. Ctrl+F search, F3 next, Ctrl+C copy.',
    [FViewer.Model.Count, FViewer.VisibleLineCount, FViewer.SearchMatchCount]);
end;

procedure TLogViewerDemo.Error(Sender: TObject; const AMessage: string);
begin FStatus.Caption := 'Log error: ' + AMessage; end;

procedure TLogViewerDemo.LogMarkerClick(Sender: TObject; ALine: TNimbusLogLine; const ASourceIndex, AVisibleIndex: Integer);
begin
  FStatus.Caption := Format('Scrollbar marker click: source row %d, visible row %d, ID %s: %s',
    [ASourceIndex + 1, AVisibleIndex + 1, UIntToStr(ALine.ID), Copy(ALine.Text, 1, 120)]);
end;

procedure TLogViewerDemo.RowColors(Sender: TObject; const AInfo: TNimbusLogRowInfo; var ABackColor, AForeColor: TThemeColor);
begin
  if FCustomColors and (AInfo.Line.Level in [nllError, nllFatal]) then
    ABackColor := NimbusBlendColor(ABackColor, NimbusDangerColor, 35);
end;

procedure TLogViewerDemo.DrawRow(Sender: TObject; const ACanvas: INimbusRenderCanvas; const AInfo: TNimbusLogRowInfo; var AHandled: Boolean);
begin
  if FCustomDraw and (Pos('Heartbeat', AInfo.Line.Text) > 0) then
  begin
    TThemedLogViewerRenderer.DrawTaggedRow(ACanvas, FViewer.Font, AInfo, 'HEARTBEAT', NimbusSuccessColor);
    AHandled := True;
  end;
end;

procedure AddLogViewerDemo(const ATabs: TPageControl);
var Page: TTabSheet; Demo: TLogViewerDemo;
begin
  Page := TTabSheet.Create(ATabs); Page.PageControl := ATabs; Page.Caption := 'LogViewer';
  Demo := TLogViewerDemo.Create(Page); Demo.Parent := Page;
  if ATabs is TThemedTabControl then TThemedTabControl(ATabs).SetTabClosable(Page, False);
end;


end.
