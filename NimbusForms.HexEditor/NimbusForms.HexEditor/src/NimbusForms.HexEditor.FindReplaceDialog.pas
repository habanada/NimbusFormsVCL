unit NimbusForms.HexEditor.FindReplaceDialog;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.HexEditor.FindReplaceTypes;

type
  THexFindReplaceDialog = class(TForm)
  private
    FPixelsPerInch: Integer;
    FMode: THexFindReplaceMode;
    FFindLabel: TLabel;
    FReplaceLabel: TLabel;
    FFindEdit: TEdit;
    FReplaceEdit: TEdit;
    FMatchCaseBox: TCheckBox;
    FWholeWordBox: TCheckBox;
    FRegexBox: TCheckBox;
    FWrapBox: TCheckBox;
    FDirectionLabel: TLabel;
    FDirectionPanel: TPanel;
    FDirectionUpButton: TRadioButton;
    FDirectionDownButton: TRadioButton;
    FScopeLabel: TLabel;
    FScopePanel: TPanel;
    FScopeDocumentButton: TRadioButton;
    FScopeSelectionButton: TRadioButton;
    FFindNextButton: TButton;
    FFindPreviousButton: TButton;
    FReplaceButton: TButton;
    FReplaceAllButton: TButton;
    FCloseButton: TButton;
    FStatusLabel: TLabel;
    FOnFindNextRequested: THexFindReplaceEvent;
    FOnFindPreviousRequested: THexFindReplaceEvent;
    FOnReplaceRequested: THexFindReplaceEvent;
    FOnReplaceAllRequested: THexFindReplaceEvent;
    FOnDialogClosed: TNotifyEvent;
    function S(const AValue: Integer): Integer;
    function CreateLabel(const AText: string): TLabel;
    function CreateEdit: TEdit;
    function CreateCheckBox(const AText: string; const AChecked: Boolean): TCheckBox;
    function CreatePanel: TPanel;
    function CreateRadio(const AParent: TWinControl; const AText: string; const AChecked: Boolean): TRadioButton;
    function CreateButton(const AText: string): TButton;
    procedure SetMode(const AValue: THexFindReplaceMode);
    function GetMatchCase: Boolean;
    function GetFindText: string;
    procedure SetFindText(const AValue: string);
    function BuildOptions: THexFindReplaceOptions;
    procedure Raise_(const AEvent: THexFindReplaceEvent);
    procedure ShowStatus(const AMessage: string; const ASuccess: Boolean);
    procedure ApplyLayout;
    procedure FindNextClick(ASender: TObject);
    procedure FindPreviousClick(ASender: TObject);
    procedure ReplaceClick(ASender: TObject);
    procedure ReplaceAllClick(ASender: TObject);
    procedure CloseClick(ASender: TObject);
    procedure DialogClose(ASender: TObject; var AAction: TCloseAction);
    procedure DialogKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
  public
    constructor CreateDialog(const AOwner: TComponent; const APixelsPerInch: Integer);
    procedure ApplyColors(const ABackColor, AForeColor, AInputBackColor, AInputForeColor: TThemeColor);
    procedure FocusFindText;
    property Mode: THexFindReplaceMode read FMode write SetMode;
    property MatchCase: Boolean read GetMatchCase;
    property FindText: string read GetFindText write SetFindText;
    property OnFindNextRequested: THexFindReplaceEvent read FOnFindNextRequested write FOnFindNextRequested;
    property OnFindPreviousRequested: THexFindReplaceEvent read FOnFindPreviousRequested write FOnFindPreviousRequested;
    property OnReplaceRequested: THexFindReplaceEvent read FOnReplaceRequested write FOnReplaceRequested;
    property OnReplaceAllRequested: THexFindReplaceEvent read FOnReplaceAllRequested write FOnReplaceAllRequested;
    property OnDialogClosed: TNotifyEvent read FOnDialogClosed write FOnDialogClosed;
  end;

implementation

uses
  NimbusForms.HexEditor.Strings;

type
  TStr = HexFindReplaceTexts;

