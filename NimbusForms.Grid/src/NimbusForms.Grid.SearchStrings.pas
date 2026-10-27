unit NimbusForms.Grid.SearchStrings;

interface

type
  ThemedGridSearchStrings = class sealed
  public
    const
      CloseText = #$00D7;
      PreviousText = #$2191;
      NextText = #$2193;
      ResultFormat = '%d / %d';
      EmptyResultText = '0 / 0';
      PanelName = 'ThemedGridSearchPanel';
      EditName = 'ThemedGridSearchEdit';
      CloseHint = 'Close (Esc)';
      PreviousHint = 'Previous (Shift+F3)';
      NextHint = 'Next (F3)';
  end;

implementation

end.
