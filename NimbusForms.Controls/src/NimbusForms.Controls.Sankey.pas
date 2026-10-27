{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Sankey;

interface

uses System.Classes, NimbusForms.Controls.Chart, NimbusForms.Charts.Sankey.Types;

type
  TThemedSankeyChart = class(TThemedChart)
  private
    function GetSankey: TNimbusSankeyData;
    procedure SetSankey(const Value: TNimbusSankeyData);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Sankey: TNimbusSankeyData read GetSankey write SetSankey;
  end;

implementation

uses NimbusForms.Charts.Types;

constructor TThemedSankeyChart.Create(AOwner: TComponent);
begin inherited; ChartType := nctSankey; ShowAxes := False; ShowGrid := False; ShowLegend := False; EnableZoom := False; EnablePan := False; TabStop := True end;

function TThemedSankeyChart.GetSankey: TNimbusSankeyData;
begin Result := Model.Sankey end;

procedure TThemedSankeyChart.SetSankey(const Value: TNimbusSankeyData);
begin if Value <> nil then Model.Sankey.Assign(Value) end;

initialization
  RegisterClass(TThemedSankeyChart);

end.
