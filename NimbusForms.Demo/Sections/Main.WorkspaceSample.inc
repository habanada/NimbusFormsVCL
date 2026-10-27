procedure TMainForm.LoadHexSample;
var
  LData, LText: TBytes;
  I: Integer;
begin
  SetLength(LData, 8192);
  for I := 0 to High(LData) do
    LData[I] := Byte((I * 17 + (I div 16) * 11) and $FF);
  LData[0] := $4D;
  LData[1] := $5A;
  LText := TEncoding.ASCII.GetBytes('NimbusForms VCL HexEditor renderer-first demo');
  for I := 0 to High(LText) do
    if 128 + I <= High(LData) then
      LData[128 + I] := LText[I];
  FHexEditor.LoadBytes(LData);
end;

