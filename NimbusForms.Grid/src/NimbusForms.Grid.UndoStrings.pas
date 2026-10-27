unit NimbusForms.Grid.UndoStrings;

interface

type
  TThemedGridUndoStrings = class sealed
  public
    const
      UnitNameDefault = 'Change';
      UnitNameBatch = 'Batch';
      UnitNamePaste = 'Paste';
      UnitNameDrop = 'Drop';
      UnitNameRowMove = 'RowMove';
      UnitNameRowAdd = 'RowAdd';
      UnitNameRowRemove = 'RowRemove';
      RemoveConfirmCaption = 'Remove rows';
      RemoveConfirmSingleText = 'Remove the selected row?';
      RemoveConfirmMultipleText = 'Remove %d selected rows?';
  end;

implementation

end.
