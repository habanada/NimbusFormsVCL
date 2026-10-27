unit NimbusForms.Grid.ControlSearch;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Controls,
  Vcl.Forms,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.Events.Search,
  NimbusForms.Grid.SearchMatch,
  NimbusForms.Grid.SearchResult,
  NimbusForms.Grid.SearchEngine,
  NimbusForms.Grid.SearchPanel,
  NimbusForms.Grid.ControlVisual;

type
  TThemedGridControlSearch = class(TThemedGridControlVisual)
  private
    FFindText: string;
    FUpdatingFindText: Boolean;
    FRunningSearch: Boolean;
    FSearchEngine: TThemedGridSearchEngine;
    FSearchPanel: TThemedGridSearchPanel;
    FSearchResults: TObjectList<TThemedGridSearchResult>;
    FSearchResultColumns: TList<TThemedGridColumn>;
    FSearchMatches: TDictionary<TThemedGridCellKey, TList<TThemedGridSearchMatch>>;
    FCurrentSearchResultIndex: Integer;
    FSearchHost: IThemedGridSearchHost;
    FOnSearchTextChanged: TThemedGridSearchTextChangedEvent;
    FOnSearchStarted: TNotifyEvent;
    FOnSearchCompleted: TThemedGridSearchCompletedEvent;
    FOnSearchResultChanged: TThemedGridSearchResultChangedEvent;
    procedure SetFindTextProperty(const AValue: string);
    function GetFindPanelVisible: Boolean;
    function GetSearchResultCount: Integer;
    function GetSearchResult(const AIndex: Integer): TThemedGridSearchResult;
    procedure ApplyCurrentSearchResult;
    procedure UpdateSearchPanelResultInfo;
    procedure LayoutSearchPanel;
    procedure ClearSearchResults;
    procedure ClearSearchState(const AClearPanelText: Boolean);
    procedure SearchPanelTextChanged(ASender: TObject);
    procedure SearchPanelNextClicked(ASender: TObject);
    procedure SearchPanelPreviousClicked(ASender: TObject);
    procedure SearchPanelCloseClicked(ASender: TObject);
  protected
    function GetSearchPanelHeight: Integer; override;
    function ResolveSearchMatches(const AKey: TThemedGridCellKey): TList<TThemedGridSearchMatch>; override;
    function TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure DataSourceReset; override;
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure Resize; override;
    procedure RunSearch;
    procedure DoSearchTextChanged(const AOldText, ANewText: string); virtual;
    procedure DoSearchStarted; virtual;
    procedure DoSearchCompleted(const AText: string; const AResultCount: Integer); virtual;
    procedure DoSearchResultChanged(const AResult: TThemedGridSearchResult; const AIndex, ACount: Integer); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
    function TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
      out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
    procedure SetFindText(const AValue: string; const ARunSearch: Boolean);
    function Search(const AText: string): Integer;
    procedure ShowFindPanel;
    procedure HideFindPanel;
    function NextSearchResult: Boolean;
    function PreviousSearchResult: Boolean;
    property FindText: string read FFindText write SetFindTextProperty;
    property FindPanelVisible: Boolean read GetFindPanelVisible;
    property SearchResultCount: Integer read GetSearchResultCount;
    property SearchResults[const AIndex: Integer]: TThemedGridSearchResult read GetSearchResult;
    property CurrentSearchResultIndex: Integer read FCurrentSearchResultIndex;
    property OnSearchTextChanged: TThemedGridSearchTextChangedEvent
      read FOnSearchTextChanged write FOnSearchTextChanged;
    property OnSearchStarted: TNotifyEvent read FOnSearchStarted write FOnSearchStarted;
    property OnSearchCompleted: TThemedGridSearchCompletedEvent
      read FOnSearchCompleted write FOnSearchCompleted;
    property OnSearchResultChanged: TThemedGridSearchResultChangedEvent
      read FOnSearchResultChanged write FOnSearchResultChanged;
  end;

