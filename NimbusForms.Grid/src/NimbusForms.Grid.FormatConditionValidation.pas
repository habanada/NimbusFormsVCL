unit NimbusForms.Grid.FormatConditionValidation;

interface

uses
  System.Generics.Collections;

type
  TThemedGridFormatConditionValidationIssue = class
  private
    FIndex: Integer;
    FName: string;
    FColumnName: string;
    FTargetColumnName: string;
    FMessage: string;
    FIsError: Boolean;
  public
    property Index: Integer read FIndex write FIndex;
    property Name: string read FName write FName;
    property ColumnName: string read FColumnName write FColumnName;
    property TargetColumnName: string read FTargetColumnName write FTargetColumnName;
    property Message: string read FMessage write FMessage;
    property IsError: Boolean read FIsError write FIsError;
  end;

  TThemedGridFormatConditionValidationResult = class
  private
    FIssues: TObjectList<TThemedGridFormatConditionValidationIssue>;
    function GetHasErrors: Boolean;
    function GetHasWarnings: Boolean;
    procedure Add(const AIndex: Integer; const AName, AColumnName, ATargetColumnName, AMessage: string; const AIsError: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddWarning(const AIndex: Integer; const AName, AColumnName, ATargetColumnName, AMessage: string);
    procedure AddError(const AIndex: Integer; const AName, AColumnName, ATargetColumnName, AMessage: string);
    property Issues: TObjectList<TThemedGridFormatConditionValidationIssue> read FIssues;
    property HasErrors: Boolean read GetHasErrors;
    property HasWarnings: Boolean read GetHasWarnings;
  end;

implementation

constructor TThemedGridFormatConditionValidationResult.Create;
begin
  inherited Create;
  FIssues := TObjectList<TThemedGridFormatConditionValidationIssue>.Create(True);
end;

destructor TThemedGridFormatConditionValidationResult.Destroy;
begin
  FIssues.Free;
  inherited Destroy;
end;

function TThemedGridFormatConditionValidationResult.GetHasErrors: Boolean;
var
  I: Integer;
begin
  for I := 0 to FIssues.Count - 1 do
    if (FIssues[I] <> nil) and FIssues[I].IsError then
      Exit(True);
  Result := False;
end;

function TThemedGridFormatConditionValidationResult.GetHasWarnings: Boolean;
var
  I: Integer;
begin
  for I := 0 to FIssues.Count - 1 do
    if (FIssues[I] <> nil) and (not FIssues[I].IsError) then
      Exit(True);
  Result := False;
end;

procedure TThemedGridFormatConditionValidationResult.Add(const AIndex: Integer; const AName, AColumnName, ATargetColumnName, AMessage: string; const AIsError: Boolean);
var
  LIssue: TThemedGridFormatConditionValidationIssue;
begin
  LIssue := TThemedGridFormatConditionValidationIssue.Create;
  LIssue.Index := AIndex;
  LIssue.Name := AName;
  LIssue.ColumnName := AColumnName;
  LIssue.TargetColumnName := ATargetColumnName;
  LIssue.Message := AMessage;
  LIssue.IsError := AIsError;
  FIssues.Add(LIssue);
end;

procedure TThemedGridFormatConditionValidationResult.AddWarning(const AIndex: Integer; const AName, AColumnName, ATargetColumnName, AMessage: string);
begin
  Add(AIndex, AName, AColumnName, ATargetColumnName, AMessage, False);
end;

procedure TThemedGridFormatConditionValidationResult.AddError(const AIndex: Integer; const AName, AColumnName, ATargetColumnName, AMessage: string);
begin
  Add(AIndex, AName, AColumnName, ATargetColumnName, AMessage, True);
end;

end.
