{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Form.Accessibility;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  System.Variants,
  NimbusForms.Theming.Form.Strings,
  NimbusForms.Theming.Form.Types;

type
  IThemedAccessible = interface(IDispatch)
    ['{618736E0-3C3D-11CF-810C-00AA00389B71}']
    function get_accParent(out ppdispParent: IDispatch): HRESULT; stdcall;
    function get_accChildCount(out pcountChildren: Integer): HRESULT; stdcall;
    function get_accChild(varChild: OleVariant; out ppdispChild: IDispatch): HRESULT; stdcall;
    function get_accName(varChild: OleVariant; out pszName: WideString): HRESULT; stdcall;
    function get_accValue(varChild: OleVariant; out pszValue: WideString): HRESULT; stdcall;
    function get_accDescription(varChild: OleVariant; out pszDescription: WideString): HRESULT; stdcall;
    function get_accRole(varChild: OleVariant; out pvarRole: OleVariant): HRESULT; stdcall;
    function get_accState(varChild: OleVariant; out pvarState: OleVariant): HRESULT; stdcall;
    function get_accHelp(varChild: OleVariant; out pszHelp: WideString): HRESULT; stdcall;
    function get_accHelpTopic(out pszHelpFile: WideString; varChild: OleVariant;
      out pidTopic: Integer): HRESULT; stdcall;
    function get_accKeyboardShortcut(varChild: OleVariant; out pszKeyboardShortcut: WideString): HRESULT; stdcall;
    function get_accFocus(out pvarChild: OleVariant): HRESULT; stdcall;
    function get_accSelection(out pvarChildren: OleVariant): HRESULT; stdcall;
    function get_accDefaultAction(varChild: OleVariant; out pszDefaultAction: WideString): HRESULT; stdcall;
    function accSelect(flagsSelect: Integer; varChild: OleVariant): HRESULT; stdcall;
    function accLocation(out pxLeft: Integer; out pyTop: Integer; out pcxWidth: Integer;
      out pcyHeight: Integer; varChild: OleVariant): HRESULT; stdcall;
    function accNavigate(navDir: Integer; varStart: OleVariant; out pvarEndUpAt: OleVariant): HRESULT; stdcall;
    function accHitTest(xLeft: Integer; yTop: Integer; out pvarChild: OleVariant): HRESULT; stdcall;
    function accDoDefaultAction(varChild: OleVariant): HRESULT; stdcall;
    function put_accName(varChild: OleVariant; pszName: WideString): HRESULT; stdcall;
    function put_accValue(varChild: OleVariant; pszValue: WideString): HRESULT; stdcall;
  end;

  IThemedModernFormAccessibilityHost = interface
    function GetWindowHandle: HWND;
    function GetCaptionText: string;
    function GetCustomChrome: Boolean;
    function GetFormVisible: Boolean;
    function GetMaximized: Boolean;
    function GetFormScreenBounds: TRect;
    function GetTitleBarScreenBounds: TRect;
    function GetSystemMenuScreenBounds: TRect;
    function IsSystemMenuVisible: Boolean;
    function IsButtonVisible(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsButtonAvailable(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsButtonHot(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsButtonPressed(const AButton: TThemedModernFormWindowButton): Boolean;
    function GetButtonScreenBounds(const AButton: TThemedModernFormWindowButton): TRect;
    procedure ShowSystemMenu;
    procedure ExecuteButton(const AButton: TThemedModernFormWindowButton);
    function GetContentWindowCount: Integer;
    function GetContentWindowHandle(const AIndex: Integer): HWND;
  end;

  TThemedModernFormAccessibility = class
  public
  const
    OBJID_WINDOW_VALUE = 0;
    OBJID_CLIENT_VALUE = -4;
    CHILDID_SELF_VALUE = 0;
    class function CreateRoot(const AHost: IThemedModernFormAccessibilityHost): IThemedAccessible; static;
    class procedure Detach(const ARoot: IThemedAccessible); static;
    class function HandleGetObject(const AWnd: HWND; const AWParam: WPARAM; const ALParam: LPARAM;
      const ARoot: IThemedAccessible; out AResult: LRESULT): Boolean; static;
    class procedure NotifyStructureChanged(const AWnd: HWND); static;
    class procedure NotifyNameChanged(const AWnd: HWND); static;
  end;

implementation

const
  ROLE_SYSTEM_TITLEBAR = 1;
  ROLE_SYSTEM_MENUBAR = 2;
  ROLE_SYSTEM_WINDOW = 9;
  ROLE_SYSTEM_PUSHBUTTON = 43;
  STATE_SYSTEM_UNAVAILABLE = $1;
  STATE_SYSTEM_PRESSED = $8;
  STATE_SYSTEM_HOTTRACKED = $80;
  STATE_SYSTEM_INVISIBLE = $8000;
  STATE_SYSTEM_OFFSCREEN = $10000;
  STATE_SYSTEM_FOCUSABLE = $100000;
  NAVDIR_NEXT = 5;
  NAVDIR_PREVIOUS = 6;
  NAVDIR_FIRSTCHILD = 7;
  NAVDIR_LASTCHILD = 8;
  OBJID_CLIENT_DWORD = DWORD($FFFFFFFC);
  EVENT_OBJECT_REORDER_VALUE = $8004;
  EVENT_OBJECT_STATECHANGE_VALUE = $800A;
  EVENT_OBJECT_NAMECHANGE_VALUE = $800C;
  IID_ThemedAccessible: TGUID = '{618736E0-3C3D-11CF-810C-00AA00389B71}';

function LresultFromObjectNative(const ARiid: TGUID; AWParam: WPARAM; AUnknown: IUnknown): LRESULT; stdcall;
  external 'oleacc.dll' name 'LresultFromObject' delayed;

function AccessibleObjectFromWindowNative(AWnd: HWND; AObjectId: DWORD; const ARiid: TGUID;
  out AObject: Pointer): HRESULT; stdcall; external 'oleacc.dll' name 'AccessibleObjectFromWindow' delayed;

procedure NotifyWinEventNative(AEvent: DWORD; AWnd: HWND; AObjectId, AChildId: Longint); stdcall;
  external 'user32.dll' name 'NotifyWinEvent' delayed;

type
  IThemedAccessibleNodeAccess = interface
    ['{5B0C2F6E-8A47-4D19-A3E1-7C94D2B6E051}']
    function GetNodeObject: TObject;
  end;

  TThemedAccessibleTree = class;

  TThemedAccessibleNode = class(TObject, IThemedAccessible, IThemedAccessibleNodeAccess)
  strict private
    FTree: TThemedAccessibleTree;
  protected
    function GetNodeObject: TObject;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer;
      DispIDs: Pointer): HRESULT; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word;
      var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
    function get_accParent(out ppdispParent: IDispatch): HRESULT; stdcall;
    function get_accChildCount(out pcountChildren: Integer): HRESULT; stdcall;
    function get_accChild(varChild: OleVariant; out ppdispChild: IDispatch): HRESULT; stdcall;
    function get_accName(varChild: OleVariant; out pszName: WideString): HRESULT; stdcall;
    function get_accValue(varChild: OleVariant; out pszValue: WideString): HRESULT; stdcall;
    function get_accDescription(varChild: OleVariant; out pszDescription: WideString): HRESULT; stdcall;
    function get_accRole(varChild: OleVariant; out pvarRole: OleVariant): HRESULT; stdcall;
    function get_accState(varChild: OleVariant; out pvarState: OleVariant): HRESULT; stdcall;
    function get_accHelp(varChild: OleVariant; out pszHelp: WideString): HRESULT; stdcall;
    function get_accHelpTopic(out pszHelpFile: WideString; varChild: OleVariant;
      out pidTopic: Integer): HRESULT; stdcall;
    function get_accKeyboardShortcut(varChild: OleVariant; out pszKeyboardShortcut: WideString): HRESULT; stdcall;
    function get_accFocus(out pvarChild: OleVariant): HRESULT; stdcall;
    function get_accSelection(out pvarChildren: OleVariant): HRESULT; stdcall;
    function get_accDefaultAction(varChild: OleVariant; out pszDefaultAction: WideString): HRESULT; stdcall;
    function accSelect(flagsSelect: Integer; varChild: OleVariant): HRESULT; stdcall;
    function accLocation(out pxLeft: Integer; out pyTop: Integer; out pcxWidth: Integer;
      out pcyHeight: Integer; varChild: OleVariant): HRESULT; stdcall;
    function accNavigate(navDir: Integer; varStart: OleVariant; out pvarEndUpAt: OleVariant): HRESULT; stdcall;
    function accHitTest(xLeft: Integer; yTop: Integer; out pvarChild: OleVariant): HRESULT; stdcall;
    function accDoDefaultAction(varChild: OleVariant): HRESULT; stdcall;
    function put_accName(varChild: OleVariant; pszName: WideString): HRESULT; stdcall;
    function put_accValue(varChild: OleVariant; pszValue: WideString): HRESULT; stdcall;
    function Route(const AChild: OleVariant; out ATarget: IThemedAccessible): HRESULT;
    function GetHost: IThemedModernFormAccessibilityHost;
    function GetRole: Integer; virtual; abstract;
    function GetName: string; virtual; abstract;
    function GetDescription: string; virtual;
    function GetDefaultAction: string; virtual;
    function GetBounds: TRect; virtual; abstract;
    function GetState: Integer; virtual; abstract;
    function GetChildCount: Integer; virtual;
    function GetChildAt(const AIndex: Integer): IThemedAccessible; virtual;
    function GetParentAccessible: IThemedAccessible; virtual; abstract;
    function GetSelfAccessible: IThemedAccessible;
    function HitTestScreen(const AX, AY: Integer): OleVariant; virtual;
    procedure DoAction; virtual;
    property Tree: TThemedAccessibleTree read FTree;
  public
    constructor Create(const ATree: TThemedAccessibleTree);
  end;

  TThemedAccessibleRootNode = class;
  TThemedAccessibleCaptionNode = class;

  TThemedAccessibleTree = class
  strict private
    FRefCount: Integer;
    FHost: IThemedModernFormAccessibilityHost;
    FRoot: TThemedAccessibleRootNode;
    FCaption: TThemedAccessibleCaptionNode;
  public
    constructor Create(const AHost: IThemedModernFormAccessibilityHost);
    destructor Destroy; override;
    function AddRef: Integer;
    function Release: Integer;
    procedure Detach;
    property Host: IThemedModernFormAccessibilityHost read FHost;
    property Root: TThemedAccessibleRootNode read FRoot;
    property Caption: TThemedAccessibleCaptionNode read FCaption;
  end;

  TThemedAccessibleRootNode = class(TThemedAccessibleNode)
  protected
    function GetRole: Integer; override;
    function GetName: string; override;
    function GetBounds: TRect; override;
    function GetState: Integer; override;
    function GetChildCount: Integer; override;
    function GetChildAt(const AIndex: Integer): IThemedAccessible; override;
    function GetParentAccessible: IThemedAccessible; override;
    function HitTestScreen(const AX, AY: Integer): OleVariant; override;
  end;

  TThemedAccessibleCaptionNode = class(TThemedAccessibleNode)
  strict private
    FSystemMenu: TThemedAccessibleNode;
    FMinimize: TThemedAccessibleNode;
    FMaximizeRestore: TThemedAccessibleNode;
    FClose: TThemedAccessibleNode;
  protected
    function GetRole: Integer; override;
    function GetName: string; override;
    function GetDescription: string; override;
    function GetBounds: TRect; override;
    function GetState: Integer; override;
    function GetChildCount: Integer; override;
    function GetChildAt(const AIndex: Integer): IThemedAccessible; override;
    function GetParentAccessible: IThemedAccessible; override;
  public
    constructor Create(const ATree: TThemedAccessibleTree);
    destructor Destroy; override;
  end;

  TThemedAccessibleSystemMenuNode = class(TThemedAccessibleNode)
  protected
    function GetRole: Integer; override;
    function GetName: string; override;
    function GetDescription: string; override;
    function GetDefaultAction: string; override;
    function GetBounds: TRect; override;
    function GetState: Integer; override;
    function GetParentAccessible: IThemedAccessible; override;
    procedure DoAction; override;
  end;

  TThemedAccessibleButtonNode = class(TThemedAccessibleNode)
  strict private
    FButton: TThemedModernFormWindowButton;
  protected
    function GetRole: Integer; override;
    function GetName: string; override;
    function GetDescription: string; override;
    function GetDefaultAction: string; override;
    function GetBounds: TRect; override;
    function GetState: Integer; override;
    function GetParentAccessible: IThemedAccessible; override;
    procedure DoAction; override;
  public
    constructor Create(const ATree: TThemedAccessibleTree; const AButton: TThemedModernFormWindowButton);
  end;

function AsNode(const AAccessible: IThemedAccessible): TThemedAccessibleNode;
var
  LAccess: IThemedAccessibleNodeAccess;
begin
  Result := nil;
  if (AAccessible <> nil) and Supports(AAccessible, IThemedAccessibleNodeAccess, LAccess) then
    Result := TThemedAccessibleNode(LAccess.GetNodeObject);
end;

function IsSelfChild(const AChild: OleVariant): Boolean;
var
  LType: Word;
begin
  LType := VarType(AChild) and varTypeMask;
  if (LType = varEmpty) or (LType = varNull) or (LType = varError) then
    Exit(True);
  case LType of
    varSmallint, varInteger, varShortInt, varByte, varWord, varLongWord:
      Result := Integer(AChild) = 0;
  else
    Result := False;
  end;
end;

function IsPointInside(const ABounds: TRect; const AX, AY: Integer): Boolean;
begin
  Result := (ABounds.Right > ABounds.Left) and (ABounds.Bottom > ABounds.Top) and
    (AX >= ABounds.Left) and (AX < ABounds.Right) and (AY >= ABounds.Top) and (AY < ABounds.Bottom);
end;

function EmptyRect: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

constructor TThemedAccessibleTree.Create(const AHost: IThemedModernFormAccessibilityHost);
begin
  inherited Create;
  FHost := AHost;
  FRoot := TThemedAccessibleRootNode.Create(Self);
  FCaption := TThemedAccessibleCaptionNode.Create(Self);
end;

destructor TThemedAccessibleTree.Destroy;
begin
  FCaption.Free;
  FRoot.Free;
  inherited Destroy;
end;

function TThemedAccessibleTree.AddRef: Integer;
begin
  Result := AtomicIncrement(FRefCount);
end;

function TThemedAccessibleTree.Release: Integer;
begin
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
    Free;
end;

procedure TThemedAccessibleTree.Detach;
begin
  FHost := nil;
end;

constructor TThemedAccessibleNode.Create(const ATree: TThemedAccessibleTree);
begin
  inherited Create;
  FTree := ATree;
end;

function TThemedAccessibleNode.GetNodeObject: TObject;
begin
  Result := Self;
end;

function TThemedAccessibleNode.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TThemedAccessibleNode._AddRef: Integer;
begin
  Result := FTree.AddRef;
end;

function TThemedAccessibleNode._Release: Integer;
begin
  Result := FTree.Release;
end;

function TThemedAccessibleNode.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
  Count := 0;
  Result := S_OK;
end;

function TThemedAccessibleNode.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TThemedAccessibleNode.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
  LocaleID: Integer; DispIDs: Pointer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TThemedAccessibleNode.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TThemedAccessibleNode.GetHost: IThemedModernFormAccessibilityHost;
begin
  Result := FTree.Host;
end;

function TThemedAccessibleNode.GetSelfAccessible: IThemedAccessible;
begin
  Result := Self;
end;

function TThemedAccessibleNode.GetDescription: string;
begin
  Result := '';
end;

function TThemedAccessibleNode.GetDefaultAction: string;
begin
  Result := '';
end;

function TThemedAccessibleNode.GetChildCount: Integer;
begin
  Result := 0;
end;

function TThemedAccessibleNode.GetChildAt(const AIndex: Integer): IThemedAccessible;
begin
  Result := nil;
end;

function TThemedAccessibleNode.HitTestScreen(const AX, AY: Integer): OleVariant;
var
  LCount: Integer;
  LIndex: Integer;
  LChild: IThemedAccessible;
  LNode: TThemedAccessibleNode;
begin
  LCount := GetChildCount;
  for LIndex := 0 to LCount - 1 do
  begin
    LChild := GetChildAt(LIndex);
    if LChild = nil then
      Continue;
    LNode := AsNode(LChild);
    if LNode <> nil then
    begin
      if IsPointInside(LNode.GetBounds, AX, AY) then
        Exit(IDispatch(LChild));
    end;
  end;
  if IsPointInside(GetBounds, AX, AY) then
    Result := TThemedModernFormAccessibility.CHILDID_SELF_VALUE
  else
    Result := Unassigned;
end;

procedure TThemedAccessibleNode.DoAction;
begin
end;

function TThemedAccessibleNode.Route(const AChild: OleVariant; out ATarget: IThemedAccessible): HRESULT;
var
  LIndex: Integer;
begin
  ATarget := nil;
  if IsSelfChild(AChild) then
    Exit(S_OK);
  try
    LIndex := Integer(AChild);
  except
    Exit(E_INVALIDARG);
  end;
  ATarget := GetChildAt(LIndex - 1);
  if ATarget = nil then
    Exit(E_INVALIDARG);
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accParent(out ppdispParent: IDispatch): HRESULT;
var
  LParent: IThemedAccessible;
begin
  LParent := GetParentAccessible;
  ppdispParent := LParent;
  if LParent = nil then
    Result := S_FALSE
  else
    Result := S_OK;
end;

function TThemedAccessibleNode.get_accChildCount(out pcountChildren: Integer): HRESULT;
begin
  pcountChildren := GetChildCount;
  Result := S_OK;
end;

function TThemedAccessibleNode.get_accChild(varChild: OleVariant; out ppdispChild: IDispatch): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  ppdispChild := nil;
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
  begin
    ppdispChild := LTarget;
    Exit(S_OK);
  end;
  if Result = S_OK then
    Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accName(varChild: OleVariant; out pszName: WideString): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  pszName := '';
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.get_accName(0, pszName));
  if Result = S_OK then
    pszName := GetName;
end;

function TThemedAccessibleNode.get_accValue(varChild: OleVariant; out pszValue: WideString): HRESULT;
begin
  pszValue := '';
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accDescription(varChild: OleVariant; out pszDescription: WideString): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  pszDescription := '';
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.get_accDescription(0, pszDescription));
  if Result = S_OK then
  begin
    pszDescription := GetDescription;
    if pszDescription = '' then
      Result := S_FALSE;
  end;
end;

function TThemedAccessibleNode.get_accRole(varChild: OleVariant; out pvarRole: OleVariant): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  pvarRole := Unassigned;
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.get_accRole(0, pvarRole));
  if Result = S_OK then
    pvarRole := GetRole;