implementation

uses
  NimbusForms.Grid.Types;

type
  TSearchHostAdapter = class(TInterfacedObject, IThemedGridSearchHost)
  private
    FOwner: TThemedGridControlSearch;
    function GetRowCount: Integer;
  public
    constructor Create(const AOwner: TThemedGridControlSearch);
    function GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
    function TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
      out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
    property RowCount: Integer read GetRowCount;
  end;

constructor TSearchHostAdapter.Create(const AOwner: TThemedGridControlSearch);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TSearchHostAdapter.GetRowCount: Integer;
begin
  Result := FOwner.RowCount;
end;

function TSearchHostAdapter.GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
begin
  Result := FOwner.GetSearchColumns(AIncludeHiddenColumns);
end;

function TSearchHostAdapter.TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
  out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
begin
  Result := FOwner.TryGetSearchText(ARowIndex, AColumn, ADisplayText, ADataSourceIndex);
end;

constructor TThemedGridControlSearch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCurrentSearchResultIndex := -1;
  FSearchEngine := TThemedGridSearchEngine.Create;
  FSearchResults := TObjectList<TThemedGridSearchResult>.Create(True);
  FSearchResultColumns := TList<TThemedGridColumn>.Create;
  FSearchMatches := TDictionary<TThemedGridCellKey, TList<TThemedGridSearchMatch>>.Create(
    TEqualityComparer<TThemedGridCellKey>.Construct(
      function(const ALeft, ARight: TThemedGridCellKey): Boolean
      begin
        Result := ALeft.Equals(ARight);
      end,
      function(const AValue: TThemedGridCellKey): Integer
      begin
        Result := AValue.GetHashCode;
      end));
  FSearchHost := TSearchHostAdapter.Create(Self);

  FSearchPanel := TThemedGridSearchPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.Height := MulDiv(32, Screen.PixelsPerInch, 96);
  FSearchPanel.Visible := False;
  FSearchPanel.OnSearchTextChanged := SearchPanelTextChanged;
  FSearchPanel.OnNextClicked := SearchPanelNextClicked;
  FSearchPanel.OnPreviousClicked := SearchPanelPreviousClicked;
  FSearchPanel.OnCloseClicked := SearchPanelCloseClicked;
  if Palette <> nil then
    FSearchPanel.ApplyTheme(Palette);
end;

destructor TThemedGridControlSearch.Destroy;
begin
  if FSearchPanel <> nil then
  begin
    FSearchPanel.CancelPendingSearch;
    FSearchPanel.OnSearchTextChanged := nil;
    FSearchPanel.OnNextClicked := nil;
    FSearchPanel.OnPreviousClicked := nil;
    FSearchPanel.OnCloseClicked := nil;
  end;
  FSearchHost := nil;
  FSearchMatches.Free;
  FSearchResultColumns.Free;
  FSearchResults.Free;
  FSearchEngine.Free;
  inherited Destroy;
end;

function TThemedGridControlSearch.GetSearchPanelHeight: Integer;
begin
  if (FSearchPanel <> nil) and FSearchPanel.Visible then
    Result := FSearchPanel.Height
  else
    Result := 0;
end;

function TThemedGridControlSearch.ResolveSearchMatches(const AKey: TThemedGridCellKey): TList<TThemedGridSearchMatch>;
begin
  if (FSearchMatches = nil) or not FSearchMatches.TryGetValue(AKey, Result) then
    Result := nil;
end;

function TThemedGridControlSearch.GetFindPanelVisible: Boolean;
begin
  Result := (FSearchPanel <> nil) and FSearchPanel.Visible;
end;

function TThemedGridControlSearch.GetSearchResultCount: Integer;
begin
  Result := FSearchResults.Count;
end;

function TThemedGridControlSearch.GetSearchResult(const AIndex: Integer): TThemedGridSearchResult;
begin
  Result := FSearchResults[AIndex];
end;

