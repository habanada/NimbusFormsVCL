{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.TagInput;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Types, System.UITypes,
  Vcl.Controls, Vcl.Graphics, NimbusForms.Controls.Types, NimbusForms.Controls.Base, NimbusForms.Controls.TextBox,
  NimbusForms.Theming.Palette, NimbusForms.Rendering.TagInput;

type
  TCustomThemedTagInput = class(TCustomNimbusControl)
  private
    FTags: TStringList;
    FEditor: TThemedTextBox;
    FRects: TArray<TRect>;
    FCloseRects: TArray<TRect>;
    FHoveredClose: Integer;
    FHovered: Boolean;
    FPadding: Integer;
    FTagHeight: Integer;
    FCloseButtonWidth: Integer;
    FCloseSize: Integer;
    FTextPadding: Integer;
    FTextBoxMinWidth: Integer;
    FCloseStrokeWidth: Single;
    FUpdatingLayout: Boolean;
    FTagColorMode: TThemedTagColorMode;
    FOnTagsChanged: TNotifyEvent;
    function GetTags: TStrings;
    procedure SetTags(const AValue: TStrings);
    procedure TagsChanged(Sender: TObject);
    procedure EditorEnterPressed(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    procedure EditorEnter(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure SetPaddingValue(const AValue: Integer);
    procedure SetTagHeight(const AValue: Integer);
    procedure SetCloseButtonWidth(const AValue: Integer);
    procedure SetCloseSize(const AValue: Integer);
    procedure SetTextPadding(const AValue: Integer);
    procedure SetTextBoxMinWidth(const AValue: Integer);
    procedure SetCloseStrokeWidth(const AValue: Single);
    function GetThemeTagColors: Boolean;
    procedure SetThemeTagColors(const AValue: Boolean);
    procedure SetTagColorMode(const AValue: TThemedTagColorMode);
    procedure UpdateLayout;
    procedure DoTagsChanged; virtual;
  protected
    procedure StyleModeChanged; override;
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoEnter; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    property Tags: TStrings read GetTags write SetTags;
    property PaddingValue: Integer read FPadding write SetPaddingValue default 6;
    property TagHeight: Integer read FTagHeight write SetTagHeight default 24;
    property CloseButtonWidth: Integer read FCloseButtonWidth write SetCloseButtonWidth default 20;
    property CloseSize: Integer read FCloseSize write SetCloseSize default 14;
    property TextPadding: Integer read FTextPadding write SetTextPadding default 8;
    property TextBoxMinWidth: Integer read FTextBoxMinWidth write SetTextBoxMinWidth default 60;
    property CloseStrokeWidth: Single read FCloseStrokeWidth write SetCloseStrokeWidth;
    property ThemeTagColors: Boolean read GetThemeTagColors write SetThemeTagColors default False;
    property TagColorMode: TThemedTagColorMode read FTagColorMode write SetTagColorMode default ttcmUniform;
    property OnTagsChanged: TNotifyEvent read FOnTagsChanged write FOnTagsChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure AddTag(const ATag: string);
    procedure RemoveTag(const AIndex: Integer);
    property Editor: TThemedTextBox read FEditor;
  end;

  TThemedTagInput = class(TCustomThemedTagInput)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Font;
    property Hint;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Tags;
    property PaddingValue;
    property TagHeight;
    property CloseButtonWidth;
    property CloseSize;
    property TextPadding;
    property TextBoxMinWidth;
    property CloseStrokeWidth;
    property ThemeTagColors;
    property TagColorMode;
    property OnTagsChanged;
    property OnClick;
    property OnEnter;
    property OnExit;
  end;

implementation

uses
  System.Math;

constructor TCustomThemedTagInput.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabStop := True;
  Width := 250;
  Height := 36;
  FPadding := 6;
  FTagHeight := 24;
  FCloseButtonWidth := 20;
  FCloseSize := 14;
  FTextPadding := 8;
  FTextBoxMinWidth := 60;
  FCloseStrokeWidth := 1.5;
  FHoveredClose := -1;
  FTagColorMode := ttcmUniform;
  FTags := TStringList.Create;
  FTags.OnChange := TagsChanged;
  FEditor := TThemedTextBox.Create(Self);
  FEditor.TabStop := True;
  FEditor.BorderThickness := 0;
  FEditor.OnEnterPressed := EditorEnterPressed;
  FEditor.Editor.OnKeyDown := EditorKeyDown;
  FEditor.Editor.OnKeyPress := EditorKeyPress;
  FEditor.Editor.OnEnter := EditorEnter;
  FEditor.Editor.OnExit := EditorExit;
end;

destructor TCustomThemedTagInput.Destroy;
begin
  FTags.OnChange := nil;
  FTags.Free;
  inherited Destroy;
end;

procedure TCustomThemedTagInput.CreateWnd;
begin
  inherited CreateWnd;
  if FEditor <> nil then
  begin
    if FEditor.Parent <> Self then FEditor.Parent := Self;
    UpdateLayout;
  end;
end;

procedure TCustomThemedTagInput.Loaded;
begin
  inherited Loaded;
  UpdateLayout;
end;

procedure TCustomThemedTagInput.DoTagsChanged;
begin
  if Assigned(FOnTagsChanged) then FOnTagsChanged(Self);
end;

procedure TCustomThemedTagInput.TagsChanged(Sender: TObject);
begin
  UpdateLayout;
  Invalidate;
  if not (csLoading in ComponentState) then DoTagsChanged;
end;

function TCustomThemedTagInput.GetTags: TStrings;
begin
  Result := FTags;
end;

procedure TCustomThemedTagInput.SetTags(const AValue: TStrings);
begin
  if AValue = FTags then Exit;
  if AValue <> nil then FTags.Assign(AValue) else FTags.Clear;
end;

procedure TCustomThemedTagInput.AddTag(const ATag: string);
var
  S: string;
begin
  S := Trim(ATag);
  while (S <> '') and (S[Length(S)] = ',') do Delete(S, Length(S), 1);
  S := Trim(S);
  if (S <> '') and (FTags.IndexOf(S) < 0) then FTags.Add(S);
end;

procedure TCustomThemedTagInput.RemoveTag(const AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < FTags.Count) then FTags.Delete(AIndex);
end;

procedure TCustomThemedTagInput.EditorEnterPressed(Sender: TObject);
begin
  AddTag(FEditor.Text);
  FEditor.ClearText;
end;

procedure TCustomThemedTagInput.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    EditorEnterPressed(Sender);
    Key := 0;
    Exit;
  end;
  if (Key = VK_BACK) and (FEditor.Text = '') and (FTags.Count > 0) then
  begin
    RemoveTag(FTags.Count - 1);
    Key := 0;
  end;
end;

procedure TCustomThemedTagInput.EditorKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ',' then
  begin
    AddTag(FEditor.Text);
    FEditor.ClearText;
    Key := #0;
  end;
end;

procedure TCustomThemedTagInput.EditorEnter(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomThemedTagInput.EditorExit(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomThemedTagInput.DoEnter;
begin
  inherited DoEnter;
  if FEditor.CanFocus then FEditor.SetFocus;
end;

procedure TCustomThemedTagInput.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHovered := False;
  FHoveredClose := -1;
  Invalidate;
end;

procedure TCustomThemedTagInput.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then FEditor.Enabled := Enabled;
  Invalidate;
end;

procedure TCustomThemedTagInput.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then
  begin
    FEditor.Font.Assign(Font);
    UpdateLayout;
  end;
end;

procedure TCustomThemedTagInput.SetPaddingValue(const AValue: Integer);
begin
  if FPadding <> Max(0, AValue) then begin FPadding := Max(0, AValue); UpdateLayout; end;
end;

procedure TCustomThemedTagInput.SetTagHeight(const AValue: Integer);
begin
  if FTagHeight <> Max(8, AValue) then begin FTagHeight := Max(8, AValue); UpdateLayout; end;
end;

procedure TCustomThemedTagInput.SetCloseButtonWidth(const AValue: Integer);
begin
  if FCloseButtonWidth <> Max(8, AValue) then begin FCloseButtonWidth := Max(8, AValue); UpdateLayout; end;
end;

procedure TCustomThemedTagInput.SetCloseSize(const AValue: Integer);
begin
  if FCloseSize <> Max(4, AValue) then begin FCloseSize := Max(4, AValue); UpdateLayout; end;
end;

procedure TCustomThemedTagInput.SetTextPadding(const AValue: Integer);
begin
  if FTextPadding <> Max(0, AValue) then begin FTextPadding := Max(0, AValue); UpdateLayout; end;
end;

procedure TCustomThemedTagInput.SetTextBoxMinWidth(const AValue: Integer);
begin
  if FTextBoxMinWidth <> Max(20, AValue) then begin FTextBoxMinWidth := Max(20, AValue); UpdateLayout; end;
end;

procedure TCustomThemedTagInput.SetCloseStrokeWidth(const AValue: Single);
begin
  if (AValue > 0) and (FCloseStrokeWidth <> AValue) then begin FCloseStrokeWidth := AValue; Invalidate; end;
end;

function TCustomThemedTagInput.GetThemeTagColors: Boolean;
begin
  Result := FTagColorMode <> ttcmUniform;
end;

procedure TCustomThemedTagInput.SetThemeTagColors(const AValue: Boolean);
begin
  if AValue then SetTagColorMode(ttcmHarmonized)
  else SetTagColorMode(ttcmUniform);
end;

procedure TCustomThemedTagInput.SetTagColorMode(const AValue: TThemedTagColorMode);
begin
  if FTagColorMode <> AValue then
  begin
    FTagColorMode := AValue;
    Invalidate;
  end;
end;

procedure TCustomThemedTagInput.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if FEditor <> nil then FEditor.StyleMode := StyleMode;
  UpdateLayout;
end;

procedure TCustomThemedTagInput.UpdateLayout;
var
  I, X, Y, W, H, MinHeight, EditorHeight: Integer;
  TagRect: TRect;
begin
  if FUpdatingLayout or (FEditor = nil) or (FTags = nil) or not HandleAllocated then Exit;
  FUpdatingLayout := True;
  try
    SetLength(FRects, FTags.Count);
    SetLength(FCloseRects, FTags.Count);
    X := ScaleValue(FPadding);
    Y := ScaleValue(FPadding);
    H := ScaleValue(Max(8, FTagHeight - Ord(StyleMode = stCompact) * 4));
    for I := 0 to FTags.Count - 1 do
    begin
      Canvas.Font.Assign(Font);
    W := Canvas.TextWidth(FTags[I]) + ScaleValue(FCloseButtonWidth + FTextPadding * 2);
      if (X + W > ClientWidth - ScaleValue(FPadding)) and (X > ScaleValue(FPadding)) then
      begin
        X := ScaleValue(FPadding);
        Inc(Y, H + ScaleValue(FPadding));
      end;
      TagRect := Rect(X, Y, X + W, Y + H);
      FRects[I] := TagRect;
      FCloseRects[I] := Rect(TagRect.Right - ScaleValue(FCloseButtonWidth) - ScaleValue(FTextPadding div 2), Y + (H - ScaleValue(FCloseSize)) div 2, TagRect.Right - ScaleValue(FCloseButtonWidth) - ScaleValue(FTextPadding div 2) + ScaleValue(FCloseSize), Y + (H + ScaleValue(FCloseSize)) div 2);
      Inc(X, W + ScaleValue(FPadding));
    end;
    if (X + ScaleValue(FTextBoxMinWidth) > ClientWidth - ScaleValue(FPadding)) and (X > ScaleValue(FPadding)) then
    begin
      X := ScaleValue(FPadding);
      Inc(Y, H + ScaleValue(FPadding));
    end;
    EditorHeight := ScaleValue(24 - Ord(StyleMode = stCompact) * 3);
    FEditor.SetBounds(X, Y + (H - EditorHeight) div 2, Max(1, ClientWidth - X - ScaleValue(FPadding)), EditorHeight);
    MinHeight := Y + H + ScaleValue(FPadding);
    if (Height <> MinHeight) and not (csLoading in ComponentState) and not (csDesigning in ComponentState) then Height := MinHeight;
    Invalidate;
  finally
    FUpdatingLayout := False;
  end;
end;

procedure TCustomThemedTagInput.Resize;
begin
  inherited Resize;
  UpdateLayout;
end;

procedure TCustomThemedTagInput.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  UpdateLayout;
end;

procedure TCustomThemedTagInput.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if FEditor <> nil then FEditor.ApplyTheme(APalette);
  Invalidate;
end;

procedure TCustomThemedTagInput.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I, HoverIndex: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  FHovered := True;
  HoverIndex := -1;
  for I := 0 to High(FCloseRects) do
    if PtInRect(FCloseRects[I], Point(X, Y)) then begin HoverIndex := I; Break; end;
  if FHoveredClose <> HoverIndex then
  begin
    FHoveredClose := HoverIndex;
    if HoverIndex >= 0 then Cursor := crHandPoint else Cursor := crIBeam;
    Invalidate;
  end;
end;

procedure TCustomThemedTagInput.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  for I := 0 to High(FCloseRects) do
    if PtInRect(FCloseRects[I], Point(X, Y)) then
    begin
      RemoveTag(I);
      FHoveredClose := -1;
      Exit;
    end;
  if FEditor.CanFocus then FEditor.SetFocus;
end;

procedure TCustomThemedTagInput.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedTagInputRenderer.Render(RenderCanvas, ClientRect, Palette, Font, FTags, FRects, FCloseRects, FHoveredClose, (FEditor <> nil) and FEditor.Editor.Focused, FHovered, Enabled, FTagColorMode, FCloseStrokeWidth * CurrentPPI / 96);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.
