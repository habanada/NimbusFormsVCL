unit NimbusForms.Charts.Financial.Data;

interface

uses System.Classes, System.SysUtils, System.Math, System.DateUtils, System.Generics.Collections,
  Data.DB, NimbusForms.Charts.Financial.Types, NimbusForms.Charts.Financial.Indicators;

type
  TNimbusFinancialDuplicateTimeHandling = (nfdthKeep, nfdthSkip, nfdthReplace, nfdthThrow);
  TNimbusFinancialCsvErrorHandling = (nfceThrow, nfceSkipInvalidRows);
  TNimbusFinancialCsvImportOptions = class(TPersistent)
  private
    FDelimiter: Char;
    FHasHeader, FTrimFields, FSortByTime: Boolean;
    FDuplicateTimeHandling: TNimbusFinancialDuplicateTimeHandling;
    FErrorHandling: TNimbusFinancialCsvErrorHandling;
    FTimeColumn, FOpenColumn, FHighColumn, FLowColumn, FCloseColumn, FVolumeColumn: string;
    FDecimalSeparator: Char;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Delimiter: Char read FDelimiter write FDelimiter;
    property HasHeader: Boolean read FHasHeader write FHasHeader;
    property TrimFields: Boolean read FTrimFields write FTrimFields;
    property SortByTime: Boolean read FSortByTime write FSortByTime;
    property DuplicateTimeHandling: TNimbusFinancialDuplicateTimeHandling read FDuplicateTimeHandling write FDuplicateTimeHandling;
    property ErrorHandling: TNimbusFinancialCsvErrorHandling read FErrorHandling write FErrorHandling;
    property DecimalSeparator: Char read FDecimalSeparator write FDecimalSeparator;
    property TimeColumn: string read FTimeColumn write FTimeColumn;
    property OpenColumn: string read FOpenColumn write FOpenColumn;
    property HighColumn: string read FHighColumn write FHighColumn;
    property LowColumn: string read FLowColumn write FLowColumn;
    property CloseColumn: string read FCloseColumn write FCloseColumn;
    property VolumeColumn: string read FVolumeColumn write FVolumeColumn;
  end;
  TNimbusFinancialDataImportResult = class(TPersistent)
  private
    FCandles: TNimbusFinancialDataPointCollection;
    FErrors: TStringList;
  public
    ReadRows, ImportedRows, SkippedRows: Integer;
    constructor Create;
    destructor Destroy; override;
    property Candles: TNimbusFinancialDataPointCollection read FCandles;
    property Errors: TStringList read FErrors;
  end;
  TNimbusFinancialDataAdapter = class sealed
  public
    class procedure ValidateCandle(const Time: TDateTime; const Open, High, Low, Close, Volume: Double); static;
    class function ImportCsvText(const Text: string; Options: TNimbusFinancialCsvImportOptions = nil): TNimbusFinancialDataImportResult; static;
    class function ImportDataSet(DataSet: TDataSet; Options: TNimbusFinancialCsvImportOptions = nil): TNimbusFinancialDataImportResult; static;
    class function ExportCsv(const Candles: TNimbusFinancialCandleArray; const First, Count: Integer; const Delimiter: Char = ','): string; static;
  end;

implementation

constructor TNimbusFinancialCsvImportOptions.Create;
begin
  inherited Create; FDelimiter := ','; FDecimalSeparator := '.'; FHasHeader := True; FTrimFields := True; FSortByTime := True;
  FDuplicateTimeHandling := nfdthReplace; FErrorHandling := nfceThrow;
  FTimeColumn := 'Date'; FOpenColumn := 'Open'; FHighColumn := 'High'; FLowColumn := 'Low'; FCloseColumn := 'Close'; FVolumeColumn := 'Volume';
end;