procedure TThemedGridControlSearch.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if (FSearchPanel <> nil) and (APalette <> nil) then
    FSearchPanel.ApplyTheme(APalette);
end;

procedure TThemedGridControlSearch.DataSourceReset;
begin
  inherited DataSourceReset;
  if FSearchResults = nil then
    Exit;
  ClearSearchResults;
  UpdateSearchPanelResultInfo;
end;

procedure TThemedGridControlSearch.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  AParams.Style := AParams.Style or WS_CLIPCHILDREN;
end;

procedure TThemedGridControlSearch.Resize;
begin
  inherited Resize;
  LayoutSearchPanel;
end;

procedure TThemedGridControlSearch.LayoutSearchPanel;
begin
  if FSearchPanel = nil then
    Exit;
  FSearchPanel.SetBounds(0, 0, ClientWidth, FSearchPanel.Height);
  FSearchPanel.BringToFront;
end;

function TThemedGridControlSearch.TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean;
begin
  if (AShift = [ssCtrl]) and (AKey = Ord('F')) then
  begin
    ShowFindPanel;
    Exit(True);
  end;
  if (AKey = VK_F3) and ((AShift = []) or (AShift = [ssShift])) then
  begin
    FSearchPanel.FlushPendingSearch;
    if ssShift in AShift then
      PreviousSearchResult
    else
      NextSearchResult;
    Exit(True);
  end;
  if (AKey = VK_ESCAPE) and (AShift = []) and FSearchPanel.Visible then
  begin
    HideFindPanel;
    Exit(True);
  end;
  Result := inherited TryHandleExtendedKey(AKey, AShift);
end;

function TThemedGridControlSearch.GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
var
  LList: TList<TThemedGridColumn>;
  LColumn: TThemedGridColumn;
  I: Integer;
begin
  if not AIncludeHiddenColumns then
  begin
    Result := GetVisibleColumns.ToArray;
    Exit;
  end;
  LList := TList<TThemedGridColumn>.Create;
  try
    for I := 0 to Columns.Count - 1 do
    begin
      LColumn := Columns[I];
      if LColumn <> nil then
        LList.Add(LColumn);
    end;
    LList.Sort(TComparer<TThemedGridColumn>.Construct(
      function(const ALeft, ARight: TThemedGridColumn): Integer
      begin
        if ALeft = ARight then
          Exit(0);
        if ALeft.VisibleIndex = ARight.VisibleIndex then
          Exit(CompareText(ALeft.Name, ARight.Name));
        if ALeft.VisibleIndex < ARight.VisibleIndex then
          Result := -1
        else
          Result := 1;
      end));
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TThemedGridControlSearch.TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
  out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
var
  LValue: TValue;
begin
  ADisplayText := '';
  ADataSourceIndex := -1;
  if (DataController = nil) or (AColumn = nil) then
    Exit(False);
  if (ARowIndex < 0) or (ARowIndex >= RowCount) then
    Exit(False);
  ADataSourceIndex := GetViewRowDataSourceIndex(ARowIndex);
  if ADataSourceIndex < 0 then
    Exit(False);
  LValue := DataController.GetValue(ADataSourceIndex, AColumn);
  ADisplayText := FormatDisplayText(LValue, AColumn, GetMetadata(ADataSourceIndex, AColumn.Name, False));
  Result := True;
end;

procedure TThemedGridControlSearch.SetFindTextProperty(const AValue: string);
begin
  SetFindText(AValue, True);
end;

procedure TThemedGridControlSearch.SetFindText(const AValue: string; const ARunSearch: Boolean);
var
  LOldText: string;
begin
  if FFindText = AValue then
    Exit;
  if FUpdatingFindText then
    Exit;
  LOldText := FFindText;
  try
    FUpdatingFindText := True;
    FFindText := AValue;
    if (FSearchPanel <> nil) and (FSearchPanel.FindText <> AValue) then
      FSearchPanel.SetFindTextSilent(AValue, True);
  finally
    FUpdatingFindText := False;
  end;
  DoSearchTextChanged(LOldText, AValue);
  if ARunSearch then
    RunSearch;
