unit NimbusForms.Grid.View;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  Vcl.Controls,
  NimbusForms.Grid.DataControllerIntf,
  NimbusForms.Grid.ControlMasterDetail;

type
  TThemedGridView = class(TThemedGridControlMasterDetail)
  private
    function GetController: IThemedGridDataController;
  public
    procedure GroupBy(const AColumnName: string);
    procedure ClearGrouping;
    property Controller: IThemedGridDataController read GetController;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property TabOrder;
    property TabStop default True;
    property Visible;
  end;

implementation

function TThemedGridView.GetController: IThemedGridDataController;
begin
  Result := DataController;
end;

procedure TThemedGridView.GroupBy(const AColumnName: string);
begin
  Groups.BeginUpdate;
  try
    Groups.Clear;
    Groups.Add(AColumnName);
  finally
    Groups.EndUpdate;
  end;
  Reload;
end;

procedure TThemedGridView.ClearGrouping;
begin
  Groups.Clear;
  Reload;
end;

end.