end;

function TThemedAccessibleNode.get_accState(varChild: OleVariant; out pvarState: OleVariant): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  pvarState := Unassigned;
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.get_accState(0, pvarState));
  if Result = S_OK then
    pvarState := GetState;
end;

function TThemedAccessibleNode.get_accHelp(varChild: OleVariant; out pszHelp: WideString): HRESULT;
begin
  pszHelp := '';
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accHelpTopic(out pszHelpFile: WideString; varChild: OleVariant;
  out pidTopic: Integer): HRESULT;
begin
  pszHelpFile := '';
  pidTopic := 0;
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accKeyboardShortcut(varChild: OleVariant;
  out pszKeyboardShortcut: WideString): HRESULT;
begin
  pszKeyboardShortcut := '';
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accFocus(out pvarChild: OleVariant): HRESULT;
begin
  pvarChild := Unassigned;
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accSelection(out pvarChildren: OleVariant): HRESULT;
begin
  pvarChildren := Unassigned;
  Result := S_FALSE;
end;

function TThemedAccessibleNode.get_accDefaultAction(varChild: OleVariant;
  out pszDefaultAction: WideString): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  pszDefaultAction := '';
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.get_accDefaultAction(0, pszDefaultAction));
  if Result = S_OK then
  begin
    pszDefaultAction := GetDefaultAction;
    if pszDefaultAction = '' then
      Result := S_FALSE;
  end;
