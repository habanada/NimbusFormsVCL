unit NimbusForms.Grid.EditStrings;

interface

type
  TThemedGridEditStrings = class sealed
  public
    const
      ChangeReasonEditor = 'Editor';
      ChangeReasonSetValue = 'SetValue';
      ChangeReasonPaste = 'Paste';
      ChangeReasonUndo = 'Undo';
      ChangeReasonRedo = 'Redo';
      ChangeReasonDrop = 'Drop';
      ChangeReasonDirectRating = 'DirectRating';
      ChangeReasonDirectToggle = 'DirectToggle';
      ChangeReasonDirectSlider = 'DirectSlider';
      ChangeReasonDirectCheckBox = 'DirectCheckBox';
      InvalidValue = 'Invalid value.';
      BlankDateFormat = '''  ''';
      DateFormatLetters = 'dMyhHmst';
      DateFormatSeparators = ' .,:/-''';
  end;

implementation

end.
