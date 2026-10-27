{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.BreadcrumbBar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.UITypes,
  Vcl.Controls, Vcl.Graphics, Vcl.Menus, Vcl.ImgList, Vcl.Forms,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types, NimbusForms.Controls.TextBox, NimbusForms.Menus.PopupMenu, NimbusForms.Theming.Palette;

type
  TThemedBreadcrumbBar = class;
  TBreadcrumbPathEditor = class(TThemedTextBox)
  public
    property OnEnterPressed;
    property OnEscapePressed;
  end;
  TBreadcrumbPathChangeSource = (bpcsCode, bpcsEdit, bpcsSegmentClick, bpcsDropDownItemClick);
  TBreadcrumbPathChangingEvent = procedure(Sender: TObject; const AOldPath, ANewPath: string; ASource: TBreadcrumbPathChangeSource; var ACancel: Boolean) of object;
  TBreadcrumbSegmentEvent = procedure(Sender: TObject; ASegmentIndex: Integer; const AText, AFullPath: string) of object;
  TBreadcrumbDropDownEvent = procedure(Sender: TObject; ASegmentIndex: Integer; const AText, AFullPath: string; var ACancel: Boolean) of object;

  TThemedBreadcrumbChild = class(TCollectionItem)
  private
    FCaption: string;
    FFullPath: string;
    FImageIndex: System.UITypes.TImageIndex;
    procedure SetCaption(const AValue: string);
    procedure SetFullPath(const AValue: string);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property FullPath: string read FFullPath write SetFullPath;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
  end;

  TThemedBreadcrumbChildren = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): TThemedBreadcrumbChild;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedBreadcrumbChild;
    property Items[AIndex: Integer]: TThemedBreadcrumbChild read GetItem; default;
  end;

  TThemedBreadcrumbSegment = class(TCollectionItem)
  private
    FCaption: string;
    FFullPath: string;
    FChildren: TThemedBreadcrumbChildren;
    FImageIndex: System.UITypes.TImageIndex;
    procedure SetCaption(const AValue: string);
    procedure SetFullPath(const AValue: string);
    procedure SetChildren(const AValue: TThemedBreadcrumbChildren);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property FullPath: string read FFullPath write SetFullPath;
    property Children: TThemedBreadcrumbChildren read FChildren write SetChildren;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
  end;

  TThemedBreadcrumbSegments = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): TThemedBreadcrumbSegment;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TThemedBreadcrumbBar);
    function Add: TThemedBreadcrumbSegment;
    property Items[AIndex: Integer]: TThemedBreadcrumbSegment read GetItem; default;
  end;

  TThemedBreadcrumbBar = class(TCustomNimbusControl)
  private
    FPath: string;
    FSeparator: Char;
    FSegments: TThemedBreadcrumbSegments;
    FStoredSegments: TThemedBreadcrumbSegments;
    FPopup: TThemedPopupMenu;
    FEditor: TBreadcrumbPathEditor;
    FImages: TCustomImageList;
    FIconBuffer: Vcl.Graphics.TBitmap;
    FImageChangeLink: TChangeLink;
    FImageSize: Integer;
    FShowSegmentDropDowns: Boolean;
    FAllowManualEdit: Boolean;
    FEditPathOnEmptyClick: Boolean;
    FEditPathOnDoubleClick: Boolean;
    FOuterPadding: Integer;
    FSegmentHorizontalPadding: Integer;
    FDropDownWidth: Integer;
    FBorderThickness: Integer;
    FStyleSavedHeight: Integer;
    FStyleAppliedHeight: Integer;
    FStyleAdjustedHeight: Boolean;
    FSegmentRects: TArray<TRect>;
    FDropRects: TArray<TRect>;
    FOverflowRect: TRect;
    FOverflowCount: Integer;
    FFocusedIndex: Integer;
    FHotIndex: Integer;
    FHotDropDown: Boolean;
    FEditing: Boolean;
    FPopupSegment: Integer;
    FOnPathChanging: TBreadcrumbPathChangingEvent;
    FOnPathChanged: TNotifyEvent;
    FOnPathEdited: TNotifyEvent;
    FOnSegmentClicked: TBreadcrumbSegmentEvent;
    FOnDropDownOpening: TBreadcrumbDropDownEvent;
    FOnDropDownItemClicked: TBreadcrumbSegmentEvent;
    procedure SetPath(const AValue: string);
    procedure SetSeparator(const AValue: Char);
    procedure SetImages(const AValue: TCustomImageList);
    procedure ImagesChanged(Sender: TObject);
    procedure SetImageSize(const AValue: Integer);
    procedure SetShowSegmentDropDowns(const AValue: Boolean);
    procedure SetAllowManualEdit(const AValue: Boolean);
    procedure SetOuterPadding(const AValue: Integer);
    procedure SetSegmentHorizontalPadding(const AValue: Integer);
    procedure SetDropDownWidth(const AValue: Integer);
    procedure SetBorderThickness(const AValue: Integer);
    procedure EditorEnterPressed(Sender: TObject);
    procedure EditorEscapePressed(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure MenuItemClick(Sender: TObject);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure ShowOverflowMenu;
    function NextVisibleSegment(AStart, ADirection: Integer): Integer;
    procedure RebuildSegments;
    procedure UpdateLayout;
    function ChangePath(const AValue: string; ASource: TBreadcrumbPathChangeSource): Boolean;
    function HitSegment(const APoint: TPoint; out AOnDropDown: Boolean): Integer;
    procedure ShowSegmentMenu(AIndex: Integer);
    procedure SetSegments(const AValue: TThemedBreadcrumbSegments);
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure BeginEdit;
    procedure EndEdit(AApply: Boolean);
    procedure SetSegmentChildren(AIndex: Integer; const AChildren: TThemedBreadcrumbChildren);
    function SegmentPath(AIndex: Integer): string;
    function SegmentCount: Integer;
    property Editing: Boolean read FEditing;
  published
    property StyleMode;
    property Path: string read FPath write SetPath;
    property Separator: Char read FSeparator write SetSeparator default '\';
    property Segments: TThemedBreadcrumbSegments read FSegments write SetSegments;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageSize: Integer read FImageSize write SetImageSize default 16;
    property ShowSegmentDropDowns: Boolean read FShowSegmentDropDowns write SetShowSegmentDropDowns default True;
    property AllowManualEdit: Boolean read FAllowManualEdit write SetAllowManualEdit default True;
    property EditPathOnEmptyClick: Boolean read FEditPathOnEmptyClick write FEditPathOnEmptyClick default True;
    property EditPathOnDoubleClick: Boolean read FEditPathOnDoubleClick write FEditPathOnDoubleClick default False;
    property OuterPadding: Integer read FOuterPadding write SetOuterPadding default 4;
    property SegmentHorizontalPadding: Integer read FSegmentHorizontalPadding write SetSegmentHorizontalPadding default 8;
    property DropDownWidth: Integer read FDropDownWidth write SetDropDownWidth default 18;
    property BorderThickness: Integer read FBorderThickness write SetBorderThickness default 1;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Font;
    property Hint;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnPathChanging: TBreadcrumbPathChangingEvent read FOnPathChanging write FOnPathChanging;
    property OnPathChanged: TNotifyEvent read FOnPathChanged write FOnPathChanged;
    property OnPathEdited: TNotifyEvent read FOnPathEdited write FOnPathEdited;
    property OnSegmentClicked: TBreadcrumbSegmentEvent read FOnSegmentClicked write FOnSegmentClicked;
    property OnDropDownOpening: TBreadcrumbDropDownEvent read FOnDropDownOpening write FOnDropDownOpening;
    property OnDropDownItemClicked: TBreadcrumbSegmentEvent read FOnDropDownItemClicked write FOnDropDownItemClicked;
  end;

implementation

uses
  System.Math, System.SysUtils, NimbusForms.Theming.Types, NimbusForms.Rendering.Types,
  NimbusForms.Rendering.BreadcrumbBar;

constructor TThemedBreadcrumbChild.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FImageIndex := -1;
end;

procedure TThemedBreadcrumbChild.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then begin FCaption := AValue; Changed(False); end;
end;

procedure TThemedBreadcrumbChild.SetFullPath(const AValue: string);
begin
  if FFullPath <> AValue then begin FFullPath := AValue; Changed(False); end;
end;

procedure TThemedBreadcrumbChild.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex <> AValue then begin FImageIndex := AValue; Changed(False); end;
end;

procedure TThemedBreadcrumbChild.Assign(Source: TPersistent);
begin
  if Source is TThemedBreadcrumbChild then
  begin
    Caption := TThemedBreadcrumbChild(Source).Caption;
    FullPath := TThemedBreadcrumbChild(Source).FullPath;
    ImageIndex := TThemedBreadcrumbChild(Source).ImageIndex;
  end else inherited Assign(Source);
end;

constructor TThemedBreadcrumbChildren.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TThemedBreadcrumbChild);
end;