end;

function TThemedAccessibleNode.accSelect(flagsSelect: Integer; varChild: OleVariant): HRESULT;
begin
  Result := S_FALSE;
end;

function TThemedAccessibleNode.accLocation(out pxLeft: Integer; out pyTop: Integer;
  out pcxWidth: Integer; out pcyHeight: Integer; varChild: OleVariant): HRESULT;
var
  LTarget: IThemedAccessible;
  LBounds: TRect;
begin
  pxLeft := 0;
  pyTop := 0;
  pcxWidth := 0;
  pcyHeight := 0;
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.accLocation(pxLeft, pyTop, pcxWidth, pcyHeight, 0));
  if Result = S_OK then
  begin
    LBounds := GetBounds;
    pxLeft := LBounds.Left;
    pyTop := LBounds.Top;
    pcxWidth := LBounds.Right - LBounds.Left;
    pcyHeight := LBounds.Bottom - LBounds.Top;
  end;
end;

function TThemedAccessibleNode.accNavigate(navDir: Integer; varStart: OleVariant;
  out pvarEndUpAt: OleVariant): HRESULT;
var
  LCount: Integer;
  LParent: IThemedAccessible;
  LParentNode: TThemedAccessibleNode;
  LIndex: Integer;
  LTarget: Integer;
  LSiblingCount: Integer;
  LSibling: IThemedAccessible;
