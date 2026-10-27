{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Marimekko.Types;

interface

uses System.Classes, System.SysUtils, System.Math, Vcl.Graphics;

type
  TNimbusMarimekkoOptions = class(TPersistent)
  private
    FShowSegmentLabels: Boolean;
    FShowSegmentValues: Boolean;
    FShowSegmentPercent: Boolean;
    FShowCategoryTotals: Boolean;
    FShowGrandTotal: Boolean;
    FShowCategoryAxis: Boolean;
    FShowPercentAxis: Boolean;
    FShowColumnSeparators: Boolean;
    FNormalizeColumns: Boolean;
    FDimUnfocusedSegments: Boolean;
    FShowHoverHighlight: Boolean;
    FShowSelectedHighlight: Boolean;
    FShowToolTipDetails: Boolean;
    FColumnGap: Single;
    FSegmentGap: Single;
    FMinimumColumnWidth: Single;
    FMinimumSegmentHeightForLabel: Single;
    FMinimumSegmentWidthForLabel: Single;
    FSegmentCornerRadius: Single;
    FValueFormat: string;
    FPercentFormat: string;
    FEmptyText: string;
    FOnChange: TNotifyEvent;
    procedure SetShowSegmentLabels(const Value: Boolean);
    procedure SetShowSegmentValues(const Value: Boolean);
    procedure SetShowSegmentPercent(const Value: Boolean);
    procedure SetShowCategoryTotals(const Value: Boolean);
    procedure SetShowGrandTotal(const Value: Boolean);
    procedure SetShowCategoryAxis(const Value: Boolean);
    procedure SetShowPercentAxis(const Value: Boolean);
    procedure SetShowColumnSeparators(const Value: Boolean);
    procedure SetNormalizeColumns(const Value: Boolean);
    procedure SetDimUnfocusedSegments(const Value: Boolean);
    procedure SetShowHoverHighlight(const Value: Boolean);
    procedure SetShowSelectedHighlight(const Value: Boolean);
    procedure SetShowToolTipDetails(const Value: Boolean);
    procedure SetColumnGap(const Value: Single);
    procedure SetSegmentGap(const Value: Single);
    procedure SetMinimumColumnWidth(const Value: Single);
    procedure SetMinimumSegmentHeightForLabel(const Value: Single);
    procedure SetMinimumSegmentWidthForLabel(const Value: Single);
    procedure SetSegmentCornerRadius(const Value: Single);
    procedure SetValueFormat(const Value: string);
    procedure SetPercentFormat(const Value: string);
    procedure SetEmptyText(const Value: string);
    procedure Changed(Sender: TObject);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property ShowSegmentLabels: Boolean read FShowSegmentLabels write SetShowSegmentLabels;
    property ShowSegmentValues: Boolean read FShowSegmentValues write SetShowSegmentValues;
    property ShowSegmentPercent: Boolean read FShowSegmentPercent write SetShowSegmentPercent;
    property ShowCategoryTotals: Boolean read FShowCategoryTotals write SetShowCategoryTotals;
    property ShowGrandTotal: Boolean read FShowGrandTotal write SetShowGrandTotal;
    property ShowCategoryAxis: Boolean read FShowCategoryAxis write SetShowCategoryAxis;
    property ShowPercentAxis: Boolean read FShowPercentAxis write SetShowPercentAxis;
    property ShowColumnSeparators: Boolean read FShowColumnSeparators write SetShowColumnSeparators;
    property NormalizeColumns: Boolean read FNormalizeColumns write SetNormalizeColumns;
    property DimUnfocusedSegments: Boolean read FDimUnfocusedSegments write SetDimUnfocusedSegments;
    property ShowHoverHighlight: Boolean read FShowHoverHighlight write SetShowHoverHighlight;
    property ShowSelectedHighlight: Boolean read FShowSelectedHighlight write SetShowSelectedHighlight;
    property ShowToolTipDetails: Boolean read FShowToolTipDetails write SetShowToolTipDetails;
    property ColumnGap: Single read FColumnGap write SetColumnGap;
    property SegmentGap: Single read FSegmentGap write SetSegmentGap;
    property MinimumColumnWidth: Single read FMinimumColumnWidth write SetMinimumColumnWidth;
    property MinimumSegmentHeightForLabel: Single read FMinimumSegmentHeightForLabel write SetMinimumSegmentHeightForLabel;
    property MinimumSegmentWidthForLabel: Single read FMinimumSegmentWidthForLabel write SetMinimumSegmentWidthForLabel;
    property SegmentCornerRadius: Single read FSegmentCornerRadius write SetSegmentCornerRadius;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property PercentFormat: string read FPercentFormat write SetPercentFormat;
    property EmptyText: string read FEmptyText write SetEmptyText;
  end;

implementation

constructor TNimbusMarimekkoOptions.Create;
begin
  inherited Create;
  FShowSegmentLabels := True;
  FShowSegmentValues := False;
  FShowSegmentPercent := True;
  FShowCategoryTotals := True;
  FShowGrandTotal := True;
  FShowCategoryAxis := True;
  FShowPercentAxis := True;
  FShowColumnSeparators := True;
  FNormalizeColumns := False;
  FDimUnfocusedSegments := True;
  FShowHoverHighlight := True;
  FShowSelectedHighlight := True;
  FShowToolTipDetails := True;
  FColumnGap := 4;
  FSegmentGap := 2;
  FMinimumColumnWidth := 18;
  FMinimumSegmentHeightForLabel := 22;
  FMinimumSegmentWidthForLabel := 48;
  FSegmentCornerRadius := 4;
  FValueFormat := '0.##';
  FPercentFormat := '0.#%';
  FEmptyText := 'No Marimekko data.';
end;

procedure TNimbusMarimekkoOptions.Assign(Source: TPersistent);
var S: TNimbusMarimekkoOptions;
begin
  if not (Source is TNimbusMarimekkoOptions) then begin inherited; Exit end; S := TNimbusMarimekkoOptions(Source);
  FShowSegmentLabels := S.FShowSegmentLabels;
  FShowSegmentValues := S.FShowSegmentValues;
  FShowSegmentPercent := S.FShowSegmentPercent;
  FShowCategoryTotals := S.FShowCategoryTotals;
  FShowGrandTotal := S.FShowGrandTotal;
  FShowCategoryAxis := S.FShowCategoryAxis;
  FShowPercentAxis := S.FShowPercentAxis;
  FShowColumnSeparators := S.FShowColumnSeparators;
  FNormalizeColumns := S.FNormalizeColumns;
  FDimUnfocusedSegments := S.FDimUnfocusedSegments;
  FShowHoverHighlight := S.FShowHoverHighlight;
  FShowSelectedHighlight := S.FShowSelectedHighlight;
  FShowToolTipDetails := S.FShowToolTipDetails;
  FColumnGap := S.FColumnGap;
  FSegmentGap := S.FSegmentGap;
  FMinimumColumnWidth := S.FMinimumColumnWidth;
  FMinimumSegmentHeightForLabel := S.FMinimumSegmentHeightForLabel;
  FMinimumSegmentWidthForLabel := S.FMinimumSegmentWidthForLabel;
  FSegmentCornerRadius := S.FSegmentCornerRadius;
  FValueFormat := S.FValueFormat;
  FPercentFormat := S.FPercentFormat;
  FEmptyText := S.FEmptyText;
  Changed(Self);
end;

procedure TNimbusMarimekkoOptions.SetShowSegmentLabels(const Value: Boolean);
begin if FShowSegmentLabels = Value then Exit; FShowSegmentLabels := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowSegmentValues(const Value: Boolean);
begin if FShowSegmentValues = Value then Exit; FShowSegmentValues := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowSegmentPercent(const Value: Boolean);
begin if FShowSegmentPercent = Value then Exit; FShowSegmentPercent := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowCategoryTotals(const Value: Boolean);
begin if FShowCategoryTotals = Value then Exit; FShowCategoryTotals := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowGrandTotal(const Value: Boolean);
begin if FShowGrandTotal = Value then Exit; FShowGrandTotal := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowCategoryAxis(const Value: Boolean);
begin if FShowCategoryAxis = Value then Exit; FShowCategoryAxis := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowPercentAxis(const Value: Boolean);
begin if FShowPercentAxis = Value then Exit; FShowPercentAxis := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowColumnSeparators(const Value: Boolean);
begin if FShowColumnSeparators = Value then Exit; FShowColumnSeparators := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetNormalizeColumns(const Value: Boolean);
begin if FNormalizeColumns = Value then Exit; FNormalizeColumns := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetDimUnfocusedSegments(const Value: Boolean);
begin if FDimUnfocusedSegments = Value then Exit; FDimUnfocusedSegments := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowHoverHighlight(const Value: Boolean);
begin if FShowHoverHighlight = Value then Exit; FShowHoverHighlight := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowSelectedHighlight(const Value: Boolean);
begin if FShowSelectedHighlight = Value then Exit; FShowSelectedHighlight := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetShowToolTipDetails(const Value: Boolean);
begin if FShowToolTipDetails = Value then Exit; FShowToolTipDetails := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetColumnGap(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FColumnGap = Value then Exit; FColumnGap := Value; Changed(Self)
end;

procedure TNimbusMarimekkoOptions.SetSegmentGap(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FSegmentGap = Value then Exit; FSegmentGap := Value; Changed(Self)
end;

procedure TNimbusMarimekkoOptions.SetMinimumColumnWidth(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMinimumColumnWidth = Value then Exit; FMinimumColumnWidth := Value; Changed(Self)
end;

procedure TNimbusMarimekkoOptions.SetMinimumSegmentHeightForLabel(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMinimumSegmentHeightForLabel = Value then Exit; FMinimumSegmentHeightForLabel := Value; Changed(Self)
end;

procedure TNimbusMarimekkoOptions.SetMinimumSegmentWidthForLabel(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMinimumSegmentWidthForLabel = Value then Exit; FMinimumSegmentWidthForLabel := Value; Changed(Self)
end;

procedure TNimbusMarimekkoOptions.SetSegmentCornerRadius(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FSegmentCornerRadius = Value then Exit; FSegmentCornerRadius := Value; Changed(Self)
end;

procedure TNimbusMarimekkoOptions.SetValueFormat(const Value: string);
begin if FValueFormat = Value then Exit; FValueFormat := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetPercentFormat(const Value: string);
begin if FPercentFormat = Value then Exit; FPercentFormat := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.SetEmptyText(const Value: string);
begin if FEmptyText = Value then Exit; FEmptyText := Value; Changed(Self) end;

procedure TNimbusMarimekkoOptions.Changed(Sender: TObject);
begin if Assigned(FOnChange) then FOnChange(Self) end;

end.