procedure TNimbusFinancialCsvImportOptions.Assign(Source: TPersistent);
var Other: TNimbusFinancialCsvImportOptions;
begin
  if not (Source is TNimbusFinancialCsvImportOptions) then begin inherited; Exit end; Other := TNimbusFinancialCsvImportOptions(Source);
  FDelimiter := Other.FDelimiter; FDecimalSeparator := Other.FDecimalSeparator; FHasHeader := Other.FHasHeader;
  FTrimFields := Other.FTrimFields; FSortByTime := Other.FSortByTime; FDuplicateTimeHandling := Other.FDuplicateTimeHandling;
  FErrorHandling := Other.FErrorHandling; FTimeColumn := Other.FTimeColumn; FOpenColumn := Other.FOpenColumn;
  FHighColumn := Other.FHighColumn; FLowColumn := Other.FLowColumn; FCloseColumn := Other.FCloseColumn; FVolumeColumn := Other.FVolumeColumn;
end;

constructor TNimbusFinancialDataImportResult.Create;
begin inherited Create; FCandles := TNimbusFinancialDataPointCollection.Create(Self); FErrors := TStringList.Create end;

destructor TNimbusFinancialDataImportResult.Destroy;
begin FErrors.Free; FCandles.Free; inherited end;

class procedure TNimbusFinancialDataAdapter.ValidateCandle(const Time: TDateTime; const Open, High, Low, Close, Volume: Double);
var Value: Double; Values: array[0..5] of Double;
begin
  Values[0] := Time; Values[1] := Open; Values[2] := High; Values[3] := Low; Values[4] := Close; Values[5] := Volume;
  for Value in Values do
    if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('Candle values must be finite');
  if (Time < EncodeDate(1, 1, 1)) or (Time >= EncodeDate(9999, 12, 31) + 1) then
    raise EArgumentOutOfRangeException.Create('Candle time is outside the supported date range');
  if (High < Low) or (Open > High) or (Open < Low) or (Close > High) or (Close < Low) or (Volume < 0) then
    raise EArgumentOutOfRangeException.Create('OHLC must lie within low/high and volume must be nonnegative');
end;

function ParseTime(const Text: string; out Time: TDateTime): Boolean;
var DateText, TimeText: string; Parts: TArray<string>; Year, Month, Day, Hour, Minute, Second: Integer; D, T: TDateTime; P: Integer;
begin
  Result := TryISO8601ToDate(Text, Time, False); if Result then Exit;
  DateText := Trim(Text); TimeText := ''; P := Pos(' ', DateText);
  if P > 0 then begin TimeText := Copy(DateText, P + 1, MaxInt); DateText := Copy(DateText, 1, P - 1) end;
  Year := 0; Month := 0; Day := 0; Hour := 0; Minute := 0; Second := 0;
  if Pos('.', DateText) > 0 then
  begin Parts := DateText.Split(['.']); if Length(Parts) <> 3 then Exit(False); Day := StrToIntDef(Parts[0], 0); Month := StrToIntDef(Parts[1], 0); Year := StrToIntDef(Parts[2], 0) end
  else if Pos('/', DateText) > 0 then
  begin Parts := DateText.Split(['/']); if Length(Parts) <> 3 then Exit(False); Month := StrToIntDef(Parts[0], 0); Day := StrToIntDef(Parts[1], 0); Year := StrToIntDef(Parts[2], 0) end
  else if Pos('-', DateText) > 0 then
  begin Parts := DateText.Split(['-']); if Length(Parts) <> 3 then Exit(False); Year := StrToIntDef(Parts[0], 0); Month := StrToIntDef(Parts[1], 0); Day := StrToIntDef(Parts[2], 0) end
  else if Length(DateText) in [8, 14] then
  begin
    Year := StrToIntDef(Copy(DateText, 1, 4), 0); Month := StrToIntDef(Copy(DateText, 5, 2), 0); Day := StrToIntDef(Copy(DateText, 7, 2), 0);
    if Length(DateText) = 14 then begin Hour := StrToIntDef(Copy(DateText, 9, 2), -1); Minute := StrToIntDef(Copy(DateText, 11, 2), -1); Second := StrToIntDef(Copy(DateText, 13, 2), -1) end;
  end;
  if TimeText <> '' then
  begin
    Parts := TimeText.Split([':']); if not (Length(Parts) in [2, 3]) then Exit(False);
    Hour := StrToIntDef(Parts[0], -1); Minute := StrToIntDef(Parts[1], -1); if Length(Parts) = 3 then Second := StrToIntDef(Parts[2], -1);
  end;
  if (Year < 1) or (Year > 9999) or (Month < 1) or (Month > 12) or (Day < 1) or (Day > 31) or
    (Hour < 0) or (Hour > 23) or (Minute < 0) or (Minute > 59) or (Second < 0) or (Second > 59) then Exit(False);
  Result := TryEncodeDate(Year, Month, Day, D) and TryEncodeTime(Hour, Minute, Second, 0, T);
  if Result then Time := D + T;