begin
  pvarEndUpAt := Unassigned;
  if not IsSelfChild(varStart) then
    Exit(S_FALSE);
  LCount := GetChildCount;
  if navDir = NAVDIR_FIRSTCHILD then
  begin
    if LCount > 0 then
    begin
      pvarEndUpAt := IDispatch(GetChildAt(0));
      Exit(S_OK);
    end;
    Exit(S_FALSE);
  end;
  if navDir = NAVDIR_LASTCHILD then
  begin
    if LCount > 0 then
    begin
      pvarEndUpAt := IDispatch(GetChildAt(LCount - 1));
      Exit(S_OK);
    end;
    Exit(S_FALSE);
  end;
  if (navDir <> NAVDIR_NEXT) and (navDir <> NAVDIR_PREVIOUS) then
    Exit(S_FALSE);
  LParent := GetParentAccessible;
  LParentNode := AsNode(LParent);
  if LParentNode = nil then
    Exit(S_FALSE);
  LSiblingCount := LParentNode.GetChildCount;
  for LIndex := 0 to LSiblingCount - 1 do
  begin
    LSibling := LParentNode.GetChildAt(LIndex);
    if AsNode(LSibling) = Self then
    begin
      if navDir = NAVDIR_NEXT then
        LTarget := LIndex + 1
      else
        LTarget := LIndex - 1;
      if (LTarget < 0) or (LTarget >= LSiblingCount) then
        Exit(S_FALSE);
      pvarEndUpAt := IDispatch(LParentNode.GetChildAt(LTarget));
      Exit(S_OK);
    end;
  end;
  Result := S_FALSE;
