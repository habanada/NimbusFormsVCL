unit NimbusForms.HexEditor.DataSource;

interface

uses
  System.Classes,
  System.SysUtils;

type
  IHexDataSource = interface
    ['{7E1B2A54-9C3D-4F0A-8B21-6D4E5A1C2F80}']
    function GetLength: Int64;
    function GetCanWrite: Boolean;
    function Read(const AOffset: Int64; var ABuffer: TBytes; const ACount: Integer): Integer;
    procedure Write(const AOffset: Int64; const AData: TBytes);
    procedure Insert(const AOffset: Int64; const AData: TBytes);
    procedure Delete(const AOffset, ALength: Int64);
    function GetOnLengthChanged: TNotifyEvent;
    procedure SetOnLengthChanged(const AValue: TNotifyEvent);
    property Length: Int64 read GetLength;
    property CanWrite: Boolean read GetCanWrite;
    property OnLengthChanged: TNotifyEvent read GetOnLengthChanged write SetOnLengthChanged;
  end;

  TBytesHexDataSource = class(TInterfacedObject, IHexDataSource)
  private
    FData: TBytes;
    FOnLengthChanged: TNotifyEvent;
    procedure DoLengthChanged;
  public
    constructor Create(const AData: TBytes);
    function GetLength: Int64;
    function GetCanWrite: Boolean;
    function Read(const AOffset: Int64; var ABuffer: TBytes; const ACount: Integer): Integer;
    procedure Write(const AOffset: Int64; const AData: TBytes);
    procedure Insert(const AOffset: Int64; const AData: TBytes);
    procedure Delete(const AOffset, ALength: Int64);
    function GetOnLengthChanged: TNotifyEvent;
    procedure SetOnLengthChanged(const AValue: TNotifyEvent);
  end;

implementation

constructor TBytesHexDataSource.Create(const AData: TBytes);
begin
  inherited Create;
  FData := Copy(AData, 0, System.Length(AData));
end;

procedure TBytesHexDataSource.DoLengthChanged;
begin
  if Assigned(FOnLengthChanged) then
    FOnLengthChanged(Self);
end;

function TBytesHexDataSource.GetLength: Int64;
begin
  Result := System.Length(FData);
end;

function TBytesHexDataSource.GetCanWrite: Boolean;
begin
  Result := True;
end;

function TBytesHexDataSource.Read(const AOffset: Int64; var ABuffer: TBytes;
  const ACount: Integer): Integer;
var
  LAvailable: Int64;
  LCount: Integer;
begin
  if (AOffset < 0) or (AOffset >= System.Length(FData)) or (ACount <= 0) then
    Exit(0);
  LAvailable := System.Length(FData) - AOffset;
  if ACount < LAvailable then
    LCount := ACount
  else
    LCount := LAvailable;
  if System.Length(ABuffer) < LCount then
    SetLength(ABuffer, LCount);
  Move(FData[AOffset], ABuffer[0], LCount);
  Result := LCount;
end;

procedure TBytesHexDataSource.Write(const AOffset: Int64; const AData: TBytes);
var
  LEnd: Int64;
begin
  if (AOffset < 0) or (System.Length(AData) = 0) then
    Exit;
  LEnd := AOffset + System.Length(AData);
  if LEnd > System.Length(FData) then
  begin
    SetLength(FData, LEnd);
    Move(AData[0], FData[AOffset], System.Length(AData));
    DoLengthChanged;
  end
  else
    Move(AData[0], FData[AOffset], System.Length(AData));
end;

procedure TBytesHexDataSource.Insert(const AOffset: Int64; const AData: TBytes);
var
  LOld, LCount: Integer;
begin
  if (AOffset < 0) or (AOffset > System.Length(FData)) or (System.Length(AData) = 0) then
    Exit;
  LOld := System.Length(FData);
  LCount := System.Length(AData);
  SetLength(FData, LOld + LCount);
  if LOld - AOffset > 0 then
    Move(FData[AOffset], FData[AOffset + LCount], LOld - AOffset);
  Move(AData[0], FData[AOffset], LCount);
  DoLengthChanged;
end;

procedure TBytesHexDataSource.Delete(const AOffset, ALength: Int64);
var
  LTail: Int64;
begin
  if (AOffset < 0) or (ALength <= 0) or (AOffset >= System.Length(FData)) then
    Exit;
  LTail := System.Length(FData) - (AOffset + ALength);
  if LTail > 0 then
    Move(FData[AOffset + ALength], FData[AOffset], LTail);
  SetLength(FData, System.Length(FData) - ALength);
  DoLengthChanged;
end;

function TBytesHexDataSource.GetOnLengthChanged: TNotifyEvent;
begin
  Result := FOnLengthChanged;
end;

procedure TBytesHexDataSource.SetOnLengthChanged(const AValue: TNotifyEvent);
begin
  FOnLengthChanged := AValue;
end;

end.
