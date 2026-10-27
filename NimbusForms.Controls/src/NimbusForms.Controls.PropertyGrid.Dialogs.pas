{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.PropertyGrid.Dialogs;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.ListBox,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.VScrollBar,
  NimbusForms.Controls.RichEdit,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.NumericUpDown,
  NimbusForms.Controls.IdeColorPicker;

function NimbusEditPropertyFlags(AOwner: TComponent; const ATitle: string; AType: PTypeInfo; const ACurrent: string; out AResult: string): Boolean;
function NimbusEditPropertyText(AOwner: TComponent; const ATitle, ACurrent: string; out AResult: string): Boolean;
function NimbusEditPropertyFont(AOwner: TComponent; const ATitle: string; AFont: TFont; out AResult: string): Boolean;
function NimbusEditPropertyCollection(AOwner: TComponent; const ATitle: string; ACollection: TCollection; out AEdited: TCollection): Boolean;
function NimbusEditPropertyImage(AOwner: TComponent; const ATitle: string; ASource: TPicture; AIconOnly: Boolean; out AEdited: TPicture; out ASourceFile: string): Boolean;

implementation

uses
  Winapi.Windows,
  System.Math,
  System.UITypes,
  NimbusForms.Controls.PropertyGrid.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.PropertyGrid,
  NimbusForms.Theming.Palette,
  Vcl.Dialogs,
  Vcl.ExtDlgs,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
  NimbusForms.Controls.PropertyGrid;

type
  TThemedPropertyGridDialog = class(TForm)
  private
    FSurface: TThemedPanel;
    FTitle: TThemedLabel;
    FViewport: TThemedPanel;
    FScroll: TThemedVScrollBar;
    FChecks: TArray<TThemedCheckBox>;
    FMemo: TThemedRichEdit;
    FFontName: TThemedComboBox;
    FFontSize: TThemedNumericUpDown;
    FFontColor: TThemedIdeColorPickerButton;
    FFontStyles: array[0..3] of TThemedCheckBox;
    FAllButton: TThemedButton;
    FNoneButton: TThemedButton;
    FOKButton: TThemedButton;
    FCollection: TCollection;
    FCollectionList: TThemedListBox;
    FCollectionGrid: TThemedPropertyGrid;
    FCollectionAdd: TThemedButton;
    FCollectionRemove: TThemedButton;
    FCollectionUp: TThemedButton;
    FCollectionDown: TThemedButton;
    FCollectionError: TThemedLabel;
    FLoadingCollection: Boolean;
    FCollectionActionActive: Boolean;
    function S(AValue: Integer): Integer;
    procedure LayoutChecks;
    procedure ScrollChanged(Sender: TObject);
    procedure CheckAll(Sender: TObject);
    procedure CheckNone(Sender: TObject);
    function GetFlags: string;
    procedure RefreshCollectionList(AIndex: Integer);
    procedure CollectionSelected(Sender: TObject);
    procedure CollectionKeys(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CollectionChanged(Sender: TObject);
    procedure CollectionAction(Sender: TObject);
    procedure CollectionConfirm(Sender: TObject);
  public
    constructor CreateDialog(AOwner: TComponent; const ATitle: string; AHeight: Integer; AWidth: Integer = 420);
    destructor Destroy; override;
    procedure AddFlag(const AName: string; AChecked: Boolean);
    procedure FinishFlags;
    procedure LoadTextSettings(const AText: string);
    procedure LoadFontSettings(AFont: TFont);
    procedure LoadCollectionSettings(ACollection: TCollection);
    function DetachCollection: TCollection;
    function GetFontValue(AFont: TFont): string;
    property Flags: string read GetFlags;
    property Memo: TThemedRichEdit read FMemo;
  end;

type
  TThemedPropertyGridImagePreview = class(TCustomNimbusControl)
  private
    FPicture: TPicture;
  protected
    procedure Paint; override;
  public
    property Picture: TPicture read FPicture write FPicture;
  end;

  TThemedPropertyGridImageDialog = class(TThemedPropertyGridDialog)
  private
    FImage: TPicture;
    FPreview: TThemedPropertyGridImagePreview;
    FDetails: TThemedLabel;
    FOpenDialog: TOpenPictureDialog;
    FIconOnly: Boolean;
    FSourceFile: string;
    procedure BrowseClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure UpdatePreview;
  public
    constructor CreateImage(AOwner: TComponent; const ATitle: string; ASource: TPicture; AIconOnly: Boolean);
    destructor Destroy; override;
    function DetachImage: TPicture;
    property SourceFile: string read FSourceFile;
  end;

procedure TThemedPropertyGridImagePreview.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    if (Palette <> nil) and (FPicture <> nil) then TThemedPropertyGridRenderer.DrawImagePreview(RenderCanvas, Palette, ClientRect, FPicture.Graphic);
  finally
    RenderCanvas.EndRender;
  end;
end;

constructor TThemedPropertyGridImageDialog.CreateImage(AOwner: TComponent; const ATitle: string; ASource: TPicture; AIconOnly: Boolean);
var
  LButton: TThemedButton;
begin
  inherited CreateDialog(AOwner, ATitle, 390, 510);
  FImage := TPicture.Create;
  FImage.Assign(ASource);
  FIconOnly := AIconOnly;
  FOpenDialog := TOpenPictureDialog.Create(Self);
  if FIconOnly then FOpenDialog.Filter := 'Windows icons (*.ico)|*.ico';
  FPreview := TThemedPropertyGridImagePreview.Create(Self);
  FPreview.Parent := FSurface;
  FPreview.SetBounds(S(18), S(52), ClientWidth - S(36), S(238));
  FPreview.Anchors := [akLeft, akTop, akRight];
  FPreview.Picture := FImage;
  FDetails := TThemedLabel.Create(Self);
  FDetails.Parent := FSurface;
  FDetails.SetBounds(S(18), S(298), ClientWidth - S(36), S(22));
  FDetails.AutoSize := False;
  FDetails.UseMutedForeColor := True;
  LButton := TThemedButton.Create(Self);
  LButton.Parent := FSurface;
  LButton.SetBounds(S(18), ClientHeight - S(52), S(92), S(32));
  LButton.Caption := 'Browse...';
  LButton.OnClick := BrowseClick;
  LButton.Anchors := [akLeft, akBottom];
  LButton := TThemedButton.Create(Self);
  LButton.Parent := FSurface;
  LButton.SetBounds(S(118), ClientHeight - S(52), S(92), S(32));
  LButton.Caption := 'Clear';
  LButton.OnClick := ClearClick;
  LButton.Anchors := [akLeft, akBottom];
  UpdatePreview;
end;

destructor TThemedPropertyGridImageDialog.Destroy;
begin
  if FPreview <> nil then FPreview.Picture := nil;
  FImage.Free;
  inherited Destroy;
end;

procedure TThemedPropertyGridImageDialog.UpdatePreview;
begin
  if (FImage.Graphic = nil) or FImage.Graphic.Empty then FDetails.Caption := '(empty image)'
  else FDetails.Caption := Format('%s - %d x %d', [FImage.Graphic.ClassName, FImage.Width, FImage.Height]);
  FPreview.Invalidate;
end;

procedure TThemedPropertyGridImageDialog.BrowseClick(Sender: TObject);
var
  LNew: TPicture;
begin
  if not FOpenDialog.Execute(Handle) then Exit;
  LNew := TPicture.Create;
  try
    try
      LNew.LoadFromFile(FOpenDialog.FileName);
      if FIconOnly and not (LNew.Graphic is TIcon) then raise EInvalidGraphic.Create('The selected file is not a Windows icon');
      FImage.Assign(LNew);
      FSourceFile := FOpenDialog.FileName;
      UpdatePreview;
    except
      on E: Exception do FDetails.Caption := E.Message;
    end;
  finally
    LNew.Free;
  end;
end;

procedure TThemedPropertyGridImageDialog.ClearClick(Sender: TObject);
begin
  FImage.Assign(nil);
  FSourceFile := '';
  UpdatePreview;
end;

function TThemedPropertyGridImageDialog.DetachImage: TPicture;
begin
  Result := FImage;
  FPreview.Picture := nil;
  FImage := nil;
end;

function TThemedPropertyGridDialog.S(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, CurrentPPI, 96);
end;

constructor TThemedPropertyGridDialog.CreateDialog(AOwner: TComponent; const ATitle: string; AHeight: Integer; AWidth: Integer);
var
  LButton: TThemedButton;
begin
  inherited CreateNew(AOwner);
  BorderStyle := bsNone;
  Position := poOwnerFormCenter;
  ClientWidth := S(AWidth);
  ClientHeight := S(AHeight);
  KeyPreview := True;
  DoubleBuffered := True;
  FSurface := TThemedPanel.Create(Self);
  FSurface.Parent := Self;
  FSurface.Align := alClient;
  FSurface.CornerRadius := 0;
  FSurface.ShowBorder := True;
  FTitle := TThemedLabel.Create(Self);
  FTitle.Parent := FSurface;
  FTitle.AutoSize := False;
  FTitle.SetBounds(S(18), S(14), ClientWidth - S(36), S(28));
  FTitle.Caption := ATitle;
  FTitle.Font.Style := [fsBold];
  LButton := TThemedButton.Create(Self);
  LButton.Parent := FSurface;
  LButton.SetBounds(ClientWidth - S(110), ClientHeight - S(52), S(92), S(32));
  LButton.Caption := 'Cancel';
  LButton.Cancel := True;
  LButton.ModalResult := mrCancel;
  LButton.Anchors := [akRight, akBottom];
  LButton := TThemedButton.Create(Self);
  LButton.Parent := FSurface;
  LButton.SetBounds(ClientWidth - S(210), ClientHeight - S(52), S(92), S(32));
  LButton.Caption := 'OK';
  FOKButton := LButton;
  LButton.Default := True;
  LButton.ModalResult := mrOk;
  LButton.Anchors := [akRight, akBottom];
  FViewport := TThemedPanel.Create(Self);
  FViewport.Parent := FSurface;
  FViewport.SetBounds(S(16), S(52), ClientWidth - S(32), ClientHeight - S(120));
  FViewport.ShowBorder := True;
  FScroll := TThemedVScrollBar.Create(Self);
  FScroll.Parent := FSurface;
  FScroll.SetBounds(FViewport.Left + FViewport.Width - S(17), FViewport.Top + S(2), S(15), FViewport.Height - S(4));
  FScroll.Visible := False;
  FScroll.OnValueChanged := ScrollChanged;
end;

destructor TThemedPropertyGridDialog.Destroy;
begin
  if FCollectionGrid <> nil then FCollectionGrid.SelectedObject := nil;
  FCollection.Free;
  inherited Destroy;
end;

procedure TThemedPropertyGridDialog.RefreshCollectionList(AIndex: Integer);
var
  I, LSelectedIndex: Integer;
begin
  if (FCollection = nil) or (FCollectionList = nil) then Exit;
  FLoadingCollection := True;
  try
    FCollectionList.Items.BeginUpdate;
    try
      FCollectionList.Items.Clear;
      for I := 0 to FCollection.Count - 1 do
        FCollectionList.Items.Add(Format('[%d] %s', [I, FCollection.Items[I].DisplayName]));
    finally
      FCollectionList.Items.EndUpdate;
    end;
    LSelectedIndex := -1;
    if FCollection.Count > 0 then LSelectedIndex := EnsureRange(AIndex, 0, FCollection.Count - 1);
    FCollectionList.ItemIndex := LSelectedIndex;
  finally
    FLoadingCollection := False;
  end;
  CollectionSelected(FCollectionList);
end;

procedure TThemedPropertyGridDialog.CollectionSelected(Sender: TObject);
var
  LIndex: Integer;
begin
  if FLoadingCollection or (FCollectionGrid = nil) then Exit;
  LIndex := FCollectionList.ItemIndex;
  if (LIndex >= 0) and (LIndex < FCollection.Count) then FCollectionGrid.SelectedObject := FCollection.Items[LIndex]
  else FCollectionGrid.SelectedObject := nil;
  FCollectionRemove.Enabled := LIndex >= 0;
  FCollectionUp.Enabled := LIndex > 0;
  FCollectionDown.Enabled := (LIndex >= 0) and (LIndex < FCollection.Count - 1);
end;

procedure TThemedPropertyGridDialog.CollectionKeys(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then CollectionAction(FCollectionRemove)
  else if (ssCtrl in Shift) and (Key = VK_UP) then CollectionAction(FCollectionUp)
  else if (ssCtrl in Shift) and (Key = VK_DOWN) then CollectionAction(FCollectionDown)
  else Exit;
  Key := 0;
end;

procedure TThemedPropertyGridDialog.CollectionChanged(Sender: TObject);
var
  LIndex: Integer;
begin
  if FLoadingCollection then Exit;
  LIndex := FCollectionList.ItemIndex;
  if (LIndex >= 0) and (LIndex < FCollection.Count) then
    FCollectionList.Items[LIndex] := Format('[%d] %s', [LIndex, FCollection.Items[LIndex].DisplayName]);
end;

procedure TThemedPropertyGridDialog.CollectionAction(Sender: TObject);
var
  LIndex, LTargetIndex, LPreviousCount, I, LRestoreIndex: Integer;
  LBackup: TCollection;
  LBackupReady: Boolean;
  LOriginalItems: TArray<TCollectionItem>;
begin
  if FCollectionActionActive or FLoadingCollection or (FCollection = nil) or (FCollectionList = nil) then Exit;
  if (Sender <> FCollectionAdd) and (Sender <> FCollectionRemove) and (Sender <> FCollectionUp) and (Sender <> FCollectionDown) then Exit;
  LIndex := FCollectionList.ItemIndex;
  if Sender <> FCollectionAdd then
    if (LIndex < 0) or (LIndex >= FCollection.Count) then Exit;
  if (Sender = FCollectionUp) and (LIndex = 0) then Exit;
  if (Sender = FCollectionDown) and (LIndex = FCollection.Count - 1) then Exit;
  LRestoreIndex := LIndex;
  LBackup := nil;
  LBackupReady := False;
  FCollectionActionActive := True;
  try
    try
      FCollectionGrid.SelectedObject := nil;
      LBackup := TCollection.Create(FCollection.ItemClass);
      LBackup.Assign(FCollection);
      LBackupReady := True;
      LPreviousCount := FCollection.Count;
      SetLength(LOriginalItems, LPreviousCount);
      for I := 0 to LPreviousCount - 1 do LOriginalItems[I] := FCollection.Items[I];
      if Sender = FCollectionAdd then
      begin
        FCollection.Add;
        if FCollection.Count <> LPreviousCount + 1 then raise EPropertyError.Create('Collection add changed an unexpected number of items');
        LIndex := FCollection.Count - 1;
      end
      else if Sender = FCollectionRemove then
      begin
        FCollection.Items[LIndex].Free;
        if FCollection.Count <> LPreviousCount - 1 then raise EPropertyError.Create('Collection remove changed an unexpected number of items');
        for I := 0 to FCollection.Count - 1 do
          if FCollection.Items[I] <> LOriginalItems[I + Ord(I >= LIndex)] then
            raise EPropertyError.Create('Collection remove changed an unrelated item');
        LIndex := Min(LIndex, FCollection.Count - 1);
      end
      else
      begin
        if Sender = FCollectionUp then LTargetIndex := LIndex - 1 else LTargetIndex := LIndex + 1;
        FCollection.Items[LIndex].Index := LTargetIndex;
        if (FCollection.Count <> LPreviousCount) or (FCollection.Items[LTargetIndex] <> LOriginalItems[LIndex]) then
          raise EPropertyError.Create('Collection reorder changed unrelated items');
        LIndex := LTargetIndex;
      end;
      RefreshCollectionList(LIndex);
      FCollectionError.Caption := '';
    except
      on E: Exception do
      begin
        if LBackupReady then FCollection.Assign(LBackup);
        RefreshCollectionList(LRestoreIndex);
        FCollectionError.Caption := E.Message;
      end;
    end;
  finally
    FCollectionActionActive := False;
    LBackup.Free;
  end;
end;

procedure TThemedPropertyGridDialog.CollectionConfirm(Sender: TObject);
begin
  FCollectionGrid.SelectedObject := nil;
  ModalResult := mrOk;
end;

procedure TThemedPropertyGridDialog.LoadCollectionSettings(ACollection: TCollection);
var
  LButton: TThemedButton;
  I: Integer;
  LCaptions: array[0..3] of string;
begin
  if ACollection = nil then raise EArgumentNilException.Create('ACollection');
  FCollection := TCollection.Create(ACollection.ItemClass);
  FCollection.Assign(ACollection);
  FViewport.Visible := False;
  FScroll.Visible := False;
  FOKButton.ModalResult := mrNone;
  FOKButton.OnClick := CollectionConfirm;
  FCollectionList := TThemedListBox.Create(Self);
  FCollectionList.Parent := FSurface;
  FCollectionList.SetBounds(S(16), S(52), S(224), ClientHeight - S(180));
  FCollectionList.OnClick := CollectionSelected;
  FCollectionList.OnKeyDown := CollectionKeys;
  FCollectionGrid := TThemedPropertyGrid.Create(Self);
  FCollectionGrid.Parent := FSurface;
  FCollectionGrid.SetBounds(S(254), S(52), ClientWidth - S(270), ClientHeight - S(122));
  FCollectionGrid.ShowSearch := False;
  FCollectionGrid.OnPropertyValueChanged := CollectionChanged;
  LCaptions[0] := 'Add';
  LCaptions[1] := 'Remove';
  LCaptions[2] := 'Up';
  LCaptions[3] := 'Down';
  for I := 0 to 3 do
  begin
    LButton := TThemedButton.Create(Self);
    LButton.Parent := FSurface;
    LButton.SetBounds(S(16 + (I mod 2) * 114), ClientHeight - S(118) + (I div 2) * S(36), S(106), S(30));
    LButton.Caption := LCaptions[I];
    LButton.OnClick := CollectionAction;
    case I of
      0: FCollectionAdd := LButton;
      1: FCollectionRemove := LButton;
      2: FCollectionUp := LButton;
      3: FCollectionDown := LButton;
    end;
  end;
  FCollectionError := TThemedLabel.Create(Self);
  FCollectionError.Parent := FSurface;
  FCollectionError.AutoSize := False;
  FCollectionError.SetBounds(S(16), ClientHeight - S(42), S(220), S(20));
  FCollectionError.UseMutedForeColor := True;
  RefreshCollectionList(0);
end;

function TThemedPropertyGridDialog.DetachCollection: TCollection;
begin
  if FCollectionGrid <> nil then FCollectionGrid.SelectedObject := nil;
  Result := FCollection;
  FCollection := nil;
end;

procedure TThemedPropertyGridDialog.AddFlag(const AName: string; AChecked: Boolean);
var
  LCheck: TThemedCheckBox;
begin
  LCheck := TThemedCheckBox.Create(Self);
  LCheck.Parent := FViewport;
  LCheck.Caption := AName;
  LCheck.Checked := AChecked;
  SetLength(FChecks, Length(FChecks) + 1);
  FChecks[High(FChecks)] := LCheck;
end;

procedure TThemedPropertyGridDialog.LayoutChecks;
var
  I, LY, LHeight: Integer;
begin
  LHeight := S(29);
  for I := 0 to High(FChecks) do
  begin
    LY := S(4) + I * LHeight - FScroll.Value;
    FChecks[I].SetBounds(S(12), LY, FViewport.Width - S(34), LHeight);
    FChecks[I].Visible := (LY + LHeight > 0) and (LY < FViewport.Height);
  end;
end;

procedure TThemedPropertyGridDialog.FinishFlags;
var
  LTotal: Integer;
begin
  LTotal := S(8) + Length(FChecks) * S(29);
  FScroll.Visible := LTotal > FViewport.Height;
  FScroll.Minimum := 0;
  FScroll.LargeChange := Max(1, FViewport.Height);
  FScroll.Maximum := Max(0, LTotal - 1);
  FScroll.SmallChange := S(29);
  FAllButton := TThemedButton.Create(Self);
  FAllButton.Parent := FSurface;
  FAllButton.SetBounds(S(18), ClientHeight - S(52), S(72), S(32));
  FAllButton.Caption := 'All';
  FAllButton.OnClick := CheckAll;
  FNoneButton := TThemedButton.Create(Self);
  FNoneButton.Parent := FSurface;
  FNoneButton.SetBounds(S(98), ClientHeight - S(52), S(72), S(32));
  FNoneButton.Caption := 'None';
  FNoneButton.OnClick := CheckNone;
  LayoutChecks;
end;

procedure TThemedPropertyGridDialog.ScrollChanged(Sender: TObject);
begin
  LayoutChecks;
end;

procedure TThemedPropertyGridDialog.CheckAll(Sender: TObject);
var
  LCheck: TThemedCheckBox;
begin
  for LCheck in FChecks do LCheck.Checked := True;
end;

procedure TThemedPropertyGridDialog.CheckNone(Sender: TObject);
var
  LCheck: TThemedCheckBox;
begin
  for LCheck in FChecks do LCheck.Checked := False;
end;

function TThemedPropertyGridDialog.GetFlags: string;
var
  LCheck: TThemedCheckBox;
begin
  Result := '[';
  for LCheck in FChecks do
    if LCheck.Checked then
    begin
      if Result <> '[' then Result := Result + ',';
      Result := Result + LCheck.Caption;
    end;
  Result := Result + ']';
end;

procedure TThemedPropertyGridDialog.LoadTextSettings(const AText: string);
begin
  FViewport.Visible := False;
  FScroll.Visible := False;
  FMemo := TThemedRichEdit.Create(Self);
  FMemo.Parent := FSurface;
  FMemo.SetBounds(S(16), S(52), ClientWidth - S(32), ClientHeight - S(120));
  FMemo.Lines.Text := AText;
  FMemo.TabStop := True;
end;

procedure TThemedPropertyGridDialog.LoadFontSettings(AFont: TFont);
const
  CStyleNames: array[0..3] of string = ('Bold', 'Italic', 'Underline', 'Strikeout');
  CStyles: array[0..3] of TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
var
  LLabel: TThemedLabel;
  I: Integer;
begin
  FViewport.Visible := False;
  FScroll.Visible := False;
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := FSurface;
  LLabel.SetBounds(S(18), S(56), S(120), S(22));
  LLabel.Caption := 'Font family';
  FFontName := TThemedComboBox.Create(Self);
  FFontName.Parent := FSurface;
  FFontName.SetBounds(S(18), S(82), S(278), S(30));
  FFontName.Items.Assign(Screen.Fonts);
  if FFontName.Items.IndexOf(AFont.Name) < 0 then FFontName.Items.Add(AFont.Name);
  FFontName.ItemIndex := FFontName.Items.IndexOf(AFont.Name);
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := FSurface;
  LLabel.SetBounds(S(310), S(56), S(90), S(22));
  LLabel.Caption := 'Size';
  FFontSize := TThemedNumericUpDown.Create(Self);
  FFontSize.Parent := FSurface;
  FFontSize.SetBounds(S(310), S(82), S(90), S(30));
  FFontSize.Minimum := 1;
  FFontSize.Maximum := 200;
  FFontSize.DecimalPlaces := 0;
  FFontSize.Value := EnsureRange(AFont.Size, 1, 200);
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := FSurface;
  LLabel.SetBounds(S(18), S(124), S(200), S(22));
  LLabel.Caption := 'Font style';
  for I := 0 to High(FFontStyles) do
  begin
    FFontStyles[I] := TThemedCheckBox.Create(Self);
    FFontStyles[I].Parent := FSurface;
    FFontStyles[I].SetBounds(S(18 + (I mod 2) * 194), S(150 + (I div 2) * 32), S(184), S(28));
    FFontStyles[I].Caption := CStyleNames[I];
    FFontStyles[I].Checked := CStyles[I] in AFont.Style;
  end;
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := FSurface;
  LLabel.SetBounds(S(18), S(224), S(210), S(22));
  LLabel.Caption := 'Font color';
  FFontColor := TThemedIdeColorPickerButton.Create(Self);
  FFontColor.Parent := FSurface;
  FFontColor.SetBounds(S(18), S(250), S(382), S(30));
  FFontColor.ButtonText := 'Choose font color';
  FFontColor.PaletteMode := icpmAll;
  FFontColor.CommitMode := iccmOkCancel;
  FFontColor.SelectedColor := AFont.Color;
end;

function TThemedPropertyGridDialog.GetFontValue(AFont: TFont): string;
var
  LFont: TFont;
  LStyles: TFontStyles;
begin
  FFontColor.CloseDropDown;
  LFont := TFont.Create;
  try
    LFont.Assign(AFont);
    LFont.Name := FFontName.Text;
    LFont.Size := Round(FFontSize.Value);
    LStyles := [];
    if FFontStyles[0].Checked then Include(LStyles, fsBold);
    if FFontStyles[1].Checked then Include(LStyles, fsItalic);
    if FFontStyles[2].Checked then Include(LStyles, fsUnderline);
    if FFontStyles[3].Checked then Include(LStyles, fsStrikeOut);
    LFont.Style := LStyles;
    LFont.Color := FFontColor.SelectedColor;
    Result := NimbusPropertyGridFontValue(LFont);
  finally
    LFont.Free;
  end;
end;

function NimbusEditPropertyFlags(AOwner: TComponent; const ATitle: string; AType: PTypeInfo; const ACurrent: string; out AResult: string): Boolean;
var
  LDialog: TThemedPropertyGridDialog;
  LNames: TArray<string>;
  LName: string;
  LChosen: Boolean;
  I, J, LCount: Integer;
begin
  Result := False;
  if AType = nil then Exit;
  LNames := StringReplace(StringReplace(ACurrent, '[', '', [rfReplaceAll]), ']', '', [rfReplaceAll]).Split([',']);
  LCount := GetTypeData(AType).MaxValue - GetTypeData(AType).MinValue + 1;
  LDialog := TThemedPropertyGridDialog.CreateDialog(AOwner, ATitle, EnsureRange(132 + LCount * 29, 220, 510));
  try
    for I := GetTypeData(AType).MinValue to GetTypeData(AType).MaxValue do
    begin
      LName := GetEnumName(AType, I);
      if LName = '' then Continue;
      LChosen := False;
      for J := 0 to High(LNames) do
        if SameText(Trim(LNames[J]), LName) then
        begin
          LChosen := True;
          Break;
        end;
      LDialog.AddFlag(LName, LChosen);
    end;
    LDialog.FinishFlags;
    Result := LDialog.ShowModal = mrOk;
    if Result then AResult := LDialog.Flags;
  finally
    LDialog.Free;
  end;
end;

function NimbusEditPropertyText(AOwner: TComponent; const ATitle, ACurrent: string; out AResult: string): Boolean;
var
  LDialog: TThemedPropertyGridDialog;
begin
  LDialog := TThemedPropertyGridDialog.CreateDialog(AOwner, ATitle, 420);
  try
    LDialog.LoadTextSettings(ACurrent);
    Result := LDialog.ShowModal = mrOk;
    if Result then AResult := LDialog.Memo.Lines.Text;
  finally
    LDialog.Free;
  end;
end;

function NimbusEditPropertyFont(AOwner: TComponent; const ATitle: string; AFont: TFont; out AResult: string): Boolean;
var
  LDialog: TThemedPropertyGridDialog;
begin
  Result := False;
  if AFont = nil then Exit;
  LDialog := TThemedPropertyGridDialog.CreateDialog(AOwner, ATitle, 360);
  try
    LDialog.LoadFontSettings(AFont);
    Result := LDialog.ShowModal = mrOk;
    if Result then AResult := LDialog.GetFontValue(AFont);
  finally
    LDialog.Free;
  end;
end;

function NimbusEditPropertyCollection(AOwner: TComponent; const ATitle: string; ACollection: TCollection; out AEdited: TCollection): Boolean;
var
  LDialog: TThemedPropertyGridDialog;
begin
  Result := False;
  AEdited := nil;
  if ACollection = nil then Exit;
  LDialog := TThemedPropertyGridDialog.CreateDialog(AOwner, ATitle, 480, 740);
  try
    LDialog.LoadCollectionSettings(ACollection);
    Result := LDialog.ShowModal = mrOk;
    if Result then AEdited := LDialog.DetachCollection;
  finally
    LDialog.Free;
  end;
end;

function NimbusEditPropertyImage(AOwner: TComponent; const ATitle: string; ASource: TPicture; AIconOnly: Boolean; out AEdited: TPicture; out ASourceFile: string): Boolean;
var
  LDialog: TThemedPropertyGridImageDialog;
begin
  Result := False;
  AEdited := nil;
  ASourceFile := '';
  if ASource = nil then Exit;
  LDialog := TThemedPropertyGridImageDialog.CreateImage(AOwner, ATitle, ASource, AIconOnly);
  try
    if LDialog.ShowModal = mrOk then
    begin
      AEdited := LDialog.DetachImage;
      ASourceFile := LDialog.SourceFile;
      Result := True;
    end;
  finally
    LDialog.Free;
  end;
end;

end.