end;

function TThemedAccessibleNode.accHitTest(xLeft: Integer; yTop: Integer; out pvarChild: OleVariant): HRESULT;
begin
  pvarChild := HitTestScreen(xLeft, yTop);
  if VarIsEmpty(pvarChild) then
    Result := S_FALSE
  else
    Result := S_OK;
end;

function TThemedAccessibleNode.accDoDefaultAction(varChild: OleVariant): HRESULT;
var
  LTarget: IThemedAccessible;
begin
  Result := Route(varChild, LTarget);
  if Result = S_FALSE then
    Exit(LTarget.accDoDefaultAction(0));
  if Result = S_OK then
  begin
    DoAction;
    Result := S_OK;
  end;
end;

function TThemedAccessibleNode.put_accName(varChild: OleVariant; pszName: WideString): HRESULT;
begin
  Result := S_FALSE;
end;

function TThemedAccessibleNode.put_accValue(varChild: OleVariant; pszValue: WideString): HRESULT;
begin
  Result := S_FALSE;
end;

function TThemedAccessibleRootNode.GetRole: Integer;
begin
  Result := ROLE_SYSTEM_WINDOW;
end;

function TThemedAccessibleRootNode.GetName: string;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if LHost = nil then
    Exit('');
  Result := LHost.GetCaptionText;