end;

function ParseCsv(const Text: string; const Delimiter: Char): TArray<TArray<string>>;
var Rows: TList<TArray<string>>; Fields: TList<string>; Field: TStringBuilder; I: Integer; Quoted: Boolean; Ch: Char;
  procedure EndField;
  begin Fields.Add(Field.ToString); Field.Clear end;
  procedure EndRow;
  begin EndField; if (Fields.Count > 1) or (Trim(Fields[0]) <> '') then Rows.Add(Fields.ToArray); Fields.Clear end;
begin
  if CharInSet(Delimiter, ['"', #0, #10, #13]) then raise EArgumentException.Create('Invalid CSV delimiter');
  Rows := TList<TArray<string>>.Create;
  try
    Fields := TList<string>.Create;
    try
      Field := TStringBuilder.Create;
      try
        I := 1; Quoted := False;
        while I <= Length(Text) do
        begin
          Ch := Text[I];
          if Ch = '"' then
          begin
            if Quoted and (I < Length(Text)) and (Text[I + 1] = '"') then begin Field.Append('"'); Inc(I) end
            else if Quoted then Quoted := False
            else if Field.Length = 0 then Quoted := True else raise EConvertError.Create('Unexpected quote in CSV field');
          end
          else if (Ch = Delimiter) and not Quoted then EndField
          else if CharInSet(Ch, [#10, #13]) and not Quoted then
          begin EndRow; if (Ch = #13) and (I < Length(Text)) and (Text[I + 1] = #10) then Inc(I) end
          else Field.Append(Ch);
          Inc(I);
        end;
        if Quoted then raise EConvertError.Create('Unterminated CSV quote');
        if (Field.Length > 0) or (Fields.Count > 0) then EndRow;
        Result := Rows.ToArray;
      finally Field.Free end;
    finally Fields.Free end;
  finally Rows.Free end;
end;

procedure StoreCandle(Result: TNimbusFinancialDataImportResult; Options: TNimbusFinancialCsvImportOptions;
  const Time: TDateTime; const Open, High, Low, Close, Volume: Double; Times: TDictionary<Double, TNimbusFinancialDataPoint>);
var Existing, Candle: TNimbusFinancialDataPoint;
begin
  TNimbusFinancialDataAdapter.ValidateCandle(Time, Open, High, Low, Close, Volume);
  if Times.TryGetValue(Time, Existing) then
    case Options.DuplicateTimeHandling of
      nfdthSkip: begin Inc(Result.SkippedRows); Exit end;
      nfdthThrow: raise EConvertError.Create('Duplicate candle time: ' + DateTimeToStr(Time));
      nfdthReplace:
        begin Existing.Open := Open; Existing.High := High; Existing.Low := Low; Existing.Close := Close; Existing.Volume := Volume; Exit end;
    end;
  Candle := Result.Candles.Add(Time, Open, High, Low, Close, Volume); Times.AddOrSetValue(Time, Candle); Inc(Result.ImportedRows);
end;

procedure SortCandles(Data: TNimbusFinancialDataPointCollection);
var Ordered: TNimbusFinancialCandleArray; I: Integer;
begin
  Ordered := TNimbusFinancialIndicators.OrderedCandles(Data);
  Data.BeginUpdate;
  try for I := 0 to High(Ordered) do Ordered[I].Index := I finally Data.EndUpdate end;
end;

class function TNimbusFinancialDataAdapter.ImportCsvText(const Text: string; Options: TNimbusFinancialCsvImportOptions): TNimbusFinancialDataImportResult;
var Rows: TArray<TArray<string>>; Actual: TNimbusFinancialCsvImportOptions; Owned: Boolean; I, J, First: Integer;
  Columns: array[0..5] of Integer; Names: array[0..5] of string; Values: array[0..4] of Double;
  Time: TDateTime; FormatSettings: TFormatSettings; Times: TDictionary<Double, TNimbusFinancialDataPoint>;
  function Field(const Column: Integer): string;
  begin
    if Column < 0 then Exit('0'); if Column >= Length(Rows[I]) then raise EConvertError.Create('CSV row has too few columns');
    Result := Rows[I][Column]; if Actual.TrimFields then Result := Trim(Result);
  end;
begin
  Owned := Options = nil; Actual := Options; if Owned then Actual := TNimbusFinancialCsvImportOptions.Create;
  try
    Rows := ParseCsv(Text, Actual.Delimiter); Result := TNimbusFinancialDataImportResult.Create;
    try
      if Length(Rows) = 0 then Exit;
      Names[0] := Actual.TimeColumn; Names[1] := Actual.OpenColumn; Names[2] := Actual.HighColumn;
      Names[3] := Actual.LowColumn; Names[4] := Actual.CloseColumn; Names[5] := Actual.VolumeColumn;
      First := 0; for J := 0 to 5 do Columns[J] := J;
      if Actual.HasHeader then
      begin
        Rows[0][0] := StringReplace(Rows[0][0], #$FEFF, '', []);
        for J := 0 to 5 do
        begin
          Columns[J] := -1;
          for I := 0 to High(Rows[0]) do if SameText(Trim(Rows[0][I]), Names[J]) then begin Columns[J] := I; Break end;
          if (Columns[J] < 0) and (J < 5) then raise EConvertError.Create('Missing CSV column: ' + Names[J]);
        end;
        First := 1;
      end;
      FormatSettings := TFormatSettings.Invariant; FormatSettings.DecimalSeparator := Actual.DecimalSeparator;
      FormatSettings.ThousandSeparator := #0;
      Times := TDictionary<Double, TNimbusFinancialDataPoint>.Create;
      try
        Result.Candles.BeginUpdate;
        try
          for I := First to High(Rows) do
          begin
            Inc(Result.ReadRows);
            try
              if not ParseTime(Field(Columns[0]), Time) then raise EConvertError.Create('Invalid candle date');
              for J := 0 to 4 do if not TryStrToFloat(Field(Columns[J + 1]), Values[J], FormatSettings) then raise EConvertError.Create('Invalid number in ' + Names[J + 1]);
              StoreCandle(Result, Actual, Time, Values[0], Values[1], Values[2], Values[3], Values[4], Times);
            except
              on E: EConvertError do
              begin
                if Actual.ErrorHandling = nfceThrow then raise EConvertError.CreateFmt('CSV row %d: %s', [I + 1, E.Message]);
                Result.Errors.Add(Format('Row %d: %s', [I + 1, E.Message])); Inc(Result.SkippedRows);
              end;
              on E: EArgumentOutOfRangeException do
              begin
                if Actual.ErrorHandling = nfceThrow then raise EConvertError.CreateFmt('CSV row %d: %s', [I + 1, E.Message]);
                Result.Errors.Add(Format('Row %d: %s', [I + 1, E.Message])); Inc(Result.SkippedRows);
              end;
            end;
          end;
        finally Result.Candles.EndUpdate end;
      finally Times.Free end;
      if Actual.SortByTime then SortCandles(Result.Candles);
    except Result.Free; raise end;
  finally if Owned then Actual.Free end;
end;

class function TNimbusFinancialDataAdapter.ImportDataSet(DataSet: TDataSet; Options: TNimbusFinancialCsvImportOptions): TNimbusFinancialDataImportResult;
var Actual: TNimbusFinancialCsvImportOptions; Owned: Boolean; Bookmark: TBookmark;
  TimeField, OpenField, HighField, LowField, CloseField, VolumeField: TField;
  Times: TDictionary<Double, TNimbusFinancialDataPoint>; Volume: Double;
begin
  if (DataSet = nil) or not DataSet.Active then raise EArgumentException.Create('An active dataset is required');
  if DataSet.IsUniDirectional then raise EArgumentException.Create('Data binding requires a bidirectional dataset to preserve its position');
  Owned := Options = nil; Actual := Options; if Owned then Actual := TNimbusFinancialCsvImportOptions.Create;
  try
    Result := TNimbusFinancialDataImportResult.Create;
    try
      TimeField := DataSet.FieldByName(Actual.TimeColumn); OpenField := DataSet.FieldByName(Actual.OpenColumn);
      HighField := DataSet.FieldByName(Actual.HighColumn); LowField := DataSet.FieldByName(Actual.LowColumn);
      CloseField := DataSet.FieldByName(Actual.CloseColumn); VolumeField := DataSet.FindField(Actual.VolumeColumn);
      Times := TDictionary<Double, TNimbusFinancialDataPoint>.Create;
      try
        Bookmark := DataSet.GetBookmark; DataSet.DisableControls;
        try
          DataSet.First;
          while not DataSet.Eof do
          begin
            Inc(Result.ReadRows);
            try
              if TimeField.IsNull or OpenField.IsNull or HighField.IsNull or LowField.IsNull or CloseField.IsNull then
                raise EConvertError.Create('Required candle field is null');
              Volume := 0; if (VolumeField <> nil) and not VolumeField.IsNull then Volume := VolumeField.AsFloat;
              StoreCandle(Result, Actual, TimeField.AsDateTime, OpenField.AsFloat, HighField.AsFloat, LowField.AsFloat, CloseField.AsFloat, Volume, Times);
            except
              on E: EConvertError do
              begin if Actual.ErrorHandling = nfceThrow then raise; Result.Errors.Add(E.Message); Inc(Result.SkippedRows) end;
              on E: EArgumentOutOfRangeException do
              begin if Actual.ErrorHandling = nfceThrow then raise; Result.Errors.Add(E.Message); Inc(Result.SkippedRows) end;
            end;
            DataSet.Next;
          end;
        finally
          try if DataSet.BookmarkValid(Bookmark) then DataSet.GotoBookmark(Bookmark)
          finally DataSet.FreeBookmark(Bookmark); DataSet.EnableControls end;
        end;
      finally Times.Free end;
      if Actual.SortByTime then SortCandles(Result.Candles);
    except Result.Free; raise end;
  finally if Owned then Actual.Free end;
end;

class function TNimbusFinancialDataAdapter.ExportCsv(const Candles: TNimbusFinancialCandleArray; const First, Count: Integer; const Delimiter: Char): string;
var Builder: TStringBuilder; I, Start, Finish: Integer; Candle: TNimbusFinancialDataPoint; Fmt: TFormatSettings;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.Append('Date').Append(Delimiter).Append('Open').Append(Delimiter).Append('High').Append(Delimiter).Append('Low').Append(Delimiter).Append('Close').Append(Delimiter).Append('Volume').AppendLine;
    Start := EnsureRange(First, 0, Length(Candles)); Finish := Integer(Min(Int64(Length(Candles)), Int64(Start) + Max(0, Count)));
    Fmt := TFormatSettings.Invariant;
    for I := Start to Finish - 1 do
    begin
      Candle := Candles[I]; Builder.Append(FormatDateTime('yyyy-mm-dd hh:nn:ss', Candle.Time, Fmt)).Append(Delimiter);
      Builder.Append(FloatToStr(Candle.Open, Fmt)).Append(Delimiter).Append(FloatToStr(Candle.High, Fmt)).Append(Delimiter);
      Builder.Append(FloatToStr(Candle.Low, Fmt)).Append(Delimiter).Append(FloatToStr(Candle.Close, Fmt)).Append(Delimiter).Append(FloatToStr(Candle.Volume, Fmt)).AppendLine;
    end;
    Result := Builder.ToString;
  finally Builder.Free end;
end;

end.
