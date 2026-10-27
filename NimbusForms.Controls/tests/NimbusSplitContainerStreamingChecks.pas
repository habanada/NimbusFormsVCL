unit NimbusSplitContainerStreamingChecks;

interface

procedure RunSplitContainerStreamingChecks;

implementation

uses System.Classes, System.SysUtils, System.TypInfo, Vcl.ExtCtrls,
  NimbusForms.Controls.SplitContainer, NimbusForms.Controls.Panel, NimbusForms.Controls.Button;

const
  LegacyProperties = '  Panel1.Left = 17'#13#10 + '  Panel1.Caption = ''legacy first'''#13#10 +
    '  Panel2.Left = 23'#13#10 + '  Panel2.Caption = ''legacy second'''#13#10;
  OwnedPanels = '  object FirstHost: TPanel'#13#10 + '    Caption = ''first'''#13#10 + '  end'#13#10 +
    '  object SecondHost: TPanel'#13#10 + '    Caption = ''second'''#13#10 +
    '    object Content: TThemedPanel'#13#10 + '      ShowBorder = False'#13#10 +
    '      object ActionButton: TThemedButton'#13#10 + '        Caption = ''Search'''#13#10 +
    '      end'#13#10 + '    end'#13#10 +
    '    object Nested: TThemedSplitContainer'#13#10 +
    '      Panel1.Left = 9'#13#10 +
    '      object NestedFirst: TPanel'#13#10 + '      end'#13#10 +
    '      object NestedSecond: TPanel'#13#10 + '      end'#13#10 +
    '    end'#13#10 + '  end'#13#10;

procedure Check(const Value: Boolean; const MessageText: string);
begin
  if not Value then raise Exception.Create(MessageText);
end;

function LoadSplit(const Properties, Children: string): TThemedSplitContainer;
var
  Text: TStringStream;
  Binary: TMemoryStream;
begin
  Text := TStringStream.Create('object Split: TThemedSplitContainer'#13#10 + Properties + Children + 'end'#13#10);
  try
    Binary := TMemoryStream.Create;
    try
      ObjectTextToBinary(Text, Binary);
      Binary.Position := 0;
      Result := TThemedSplitContainer(Binary.ReadComponent(nil));
    finally
      Binary.Free;
    end;
  finally
    Text.Free;
  end;
end;

procedure CheckPanels(Split: TThemedSplitContainer);
var
  I, Count: Integer;
begin
  Check((Split.Panel1 <> nil) and (Split.Panel2 <> nil), 'Both panels must survive DFM loading');
  Check(Split.Panel1 <> Split.Panel2, 'Panels must remain distinct');
  Check((Split.Panel1.Parent = Split) and (Split.Panel2.Parent = Split), 'Panels must keep their parent');
  Check((Split.Panel1.Owner = Split) and (Split.Panel2.Owner = Split), 'Panels must keep their owner');
  Count := 0;
  for I := 0 to Split.ComponentCount - 1 do
    if Split.Components[I] is TPanel then Inc(Count);
  Check(Count = 2, 'Loading must not leave duplicate host panels');
end;

procedure CheckContent(Split: TThemedSplitContainer);
var
  Content: TThemedPanel;
  Button: TThemedButton;
  Nested: TThemedSplitContainer;
begin
  CheckPanels(Split);
  Check((Split.Panel1.Name = 'FirstHost') and (Split.Panel2.Name = 'SecondHost'), 'Owned panel order must survive loading');
  Check((Split.Panel1.Caption = 'first') and (Split.Panel2.Caption = 'second'), 'Owned hosts take precedence over legacy panel defaults');
  Content := Split.FindComponent('Content') as TThemedPanel;
  Check((Content <> nil) and (Content.Parent = Split.Panel2), 'Themed panel must remain in the second host');
  Button := Split.FindComponent('ActionButton') as TThemedButton;
  Check((Button <> nil) and (Button.Parent = Content) and (Button.Caption = 'Search'), 'Nested button must keep its parent and caption');
  Nested := Split.FindComponent('Nested') as TThemedSplitContainer;
  Check((Nested <> nil) and (Nested.Parent = Split.Panel2), 'Nested split container must remain in the second host');
  CheckPanels(Nested);
  Check((Nested.Panel1.Name = 'NestedFirst') and (Nested.Panel2.Name = 'NestedSecond'), 'Nested host names must survive loading');
end;

procedure CheckRoundTrip(Split: TThemedSplitContainer);
var
  Binary: TMemoryStream;
  Text: TStringStream;
  Loaded: TThemedSplitContainer;
begin
  Binary := TMemoryStream.Create;
  try
    Binary.WriteComponent(Split);
    Binary.Position := 0;
    Text := TStringStream.Create;
    try
      ObjectBinaryToText(Binary, Text);
      Check((Pos('Panel1.', Text.DataString) = 0) and (Pos('Panel2.', Text.DataString) = 0),
        'Writer must serialize hosts only as child objects');
    finally
      Text.Free;
    end;
    Binary.Position := 0;
    Loaded := TThemedSplitContainer(Binary.ReadComponent(nil));
    try
      CheckContent(Loaded);
    finally
      Loaded.Free;
    end;
  finally
    Binary.Free;
  end;
end;

procedure RunSplitContainerStreamingChecks;
var
  Split: TThemedSplitContainer;
  PanelInfo: PPropInfo;
begin
  RegisterClasses([TThemedSplitContainer, TThemedPanel, TThemedButton]);
  Split := LoadSplit(LegacyProperties, '');
  try
    CheckPanels(Split);
    Check((Split.Panel1.Left = 17) and (Split.Panel2.Left = 23), 'Legacy dotted coordinates must load');
    Check((Split.Panel1.Caption = 'legacy first') and (Split.Panel2.Caption = 'legacy second'), 'Legacy dotted captions must load');
    PanelInfo := GetPropInfo(Split.ClassInfo, 'Panel1');
    Check(PanelInfo <> nil, 'Panel1 must have published RTTI');
    Check(not IsStoredProp(Split, PanelInfo), 'Panel1 must not be written as a dotted property');
    PanelInfo := GetPropInfo(Split.ClassInfo, 'Panel2');
    Check(PanelInfo <> nil, 'Panel2 must have published RTTI');
    Check(not IsStoredProp(Split, PanelInfo), 'Panel2 must not be written as a dotted property');
  finally
    Split.Free;
  end;
  Split := LoadSplit(LegacyProperties, OwnedPanels);
  try
    CheckContent(Split);
    CheckRoundTrip(Split);
  finally
    Split.Free;
  end;
  Split := LoadSplit('', OwnedPanels);
  try
    CheckContent(Split);
    CheckRoundTrip(Split);
  finally
    Split.Free;
  end;
end;

end.