end;

function TThemedAccessibleRootNode.GetBounds: TRect;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if LHost = nil then
    Exit(EmptyRect);
  Result := LHost.GetFormScreenBounds;
end;

function TThemedAccessibleRootNode.GetState: Integer;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := STATE_SYSTEM_FOCUSABLE;
  LHost := GetHost;
  if (LHost = nil) or not LHost.GetFormVisible then
    Result := Result or STATE_SYSTEM_INVISIBLE or STATE_SYSTEM_OFFSCREEN;
end;

function TThemedAccessibleRootNode.GetChildCount: Integer;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := 0;
  LHost := GetHost;
  if LHost = nil then
    Exit;
  if LHost.GetCustomChrome then
    Result := 1;
  Result := Result + LHost.GetContentWindowCount;
end;

function TThemedAccessibleRootNode.GetChildAt(const AIndex: Integer): IThemedAccessible;
var
  LHost: IThemedModernFormAccessibilityHost;
  LIndex: Integer;
  LHandle: HWND;
  LObject: Pointer;
begin
  Result := nil;
  LHost := GetHost;
  if (LHost = nil) or (AIndex < 0) then
    Exit;
  LIndex := AIndex;
  if LHost.GetCustomChrome then
  begin
    if LIndex = 0 then
      Exit(Tree.Caption.GetSelfAccessible);
    Dec(LIndex);
  end;
  LHandle := LHost.GetContentWindowHandle(LIndex);
  if LHandle = 0 then
    Exit;
  LObject := nil;
  try
    if Succeeded(AccessibleObjectFromWindowNative(LHandle, OBJID_CLIENT_DWORD, IID_ThemedAccessible, LObject)) then
      Pointer(Result) := LObject;
  except
    Result := nil;
  end;
end;

function TThemedAccessibleRootNode.GetParentAccessible: IThemedAccessible;
var
  LHost: IThemedModernFormAccessibilityHost;
  LParentWnd: HWND;
  LObject: Pointer;
begin
  Result := nil;
  LHost := GetHost;
  if LHost = nil then
    Exit;
  LParentWnd := GetAncestor(LHost.GetWindowHandle, GA_PARENT);
  if LParentWnd = 0 then
    Exit;
  LObject := nil;
  try
    if Succeeded(AccessibleObjectFromWindowNative(LParentWnd, DWORD(TThemedModernFormAccessibility.OBJID_WINDOW_VALUE),
      IID_ThemedAccessible, LObject)) then
      Pointer(Result) := LObject;
  except
    Result := nil;
  end;
end;

function TThemedAccessibleRootNode.HitTestScreen(const AX, AY: Integer): OleVariant;
var
  LHost: IThemedModernFormAccessibilityHost;
  LIndex: Integer;
  LHandle: HWND;
  LRect: TRect;
  LChild: IThemedAccessible;
begin
  LHost := GetHost;
  if LHost = nil then
    Exit(Unassigned);
  if LHost.GetCustomChrome and IsPointInside(Tree.Caption.GetBounds, AX, AY) then
    Exit(Tree.Caption.HitTestScreen(AX, AY));
  for LIndex := LHost.GetContentWindowCount - 1 downto 0 do
  begin
    LHandle := LHost.GetContentWindowHandle(LIndex);
    if (LHandle = 0) or not IsWindowVisible(LHandle) then
      Continue;
    if not GetWindowRect(LHandle, LRect) then
      Continue;
    if IsPointInside(LRect, AX, AY) then
    begin
      LChild := GetChildAt(LIndex + Ord(LHost.GetCustomChrome));
      if LChild <> nil then
        Exit(IDispatch(LChild));
    end;
  end;
  if IsPointInside(GetBounds, AX, AY) then
    Result := TThemedModernFormAccessibility.CHILDID_SELF_VALUE
  else
    Result := Unassigned;
end;

constructor TThemedAccessibleCaptionNode.Create(const ATree: TThemedAccessibleTree);
begin
  inherited Create(ATree);
  FSystemMenu := TThemedAccessibleSystemMenuNode.Create(ATree);
  FMinimize := TThemedAccessibleButtonNode.Create(ATree, TThemedModernFormWindowButton.Minimize);
  FMaximizeRestore := TThemedAccessibleButtonNode.Create(ATree, TThemedModernFormWindowButton.MaximizeRestore);
  FClose := TThemedAccessibleButtonNode.Create(ATree, TThemedModernFormWindowButton.Close);
end;

destructor TThemedAccessibleCaptionNode.Destroy;
begin
  FClose.Free;
  FMaximizeRestore.Free;
  FMinimize.Free;
  FSystemMenu.Free;
  inherited Destroy;
end;

function TThemedAccessibleCaptionNode.GetRole: Integer;
begin
  Result := ROLE_SYSTEM_TITLEBAR;
end;

function TThemedAccessibleCaptionNode.GetName: string;
begin
  Result := ThemedModernFormTexts.AccessibilityTitleBarName;
