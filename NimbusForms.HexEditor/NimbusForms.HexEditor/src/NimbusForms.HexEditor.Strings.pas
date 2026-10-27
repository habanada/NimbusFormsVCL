unit NimbusForms.HexEditor.Strings;

interface

type
  HexEditorTexts = class
  public
  const
    NoData = 'No data';
    OffsetHeader = 'Offset';
    AsciiHeader = 'ASCII';
    SpecialByteCarriageReturn = 'CR';
    SpecialByteLineFeed = 'LF';
    SpecialByteTab = #$2192;
    SpecialByteSpace = #$00B7;
    SpecialByteNull = '0';
    SpecialByteControl = #$2022;
    ErrNoDocument = 'No document is loaded.';
    ErrSessionWithoutFile = 'The session does not reference an original file.';
  end;

  HexFindReplaceTexts = class
  public
  const
    FindNotFound = 'No match found.';
    FindFoundPrefix = 'Found at ';
    FindTextRequired = 'Enter text to find.';
    FindOptionNotSupportedByHexAdapter = 'Whole word and regular expressions are not supported in the hex editor.';
    FindInvalidHexPattern = 'Invalid hex pattern.';
    ReplaceInvalidHexPattern = 'Invalid hex replacement.';
    ReplaceNoActiveMatch = 'No active match to replace.';
    ReplaceFailed = 'Replace failed.';
    ReplaceDone = 'Replaced.';
    ReplaceAllDonePrefix = 'Replaced: ';
    OffsetFormat = '0x%.8X';
    HexPrefixLong = 'hex:';
    HexPrefixShort = '0x';
    DialogTitleFind = 'Find';
    DialogTitleReplace = 'Replace';
    LabelFind = 'Find what:';
    LabelReplace = 'Replace with:';
    OptionMatchCase = 'Match case';
    OptionWholeWord = 'Whole word';
    OptionRegex = 'Regular expression';
    OptionWrap = 'Wrap around';
    LabelDirection = 'Direction';
    DirectionUp = 'Up';
    DirectionDown = 'Down';
    LabelScope = 'Scope';
    ScopeDocument = 'Document';
    ScopeSelection = 'Selection';
    ButtonFindNext = 'Find Next';
    ButtonFindPrevious = 'Find Previous';
    ButtonReplace = 'Replace';
    ButtonReplaceAll = 'Replace All';
    ButtonClose = 'Close';
    FontName = 'Segoe UI';
    DialogName = 'ThemedHexFindReplaceDialog';
  end;

implementation

end.
