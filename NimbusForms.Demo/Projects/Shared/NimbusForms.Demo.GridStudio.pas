{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.GridStudio;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  System.TypInfo,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  System.Types,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Imaging.jpeg,
  System.UITypes,
  System.Actions,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.Types,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.TextBox,
  NimbusForms.Demo.Host,
  NimbusForms.Demo.GridEditors;

type
  TGridStudioForm = class(TDemoHostForm)
  private
    FDemo: TInteractiveGridDemo;
    FSearch: TThemedTextBox;
    FStatus: TThemedLabel;
    procedure Command(Sender: TObject);
    procedure SearchChanged(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

implementation

resourcestring
  SSearch = 'Search all grid columns';
  SGroup = 'Group status';
  SUngroup = 'Ungroup';
  SApproved = 'Approved only';
  SClear = 'Clear filters';
  SFreeze = 'Freeze first two';
  SUnfreeze = 'Unfreeze';
  SCopy = 'Copy grid';
  SCsv = 'Export CSV';
  SJson = 'Export JSON';
  SFind = 'Find panel';
  SFormats = 'Conditions on/off';
  SReady = '2,000 editable rows. Sort headers, group, filter, freeze, search, copy and export. Cell edits support validation and undo/redo.';
  SMatches = '%d matches';
  SExported = 'Exported %s';
  SExportFilter = 'CSV files|*.csv|JSON files|*.json';
  SFailed = 'Operation failed: %s';

constructor TGridStudioForm.CreateNew(AOwner: TComponent; Dummy: Integer);
var Bar: TThemedPanel; Button: TThemedButton; I: Integer; Condition: TThemedGridFormatCondition;
begin
  inherited;
  Bar := TThemedPanel.Create(Self); Bar.Parent := Body; Bar.Align := alTop; Bar.Height := 90;
  FSearch := TThemedTextBox.Create(Self); FSearch.Parent := Bar; FSearch.SetBounds(10, 8, 320, 30); FSearch.PlaceholderText := SSearch; FSearch.OnChange := SearchChanged;
  for I := 0 to 10 do
  begin
    Button := TThemedButton.Create(Self); Button.Parent := Bar; Button.SetBounds(10 + (I mod 6) * 152, 46 + (I div 6) * 36, 145, 30);
    if I >= 6 then Button.SetBounds(342 + (I - 6) * 112, 8, 106, 30);
    Button.Tag := I; Button.OnClick := Command;
    case I of
      0: Button.Caption := SGroup; 1: Button.Caption := SUngroup; 2: Button.Caption := SApproved;
      3: Button.Caption := SClear; 4: Button.Caption := SFreeze; 5: Button.Caption := SUnfreeze;
      6: Button.Caption := SCopy; 7: Button.Caption := SCsv; 8: Button.Caption := SJson;
      9: Button.Caption := SFind; 10: Button.Caption := SFormats;
    end;
  end;
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Body; FStatus.Align := alBottom; FStatus.AutoSize := False; FStatus.Height := 32; FStatus.Caption := SReady;
  FDemo := TInteractiveGridDemo.Create(Self); FDemo.Parent := Body; FDemo.Align := alClient;
  Condition := TThemedGridFormatCondition.Create;
  try
    Condition.ColumnName := 'Rating'; Condition.TargetColumnName := 'Rating'; Condition.Operator := TThemedGridFormatConditionOperator.GreaterOrEqual;
    Condition.Value := TValue.From<Double>(4); Condition.Style := TThemedGridFormatStyle.Create; Condition.Style.Bold := True; Condition.Style.ForeColor := $FF4EC9B0;
    FDemo.Grid.FormatConditions.Add(Condition); Condition := nil;
  finally Condition.Free; end;
end;

procedure TGridStudioForm.SearchChanged(Sender: TObject);
begin
  if FDemo = nil then Exit;
  FStatus.Caption := Format(SMatches, [FDemo.Grid.Search(FSearch.Text)]);
end;

procedure TGridStudioForm.Command(Sender: TObject);
var Dialog: TSaveDialog; Content: string; Tag: Integer;
begin
  Tag := TComponent(Sender).Tag;
  try
    if not FDemo.Grid.CommitEdit then Exit;
    case Tag of
      0: FDemo.Grid.GroupBy('Status');
      1: FDemo.Grid.ClearGrouping;
      2: FDemo.Grid.ApplyFilter('Approved', TThemedGridFilterOperator.Equals, TValue.From<Boolean>(True));
      3: FDemo.Grid.ClearFilters;
      4: FDemo.Grid.FreezeColumnsLeft(2);
      5: FDemo.Grid.ClearFrozenColumns;
      6: FDemo.Grid.CopyExportToClipboard;
      7, 8:
        begin
          Dialog := TSaveDialog.Create(Self);
          try
            Dialog.Filter := SExportFilter; Dialog.Options := Dialog.Options + [ofOverwritePrompt];
            if Tag = 7 then begin Dialog.FilterIndex := 1; Dialog.DefaultExt := 'csv'; Dialog.FileName := 'NimbusGrid.csv'; end
            else begin Dialog.FilterIndex := 2; Dialog.DefaultExt := 'json'; Dialog.FileName := 'NimbusGrid.json'; end;
            if Dialog.Execute then
            begin
              if Tag = 7 then Content := FDemo.Grid.ExportToCsv else Content := FDemo.Grid.ExportToJson;
              TFile.WriteAllText(Dialog.FileName, Content, TEncoding.UTF8); FStatus.Caption := Format(SExported, [Dialog.FileName]);
            end;
          finally Dialog.Free; end;
        end;
      9: if FDemo.Grid.FindPanelVisible then FDemo.Grid.HideFindPanel else FDemo.Grid.ShowFindPanel;
      10: FDemo.Grid.SetFormatConditionsEnabled(not FDemo.Grid.FormatConditionsEnabled);
    end;
  except on E: Exception do FStatus.Caption := Format(SFailed, [E.Message]); end;
end;

end.