end;

function TThemedAccessibleCaptionNode.GetDescription: string;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if LHost = nil then
    Exit('');
  Result := LHost.GetCaptionText;
end;

function TThemedAccessibleCaptionNode.GetBounds: TRect;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if (LHost = nil) or not LHost.GetCustomChrome then
    Exit(EmptyRect);
  Result := LHost.GetTitleBarScreenBounds;
end;

function TThemedAccessibleCaptionNode.GetState: Integer;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := STATE_SYSTEM_FOCUSABLE;
  LHost := GetHost;
  if (LHost = nil) or not LHost.GetFormVisible then
    Result := Result or STATE_SYSTEM_OFFSCREEN;
end;

function TThemedAccessibleCaptionNode.GetChildCount: Integer;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := 0;
  LHost := GetHost;
  if LHost = nil then
    Exit;
  if LHost.IsSystemMenuVisible then
    Inc(Result);
  if LHost.IsButtonVisible(TThemedModernFormWindowButton.Minimize) then
    Inc(Result);
  if LHost.IsButtonVisible(TThemedModernFormWindowButton.MaximizeRestore) then
    Inc(Result);
  if LHost.IsButtonVisible(TThemedModernFormWindowButton.Close) then
    Inc(Result);
end;

function TThemedAccessibleCaptionNode.GetChildAt(const AIndex: Integer): IThemedAccessible;
var
  LHost: IThemedModernFormAccessibilityHost;
  LCurrent: Integer;
begin
  Result := nil;
  LHost := GetHost;
  if (LHost = nil) or (AIndex < 0) then
    Exit;
  LCurrent := 0;
  if LHost.IsSystemMenuVisible then
  begin
    if LCurrent = AIndex then
      Exit(FSystemMenu.GetSelfAccessible);
    Inc(LCurrent);
  end;
  if LHost.IsButtonVisible(TThemedModernFormWindowButton.Minimize) then
  begin
    if LCurrent = AIndex then
      Exit(FMinimize.GetSelfAccessible);
    Inc(LCurrent);
  end;
  if LHost.IsButtonVisible(TThemedModernFormWindowButton.MaximizeRestore) then
  begin
    if LCurrent = AIndex then
      Exit(FMaximizeRestore.GetSelfAccessible);
    Inc(LCurrent);
  end;
  if LHost.IsButtonVisible(TThemedModernFormWindowButton.Close) then
    if LCurrent = AIndex then
      Exit(FClose.GetSelfAccessible);
end;

function TThemedAccessibleCaptionNode.GetParentAccessible: IThemedAccessible;
begin
  Result := Tree.Root.GetSelfAccessible;
end;

function TThemedAccessibleSystemMenuNode.GetRole: Integer;
begin
  Result := ROLE_SYSTEM_MENUBAR;
end;

function TThemedAccessibleSystemMenuNode.GetName: string;
begin
  Result := ThemedModernFormTexts.AccessibilitySystemMenuName;
end;

function TThemedAccessibleSystemMenuNode.GetDescription: string;
begin
  Result := ThemedModernFormTexts.AccessibilitySystemMenuDescription;
end;

function TThemedAccessibleSystemMenuNode.GetDefaultAction: string;
begin
  Result := ThemedModernFormTexts.AccessibilityPressAction;
end;

function TThemedAccessibleSystemMenuNode.GetBounds: TRect;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if (LHost = nil) or not LHost.IsSystemMenuVisible then
    Exit(EmptyRect);
  Result := LHost.GetSystemMenuScreenBounds;
end;

function TThemedAccessibleSystemMenuNode.GetState: Integer;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := STATE_SYSTEM_FOCUSABLE;
  LHost := GetHost;
  if (LHost = nil) or not LHost.IsSystemMenuVisible then
    Result := Result or STATE_SYSTEM_INVISIBLE;
  if (LHost = nil) or not LHost.GetFormVisible then
    Result := Result or STATE_SYSTEM_OFFSCREEN;
end;

function TThemedAccessibleSystemMenuNode.GetParentAccessible: IThemedAccessible;
begin
  Result := Tree.Caption.GetSelfAccessible;
end;

procedure TThemedAccessibleSystemMenuNode.DoAction;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if (LHost = nil) or not LHost.IsSystemMenuVisible then
    Exit;
  LHost.ShowSystemMenu;
end;

constructor TThemedAccessibleButtonNode.Create(const ATree: TThemedAccessibleTree;
  const AButton: TThemedModernFormWindowButton);
begin
  inherited Create(ATree);
  FButton := AButton;
end;

function TThemedAccessibleButtonNode.GetRole: Integer;
begin
  Result := ROLE_SYSTEM_PUSHBUTTON;
end;

