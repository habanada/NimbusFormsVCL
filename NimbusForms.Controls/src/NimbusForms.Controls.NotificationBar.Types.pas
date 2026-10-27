{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.NotificationBar.Types;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections, Vcl.ActnList, Vcl.Graphics,
  NimbusForms.Theming.Types, NimbusForms.Rendering.Markup;

type
  TNimbusNotificationSeverity = (nnsInfo, nnsSuccess, nnsWarning, nnsError, nnsCustom);
  TNimbusNotificationDisplayMode = (nndStack, nndCarousel);
  TNimbusNotificationActionStyle = (nnasLink, nnasCompactButton);
  TNimbusNotificationDismissReason = (nndrManual, nndrAction, nndrExpired, nndrDismissAll);

  TThemedIdeNotificationAction = class(TCollectionItem)
  private
    FText: string;
    FEnabled, FClosesNotification: Boolean;
    FStyle: TNimbusNotificationActionStyle;
    FAction: TCustomAction;
    FOnClick: TNotifyEvent;
    procedure SetText(const AValue: string);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetClosesNotification(const AValue: Boolean);
    procedure SetStyle(const AValue: TNimbusNotificationActionStyle);
    procedure SetAction(const AValue: TCustomAction);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function DisplayText: string;
    function IsEnabled: Boolean;
    function IsVisible: Boolean;
    procedure Execute(Sender: TObject);
  published
    property Text: string read FText write SetText;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property ClosesNotification: Boolean read FClosesNotification write SetClosesNotification default False;
    property Style: TNimbusNotificationActionStyle read FStyle write SetStyle default nnasLink;
    property Action: TCustomAction read FAction write SetAction;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TThemedIdeNotificationActions = class(TOwnedCollection)
  private
    function GetItem(const AIndex: Integer): TThemedIdeNotificationAction;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedIdeNotificationAction;
    property Items[const AIndex: Integer]: TThemedIdeNotificationAction read GetItem; default;
  end;

  TThemedIdeNotificationMessage = class(TCollectionItem)
  private
    FID, FText, FCustomGlyph: string;
    FSeverity: TNimbusNotificationSeverity;
    FPriority, FAutoDismissMilliseconds: Integer;
    FSticky, FCompact, FUseMarkdown: Boolean;
    FCustomColor: TThemeColor;
    FActions: TThemedIdeNotificationActions;
    FPicture: TPicture;
    FMarkup: TThemedMarkupRenderer;
    FPrepared: Boolean;
    FDestroying: Boolean;
    FCreatedTick: UInt64;
    procedure SetText(const AValue: string);
    procedure SetCustomGlyph(const AValue: string);
    procedure SetSeverity(const AValue: TNimbusNotificationSeverity);
    procedure SetPriority(const AValue: Integer);
    procedure SetAutoDismissMilliseconds(const AValue: Integer);
    procedure SetSticky(const AValue: Boolean);
    procedure SetCompact(const AValue: Boolean);
    procedure SetUseMarkdown(const AValue: Boolean);
    procedure SetCustomColor(const AValue: TThemeColor);
    procedure SetActions(const AValue: TThemedIdeNotificationActions);
    procedure SetPicture(const AValue: TPicture);
    procedure PictureChanged(Sender: TObject);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function PrepareText(const AFont: TFont): TThemedMarkupRenderer;
    procedure ActionsChanged;
    property ID: string read FID;
    property CreatedTick: UInt64 read FCreatedTick;
    property Destroying: Boolean read FDestroying;
  published
    property Text: string read FText write SetText;
    property Severity: TNimbusNotificationSeverity read FSeverity write SetSeverity default nnsInfo;
    property Priority: Integer read FPriority write SetPriority default 0;
    property AutoDismissMilliseconds: Integer read FAutoDismissMilliseconds write SetAutoDismissMilliseconds default 0;
    property Sticky: Boolean read FSticky write SetSticky default False;
    property Compact: Boolean read FCompact write SetCompact default False;
    property UseMarkdown: Boolean read FUseMarkdown write SetUseMarkdown default False;
    property CustomColor: TThemeColor read FCustomColor write SetCustomColor default 0;
    property CustomGlyph: string read FCustomGlyph write SetCustomGlyph;
    property Picture: TPicture read FPicture write SetPicture;
    property Actions: TThemedIdeNotificationActions read FActions write SetActions;
  end;

  TThemedIdeNotificationMessages = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(const AIndex: Integer): TThemedIdeNotificationMessage;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; const AOnChange: TNotifyEvent);
    function Add: TThemedIdeNotificationMessage;
    function FindID(const AID: string): TThemedIdeNotificationMessage;
    function DisplayOrder: TArray<Integer>;
    property Items[const AIndex: Integer]: TThemedIdeNotificationMessage read GetItem; default;
  end;

  TNimbusNotificationDismissEvent = procedure(Sender: TObject; const AID: string;
    const AReason: TNimbusNotificationDismissReason) of object;
  TNimbusNotificationActionEvent = procedure(Sender: TObject; AMessage: TThemedIdeNotificationMessage;
    AAction: TThemedIdeNotificationAction) of object;
  TNimbusNotificationLinkEvent = procedure(Sender: TObject; const AID, AURL: string) of object;
  TNimbusNotificationClosingEvent = procedure(Sender: TObject; AMessage: TThemedIdeNotificationMessage;
    const AReason: TNimbusNotificationDismissReason; var AAllow: Boolean) of object;
  TNimbusNotificationNavigationEvent = procedure(Sender: TObject; const AID: string;
    const AIndex, ACount: Integer) of object;

