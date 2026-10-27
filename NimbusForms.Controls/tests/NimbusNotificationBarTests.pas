{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusNotificationBarTests;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Forms, Vcl.Graphics, Vcl.ActnList, Vcl.StdCtrls,
  NimbusForms.Controls.NotificationBar, NimbusForms.Controls.NotificationBar.Types,
  NimbusForms.Rendering.NotificationBar, NimbusForms.Rendering.Markdown, NimbusForms.Rendering.Markup,
  NimbusForms.Rendering.Canvas;

procedure Check(const Value: Boolean; const Text: string);
begin
  if not Value then raise Exception.Create(Text);
end;

type
  TInteractionBar = class(TThemedIdeNotificationBar)
  public
    function Views: TNimbusNotificationViews;
    procedure ClickAt(const P: TPoint);
  end;

  TInteractionObserver = class
  public
    NavigationCount, ActionCount, ExecutionCount, DismissCount: Integer;
    procedure Navigated(Sender: TObject; const AID: string; const AIndex, ACount: Integer);
    procedure ActionRequested(Sender: TObject; AMessage: TThemedIdeNotificationMessage; AAction: TThemedIdeNotificationAction);
    procedure Executed(Sender: TObject);
    procedure Dismissed(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
  end;

function TInteractionBar.Views: TNimbusNotificationViews;
var H: Integer; C: INimbusRenderCanvas; B: Vcl.Graphics.TBitmap;
begin
  B := Vcl.Graphics.TBitmap.Create;
  C := TNimbusRenderCanvas.Create;
  try
    B.SetSize(Width, Max(1, Height));
    C.BeginRender(B.Canvas);
    try
      H := TThemedIdeNotificationBarRenderer.Layout(C, Font, Messages, ClientWidth, CurrentPPI,
        MaxStackItems, CurrentMessageIndex, DisplayMode, CompactMode, Multiline, ShowCloseButton, Result);
      Check(H >= 0, 'Valid interaction layout height');
    finally C.EndRender; end;
  finally C := nil; B.Free; end;
end;

procedure TInteractionBar.ClickAt(const P: TPoint);
begin
  Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(P.X, P.Y));
  Perform(WM_LBUTTONUP, 0, MakeLParam(P.X, P.Y));
end;

procedure TInteractionObserver.Navigated(Sender: TObject; const AID: string; const AIndex, ACount: Integer);
begin
  Inc(NavigationCount);
end;

procedure TInteractionObserver.ActionRequested(Sender: TObject; AMessage: TThemedIdeNotificationMessage; AAction: TThemedIdeNotificationAction);
begin
  Inc(ActionCount);
end;

procedure TInteractionObserver.Executed(Sender: TObject);
begin
  Inc(ExecutionCount);
end;

procedure TInteractionObserver.Dismissed(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
begin
  Inc(DismissCount);
end;

procedure InteractionChecks;
var Form: TForm; Bar: TInteractionBar; Observer: TInteractionObserver;
  M: TThemedIdeNotificationMessage; V: TNimbusNotificationViews; FirstID: string;
begin
  Form := TForm.CreateNew(nil);
  Observer := TInteractionObserver.Create;
  try
    Form.ClientWidth := 640;
    Bar := TInteractionBar.Create(Form);
    Bar.Parent := Form;
    Bar.Width := 600;
    Bar.DisplayMode := nndCarousel;
    Bar.OnNavigation := Observer.Navigated;
    Bar.OnAction := Observer.ActionRequested;
    Bar.OnDismissed := Observer.Dismissed;
    M := Bar.ShowNotification('First message');
    FirstID := M.ID;
    M.Actions.Add.Text := 'Execute';
    M.Actions[0].OnClick := Observer.Executed;
    Bar.ShowNotification('Second message');
    Bar.Perform(WM_PAINT, 0, 0);
    V := Bar.Views;
    Bar.ClickAt(V[0].ActionBounds[0].CenterPoint);
    Check((Observer.ActionCount = 1) and (Observer.ExecutionCount = 1), 'Mouse release must execute the pressed action exactly once');
    V := Bar.Views;
    Bar.ClickAt(V[0].NextBounds.CenterPoint);
    Check((Observer.NavigationCount = 1) and (Bar.CurrentMessageID <> FirstID), 'Next arrow changes the current notification and emits navigation');
    V := Bar.Views;
    Bar.ClickAt(V[0].PreviousBounds.CenterPoint);
    Check((Observer.NavigationCount = 2) and (Bar.CurrentMessageID = FirstID), 'Previous arrow navigation');
    V := Bar.Views;
    Bar.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(V[0].CloseBounds.CenterPoint.X, V[0].CloseBounds.CenterPoint.Y));
    Bar.Perform(WM_CANCELMODE, 0, 0);
    Bar.Perform(WM_LBUTTONUP, 0, MakeLParam(V[0].CloseBounds.CenterPoint.X, V[0].CloseBounds.CenterPoint.Y));
    Check(Bar.Messages.Count = 2, 'Cancelled capture must not dismiss');
    Bar.ClickAt(V[0].CloseBounds.CenterPoint);
    Check((Bar.Messages.Count = 1) and (Observer.DismissCount = 1), 'Close button dismisses the pressed notification');
  finally Form.Free; Observer.Free; end;
end;

procedure MarkdownChecks;
var Spans: TArray<TThemedMarkupSpan>; Span: TThemedMarkupSpan; Text: string;
  Bold, Italic, Code, Link: Boolean;
begin
  Spans := TNimbusMarkdownParser.Parse('**bold** *italic* `a*b` [help](https://example.com) <b>literal</b>');
  Bold := False; Italic := False; Code := False; Link := False; Text := '';
  for Span in Spans do
  begin
    Bold := Bold or ((Span.Text = 'bold') and (tmseBold in Span.Style));
    Italic := Italic or ((Span.Text = 'italic') and (tmseItalic in Span.Style));
    Code := Code or ((Span.Text = 'a*b') and (Span.InlineKind = tmikCode));
    Link := Link or ((Span.Text = 'help') and (Span.LinkTarget = 'https://example.com'));
    Text := Text + Span.Text;
  end;
  Check(Bold and Italic and Code and Link, 'Markdown inline types');
  Check(Pos('<b>literal</b>', Text) > 0, 'Markdown must preserve raw tags as text');
  Spans := TNimbusMarkdownParser.Parse('escaped \*star\* and file_name');
  Text := ''; for Span in Spans do Text := Text + Span.Text;
  Check(Text = 'escaped *star* and file_name', 'Escapes and identifiers');
  Spans := TNimbusMarkdownParser.Parse('# Heading' + #10 + '- item');
  Check((Length(Spans) = 3) and (Spans[0].HeadingLevel = 1) and
    (Spans[1].Kind = tmskLineBreak), 'Heading and list line structure');
end;

procedure ModelChecks;
var Bar, CopyBar: TThemedIdeNotificationBar; M: TThemedIdeNotificationMessage;
  Action: TAction; ID: string;
begin
  Bar := TThemedIdeNotificationBar.Create(nil);
  CopyBar := TThemedIdeNotificationBar.Create(nil);
  Action := TAction.Create(nil);
  try
    M := Bar.ShowNotification('plain <b>text</b>', nnsWarning);
    ID := M.ID;
    M.Actions.Add.Action := Action;
    Action.Caption := 'Retry';
    Check(M.Actions[0].DisplayText = 'Retry', 'Native action caption');
    Action.Enabled := False;
    Check(not M.Actions[0].IsEnabled, 'Native action enabled state');
    Action.Visible := False;
    Check(not M.Actions[0].IsVisible, 'Native action visibility');
    Action.Visible := True;
    CopyBar.Messages.Assign(Bar.Messages);
    Check((CopyBar.Messages.Count = 1) and (CopyBar.Messages[0].Actions.Count = 1) and
      (CopyBar.Messages[0].Actions[0].DisplayText = 'Retry'), 'Collection assign including actions');
    FreeAndNil(Action);
    Check((M.Actions[0].Action = nil) and (CopyBar.Messages[0].Actions[0].Action = nil), 'Action free notification');
    Check(not Bar.HandleAllocated and not CopyBar.HandleAllocated, 'Data setup must not force a window handle');
    Check(Bar.Dismiss(M.ID) and (Bar.Messages.Count = 0), 'Dismiss ID must survive freeing its source message');
    Check(not Bar.Dismiss(ID), 'Repeated dismissal');
    Bar.ShowNotification('again', nnsSuccess, True);
    Bar.DismissAll;
    Check(Bar.Messages.Count = 0, 'Dismiss all');
  finally Action.Free; CopyBar.Free; Bar.Free; end;
end;

procedure CustomSpanChecks;
var
  Bitmap: Vcl.Graphics.TBitmap;
  Font: TFont;
  Canvas: INimbusRenderCanvas;
  Markup: TThemedMarkupRenderer;
  Size: TSize;

  procedure Prepare;
  begin
    Markup.PrepareLayout(Canvas, 400, True, 0, 0, False, False, epEndEllipsis, nmvNormal);
    Size := Markup.Measure;
  end;

begin
  Bitmap := Vcl.Graphics.TBitmap.Create;
  Font := TFont.Create;
  Markup := TThemedMarkupRenderer.Create;
  Canvas := TNimbusRenderCanvas.Create;
  try
    Bitmap.SetSize(400, 120);
    Font.Name := 'Segoe UI';
    Font.Size := 9;
    Markup.SetFont(Font);
    Canvas.BeginRender(Bitmap.Canvas);
    try
      Markup.SetSpans(TNimbusMarkdownParser.Parse('**Visible Markdown**'));
      Prepare;
      Check((Size.cx > 0) and (Size.cy > 0), 'Custom spans must render without a source text string');
      Markup.SetText('', False);
      Prepare;
      Check((Size.cx = 0) and (Size.cy = 0), 'Empty plain text must clear custom spans');
      Markup.SetText('Plain text', False);
      Prepare;
      Check(Size.cx > 0, 'Plain text after Markdown');
      Markup.SetSpans(nil);
      Prepare;
      Check((Size.cx = 0) and (Size.cy = 0), 'Empty custom spans must clear previous plain text');
      Markup.SetText('Plain text', False);
      Prepare;
      Check(Size.cx > 0, 'Switching back to the same plain source text must rebuild layout');
      Markup.SetSpans(TNimbusMarkdownParser.Parse('[Visible link](https://example.com)'));
      Prepare;
      Check((Size.cx > 0) and (Length(Markup.LinkTargets) = 1), 'Markdown links after plain text');
    finally Canvas.EndRender; end;
  finally Canvas := nil; Markup.Free; Font.Free; Bitmap.Free; end;
end;

procedure LayoutChecks;
var
  Bitmap: TBitmap;
  Canvas: INimbusRenderCanvas;
  Font: TFont;
  Messages: TThemedIdeNotificationMessages;
  M: TThemedIdeNotificationMessage;
  Views: TNimbusNotificationViews;
  MultiHeight, CompactHeight, I: Integer;
  URL: string;
begin
  Bitmap := TBitmap.Create;
  Font := TFont.Create;
  Messages := TThemedIdeNotificationMessages.Create(nil, nil);
  Canvas := TNimbusRenderCanvas.Create;
  try
    Bitmap.SetSize(600, 600);
    Font.Name := 'Segoe UI'; Font.Size := 9;
    M := Messages.Add;
    M.Text := '[Help](https://example.com) ' + StringOfChar('W', 180);
    M.UseMarkdown := True;
    M.Actions.Add.Text := 'A long action caption';
    M.Actions.Add.Text := 'Another action caption';
    Canvas.BeginRender(Bitmap.Canvas);
    try
      MultiHeight := TThemedIdeNotificationBarRenderer.Layout(Canvas, Font, Messages, 240, 96,
        5, 0, nndStack, False, True, True, Views);
      Check((Length(Views) = 1) and (MultiHeight > 34), 'Wrapped notification height');
      for I := 0 to High(Views[0].ActionBounds) do
      begin
        Check(Views[0].ActionBounds[I].Top >= Views[0].TextBounds.Bottom, 'Actions below text');
        Check(Views[0].ActionBounds[I].Right <= Views[0].TextBounds.Right, 'Action wrapping inside body');
      end;
      URL := M.PrepareText(Font).HitTestLink(Point(Views[0].TextBounds.Left + 2,
        Views[0].TextBounds.Top + 2), Views[0].TextBounds, taLeftJustify, tlTop, 0, False);
      Check(URL = 'https://example.com', 'Link hit test uses measured layout');
      CompactHeight := TThemedIdeNotificationBarRenderer.Layout(Canvas, Font, Messages, 240, 96,
        5, 0, nndStack, True, True, True, Views);
      Check(CompactHeight < MultiHeight, 'Compact mode uses one text line');
      TThemedIdeNotificationBarRenderer.Render(Canvas, Font, nil, Messages, Views, 96,
        -1, -1, -1, -1, True, True, '');
    finally Canvas.EndRender; end;
  finally Canvas := nil; Messages.Free; Font.Free; Bitmap.Free; end;
end;

begin
  try
    Application.Initialize;
    MarkdownChecks;
    ModelChecks;
    CustomSpanChecks;
    LayoutChecks;
    InteractionChecks;
    Writeln('NotificationBar checks passed');
  except
    on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end;
  end;
end.
