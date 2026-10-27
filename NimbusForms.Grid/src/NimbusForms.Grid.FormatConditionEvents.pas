unit NimbusForms.Grid.FormatConditionEvents;

{$SCOPEDENUMS ON}

interface

uses
  NimbusForms.Grid.FormatCondition;

type
  TThemedGridFormatConditionChangeAction = (Add, Insert, Remove, RemoveAt, Clear, Replace, Reset,
    EnabledChanged, ConditionChanged, BeginUpdate, EndUpdate);

  TThemedGridFormatConditionChangedEventArgs = class
  private
    FAction: TThemedGridFormatConditionChangeAction;
    FCondition: TThemedGridFormatCondition;
    FIndex: Integer;
    FConditionsEnabled: Boolean;
    FConditionCount: Integer;
    FEnabledConditionCount: Integer;
  public
    constructor Create(const AAction: TThemedGridFormatConditionChangeAction;
      const ACondition: TThemedGridFormatCondition; const AIndex: Integer;
      const AConditionsEnabled: Boolean; const AConditionCount, AEnabledConditionCount: Integer);
    property Action: TThemedGridFormatConditionChangeAction read FAction;
    property Condition: TThemedGridFormatCondition read FCondition;
    property Index: Integer read FIndex;
    property ConditionsEnabled: Boolean read FConditionsEnabled;
    property ConditionCount: Integer read FConditionCount;
    property EnabledConditionCount: Integer read FEnabledConditionCount;
  end;

  TThemedGridFormatConditionChangedEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridFormatConditionChangedEventArgs) of object;

implementation

constructor TThemedGridFormatConditionChangedEventArgs.Create(const AAction: TThemedGridFormatConditionChangeAction;
  const ACondition: TThemedGridFormatCondition; const AIndex: Integer;
  const AConditionsEnabled: Boolean; const AConditionCount, AEnabledConditionCount: Integer);
begin
  inherited Create;
  FAction := AAction;
  FCondition := ACondition;
  FIndex := AIndex;
  FConditionsEnabled := AConditionsEnabled;
  FConditionCount := AConditionCount;
  FEnabledConditionCount := AEnabledConditionCount;
end;

end.