end;

function TThemedGridControlSearch.Search(const AText: string): Integer;
begin
  SetFindText(AText, True);
  Result := FSearchResults.Count;
end;

procedure TThemedGridControlSearch.ShowFindPanel;
begin
  if FSearchPanel.Visible then
  begin
    FSearchPanel.FocusTextBox;
    Exit;
  end;
  FSearchPanel.Visible := True;
  LayoutSearchPanel;
  NormalizeScrollValues;
  Invalidate;
  FSearchPanel.FocusTextBox;
end;

procedure TThemedGridControlSearch.HideFindPanel;
var
  LHadFocus: Boolean;
begin
  if FSearchPanel = nil then
    Exit;
  ClearSearchState(True);
  if not FSearchPanel.Visible then
    Exit;
  LHadFocus := FSearchPanel.ContainsControl(Screen.ActiveControl);
  FSearchPanel.Visible := False;
  LayoutSearchPanel;
  NormalizeScrollValues;
  Invalidate;
  if LHadFocus and CanFocus then
    SetFocus;
end;

procedure TThemedGridControlSearch.ClearSearchResults;
begin
  FSearchResults.Clear;
  FSearchResultColumns.Clear;
  FSearchMatches.Clear;
  FCurrentSearchResultIndex := -1;
end;

procedure TThemedGridControlSearch.ClearSearchState(const AClearPanelText: Boolean);
var
  LOldText: string;
begin
  if FSearchPanel <> nil then
  begin
    FSearchPanel.CancelPendingSearch;
    if AClearPanelText then
      FSearchPanel.SetFindTextSilent('', True);
    FSearchPanel.SetResultInfo(-1, 0);
  end;
  if FFindText <> '' then
  begin
    LOldText := FFindText;
    FFindText := '';
    DoSearchTextChanged(LOldText, '');
  end;
  ClearSearchResults;
  Invalidate;
end;

function TThemedGridControlSearch.NextSearchResult: Boolean;
begin
  if FSearchResults.Count = 0 then
    Exit(False);
  Inc(FCurrentSearchResultIndex);
  if FCurrentSearchResultIndex >= FSearchResults.Count then
    FCurrentSearchResultIndex := 0;
  ApplyCurrentSearchResult;
  Result := True;
end;

function TThemedGridControlSearch.PreviousSearchResult: Boolean;
begin
  if FSearchResults.Count = 0 then
    Exit(False);
  Dec(FCurrentSearchResultIndex);
  if FCurrentSearchResultIndex < 0 then
    FCurrentSearchResultIndex := FSearchResults.Count - 1;
  ApplyCurrentSearchResult;
  Result := True;
end;

procedure TThemedGridControlSearch.RunSearch;
var
  LColumns: TArray<TThemedGridColumn>;
  LFound: TObjectList<TThemedGridSearchResult>;
  LResult: TThemedGridSearchResult;
  LColumn: TThemedGridColumn;
  I: Integer;
begin
  if FRunningSearch then
    Exit;
  try
    FRunningSearch := True;
    DoSearchStarted;
    ClearSearchResults;
    if (FFindText <> '') and (Length(FFindText) >= SearchOptions.MinimumSearchLength) then
    begin
      LColumns := GetSearchColumns(SearchOptions.IncludeHiddenColumns);
      LFound := FSearchEngine.Search(FSearchHost, FFindText, SearchOptions);
      try
        for I := LFound.Count - 1 downto 0 do
          if (LFound[I].ColumnIndex < 0) or (LFound[I].ColumnIndex > High(LColumns)) then
            LFound.Delete(I);
        while LFound.Count > 0 do
        begin
          LResult := LFound.Extract(LFound[0]);
          LColumn := LColumns[LResult.ColumnIndex];
          FSearchResults.Add(LResult);
          FSearchResultColumns.Add(LColumn);
          if SearchOptions.HighlightMatches then
            FSearchMatches.AddOrSetValue(TThemedGridCellKey.Create(LResult.DataSourceIndex, LColumn.Name),
              LResult.Matches);
        end;
      finally
        LFound.Free;
      end;
      if FSearchResults.Count > 0 then
        FCurrentSearchResultIndex := 0;
    end;
    UpdateSearchPanelResultInfo;
    DoSearchCompleted(FFindText, FSearchResults.Count);
    if FCurrentSearchResultIndex >= 0 then
      ApplyCurrentSearchResult
    else
      Invalidate;
  finally
    FRunningSearch := False;
  end;
