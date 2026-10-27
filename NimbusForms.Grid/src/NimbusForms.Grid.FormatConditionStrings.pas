unit NimbusForms.Grid.FormatConditionStrings;

interface

type
  ThemedGridFormatConditionStrings = class
  public
  const
    JsonVersion = 'Version';
    JsonName = 'Name';
    JsonEnabled = 'Enabled';
    JsonConditions = 'Conditions';
    JsonScope = 'Scope';
    JsonColumnName = 'ColumnName';
    JsonTargetColumnName = 'TargetColumnName';
    JsonOperator = 'Operator';
    JsonValue = 'Value';
    JsonValue2 = 'Value2';
    JsonValues = 'Values';
    JsonValueType = 'ValueType';
    JsonPredicateKey = 'PredicateKey';
    JsonStyle = 'Style';
    JsonTag = 'Tag';
    JsonBackColor = 'BackColor';
    JsonForeColor = 'ForeColor';
    JsonBorderColor = 'BorderColor';
    JsonSelectionBackColor = 'SelectionBackColor';
    JsonSelectionForeColor = 'SelectionForeColor';
    JsonHoverBackColor = 'HoverBackColor';
    JsonHoverForeColor = 'HoverForeColor';
    JsonCurrentBorderColor = 'CurrentBorderColor';
    JsonBold = 'Bold';
    JsonItalic = 'Italic';
    DateTimeFormat = 'mm"/"dd"/"yyyy hh:nn:ss';
    TimeSpanFormat = 'hh:nn:ss';
    BooleanTrueText = 'True';
    BooleanFalseText = 'False';
    WarnRuleEmpty = 'Die Regel ist leer und wird ignoriert.';
    WarnSourceColumnMissing = 'Die Quellspalte fehlt. Die Regel wird ignoriert.';
    WarnSourceColumnUnknown = 'Die Quellspalte existiert im aktuellen Grid nicht. Die Regel bleibt gespeichert, wird aber nicht angewendet.';
    WarnTargetColumnUnknown = 'Die Zielspalte existiert im aktuellen Grid nicht. Die Regel bleibt gespeichert, wird aber nicht angewendet.';
    WarnStyleMissing = 'Die Regel hat keinen Style und hat dadurch keine sichtbare Wirkung.';
    ErrInvalidJson = 'Invalid format condition JSON.';
  end;

implementation

end.