constructor THexFindReplaceDialog.CreateDialog(const AOwner: TComponent; const APixelsPerInch: Integer);
begin
  inherited CreateNew(AOwner);
  Scaled := False;
  Name := TStr.DialogName;
  FPixelsPerInch := APixelsPerInch;
  if FPixelsPerInch <= 0 then
    FPixelsPerInch := Screen.PixelsPerInch;
  BorderStyle := bsDialog;
  BorderIcons := [biSystemMenu];
  Position := poOwnerFormCenter;
  KeyPreview := True;
  Font.Name := TStr.FontName;
  Font.Height := -MulDiv(9, FPixelsPerInch, 72);
  ClientWidth := S(500);

  FFindLabel := CreateLabel(TStr.LabelFind);
  FReplaceLabel := CreateLabel(TStr.LabelReplace);
  FFindEdit := CreateEdit;
  FReplaceEdit := CreateEdit;
  FMatchCaseBox := CreateCheckBox(TStr.OptionMatchCase, False);
  FWholeWordBox := CreateCheckBox(TStr.OptionWholeWord, False);
  FRegexBox := CreateCheckBox(TStr.OptionRegex, False);
  FWrapBox := CreateCheckBox(TStr.OptionWrap, True);
  FDirectionLabel := CreateLabel(TStr.LabelDirection);
  FDirectionPanel := CreatePanel;
  FDirectionUpButton := CreateRadio(FDirectionPanel, TStr.DirectionUp, False);
  FDirectionDownButton := CreateRadio(FDirectionPanel, TStr.DirectionDown, True);
  FScopeLabel := CreateLabel(TStr.LabelScope);
  FScopePanel := CreatePanel;
  FScopeDocumentButton := CreateRadio(FScopePanel, TStr.ScopeDocument, True);
  FScopeSelectionButton := CreateRadio(FScopePanel, TStr.ScopeSelection, False);
  FFindNextButton := CreateButton(TStr.ButtonFindNext);
  FFindPreviousButton := CreateButton(TStr.ButtonFindPrevious);
  FReplaceButton := CreateButton(TStr.ButtonReplace);
  FReplaceAllButton := CreateButton(TStr.ButtonReplaceAll);
  FCloseButton := CreateButton(TStr.ButtonClose);
  FStatusLabel := CreateLabel('');
  FDirectionLabel.Font.Style := [fsBold];
  FScopeLabel.Font.Style := [fsBold];

  FFindNextButton.OnClick := FindNextClick;
  FFindPreviousButton.OnClick := FindPreviousClick;
  FReplaceButton.OnClick := ReplaceClick;
  FReplaceAllButton.OnClick := ReplaceAllClick;
  FCloseButton.OnClick := CloseClick;
  OnClose := DialogClose;
  OnKeyDown := DialogKeyDown;
  FMode := hfmFind;
  ApplyLayout;
end;

function THexFindReplaceDialog.S(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, FPixelsPerInch, 96);
end;

function THexFindReplaceDialog.CreateLabel(const AText: string): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.AutoSize := False;
  Result.Transparent := True;
  Result.Layout := tlCenter;
  Result.Parent := Self;
  Result.Caption := AText;
end;

function THexFindReplaceDialog.CreateEdit: TEdit;
begin
  Result := TEdit.Create(Self);
  Result.AutoSize := False;
  Result.Height := S(24);
  Result.Parent := Self;
end;

function THexFindReplaceDialog.CreateCheckBox(const AText: string; const AChecked: Boolean): TCheckBox;
begin
  Result := TCheckBox.Create(Self);
  Result.Parent := Self;
  Result.Caption := AText;
  Result.Checked := AChecked;
end;

function THexFindReplaceDialog.CreatePanel: TPanel;
begin
  Result := TPanel.Create(Self);
  Result.BevelOuter := bvNone;
  Result.ShowCaption := False;
  Result.ParentBackground := True;
  Result.Parent := Self;
end;

function THexFindReplaceDialog.CreateRadio(const AParent: TWinControl; const AText: string;
  const AChecked: Boolean): TRadioButton;
begin
  Result := TRadioButton.Create(Self);
  Result.Parent := AParent;
  Result.Caption := AText;
  Result.Checked := AChecked;
end;

