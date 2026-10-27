unit NimbusForms.Grid.ClipboardOptions;

interface

uses
  System.Classes;

type
  TThemedGridClipboardOptions = class
  private
    FIncludeHeaders: Boolean;
    FAllowPaste: Boolean;
    FPasteFillsSelection: Boolean;
    FNullText: string;
    FColumnSeparator: string;
    FRowSeparator: string;
    FOnChanged: TNotifyEvent;
    procedure SetIncludeHeaders(const AValue: Boolean);
    procedure SetAllowPaste(const AValue: Boolean);
    procedure SetPasteFillsSelection(const AValue: Boolean);
    procedure SetNullText(const AValue: string);
    procedure SetColumnSeparator(const AValue: string);
    procedure SetRowSeparator(const AValue: string);
    procedure DoChanged;
  public
    constructor Create;
    property IncludeHeaders: Boolean read FIncludeHeaders write SetIncludeHeaders;
    property AllowPaste: Boolean read FAllowPaste write SetAllowPaste;
    property PasteFillsSelection: Boolean read FPasteFillsSelection write SetPasteFillsSelection;
    property NullText: string read FNullText write SetNullText;
    property ColumnSeparator: string read FColumnSeparator write SetColumnSeparator;
    property RowSeparator: string read FRowSeparator write SetRowSeparator;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridClipboardOptions.Create;
begin
  inherited Create;
  FAllowPaste := True;
  FPasteFillsSelection := True;
  FNullText := '';
  FColumnSeparator := #9;
  FRowSeparator := #13#10;
end;

procedure TThemedGridClipboardOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridClipboardOptions.SetIncludeHeaders(const AValue: Boolean);
begin
  if FIncludeHeaders = AValue then Exit;
  FIncludeHeaders := AValue; DoChanged;
end;

procedure TThemedGridClipboardOptions.SetAllowPaste(const AValue: Boolean);
begin
  if FAllowPaste = AValue then Exit;
  FAllowPaste := AValue; DoChanged;
end;

procedure TThemedGridClipboardOptions.SetPasteFillsSelection(const AValue: Boolean);
begin
  if FPasteFillsSelection = AValue then Exit;
  FPasteFillsSelection := AValue; DoChanged;
end;

procedure TThemedGridClipboardOptions.SetNullText(const AValue: string);
begin
  if FNullText = AValue then Exit;
  FNullText := AValue; DoChanged;
end;

procedure TThemedGridClipboardOptions.SetColumnSeparator(const AValue: string);
var
  LValue: string;
begin
  LValue := AValue;
  if LValue = '' then
    LValue := #9;
  if FColumnSeparator = LValue then Exit;
  FColumnSeparator := LValue; DoChanged;
end;

procedure TThemedGridClipboardOptions.SetRowSeparator(const AValue: string);
var
  LValue: string;
begin
  LValue := AValue;
  if LValue = '' then
    LValue := #13#10;
  if FRowSeparator = LValue then Exit;
  FRowSeparator := LValue; DoChanged;
end;

end.
