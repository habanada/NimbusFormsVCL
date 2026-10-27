{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Properties;

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
  NimbusForms.Controls.Splitter,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.PropertyGrid.Types,
  NimbusForms.Controls.PropertyGrid.Adapters,
  NimbusForms.Controls.PropertyGrid,
  NimbusForms.Controls.TabControl;

procedure AddNimbusPropertyGridGallery(const Tabs: TThemedTabControl);

implementation

type
  TNimbusCollectionDemoItem = class(TCollectionItem)
  private
    FCaption: string;
    FEnabled: Boolean;
    FPriority: Integer;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write FCaption;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Priority: Integer read FPriority write FPriority default 0;
  end;

  TNimbusPropertyGridArrayOfInteger = class(TNimbusPropertyGridArray<Integer>);

  TNimbusPropertyGridDemoNode = class(TPersistent)
  private
    FCaption: string;
    FEnabled: Boolean;
    FPriority: Integer;
  published
    property Caption: string read FCaption write FCaption;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Priority: Integer read FPriority write FPriority;
  end;

  TNimbusCollectionDemoHost = class(TComponent)
  private
    FItems: TCollection;
    FLines: TStrings;
    FValues: Variant;
    FNames: TList<string>;
    FNumbers: TList<Integer>;
    FTotals: TList<Double>;
    FFlags: TList<Boolean>;
    FMeasurements: TList<Single>;
    FScores: TNimbusPropertyGridArrayOfInteger;
    FNodes: TObjectList<TNimbusPropertyGridDemoNode>;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TCollection read FItems;
    property Lines: TStrings read FLines;
    property Values: Variant read FValues write FValues;
    property Names: TList<string> read FNames;
    property Numbers: TList<Integer> read FNumbers;
    property Totals: TList<Double> read FTotals;
    property Flags: TList<Boolean> read FFlags;
    property Measurements: TList<Single> read FMeasurements;
    property Scores: TNimbusPropertyGridArrayOfInteger read FScores;
    property Nodes: TObjectList<TNimbusPropertyGridDemoNode> read FNodes;
  end;

constructor TNimbusCollectionDemoItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
end;

function TNimbusCollectionDemoItem.GetDisplayName: string;
begin
  if FCaption <> '' then Result := FCaption else Result := inherited GetDisplayName;
end;

procedure TNimbusCollectionDemoItem.Assign(Source: TPersistent);
begin
  if Source is TNimbusCollectionDemoItem then
  begin
    FCaption := TNimbusCollectionDemoItem(Source).Caption;
    FEnabled := TNimbusCollectionDemoItem(Source).Enabled;
    FPriority := TNimbusCollectionDemoItem(Source).Priority;
  end
  else inherited Assign(Source);
end;

constructor TNimbusCollectionDemoHost.Create(AOwner: TComponent);
var
  LItem: TNimbusCollectionDemoItem;
begin
  inherited Create(AOwner);
  FItems := TCollection.Create(TNimbusCollectionDemoItem);
  FLines := TStringList.Create;
  FLines.Add('Build');
  FLines.Add('Validate');
  FLines.Add('Deploy');
  FValues := VarArrayCreate([0, 2], varVariant);
  FValues[0] := 'Alpha';
  FValues[1] := 42;
  FValues[2] := True;
  FNames := TList<string>.Create;
  FNames.Add('Alpha');
  FNames.Add('Beta');
  FNames.Add('Gamma');
  FNumbers := TList<Integer>.Create;
  FNumbers.Add(10);
  FNumbers.Add(20);
  FNumbers.Add(30);
  FTotals := TList<Double>.Create;
  FTotals.Add(12.5);
  FTotals.Add(25.75);
  FFlags := TList<Boolean>.Create;
  FFlags.Add(True);
  FFlags.Add(False);
  FMeasurements := TList<Single>.Create;
  FMeasurements.Add(1.25);
  FMeasurements.Add(2.5);
  FScores := TNimbusPropertyGridArrayOfInteger.Create;
  FScores.Load([12, 24, 48]);
  FNodes := TObjectList<TNimbusPropertyGridDemoNode>.Create(True);
  var LNode := TNimbusPropertyGridDemoNode.Create;
  LNode.Caption := 'Build';
  LNode.Enabled := True;
  LNode.Priority := 10;
  FNodes.Add(LNode);
  LNode := TNimbusPropertyGridDemoNode.Create;
  LNode.Caption := 'Validate';
  LNode.Enabled := False;
  LNode.Priority := 20;
  FNodes.Add(LNode);
  LItem := TNimbusCollectionDemoItem(FItems.Add);
  LItem.Caption := 'Build';
  LItem.Enabled := True;
  LItem.Priority := 10;
  LItem := TNimbusCollectionDemoItem(FItems.Add);
  LItem.Caption := 'Validate';
  LItem.Enabled := True;
  LItem.Priority := 20;
  LItem := TNimbusCollectionDemoItem(FItems.Add);
  LItem.Caption := 'Deploy';
  LItem.Enabled := False;
  LItem.Priority := 30;
end;

destructor TNimbusCollectionDemoHost.Destroy;
begin
  FNodes.Free;
  FScores.Free;
  FMeasurements.Free;
  FFlags.Free;
  FTotals.Free;
  FNumbers.Free;
  FNames.Free;
  FLines.Free;
  FItems.Free;
  inherited Destroy;
end;

type
  TNimbusDatePropertyDemo = class(TComponent)
  private
    FDate: TDate;
    FTime: TTime;
    FDateTime: TDateTime;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EventDate: TDate read FDate write FDate;
    property EventTime: TTime read FTime write FTime;
    property DueAt: TDateTime read FDateTime write FDateTime;
  end;

constructor TNimbusDatePropertyDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDate := Date;
  FTime := Time;
  FDateTime := Now;
end;

type
  TNimbusNumericPropertyDemo = class(TComponent)
  private
    FLevel: Byte;
    FOffset: SmallInt;
    FCount: Cardinal;
    FPosition: Int64;
    FOpacity: Single;
    FRatio: Double;
    FBalance: Currency;
    FTitle: string;
    FOutputPath: string;
    FInternalId: string;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Level: Byte read FLevel write FLevel;
    property Offset: SmallInt read FOffset write FOffset;
    property Count: Cardinal read FCount write FCount;
    property Position: Int64 read FPosition write FPosition;
    property Opacity: Single read FOpacity write FOpacity;
    property Ratio: Double read FRatio write FRatio;
    property Balance: Currency read FBalance write FBalance;
    property Title: string read FTitle write FTitle;
    property OutputPath: string read FOutputPath write FOutputPath;
    property InternalId: string read FInternalId write FInternalId;
  end;

constructor TNimbusNumericPropertyDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLevel := 12;
  FOffset := -50;
  FCount := 2500000000;
  FPosition := 8000000000000000000;
  FOpacity := 0.75;
  FRatio := 1.23456;
  FBalance := 1250.4567;
  FTitle := 'Nimbus metadata demo';
  FOutputPath := '';
  FInternalId := 'private';
end;

type
  TNimbusAssetPropertyDemo = class(TComponent)
  private
    FSourceFile: string;
    FOutputFolder: string;
    FPicture: TPicture;
    FIcon: TIcon;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property SourceFile: string read FSourceFile write FSourceFile;
    property OutputFolder: string read FOutputFolder write FOutputFolder;
    property Picture: TPicture read FPicture;
    property Icon: TIcon read FIcon;
  end;

constructor TNimbusAssetPropertyDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPicture := TPicture.Create;
  FIcon := TIcon.Create;
  FIcon.Assign(Application.Icon);
  FSourceFile := '';
  FOutputFolder := GetCurrentDir;
end;

destructor TNimbusAssetPropertyDemo.Destroy;
begin
  FIcon.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure AddNimbusPropertyGridGallery(const Tabs: TThemedTabControl);
var
  LPage: TTabSheet;
  LPreview: TThemedPanel;
  LGrid: TThemedPropertyGrid;
  LHint: TThemedLabel;
  LCollectionsPage: TTabSheet;
  LCollectionPanel: TThemedPanel;
  LCollectionHint: TThemedLabel;
  LHost: TNimbusCollectionDemoHost;
  LDatePage: TTabSheet;
  LDateInfo: TThemedLabel;
  LDateGrid: TThemedPropertyGrid;
  LDateHost: TNimbusDatePropertyDemo;
  LNumericPage: TTabSheet;
  LNumericInfo: TThemedLabel;
  LNumericGrid: TThemedPropertyGrid;
  LNumericHost: TNimbusNumericPropertyDemo;
  LAssetPage: TTabSheet;
  LAssetInfo: TThemedLabel;
  LAssetGrid: TThemedPropertyGrid;
  LAssetHost: TNimbusAssetPropertyDemo;
begin
  LPage := TTabSheet.Create(Tabs);
  LPage.PageControl := Tabs;
  LPage.Caption := 'Property Grid';

  LPreview := TThemedPanel.Create(LPage);
  LPreview.Parent := LPage;
  LPreview.Align := alLeft;
  LPreview.Width := 340;
  LPreview.Font.Name := 'Segoe UI';
  LPreview.Font.Size := 11;

  LHint := TThemedLabel.Create(LPage);
  LHint.Parent := LPreview;
  LHint.AutoSize := False;
  LHint.Align := alTop;
  LHint.Height := 46;
  LHint.Alignment := taCenter;
  LHint.Layout := tlCenter;
  LHint.Caption := 'Edit the preview through the Property Grid';

  LGrid := TThemedPropertyGrid.Create(LPage);
  LGrid.Parent := LPage;
  LGrid.Align := alClient;
  LGrid.NameColumnWidth := 190;
  LGrid.SelectedObject := LPreview;
  Tabs.SetTabClosable(LPage, False);

  LCollectionsPage := TTabSheet.Create(Tabs);
  LCollectionsPage.PageControl := Tabs;
  LCollectionsPage.Caption := 'PropertyGrid Collections';
  LCollectionPanel := TThemedPanel.Create(LCollectionsPage);
  LCollectionPanel.Parent := LCollectionsPage;
  LCollectionPanel.Align := alLeft;
  LCollectionPanel.Width := 290;
  LCollectionPanel.ShowBorder := False;
  LCollectionHint := TThemedLabel.Create(LCollectionsPage);
  LCollectionHint.Parent := LCollectionPanel;
  LCollectionHint.Align := alTop;
  LCollectionHint.Height := 120;
  LCollectionHint.AutoSize := False;
  LCollectionHint.WordWrap := True;
  LCollectionHint.Caption := 'Expand Items, Lines, Values, typed lists, Scores and Nodes. Right-click an item to add, remove or reorder, or use Ctrl+Insert, Ctrl+Delete and Alt+Up/Down. Nested object lists are read-only structurally. Test Undo and Redo.';
  LGrid := TThemedPropertyGrid.Create(LCollectionsPage);
  LGrid.Parent := LCollectionsPage;
  LGrid.Align := alClient;
  LGrid.NameColumnWidth := 190;
  LGrid.MaxNestedDepth := 5;
  NimbusRegisterPropertyGridAdapter(TNimbusPropertyGridListAdapter<Single>.Create(tkFloat,
    function(const AValue: Single): Variant begin Result := AValue; end,
    function(const AValue: Variant): Single begin Result := AValue; end));
  NimbusRegisterPropertyGridAdapter(TNimbusPropertyGridArrayAdapter<Integer>.Create(tkInteger,
    function(const AValue: Integer): Variant begin Result := AValue; end,
    function(const AValue: Variant): Integer begin Result := AValue; end));
  NimbusRegisterPropertyGridAdapter(TNimbusPropertyGridObjectListAdapter<TNimbusPropertyGridDemoNode>.Create);
  LHost := TNimbusCollectionDemoHost.Create(LCollectionsPage);
  LGrid.SelectedObject := LHost;
  Tabs.SetTabClosable(LCollectionsPage, False);

  LDatePage := TTabSheet.Create(Tabs);
  LDatePage.PageControl := Tabs;
  LDatePage.Caption := 'PropertyGrid Dates';
  LDateInfo := TThemedLabel.Create(LDatePage);
  LDateInfo.Parent := LDatePage;
  LDateInfo.Align := alTop;
  LDateInfo.Height := 76;
  LDateInfo.AutoSize := False;
  LDateInfo.WordWrap := True;
  LDateInfo.Caption := 'Edit EventDate, EventTime and DueAt using the themed calendar. A date click confirms the date; for time values, use Confirm. Escape or clicking outside cancels. Test Undo and Redo from the grid context menu.';
  LDateGrid := TThemedPropertyGrid.Create(LDatePage);
  LDateGrid.Parent := LDatePage;
  LDateGrid.Align := alClient;
  LDateGrid.NameColumnWidth := 200;
  LDateHost := TNimbusDatePropertyDemo.Create(LDatePage);
  LDateGrid.SelectedObject := LDateHost;
  Tabs.SetTabClosable(LDatePage, False);

  LNumericPage := TTabSheet.Create(Tabs);
  LNumericPage.PageControl := Tabs;
  LNumericPage.Caption := 'PropertyGrid Metadata';
  LNumericInfo := TThemedLabel.Create(LNumericPage);
  LNumericInfo.Parent := LNumericPage;
  LNumericInfo.Align := alTop;
  LNumericInfo.Height := 92;
  LNumericInfo.AutoSize := False;
  LNumericInfo.WordWrap := True;
  LNumericInfo.Caption := 'Metadata overrides, typed bounds and precision. Change Level, Opacity or Ratio, then right-click Reset to restore their configured defaults. Try invalid values and Undo/Redo. Title is read-only and InternalId is hidden. Use Accept Changes and Modified to test change tracking.';
  LNumericGrid := TThemedPropertyGrid.Create(LNumericPage);
  LNumericGrid.Parent := LNumericPage;
  LNumericGrid.Align := alClient;
  LNumericGrid.NameColumnWidth := 205;
  LNumericHost := TNimbusNumericPropertyDemo.Create(LNumericPage);
  LNumericGrid.ConfigureType('Single').DecimalPlaces := 3;
  LNumericGrid.ConfigureType('Currency').DecimalPlaces := 4;
  with LNumericGrid.ConfigureProperty('Level') do
  begin
    DisplayName := 'Build level';
    Category := 'Limits';
    Description := 'Allowed range: 0 to 100. Increment: 5.';
    Minimum := 0;
    Maximum := 100;
    Increment := 5;
    DefaultValue := 12;
  end;
  with LNumericGrid.ConfigureProperty('Opacity') do
  begin
    Category := 'Limits';
    Minimum := 0;
    Maximum := 1;
    Increment := 0.05;
    DecimalPlaces := 2;
    DefaultValue := 0.5;
  end;
  with LNumericGrid.ConfigureProperty('Ratio') do
  begin
    Category := 'Precision';
    DecimalPlaces := 3;
    Increment := 0.125;
    DefaultValue := 1.5;
  end;
  with LNumericGrid.ConfigureProperty('Balance') do
  begin
    Category := 'Precision';
    Description := 'Currency value with four decimal places.';
  end;
  LNumericGrid.ConfigureProperty('Position').Description := 'Edit as exact signed 64-bit integer in the text field.';
  LNumericGrid.ConfigureProperty('Title').ReadOnly := True;
  LNumericGrid.ConfigureProperty('OutputPath').EditorKind := pgeFile;
  LNumericGrid.ConfigureProperty('InternalId').Browsable := False;
  LNumericGrid.SelectedObject := LNumericHost;
  Tabs.SetTabClosable(LNumericPage, False);

  LAssetPage := TTabSheet.Create(Tabs);
  LAssetPage.PageControl := Tabs;
  LAssetPage.Caption := 'PropertyGrid Assets';
  LAssetInfo := TThemedLabel.Create(LAssetPage);
  LAssetInfo.Parent := LAssetPage;
  LAssetInfo.Align := alTop;
  LAssetInfo.Height := 82;
  LAssetInfo.AutoSize := False;
  LAssetInfo.WordWrap := True;
  LAssetInfo.Caption := 'SourceFile: choose an existing image. OutputFolder: select a directory. Picture and Icon: open the themed image editor, preview the image, browse or clear, then confirm or cancel. Test Undo, Redo and multiple edits.';
  LAssetGrid := TThemedPropertyGrid.Create(LAssetPage);
  LAssetGrid.Parent := LAssetPage;
  LAssetGrid.Align := alClient;
  LAssetGrid.NameColumnWidth := 190;
  LAssetHost := TNimbusAssetPropertyDemo.Create(LAssetPage);
  with LAssetGrid.ConfigureProperty('SourceFile') do
  begin
    EditorKind := pgeFile;
    Category := 'Files';
    Description := 'Select an existing picture file.';
    PathFilter := 'Image files (*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.ico)|*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.ico|All files (*.*)|*.*';
    PathCheckExists := True;
  end;
  with LAssetGrid.ConfigureProperty('OutputFolder') do
  begin
    EditorKind := pgeFolder;
    Category := 'Files';
    Description := 'Select an existing output directory.';
    PathCheckExists := True;
  end;
  with LAssetGrid.ConfigureProperty('Picture') do
  begin
    EditorKind := pgeImage;
    Category := 'Images';
    Description := 'Browse, clear and preview a picture. Changes apply after OK.';
  end;
  with LAssetGrid.ConfigureProperty('Icon') do
  begin
    EditorKind := pgeIcon;
    Category := 'Images';
    Description := 'Browse and preview a Windows icon (*.ico).';
  end;
  LAssetGrid.SelectedObject := LAssetHost;
  Tabs.SetTabClosable(LAssetPage, False);
end;


end.