implementation

uses Winapi.Windows, System.Generics.Defaults, NimbusForms.Rendering.Markdown;

constructor TThemedIdeNotificationAction.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
end;

procedure TThemedIdeNotificationAction.Assign(Source: TPersistent);
var A: TThemedIdeNotificationAction;
begin
  if not (Source is TThemedIdeNotificationAction) then begin inherited; Exit; end;
  A := TThemedIdeNotificationAction(Source);
  FText := A.Text;
  FEnabled := A.Enabled;
  FClosesNotification := A.ClosesNotification;
  FStyle := A.Style;
  FAction := A.Action;
  FOnClick := A.OnClick;
  Changed(False);
end;

function TThemedIdeNotificationAction.DisplayText: string;
begin
  if FAction <> nil then Result := FAction.Caption else Result := FText;
end;

function TThemedIdeNotificationAction.IsEnabled: Boolean;
begin
  Result := FEnabled and ((FAction = nil) or FAction.Enabled);
end;

procedure TThemedIdeNotificationAction.Execute(Sender: TObject);
begin
  if not IsEnabled or not IsVisible then Exit;
  if FAction <> nil then FAction.Execute else if Assigned(FOnClick) then FOnClick(Sender);
end;

function TThemedIdeNotificationAction.IsVisible: Boolean;
begin
  Result := (FAction = nil) or FAction.Visible;
end;

constructor TThemedIdeNotificationActions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TThemedIdeNotificationAction);
end;

function TThemedIdeNotificationActions.Add: TThemedIdeNotificationAction;
begin
  Result := TThemedIdeNotificationAction(inherited Add);
end;

function TThemedIdeNotificationActions.GetItem(const AIndex: Integer): TThemedIdeNotificationAction;
begin
  Result := TThemedIdeNotificationAction(inherited Items[AIndex]);
end;

procedure TThemedIdeNotificationActions.Update(Item: TCollectionItem);
begin
  inherited;
  if (GetOwner is TThemedIdeNotificationMessage) and not TThemedIdeNotificationMessage(GetOwner).Destroying then
    TThemedIdeNotificationMessage(GetOwner).ActionsChanged;
end;

constructor TThemedIdeNotificationMessage.Create(Collection: TCollection);
var G: TGUID;
begin
  inherited Create(Collection);
  CreateGUID(G);
  FID := GUIDToString(G);
  FCreatedTick := GetTickCount64;
  FActions := TThemedIdeNotificationActions.Create(Self);
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FMarkup := TThemedMarkupRenderer.Create;
  Changed(False);
end;

destructor TThemedIdeNotificationMessage.Destroy;
begin
  FDestroying := True;
  FPicture.OnChange := nil;
  FPicture.Free;
  FActions.Free;
  FMarkup.Free;
  inherited Destroy;
end;

procedure TThemedIdeNotificationMessage.Assign(Source: TPersistent);
var M: TThemedIdeNotificationMessage;
begin
  if not (Source is TThemedIdeNotificationMessage) then begin inherited; Exit; end;
  M := TThemedIdeNotificationMessage(Source);
  FText := M.Text;
  FSeverity := M.Severity;
  FPriority := M.Priority;
  FAutoDismissMilliseconds := M.AutoDismissMilliseconds;
  FSticky := M.Sticky;
  FCompact := M.Compact;
  FUseMarkdown := M.UseMarkdown;
  FCustomColor := M.CustomColor;
  FCustomGlyph := M.CustomGlyph;
  FActions.Assign(M.Actions);
  FPicture.Assign(M.Picture);
  FPrepared := False;
  Changed(False);
