unit NimbusForms.Grid.FilterStrings;

interface

type
  ThemedGridFilterStrings = class sealed
  public
    const
      OperatorEquals = 'Equals';
      OperatorNotEquals = 'Not equals';
      OperatorContains = 'Contains';
      OperatorNotContains = 'Does not contain';
      OperatorStartsWith = 'Starts with';
      OperatorEndsWith = 'Ends with';
      OperatorGreaterThan = 'Greater than';
      OperatorGreaterOrEqual = 'Greater or equal';
      OperatorLessThan = 'Less than';
      OperatorLessOrEqual = 'Less or equal';
      OperatorAfter = 'After';
      OperatorFrom = 'From';
      OperatorBefore = 'Before';
      OperatorUntil = 'Until';
      OperatorBetween = 'Between';
      OperatorIsNull = 'Is null';
      OperatorIsNotNull = 'Is not null';
      OperatorIsEmpty = 'Is empty';
      OperatorIsNotEmpty = 'Is not empty';
      OperatorToday = 'Today';
      OperatorYesterday = 'Yesterday';
      OperatorThisWeek = 'This week';
      OperatorThisMonth = 'This month';
      OperatorThisYear = 'This year';
      OperatorIn = 'Select values';
      OperatorNotIn = 'Exclude values';
      OperatorLabel = 'Operator';
      ValueLabel = 'Value';
      SecondValueLabel = 'To';
      ValueCue = 'Enter value';
      SecondValueCue = 'Enter second value';
      SearchValuesCue = 'Search values';
      SelectAll = 'All';
      SelectNone = 'None';
      SelectionStateFormat = '%d / %d selected';
      SelectAtLeastOne = 'Select at least one value';
      InvalidNumber = 'Invalid number';
      ButtonOk = 'OK';
      ButtonClear = 'Clear';
      ButtonCancel = 'Cancel';
      CloseGlyph = #$00D7;
      BoolCaption = 'True';
      NoValues = 'No values';
      PopupName = 'ThemedGridHeaderFilterPopup';
      TimeFormatLetters = 'HhmsHmms';
      DateOnlyFormat = 'dd.MM.yyyy';
      DateTimeFormat = 'dd.MM.yyyy HH:mm:ss';
      TimeOnlyFormat = 'HH:mm:ss';
  end;

implementation

end.