function TThemedBreadcrumbChildren.Add: TThemedBreadcrumbChild;
begin
  Result := TThemedBreadcrumbChild(inherited Add);
end;

function TThemedBreadcrumbChildren.GetItem(AIndex: Integer): TThemedBreadcrumbChild;
begin
  Result := TThemedBreadcrumbChild(inherited Items[AIndex]);
end;

constructor TThemedBreadcrumbSegment.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FImageIndex := -1;
  FChildren := TThemedBreadcrumbChildren.Create(Self);
end;

destructor TThemedBreadcrumbSegment.Destroy;
begin
  FChildren.Free;
  inherited Destroy;
end;

procedure TThemedBreadcrumbSegment.Assign(Source: TPersistent);
begin
  if Source is TThemedBreadcrumbSegment then
  begin
    Caption := TThemedBreadcrumbSegment(Source).Caption;
    FullPath := TThemedBreadcrumbSegment(Source).FullPath;
    ImageIndex := TThemedBreadcrumbSegment(Source).ImageIndex;
    Children.Assign(TThemedBreadcrumbSegment(Source).Children);
  end else inherited Assign(Source);
end;

procedure TThemedBreadcrumbSegment.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then begin FCaption := AValue; Changed(False); end;
end;

procedure TThemedBreadcrumbSegment.SetFullPath(const AValue: string);
begin
  if FFullPath <> AValue then begin FFullPath := AValue; Changed(False); end;