function TThemedAccessibleButtonNode.GetName: string;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := '';
  LHost := GetHost;
  if FButton = TThemedModernFormWindowButton.Minimize then
    Result := ThemedModernFormTexts.AccessibilityMinimizeName
  else if FButton = TThemedModernFormWindowButton.MaximizeRestore then
  begin
    if (LHost <> nil) and LHost.GetMaximized then
      Result := ThemedModernFormTexts.AccessibilityRestoreName
    else
      Result := ThemedModernFormTexts.AccessibilityMaximizeName;
  end
  else if FButton = TThemedModernFormWindowButton.Close then
    Result := ThemedModernFormTexts.AccessibilityCloseName;
end;

function TThemedAccessibleButtonNode.GetDescription: string;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := '';
  LHost := GetHost;
  if FButton = TThemedModernFormWindowButton.Minimize then
    Result := ThemedModernFormTexts.AccessibilityMinimizeDescription
  else if FButton = TThemedModernFormWindowButton.MaximizeRestore then
  begin
    if (LHost <> nil) and LHost.GetMaximized then
      Result := ThemedModernFormTexts.AccessibilityRestoreDescription
    else
      Result := ThemedModernFormTexts.AccessibilityMaximizeDescription;
  end
  else if FButton = TThemedModernFormWindowButton.Close then
    Result := ThemedModernFormTexts.AccessibilityCloseDescription;
end;

function TThemedAccessibleButtonNode.GetDefaultAction: string;
begin
  Result := ThemedModernFormTexts.AccessibilityPressAction;
end;

function TThemedAccessibleButtonNode.GetBounds: TRect;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if (LHost = nil) or not LHost.IsButtonVisible(FButton) then
    Exit(EmptyRect);
  Result := LHost.GetButtonScreenBounds(FButton);
end;

function TThemedAccessibleButtonNode.GetState: Integer;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  Result := STATE_SYSTEM_FOCUSABLE;
  LHost := GetHost;
  if LHost = nil then
    Exit(Result or STATE_SYSTEM_INVISIBLE or STATE_SYSTEM_OFFSCREEN);
  if not LHost.IsButtonVisible(FButton) then
    Result := Result or STATE_SYSTEM_INVISIBLE
  else if not LHost.IsButtonAvailable(FButton) then
    Result := Result or STATE_SYSTEM_UNAVAILABLE;
  if not LHost.GetFormVisible then
    Result := Result or STATE_SYSTEM_OFFSCREEN;
  if LHost.IsButtonHot(FButton) then
    Result := Result or STATE_SYSTEM_HOTTRACKED;
  if LHost.IsButtonPressed(FButton) then
    Result := Result or STATE_SYSTEM_PRESSED;
end;

function TThemedAccessibleButtonNode.GetParentAccessible: IThemedAccessible;
begin
  Result := Tree.Caption.GetSelfAccessible;
end;

procedure TThemedAccessibleButtonNode.DoAction;
var
  LHost: IThemedModernFormAccessibilityHost;
begin
  LHost := GetHost;
  if (LHost = nil) or not LHost.IsButtonAvailable(FButton) then
    Exit;
  LHost.ExecuteButton(FButton);
end;

class function TThemedModernFormAccessibility.CreateRoot(
  const AHost: IThemedModernFormAccessibilityHost): IThemedAccessible;
var
  LTree: TThemedAccessibleTree;
begin
  LTree := TThemedAccessibleTree.Create(AHost);
  Result := LTree.Root.GetSelfAccessible;
end;

class procedure TThemedModernFormAccessibility.Detach(const ARoot: IThemedAccessible);
begin
  if AsNode(ARoot) <> nil then
    AsNode(ARoot).Tree.Detach;
end;

class function TThemedModernFormAccessibility.HandleGetObject(const AWnd: HWND; const AWParam: WPARAM;
  const ALParam: LPARAM; const ARoot: IThemedAccessible; out AResult: LRESULT): Boolean;
begin
  AResult := 0;
  Result := False;
  if (ARoot = nil) or (Integer(ALParam) <> OBJID_CLIENT_VALUE) then
    Exit;
  try
    AResult := LresultFromObjectNative(IID_ThemedAccessible, AWParam, ARoot);
    Result := True;
  except
    AResult := 0;
    Result := False;
  end;
end;

class procedure TThemedModernFormAccessibility.NotifyStructureChanged(const AWnd: HWND);
begin
  if AWnd = 0 then
    Exit;
  try
    NotifyWinEventNative(EVENT_OBJECT_REORDER_VALUE, AWnd, OBJID_CLIENT_VALUE, CHILDID_SELF_VALUE);
    NotifyWinEventNative(EVENT_OBJECT_STATECHANGE_VALUE, AWnd, OBJID_CLIENT_VALUE, CHILDID_SELF_VALUE);
  except
  end;
end;

class procedure TThemedModernFormAccessibility.NotifyNameChanged(const AWnd: HWND);
begin
  if AWnd = 0 then
    Exit;
  try
    NotifyWinEventNative(EVENT_OBJECT_NAMECHANGE_VALUE, AWnd, OBJID_CLIENT_VALUE, CHILDID_SELF_VALUE);
  except
  end;
end;

end.