end;

function TThemedIdeNotificationMessage.PrepareText(const AFont: TFont): TThemedMarkupRenderer;
begin
  if not FPrepared then
  begin
    if FUseMarkdown then FMarkup.SetSpans(TNimbusMarkdownParser.Parse(FText))
    else FMarkup.SetText(FText, False);
    FPrepared := True;
  end;
  FMarkup.SetFont(AFont);
  Result := FMarkup;
end;

procedure TThemedIdeNotificationMessage.ActionsChanged;
begin
  if not FDestroying then Changed(False);
end;

procedure TThemedIdeNotificationMessage.PictureChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetActions(const AValue: TThemedIdeNotificationActions);
begin
  FActions.Assign(AValue);
end;

procedure TThemedIdeNotificationMessage.SetPicture(const AValue: TPicture);
begin
  FPicture.Assign(AValue);
end;

constructor TThemedIdeNotificationMessages.Create(AOwner: TPersistent; const AOnChange: TNotifyEvent);
begin
  inherited Create(AOwner, TThemedIdeNotificationMessage);
  FOnChange := AOnChange;
end;

function TThemedIdeNotificationMessages.Add: TThemedIdeNotificationMessage;
begin
  Result := TThemedIdeNotificationMessage(inherited Add);
end;

function TThemedIdeNotificationMessages.GetItem(const AIndex: Integer): TThemedIdeNotificationMessage;
begin
  Result := TThemedIdeNotificationMessage(inherited Items[AIndex]);
end;

function TThemedIdeNotificationMessages.FindID(const AID: string): TThemedIdeNotificationMessage;
var I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do if Items[I].ID = AID then Exit(Items[I]);
end;

function TThemedIdeNotificationMessages.DisplayOrder: TArray<Integer>;
var I: Integer;
begin
  SetLength(Result, Count);
  for I := 0 to Count - 1 do Result[I] := I;
  TArray.Sort<Integer>(Result, TComparer<Integer>.Construct(
    function(const L, R: Integer): Integer
    begin
      if Items[L].Priority > Items[R].Priority then Result := -1
      else if Items[L].Priority < Items[R].Priority then Result := 1
      else if L < R then Result := -1 else if L > R then Result := 1 else Result := 0;
    end));
end;

procedure TThemedIdeNotificationMessages.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedIdeNotificationAction.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationAction.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationAction.SetClosesNotification(const AValue: Boolean);
begin
  if FClosesNotification = AValue then Exit;
  FClosesNotification := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationAction.SetStyle(const AValue: TNimbusNotificationActionStyle);
begin
  if FStyle = AValue then Exit;
  FStyle := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationAction.SetAction(const AValue: TCustomAction);
begin
  if FAction = AValue then Exit;
  FAction := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue;
  FPrepared := False;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetCustomGlyph(const AValue: string);
begin
  if FCustomGlyph = AValue then Exit;
  FCustomGlyph := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetSeverity(const AValue: TNimbusNotificationSeverity);
begin
  if FSeverity = AValue then Exit;
  FSeverity := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetPriority(const AValue: Integer);
begin
  if FPriority = AValue then Exit;
  FPriority := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetAutoDismissMilliseconds(const AValue: Integer);
begin
  if AValue < 0 then raise EArgumentOutOfRangeException.Create('AutoDismissMilliseconds');
  if FAutoDismissMilliseconds = AValue then Exit;
  FAutoDismissMilliseconds := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetSticky(const AValue: Boolean);
begin
  if FSticky = AValue then Exit;
  FSticky := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetCompact(const AValue: Boolean);
begin
  if FCompact = AValue then Exit;
  FCompact := AValue;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetUseMarkdown(const AValue: Boolean);
begin
  if FUseMarkdown = AValue then Exit;
  FUseMarkdown := AValue;
  FPrepared := False;
  Changed(False);
end;

procedure TThemedIdeNotificationMessage.SetCustomColor(const AValue: TThemeColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Changed(False);
end;

end.