end;

procedure TThemedGridControlSearch.ApplyCurrentSearchResult;
var
  LResult: TThemedGridSearchResult;
  LColumnIndex: Integer;
begin
  if (FCurrentSearchResultIndex < 0) or (FCurrentSearchResultIndex >= FSearchResults.Count) then
    Exit;
  LResult := FSearchResults[FCurrentSearchResultIndex];
  LColumnIndex := GetColumnVisibleIndex(FSearchResultColumns[FCurrentSearchResultIndex].Name);
  if LColumnIndex < 0 then
    LColumnIndex := CurrentColumnIndex;
  if LColumnIndex < 0 then
    LColumnIndex := 0;
  SetCurrentCell(LResult.RowIndex, LColumnIndex);
  EnsureVisible(LResult.RowIndex, LColumnIndex);
  UpdateSearchPanelResultInfo;
  DoSearchResultChanged(LResult, FCurrentSearchResultIndex, FSearchResults.Count);
  Invalidate;
end;

procedure TThemedGridControlSearch.UpdateSearchPanelResultInfo;
begin
  if FSearchPanel = nil then
    Exit;
  FSearchPanel.SetResultInfo(FCurrentSearchResultIndex, FSearchResults.Count);
end;

procedure TThemedGridControlSearch.SearchPanelTextChanged(ASender: TObject);
begin
  if FSearchPanel = nil then
    Exit;
  SetFindText(FSearchPanel.FindText, True);
end;

procedure TThemedGridControlSearch.SearchPanelNextClicked(ASender: TObject);
begin
  NextSearchResult;
end;

procedure TThemedGridControlSearch.SearchPanelPreviousClicked(ASender: TObject);
begin
  PreviousSearchResult;
end;

procedure TThemedGridControlSearch.SearchPanelCloseClicked(ASender: TObject);
begin
  HideFindPanel;
end;

procedure TThemedGridControlSearch.DoSearchTextChanged(const AOldText, ANewText: string);
var
  LArgs: TThemedGridSearchTextChangedEventArgs;
begin
  if not Assigned(FOnSearchTextChanged) then
    Exit;
  LArgs := TThemedGridSearchTextChangedEventArgs.Create(AOldText, ANewText);
  try
    FOnSearchTextChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlSearch.DoSearchStarted;
begin
  if Assigned(FOnSearchStarted) then
    FOnSearchStarted(Self);
end;

procedure TThemedGridControlSearch.DoSearchCompleted(const AText: string; const AResultCount: Integer);
var
  LArgs: TThemedGridSearchCompletedEventArgs;
begin
  if not Assigned(FOnSearchCompleted) then
    Exit;
  LArgs := TThemedGridSearchCompletedEventArgs.Create(AText, AResultCount);
  try
    FOnSearchCompleted(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlSearch.DoSearchResultChanged(const AResult: TThemedGridSearchResult;
  const AIndex, ACount: Integer);
var
  LArgs: TThemedGridSearchResultChangedEventArgs;
begin
  if not Assigned(FOnSearchResultChanged) then
    Exit;
  LArgs := TThemedGridSearchResultChangedEventArgs.Create(AResult, AIndex, ACount);
  try
    FOnSearchResultChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

end.