function THexFindReplaceDialog.CreateButton(const AText: string): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := Self;
  Result.Caption := AText;
end;

procedure THexFindReplaceDialog.ApplyLayout;
var
  LOptionsTop: Integer;
  LGroupTop: Integer;
  LButtonTop: Integer;
  LReplace: Boolean;
begin
  LReplace := FMode = hfmReplace;
  if LReplace then
    Caption := TStr.DialogTitleReplace
  else
    Caption := TStr.DialogTitleFind;
  FFindLabel.SetBounds(S(14), S(14), S(92), S(24));
  FFindEdit.SetBounds(S(110), S(14), S(250), S(24));
  FReplaceLabel.Visible := LReplace;
  FReplaceEdit.Visible := LReplace;
  FReplaceButton.Visible := LReplace;
  FReplaceAllButton.Visible := LReplace;
  FReplaceLabel.SetBounds(S(14), S(46), S(92), S(24));
  FReplaceEdit.SetBounds(S(110), S(46), S(250), S(24));
  if LReplace then
    LOptionsTop := S(82)
  else
    LOptionsTop := S(50);
  FMatchCaseBox.SetBounds(S(14), LOptionsTop, S(170), S(22));
  FWholeWordBox.SetBounds(S(190), LOptionsTop, S(170), S(22));
  FRegexBox.SetBounds(S(14), LOptionsTop + S(24), S(170), S(22));
  FWrapBox.SetBounds(S(190), LOptionsTop + S(24), S(170), S(22));
  LGroupTop := LOptionsTop + S(58);
  FDirectionLabel.SetBounds(S(14), LGroupTop, S(80), S(22));
  FDirectionPanel.SetBounds(S(14), LGroupTop + S(24), S(170), S(24));
  FDirectionUpButton.SetBounds(0, S(1), S(80), S(22));
  FDirectionDownButton.SetBounds(S(86), S(1), S(80), S(22));
  FScopeLabel.SetBounds(S(190), LGroupTop, S(80), S(22));
  FScopePanel.SetBounds(S(190), LGroupTop + S(24), S(180), S(24));
  FScopeDocumentButton.SetBounds(0, S(1), S(88), S(22));
  FScopeSelectionButton.SetBounds(S(94), S(1), S(84), S(22));
  FFindNextButton.SetBounds(S(376), S(14), S(110), S(26));
  FFindPreviousButton.SetBounds(S(376), S(46), S(110), S(26));
  FReplaceButton.SetBounds(S(376), S(78), S(110), S(26));
  FReplaceAllButton.SetBounds(S(376), S(110), S(110), S(26));
  if LReplace then
    LButtonTop := S(142)
  else
    LButtonTop := S(78);
  FCloseButton.SetBounds(S(376), LButtonTop, S(110), S(26));
  FStatusLabel.SetBounds(S(14), LGroupTop + S(56), S(472), S(22));
  ClientHeight := LGroupTop + S(86);
end;

procedure THexFindReplaceDialog.SetMode(const AValue: THexFindReplaceMode);
begin
  FMode := AValue;
  ApplyLayout;
end;

function THexFindReplaceDialog.GetMatchCase: Boolean;
begin
  Result := FMatchCaseBox.Checked;
end;

function THexFindReplaceDialog.GetFindText: string;
begin
  Result := FFindEdit.Text;
end;

procedure THexFindReplaceDialog.SetFindText(const AValue: string);
begin
  FFindEdit.Text := AValue;
end;

function THexFindReplaceDialog.BuildOptions: THexFindReplaceOptions;
begin
  Result.FindText := FFindEdit.Text;
  Result.ReplaceText := FReplaceEdit.Text;
  if FDirectionUpButton.Checked then
    Result.Direction := hfdUp
  else
    Result.Direction := hfdDown;
  if FScopeSelectionButton.Checked then
    Result.Scope := hfsSelection
  else
    Result.Scope := hfsDocument;
  Result.MatchCase := FMatchCaseBox.Checked;
  Result.MatchWholeWord := FWholeWordBox.Checked;
  Result.UseRegex := FRegexBox.Checked;
  Result.WrapSearch := FWrapBox.Checked;
end;

