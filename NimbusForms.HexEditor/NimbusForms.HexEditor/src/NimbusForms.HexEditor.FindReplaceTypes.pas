unit NimbusForms.HexEditor.FindReplaceTypes;

interface

uses
  System.SysUtils,
  Vcl.Forms,
  NimbusForms.HexEditor.Theme;

type
  THexFindDirection = (hfdDown, hfdUp);

  THexFindScope = (hfsDocument, hfsSelection);

  THexFindReplaceMode = (hfmFind, hfmReplace);

  THexFindReplaceOptions = record
    FindText: string;
    ReplaceText: string;
    Direction: THexFindDirection;
    Scope: THexFindScope;
    MatchCase: Boolean;
    MatchWholeWord: Boolean;
    UseRegex: Boolean;
    WrapSearch: Boolean;
  end;

  THexFindReplaceEventArgs = class
  private
    FOptions: THexFindReplaceOptions;
    FHandled: Boolean;
    FSuccess: Boolean;
    FMessage: string;
  public
    constructor Create(const AOptions: THexFindReplaceOptions);
    property Options: THexFindReplaceOptions read FOptions;
    property Handled: Boolean read FHandled write FHandled;
    property Success: Boolean read FSuccess write FSuccess;
    property Message: string read FMessage write FMessage;
  end;

  THexFindReplaceEvent = procedure(ASender: TObject; const AArgs: THexFindReplaceEventArgs) of object;

  IHexFindReplaceHost = interface
    ['{AFCE58EA-ECF0-4377-8F51-FFF0AFF42347}']
    function GetDataLength: Int64;
    function ReadBytes(const AOffset: Int64; const ACount: Integer): TBytes;
    function InsertBytes(const AOffset: Int64; const AData: TBytes): Boolean;
    function DeleteBytes(const AOffset, ALength: Int64): Boolean;
    function GetHasSelection: Boolean;
    function GetSelectionStart: Int64;
    function GetSelectionLength: Int64;
    function GetCursorOffset: Int64;
    procedure GoToOffset(const AOffset, ALength: Int64);
    function GetOwnerForm: TCustomForm;
    function GetPixelsPerInch: Integer;
    function GetTheme: THexTheme;
  end;

implementation

constructor THexFindReplaceEventArgs.Create(const AOptions: THexFindReplaceOptions);
begin
  inherited Create;
  FOptions := AOptions;
end;

end.