end;

procedure TThemedBreadcrumbSegment.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex <> AValue then begin FImageIndex := AValue; Changed(False); end;
end;

procedure TThemedBreadcrumbSegment.SetChildren(const AValue: TThemedBreadcrumbChildren);
begin
  FChildren.Assign(AValue);
  Changed(False);
end;

constructor TThemedBreadcrumbSegments.Create(AOwner: TThemedBreadcrumbBar);
begin
  inherited Create(AOwner, TThemedBreadcrumbSegment);
end;

function TThemedBreadcrumbSegments.GetItem(AIndex: Integer): TThemedBreadcrumbSegment;
begin
  Result := TThemedBreadcrumbSegment(inherited Items[AIndex]);
end;

function TThemedBreadcrumbSegments.Add: TThemedBreadcrumbSegment;
begin
  Result := TThemedBreadcrumbSegment(inherited Add);
end;

procedure TThemedBreadcrumbSegments.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if GetOwner is TThemedBreadcrumbBar then TThemedBreadcrumbBar(GetOwner).UpdateLayout;
end;

constructor TThemedBreadcrumbBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 400;
  Height := 28;
  TabStop := True;
  FSeparator := '\';
  FImageSize := 16;
  FOuterPadding := 4;
  FSegmentHorizontalPadding := 8;
  FDropDownWidth := 18;
  FBorderThickness := 1;
  FShowSegmentDropDowns := True;
  FAllowManualEdit := True;
  FEditPathOnEmptyClick := True;
  FHotIndex := -1;
  FPopupSegment := -1;
  FFocusedIndex := -1;
  FOverflowRect := Rect(0, 0, 0, 0);
  FSegments := TThemedBreadcrumbSegments.Create(Self);
  FStoredSegments := TThemedBreadcrumbSegments.Create(Self);
  FPopup := TThemedPopupMenu.Create(Self);
  FIconBuffer := Vcl.Graphics.TBitmap.Create;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImagesChanged;
  FEditor := TBreadcrumbPathEditor.Create(Self);
  FEditor.Parent := Self;
  FEditor.ShowValidationIcon := False;
  FEditor.UseRoundedCorners := True;
  FEditor.AutoSelectAllOnFocus := True;
  FEditor.Visible := False;
  FEditor.OnEnterPressed := EditorEnterPressed;
  FEditor.OnEscapePressed := EditorEscapePressed;
  FEditor.OnExit := EditorExit;
end;

destructor TThemedBreadcrumbBar.Destroy;
begin
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FImageChangeLink.Free;
  FIconBuffer.Free;
  FStoredSegments.Free;
  FSegments.Free;
  inherited Destroy;
end;

procedure TThemedBreadcrumbBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    Invalidate;
  end;
end;

procedure TThemedBreadcrumbBar.SetImages(const AValue: TCustomImageList);
begin
  if FImages = AValue then Exit;
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FImages := AValue;
  if FImages <> nil then
  begin
    FImages.FreeNotification(Self);
    FImages.RegisterChanges(FImageChangeLink);
  end;
  UpdateLayout;
end;