procedure THexFindReplaceDialog.ShowStatus(const AMessage: string; const ASuccess: Boolean);
begin
  if ASuccess then
    FStatusLabel.Font.Color := TColor($0050AF4C)
  else
    FStatusLabel.Font.Color := TColor($005353E5);
  FStatusLabel.Caption := AMessage;
end;

procedure THexFindReplaceDialog.Raise_(const AEvent: THexFindReplaceEvent);
var
  LArgs: THexFindReplaceEventArgs;
begin
  if not Assigned(AEvent) then
    Exit;
  LArgs := THexFindReplaceEventArgs.Create(BuildOptions);
  try
    AEvent(Self, LArgs);
    if LArgs.Message <> '' then
      ShowStatus(LArgs.Message, LArgs.Success);
  finally
    LArgs.Free;
  end;
end;

procedure THexFindReplaceDialog.FindNextClick(ASender: TObject);
begin
  Raise_(FOnFindNextRequested);
end;

procedure THexFindReplaceDialog.FindPreviousClick(ASender: TObject);
begin
  Raise_(FOnFindPreviousRequested);
end;

procedure THexFindReplaceDialog.ReplaceClick(ASender: TObject);
begin
  Raise_(FOnReplaceRequested);
end;

procedure THexFindReplaceDialog.ReplaceAllClick(ASender: TObject);
begin
  Raise_(FOnReplaceAllRequested);
end;

procedure THexFindReplaceDialog.CloseClick(ASender: TObject);
begin
  Close;
end;

procedure THexFindReplaceDialog.DialogClose(ASender: TObject; var AAction: TCloseAction);
begin
  AAction := caFree;
  if Assigned(FOnDialogClosed) then
    FOnDialogClosed(Self);
end;

procedure THexFindReplaceDialog.DialogKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
begin
  if AKey = VK_ESCAPE then
  begin
    AKey := 0;
    Close;
    Exit;
  end;
  if (AKey = VK_RETURN) and ((ActiveControl = FFindEdit) or (ActiveControl = FReplaceEdit)) then
  begin
    AKey := 0;
    if ssShift in AShift then
      Raise_(FOnFindPreviousRequested)
    else
      Raise_(FOnFindNextRequested);
  end;
end;

procedure THexFindReplaceDialog.FocusFindText;
begin
  if FFindEdit.CanFocus then
  begin
    FFindEdit.SetFocus;
    FFindEdit.SelectAll;
  end;
end;

procedure THexFindReplaceDialog.ApplyColors(const ABackColor, AForeColor, AInputBackColor,
  AInputForeColor: TThemeColor);
var
  I: Integer;
  LControl: TControl;
begin
  Color := ThemeColorToColor(ABackColor);
  Font.Color := ThemeColorToColor(AForeColor);
  for I := 0 to ControlCount - 1 do
  begin
    LControl := Controls[I];
    if LControl is TLabel then
    begin
      if LControl <> FStatusLabel then
        TLabel(LControl).Font.Color := ThemeColorToColor(AForeColor);
    end
    else if LControl is TCheckBox then
    begin
      TCheckBox(LControl).StyleElements := [seBorder];
      TCheckBox(LControl).Font.Color := ThemeColorToColor(AForeColor);
    end
    else if LControl is TEdit then
    begin
      TEdit(LControl).StyleElements := [];
      TEdit(LControl).Color := ThemeColorToColor(AInputBackColor);
      TEdit(LControl).Font.Color := ThemeColorToColor(AInputForeColor);
    end;
  end;
  FDirectionUpButton.StyleElements := [seBorder];
  FDirectionUpButton.Font.Color := ThemeColorToColor(AForeColor);
  FDirectionDownButton.StyleElements := [seBorder];
  FDirectionDownButton.Font.Color := ThemeColorToColor(AForeColor);
  FScopeDocumentButton.StyleElements := [seBorder];
  FScopeDocumentButton.Font.Color := ThemeColorToColor(AForeColor);
  FScopeSelectionButton.StyleElements := [seBorder];
  FScopeSelectionButton.Font.Color := ThemeColorToColor(AForeColor);
  Invalidate;
end;

end.
