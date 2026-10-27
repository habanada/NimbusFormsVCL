unit NimbusForms.Grid.ControlFormatConditions;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Vcl.Controls,
  Vcl.Forms,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionValidation,
  NimbusForms.Grid.ControlFilter;

type
  TThemedGridControlFormatConditions = class(TThemedGridControlFilter)
  public
    procedure ResetFormatConditions(const AConditions: array of TThemedGridFormatCondition);
    procedure BeginFormatConditionUpdate;
    procedure EndFormatConditionUpdate;
    function SaveFormatConditionsToJson: string;
    procedure SaveFormatConditionsToFile(const AFileName: string);
    function LoadFormatConditionsFromJson(const AJson: string): TThemedGridFormatConditionValidationResult;
    function LoadFormatConditionsFromFile(const AFileName: string): TThemedGridFormatConditionValidationResult;
    function ValidateFormatConditions: TThemedGridFormatConditionValidationResult;
    function ShowFormatConditionDesigner: TModalResult; overload;
    function ShowFormatConditionDesigner(const AOwner: TCustomForm): TModalResult; overload;
  end;

implementation

uses
  System.IOUtils,
  NimbusForms.Grid.FormatConditionCollection,
  NimbusForms.Grid.FormatConditionSerializer,
  NimbusForms.Grid.FormatConditionDesigner;

procedure TThemedGridControlFormatConditions.ResetFormatConditions(
  const AConditions: array of TThemedGridFormatCondition);
begin
  FormatConditions.ReplaceAll(AConditions);
end;

procedure TThemedGridControlFormatConditions.BeginFormatConditionUpdate;
begin
  FormatConditions.BeginUpdate;
end;

procedure TThemedGridControlFormatConditions.EndFormatConditionUpdate;
begin
  FormatConditions.EndUpdate;
end;

function TThemedGridControlFormatConditions.SaveFormatConditionsToJson: string;
begin
  Result := TThemedGridFormatConditionSerializer.SaveToJson(FormatConditions);
end;

procedure TThemedGridControlFormatConditions.SaveFormatConditionsToFile(const AFileName: string);
begin
  TThemedGridFormatConditionSerializer.SaveToFile(FormatConditions, AFileName);
end;

function TThemedGridControlFormatConditions.LoadFormatConditionsFromJson(
  const AJson: string): TThemedGridFormatConditionValidationResult;
var
  LLoaded: TThemedGridFormatConditionCollection;
begin
  LLoaded := TThemedGridFormatConditionSerializer.LoadFromJson(AJson);
  try
    FormatConditions.ReplaceAllFrom(LLoaded);
    FormatConditions.SetEnabled(LLoaded.Enabled);
  finally
    LLoaded.Free;
  end;
  Invalidate;
  Result := ValidateFormatConditions;
end;

function TThemedGridControlFormatConditions.LoadFormatConditionsFromFile(
  const AFileName: string): TThemedGridFormatConditionValidationResult;
begin
  Result := LoadFormatConditionsFromJson(TFile.ReadAllText(AFileName));
end;

function TThemedGridControlFormatConditions.ValidateFormatConditions: TThemedGridFormatConditionValidationResult;
begin
  Result := TThemedGridFormatConditionSerializer.Validate(FormatConditions, Columns);
end;

function TThemedGridControlFormatConditions.ShowFormatConditionDesigner: TModalResult;
begin
  Result := ShowFormatConditionDesigner(GetParentForm(Self));
end;

function TThemedGridControlFormatConditions.ShowFormatConditionDesigner(const AOwner: TCustomForm): TModalResult;
var
  LDialog: TThemedGridFormatConditionDesignerDialog;
begin
  if AOwner <> nil then
    LDialog := TThemedGridFormatConditionDesignerDialog.CreateDesigner(AOwner, Columns, FormatConditions, CurrentPPI)
  else
    LDialog := TThemedGridFormatConditionDesignerDialog.CreateDesigner(Self, Columns, FormatConditions, CurrentPPI);
  try
    if AOwner <> nil then
    begin
      LDialog.PopupMode := pmExplicit;
      LDialog.PopupParent := AOwner;
    end
    else
      LDialog.Position := poScreenCenter;
    Result := LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