procedure TThemedBreadcrumbBar.ImagesChanged(Sender: TObject);
begin
  UpdateLayout;
end;

procedure TThemedBreadcrumbBar.SetImageSize(const AValue: Integer);
begin
  if FImageSize <> Max(0, AValue) then begin FImageSize := Max(0, AValue); UpdateLayout; end;
end;

procedure TThemedBreadcrumbBar.SetSegments(const AValue: TThemedBreadcrumbSegments);
begin
  if AValue <> nil then begin FSegments.Assign(AValue); UpdateLayout; end;
end;

procedure TThemedBreadcrumbBar.SetSeparator(const AValue: Char);
begin
  if (AValue <> #0) and (FSeparator <> AValue) then begin FSeparator := AValue; RebuildSegments; end;
end;

procedure TThemedBreadcrumbBar.SetPath(const AValue: string);
begin
  ChangePath(AValue, bpcsCode);
end;

function TThemedBreadcrumbBar.ChangePath(const AValue: string; ASource: TBreadcrumbPathChangeSource): Boolean;
var
  LCancel: Boolean;
  LOldPath: string;
begin
  Result := False;
  if FPath = AValue then Exit;
  LCancel := False;
  LOldPath := FPath;
  if Assigned(FOnPathChanging) then FOnPathChanging(Self, LOldPath, AValue, ASource, LCancel);
  if LCancel or (csDestroying in ComponentState) then Exit;
  FPath := AValue;
  RebuildSegments;
  if Assigned(FOnPathChanged) then FOnPathChanged(Self);
  if (ASource = bpcsEdit) and Assigned(FOnPathEdited) then FOnPathEdited(Self);
  Result := True;
end;

procedure TThemedBreadcrumbBar.RebuildSegments;
var
  I, J, LStart, LCount, LFound: Integer;
  LItem, LStored: TThemedBreadcrumbSegment;
  LCaption, LFullPath: string;
begin
  FStoredSegments.BeginUpdate;
  FSegments.BeginUpdate;
  try
    for I := 0 to FSegments.Count - 1 do
    begin
      LFound := -1;
      for J := 0 to FStoredSegments.Count - 1 do
        if SameText(FStoredSegments[J].FullPath, FSegments[I].FullPath) then
        begin
          LFound := J;
          Break;
        end;
      if LFound < 0 then LStored := FStoredSegments.Add
      else LStored := FStoredSegments[LFound];
      LStored.Assign(FSegments[I]);
    end;
    FSegments.Clear;
    LStart := 1;
    LCount := Length(FPath);
    for I := 1 to LCount + 1 do
      if (I > LCount) or (FPath[I] = FSeparator) then
      begin
        if I > LStart then
        begin
          LCaption := Copy(FPath, LStart, I - LStart);
          LFullPath := Copy(FPath, 1, I - 1);
          LItem := FSegments.Add;
          LFound := -1;
          for J := 0 to FStoredSegments.Count - 1 do
            if SameText(FStoredSegments[J].FullPath, LFullPath) then
            begin
              LFound := J;
              Break;
            end;
          if LFound >= 0 then LItem.Assign(FStoredSegments[LFound]);
          LItem.Caption := LCaption;
          LItem.FullPath := LFullPath;
        end;
        LStart := I + 1;
      end;
  finally
    FSegments.EndUpdate;
    FStoredSegments.EndUpdate;
  end;
  FHotIndex := -1;
  FHotDropDown := False;
  FPopupSegment := -1;
  FFocusedIndex := -1;
  UpdateLayout;
end;

function TThemedBreadcrumbBar.SegmentCount: Integer;
begin
  Result := FSegments.Count;
end;

function TThemedBreadcrumbBar.SegmentPath(AIndex: Integer): string;
begin
  Result := '';
  if (AIndex >= 0) and (AIndex < FSegments.Count) then Result := FSegments[AIndex].FullPath;
end;

procedure TThemedBreadcrumbBar.SetSegmentChildren(AIndex: Integer; const AChildren: TThemedBreadcrumbChildren);
begin
  if (AIndex >= 0) and (AIndex < FSegments.Count) and (AChildren <> nil) then FSegments[AIndex].Children.Assign(AChildren);
end;

procedure TThemedBreadcrumbBar.SetShowSegmentDropDowns(const AValue: Boolean);
begin
  if FShowSegmentDropDowns <> AValue then begin FShowSegmentDropDowns := AValue; UpdateLayout; end;
end;

procedure TThemedBreadcrumbBar.SetAllowManualEdit(const AValue: Boolean);
begin
  if FAllowManualEdit <> AValue then
  begin
    FAllowManualEdit := AValue;
    if not AValue then EndEdit(False);
  end;
end;

procedure TThemedBreadcrumbBar.SetOuterPadding(const AValue: Integer);
begin
  if FOuterPadding <> Max(0, AValue) then begin FOuterPadding := Max(0, AValue); UpdateLayout; end;
end;

procedure TThemedBreadcrumbBar.SetSegmentHorizontalPadding(const AValue: Integer);
begin
  if FSegmentHorizontalPadding <> Max(0, AValue) then begin FSegmentHorizontalPadding := Max(0, AValue); UpdateLayout; end;
end;

procedure TThemedBreadcrumbBar.SetDropDownWidth(const AValue: Integer);
begin
  if FDropDownWidth <> Max(8, AValue) then begin FDropDownWidth := Max(8, AValue); UpdateLayout; end;
end;

procedure TThemedBreadcrumbBar.SetBorderThickness(const AValue: Integer);
begin
  if FBorderThickness <> Max(0, AValue) then begin FBorderThickness := Max(0, AValue); Invalidate; end;
end;

procedure TThemedBreadcrumbBar.StyleModeChanged;
var
  LHeight: Integer;
begin
  inherited StyleModeChanged;
  if StyleMode = stCompact then
  begin
    FStyleAdjustedHeight := False;
    if Align in [alNone, alTop, alBottom] then
    begin
      FStyleSavedHeight := Height;
      if (Height = 28) or (Height = ScaleValue(28)) then LHeight := ScaleValue(23)
      else LHeight := Max(ScaleValue(21), Height - ScaleValue(7));
      if LHeight < Height then
      begin
        Height := LHeight;
        FStyleAppliedHeight := Height;
        FStyleAdjustedHeight := True;
      end;
    end;
  end
  else
  begin
    if FStyleAdjustedHeight and (Align in [alNone, alTop, alBottom]) and (Height = FStyleAppliedHeight) then
      Height := FStyleSavedHeight;
    FStyleAdjustedHeight := False;
  end;
  if FEditor <> nil then FEditor.StyleMode := StyleMode;
  UpdateLayout;
end;

procedure TThemedBreadcrumbBar.UpdateLayout;
var
  I, LX, LW, LPadding, LDropWidth, LRight, LStart, LOverflowWidth, LGap: Integer;
  LSize: TSize;
  LWidths: TArray<Integer>;
  LFlags: TNimbusTextFlags;
begin
  if (FSegments = nil) or not HandleAllocated or (RenderCanvas = nil) then Exit;
  SetLength(FSegmentRects, FSegments.Count);
  SetLength(FDropRects, FSegments.Count);
  SetLength(LWidths, FSegments.Count);
  LPadding := ScaleValue(FSegmentHorizontalPadding - Ord((StyleMode = stCompact) and (FSegmentHorizontalPadding = 8)) * 3);
  LDropWidth := ScaleValue(FDropDownWidth - Ord((StyleMode = stCompact) and (FDropDownWidth = 18)) * 4);
  LGap := ScaleValue(2);
  LRight := Max(0, ClientWidth - ScaleValue(FOuterPadding));
  LOverflowWidth := ScaleValue(30 - Ord(StyleMode = stCompact) * 6);
  FOverflowRect := Rect(0, 0, 0, 0);
  FOverflowCount := 0;
  LFlags := [ntfSingleLine, ntfNoPrefix];
  if BiDiMode = bdRightToLeft then Include(LFlags, ntfRightToLeft);
  RenderCanvas.BeginRender(Canvas);
  try
    for I := 0 to FSegments.Count - 1 do
    begin
      LSize := RenderCanvas.MeasureText(FSegments[I].Caption, Font, 0, LFlags);
      LW := Max(1, LSize.cx) + 2 * LPadding;
      if (FImages <> nil) and (FSegments[I].ImageIndex >= 0) and (FSegments[I].ImageIndex < FImages.Count) then
        Inc(LW, ScaleValue(FImageSize + 4));
      if FShowSegmentDropDowns then Inc(LW, LDropWidth);
      LWidths[I] := LW;
      FSegmentRects[I] := Rect(0, 0, 0, 0);
      FDropRects[I] := Rect(0, 0, 0, 0);
    end;
  finally
    RenderCanvas.EndRender;
  end;
  LStart := 0;
  LX := ScaleValue(FOuterPadding);
  LW := LX;
  for I := 0 to High(LWidths) do Inc(LW, LWidths[I] + LGap);
  if LW > LRight then
  begin
    LStart := Length(LWidths);
    LW := LX + LOverflowWidth + LGap;
    for I := High(LWidths) downto 0 do
    begin
      if LW + LWidths[I] > LRight then Break;
      Inc(LW, LWidths[I] + LGap);
      LStart := I;
    end;
    if LStart = 0 then LStart := 1;
    FOverflowCount := LStart;
    if LX + LOverflowWidth <= LRight then
    begin
      FOverflowRect := Rect(LX, ScaleValue(2 - Ord(StyleMode = stCompact)), LX + LOverflowWidth, Max(ScaleValue(2 - Ord(StyleMode = stCompact)), ClientHeight - ScaleValue(2 - Ord(StyleMode = stCompact))));
      Inc(LX, LOverflowWidth + LGap);
    end;
  end;
  for I := LStart to High(LWidths) do
  begin
    if LX + LWidths[I] > LRight then Break;
    FSegmentRects[I] := Rect(LX, ScaleValue(2 - Ord(StyleMode = stCompact)), LX + LWidths[I], Max(ScaleValue(2 - Ord(StyleMode = stCompact)), ClientHeight - ScaleValue(2 - Ord(StyleMode = stCompact))));
    if FShowSegmentDropDowns then
      FDropRects[I] := Rect(LX + LWidths[I] - LDropWidth, FSegmentRects[I].Top, LX + LWidths[I], FSegmentRects[I].Bottom);
    Inc(LX, LWidths[I] + LGap);
  end;
  if (FFocusedIndex >= 0) and ((FFocusedIndex >= Length(FSegmentRects)) or ((FFocusedIndex < Length(FSegmentRects)) and IsRectEmpty(FSegmentRects[FFocusedIndex]))) then
    FFocusedIndex := NextVisibleSegment(-1, 1);
  if FEditing then FEditor.SetBounds(ScaleValue(4), (Height - FEditor.Height) div 2, Max(1, Width - ScaleValue(8)), FEditor.Height);
  Invalidate;
end;

procedure TThemedBreadcrumbBar.Loaded;
begin
  inherited Loaded;
  UpdateLayout;
end;

procedure TThemedBreadcrumbBar.Resize;
begin
  inherited Resize;
  UpdateLayout;
end;

procedure TThemedBreadcrumbBar.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then FEditor.Font.Assign(Font);
  UpdateLayout;
end;

procedure TThemedBreadcrumbBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHotIndex := -1;
  FHotDropDown := False;
  Invalidate;
end;

procedure TThemedBreadcrumbBar.CMDialogKey(var Message: TCMDialogKey);
var
  LKey: Word;
begin
  if FEditing then begin inherited; Exit; end;
  if (Message.CharCode in [VK_F2, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_DOWN, VK_RETURN, VK_SPACE, VK_ESCAPE]) and Focused then
  begin
    LKey := Message.CharCode;
    KeyDown(LKey, []);
    Message.Result := 1;
  end else inherited;
end;

procedure TThemedBreadcrumbBar.CMEnter(var Message: TCMEnter);
begin
  inherited;
  if FFocusedIndex < 0 then FFocusedIndex := NextVisibleSegment(-1, 1);
  Invalidate;
end;

procedure TThemedBreadcrumbBar.CMExit(var Message: TCMExit);
begin
  inherited;
  FFocusedIndex := -1;
  Invalidate;
end;

function TThemedBreadcrumbBar.NextVisibleSegment(AStart, ADirection: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := AStart + ADirection;
  while (I >= 0) and (I < Length(FSegmentRects)) do
  begin
    if not IsRectEmpty(FSegmentRects[I]) then Exit(I);
    Inc(I, ADirection);
  end;
end;

procedure TThemedBreadcrumbBar.KeyDown(var Key: Word; Shift: TShiftState);
var
  LIndex: Integer;
  LPath, LCaption: string;
begin
  inherited KeyDown(Key, Shift);
  if FEditing or not Enabled then Exit;
  case Key of
    VK_F2: if FAllowManualEdit then BeginEdit else Exit;
    VK_LEFT, VK_RIGHT:
      begin
        if Key = VK_LEFT then LIndex := NextVisibleSegment(FFocusedIndex, -1)
        else LIndex := NextVisibleSegment(FFocusedIndex, 1);
        if LIndex >= 0 then FFocusedIndex := LIndex;
        Invalidate;
      end;
    VK_HOME: begin FFocusedIndex := NextVisibleSegment(-1, 1); Invalidate; end;
    VK_END: begin FFocusedIndex := NextVisibleSegment(Length(FSegmentRects), -1); Invalidate; end;
    VK_DOWN:
      begin
        if (FFocusedIndex >= 0) and ((ssAlt in Shift) or FShowSegmentDropDowns) then ShowSegmentMenu(FFocusedIndex)
        else if FOverflowCount > 0 then ShowOverflowMenu;
      end;
    VK_RETURN, VK_SPACE:
      begin
        if (FFocusedIndex < 0) or (FFocusedIndex >= FSegments.Count) then Exit;
        LPath := FSegments[FFocusedIndex].FullPath;
        LCaption := FSegments[FFocusedIndex].Caption;
        LIndex := FFocusedIndex;
        if Assigned(FOnSegmentClicked) then FOnSegmentClicked(Self, LIndex, LCaption, LPath);
        ChangePath(LPath, bpcsSegmentClick);
      end;
    VK_ESCAPE: begin FFocusedIndex := -1; Invalidate; end;
  else
    Exit;
  end;
  Key := 0;
end;

procedure TThemedBreadcrumbBar.BeginEdit;
begin
  if FEditing or not FAllowManualEdit or not Enabled or (FEditor = nil) then Exit;
  FEditing := True;
  FEditor.Font.Assign(Font);
  FEditor.Text := FPath;
  FEditor.SetBounds(ScaleValue(4), (Height - FEditor.Height) div 2, Max(1, Width - ScaleValue(8)), FEditor.Height);
  FEditor.Visible := True;
  FEditor.SetFocus;
  FEditor.SelectAll;
  Invalidate;
end;

procedure TThemedBreadcrumbBar.EndEdit(AApply: Boolean);
var
  LText: string;
begin
  if not FEditing then Exit;
  LText := FEditor.Text;
  FEditing := False;
  FEditor.Visible := False;
  if AApply then ChangePath(LText, bpcsEdit);
  Invalidate;
end;

procedure TThemedBreadcrumbBar.EditorEnterPressed(Sender: TObject);
begin
  EndEdit(True);
end;

procedure TThemedBreadcrumbBar.EditorEscapePressed(Sender: TObject);
begin
  EndEdit(False);
end;

procedure TThemedBreadcrumbBar.EditorExit(Sender: TObject);
begin
  EndEdit(True);
end;

function TThemedBreadcrumbBar.HitSegment(const APoint: TPoint; out AOnDropDown: Boolean): Integer;
var
  I: Integer;
begin
  Result := -1;
  AOnDropDown := False;
  for I := 0 to High(FSegmentRects) do
    if PtInRect(FSegmentRects[I], APoint) then
    begin
      Result := I;
      AOnDropDown := FShowSegmentDropDowns and PtInRect(FDropRects[I], APoint);
      Exit;
    end;
end;

procedure TThemedBreadcrumbBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
  LDrop: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LIndex := HitSegment(Point(X, Y), LDrop);
  if (FHotIndex <> LIndex) or (FHotDropDown <> LDrop) then
  begin
    FHotIndex := LIndex;
    FHotDropDown := LDrop;
    Invalidate;
  end;
end;

procedure TThemedBreadcrumbBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
  LDrop: Boolean;
  LPath, LCaption: string;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or FEditing then Exit;
  LIndex := HitSegment(Point(X, Y), LDrop);
  if LIndex < 0 then
  begin
    if PtInRect(FOverflowRect, Point(X, Y)) then begin ShowOverflowMenu; Exit; end;
    if FEditPathOnEmptyClick then BeginEdit;
    Exit;
  end;
  if CanFocus then SetFocus;
  FFocusedIndex := LIndex;
  if LDrop then begin ShowSegmentMenu(LIndex); Exit; end;
  LPath := FSegments[LIndex].FullPath;
  LCaption := FSegments[LIndex].Caption;
  if Assigned(FOnSegmentClicked) then FOnSegmentClicked(Self, LIndex, LCaption, LPath);
  ChangePath(LPath, bpcsSegmentClick);
end;

procedure TThemedBreadcrumbBar.DblClick;
begin
  inherited DblClick;
  if FEditPathOnDoubleClick then BeginEdit;
end;

procedure TThemedBreadcrumbBar.ShowOverflowMenu;
var
  I: Integer;
  LItem: TMenuItem;
  LPoint: TPoint;
begin
  if (FOverflowCount <= 0) or IsRectEmpty(FOverflowRect) then Exit;
  FPopup.Items.Clear;
  FPopupSegment := -2;
  FPopup.Images := FImages;
  for I := 0 to Min(FOverflowCount, FSegments.Count) - 1 do
  begin
    LItem := TMenuItem.Create(FPopup);
    LItem.Caption := FSegments[I].Caption;
    LItem.ImageIndex := FSegments[I].ImageIndex;
    LItem.Tag := I;
    LItem.OnClick := MenuItemClick;
    FPopup.Items.Add(LItem);
  end;
  LPoint := ClientToScreen(Point(FOverflowRect.Left, FOverflowRect.Bottom));
  FPopup.Popup(LPoint.X, LPoint.Y);
end;

procedure TThemedBreadcrumbBar.ShowSegmentMenu(AIndex: Integer);
var
  I: Integer;
  LItem: TMenuItem;
  LPoint: TPoint;
  LCancel: Boolean;
begin
  if not FShowSegmentDropDowns or (AIndex < 0) or (AIndex >= FSegments.Count) then Exit;
  LCancel := False;
  if Assigned(FOnDropDownOpening) then FOnDropDownOpening(Self, AIndex, FSegments[AIndex].Caption, FSegments[AIndex].FullPath, LCancel);
  if LCancel or (csDestroying in ComponentState) then Exit;
  FPopup.Items.Clear;
  FPopupSegment := AIndex;
  FPopup.Images := FImages;
  for I := 0 to FSegments[AIndex].Children.Count - 1 do
  begin
    LItem := TMenuItem.Create(FPopup);
    LItem.Caption := FSegments[AIndex].Children[I].Caption;
    LItem.ImageIndex := FSegments[AIndex].Children[I].ImageIndex;
    LItem.Tag := I;
    LItem.OnClick := MenuItemClick;
    FPopup.Items.Add(LItem);
  end;
  if FPopup.Items.Count = 0 then Exit;
  LPoint := ClientToScreen(Point(FDropRects[AIndex].Left, FDropRects[AIndex].Bottom));
  FPopup.Popup(LPoint.X, LPoint.Y);
end;

procedure TThemedBreadcrumbBar.MenuItemClick(Sender: TObject);
var
  LItem: TThemedBreadcrumbChild;
  LPath, LCaption: string;
  LIndex: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  if FPopupSegment = -2 then
  begin
    LIndex := TMenuItem(Sender).Tag;
    if (LIndex < 0) or (LIndex >= FOverflowCount) or (LIndex >= FSegments.Count) then Exit;
    LPath := FSegments[LIndex].FullPath;
    LCaption := FSegments[LIndex].Caption;
    if Assigned(FOnSegmentClicked) then FOnSegmentClicked(Self, LIndex, LCaption, LPath);
    ChangePath(LPath, bpcsSegmentClick);
    Exit;
  end;
  if (FPopupSegment < 0) or (FPopupSegment >= FSegments.Count) then Exit;
  LIndex := TMenuItem(Sender).Tag;
  if (LIndex < 0) or (LIndex >= FSegments[FPopupSegment].Children.Count) then Exit;
  LItem := FSegments[FPopupSegment].Children[LIndex];
  LPath := LItem.FullPath;
  LCaption := LItem.Caption;
  if LPath = '' then LPath := LCaption;
  if Assigned(FOnDropDownItemClicked) then FOnDropDownItemClicked(Self, FPopupSegment, LCaption, LPath);
  ChangePath(LPath, bpcsDropDownItemClick);
end;

procedure TThemedBreadcrumbBar.Paint;
var
  LContext: TThemedBreadcrumbRenderContext;
begin
  if RenderCanvas = nil then Exit;
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Palette := Palette;
    LContext.Font := Font;
    LContext.Segments := FSegments;
    LContext.SegmentRects := FSegmentRects;
    LContext.DropRects := FDropRects;
    LContext.OverflowRect := FOverflowRect;
    LContext.FocusedIndex := FFocusedIndex;
    LContext.HasFocus := Focused;
    LContext.HotIndex := FHotIndex;
    LContext.HotDropDown := FHotDropDown;
    LContext.ShowDropDowns := FShowSegmentDropDowns;
    LContext.BorderThickness := FBorderThickness;
    LContext.Images := FImages;
    LContext.ImageBuffer := FIconBuffer;
    LContext.ImageSize := ScaleValue(FImageSize);
    LContext.RightToLeft := BiDiMode = bdRightToLeft;
    LContext.Enabled := Enabled;
    TThemedBreadcrumbRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TThemedBreadcrumbBar.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  FPopup.ApplyTheme(APalette);
  FEditor.ApplyTheme(APalette);
end;

end.
