unit NimbusForms.HexEditor.FileDataSource;

interface

uses
  System.Classes,
  System.SysUtils,
  NimbusForms.HexEditor.DataSource;

type
  TFileHexDataSource = class(TInterfacedObject, IHexDataSource)
  private
    FStream: TFileStream;
    FOnLengthChanged: TNotifyEvent;
  public
    constructor Create(const AFilePath: string);
    destructor Destroy; override;
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

constructor TFileHexDataSource.Create(const AFilePath: string);
begin
  inherited Create;
  FStream := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyWrite);
end;

destructor TFileHexDataSource.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TFileHexDataSource.GetLength: Int64;
begin
  Result := FStream.Size;
end;

function TFileHexDataSource.GetCanWrite: Boolean;
begin
  Result := False;
end;

function TFileHexDataSource.Read(const AOffset: Int64; var ABuffer: TBytes;
  const ACount: Integer): Integer;
var
  LAvailable: Int64;
  LCount: Integer;
begin
  if (AOffset < 0) or (AOffset >= FStream.Size) or (ACount <= 0) then
    Exit(0);
  LAvailable := FStream.Size - AOffset;
  if ACount < LAvailable then
    LCount := ACount
  else
    LCount := LAvailable;
  if System.Length(ABuffer) < LCount then
    SetLength(ABuffer, LCount);
  FStream.Position := AOffset;
  Result := FStream.Read(ABuffer[0], LCount);
end;

procedure TFileHexDataSource.Write(const AOffset: Int64; const AData: TBytes);
begin
  raise ENotSupportedException.Create('File data source is read-only.');
end;

procedure TFileHexDataSource.Insert(const AOffset: Int64; const AData: TBytes);
begin
  raise ENotSupportedException.Create('File data source is read-only.');
end;

procedure TFileHexDataSource.Delete(const AOffset, ALength: Int64);
begin
  raise ENotSupportedException.Create('File data source is read-only.');
end;

function TFileHexDataSource.GetOnLengthChanged: TNotifyEvent;
begin
  Result := FOnLengthChanged;
end;

procedure TFileHexDataSource.SetOnLengthChanged(const AValue: TNotifyEvent);
begin
  FOnLengthChanged := AValue;
end;

end.
