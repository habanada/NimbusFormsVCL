{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Actions;

interface

uses System.Classes, Vcl.ActnList, NimbusForms.Controls.CodeEditor;

type
  TCodeEditorCommand = (cecUndo, cecRedo, cecCut, cecCopy, cecPaste, cecSelectAll,
    cecTriggerCompletion, cecToggleBookmark, cecNextBookmark, cecPreviousBookmark,
    cecToggleFold, cecFoldAll, cecUnfoldAll, cecGoToDefinition, cecNextMatch, cecPreviousMatch, cecToggleBreakpoint,
    cecZoomIn, cecZoomOut, cecResetZoom, cecToggleWordWrap, cecToggleLineNumbers, cecToggleIndentGuides);
  TCodeEditorAction = class(TAction)
  private
    FEditor: TCustomThemedCodeEditor;
    FCommand: TCodeEditorCommand;
    procedure SetEditor(const Value: TCustomThemedCodeEditor);
    procedure SetCommand(const Value: TCodeEditorCommand);
    procedure ExecuteCommand(Sender: TObject);
    procedure UpdateCommand(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Editor: TCustomThemedCodeEditor read FEditor write SetEditor;
    property Command: TCodeEditorCommand read FCommand write SetCommand default cecUndo;
  end;

function AttachCodeEditorActions(Actions: TActionList; Editor: TCustomThemedCodeEditor): TArray<TCodeEditorAction>;

implementation

uses Winapi.Windows, System.SysUtils, System.Actions, Vcl.Controls, Vcl.Menus, Vcl.Clipbrd;

constructor TCodeEditorAction.Create(AOwner: TComponent);
begin inherited; FCommand := cecPreviousMatch; SetCommand(cecUndo); OnExecute := ExecuteCommand; OnUpdate := UpdateCommand; end;
procedure TCodeEditorAction.SetEditor(const Value: TCustomThemedCodeEditor);
begin if FEditor = Value then Exit; if FEditor <> nil then FEditor.RemoveFreeNotification(Self); FEditor := Value; if FEditor <> nil then FEditor.FreeNotification(Self); end;
procedure TCodeEditorAction.Notification(AComponent: TComponent; Operation: TOperation);
begin inherited; if (Operation = opRemove) and (AComponent = FEditor) then FEditor := nil; end;
procedure TCodeEditorAction.SetCommand(const Value: TCodeEditorCommand);
const Captions: array[TCodeEditorCommand] of string = ('Undo', 'Redo', 'Cut', 'Copy', 'Paste', 'Select All',
    'Completion', 'Toggle Bookmark', 'Next Bookmark', 'Previous Bookmark', 'Toggle Fold', 'Fold All', 'Unfold All', 'Go To Definition', 'Next Match', 'Previous Match', 'Toggle Breakpoint',
    'Zoom In', 'Zoom Out', 'Reset Zoom', 'Word Wrap', 'Line Numbers', 'Indent Guides');
begin
  FCommand := Value; Caption := Captions[Value]; Category := 'Code Editor'; ShortCut := 0;
  case Value of
    cecUndo: ShortCut := Vcl.Menus.ShortCut(Ord('Z'), [ssCtrl]);
    cecRedo: ShortCut := Vcl.Menus.ShortCut(Ord('Y'), [ssCtrl]);
    cecCut: ShortCut := Vcl.Menus.ShortCut(Ord('X'), [ssCtrl]);
    cecCopy: ShortCut := Vcl.Menus.ShortCut(Ord('C'), [ssCtrl]);
    cecPaste: ShortCut := Vcl.Menus.ShortCut(Ord('V'), [ssCtrl]);
    cecSelectAll: ShortCut := Vcl.Menus.ShortCut(Ord('A'), [ssCtrl]);
    cecTriggerCompletion: ShortCut := Vcl.Menus.ShortCut(VK_SPACE, [ssCtrl]);
    cecToggleBookmark: ShortCut := Vcl.Menus.ShortCut(VK_F2, [ssCtrl]);
    cecNextBookmark: ShortCut := Vcl.Menus.ShortCut(VK_F2, []);
    cecPreviousBookmark: ShortCut := Vcl.Menus.ShortCut(VK_F2, [ssShift]);
    cecGoToDefinition: ShortCut := Vcl.Menus.ShortCut(VK_F12, []);
    cecNextMatch: ShortCut := Vcl.Menus.ShortCut(VK_F3, []);
    cecPreviousMatch: ShortCut := Vcl.Menus.ShortCut(VK_F3, [ssShift]);
    cecToggleBreakpoint: ShortCut := Vcl.Menus.ShortCut(VK_F9, []);
    cecZoomIn: ShortCut := Vcl.Menus.ShortCut(VK_ADD, [ssCtrl]);
    cecZoomOut: ShortCut := Vcl.Menus.ShortCut(VK_SUBTRACT, [ssCtrl]);
    cecResetZoom: ShortCut := Vcl.Menus.ShortCut(Ord('0'), [ssCtrl]);
  end;
end;
procedure TCodeEditorAction.ExecuteCommand(Sender: TObject);
begin
  if FEditor = nil then Exit;
  case FCommand of
    cecUndo: FEditor.Undo;
    cecRedo: FEditor.Redo;
    cecCut: FEditor.Cut;
    cecCopy: FEditor.Copy;
    cecPaste: FEditor.Paste;
    cecSelectAll: FEditor.SelectAll;
    cecTriggerCompletion: FEditor.TriggerCompletion;
    cecToggleBookmark: FEditor.ToggleBookmark;
    cecNextBookmark: FEditor.NextBookmark;
    cecPreviousBookmark: FEditor.PreviousBookmark;
    cecToggleFold: FEditor.ToggleFold;
    cecFoldAll: FEditor.CollapseAllFolds;
    cecUnfoldAll: FEditor.ExpandAllFolds;
    cecGoToDefinition: FEditor.TryNavigateFromPosition(FEditor.Caret.Position);
    cecNextMatch: FEditor.FindNext(True);
    cecPreviousMatch: FEditor.FindNext(False);
    cecToggleBreakpoint: FEditor.ToggleBreakpoint;
    cecZoomIn: FEditor.ZoomIn;
    cecZoomOut: FEditor.ZoomOut;
    cecResetZoom: FEditor.ResetZoom;
    cecToggleWordWrap: FEditor.Options.WordWrap := not FEditor.Options.WordWrap;
    cecToggleLineNumbers: FEditor.Options.ShowLineNumbers := not FEditor.Options.ShowLineNumbers;
    cecToggleIndentGuides: FEditor.Options.ShowIndentGuides := not FEditor.Options.ShowIndentGuides;
  end;
end;
procedure TCodeEditorAction.UpdateCommand(Sender: TObject);
begin
  Checked := False;
  Enabled := (FEditor <> nil) and FEditor.Enabled and FEditor.Showing; if not Enabled then Exit;
  case FCommand of
    cecUndo: Enabled := not FEditor.ReadOnly and FEditor.UndoManager.CanUndo;
    cecRedo: Enabled := not FEditor.ReadOnly and FEditor.UndoManager.CanRedo;
    cecCut: Enabled := not FEditor.ReadOnly and not FEditor.Selection.IsEmpty;
    cecCopy: Enabled := not FEditor.Selection.IsEmpty;
    cecPaste: Enabled := not FEditor.ReadOnly and Clipboard.HasFormat(CF_UNICODETEXT);
    cecTriggerCompletion: Enabled := not FEditor.ReadOnly;
    cecNextBookmark, cecPreviousBookmark: Enabled := FEditor.Bookmarks.Items.Count > 0;
    cecToggleFold, cecFoldAll, cecUnfoldAll: Enabled := FEditor.FoldManager.Regions.Count > 0;
    cecNextMatch, cecPreviousMatch: Enabled := Length(FEditor.SearchMatches) > 0;
    cecZoomIn: Enabled := FEditor.Zoom < 400;
    cecZoomOut: Enabled := FEditor.Zoom > 25;
    cecResetZoom: Enabled := FEditor.Zoom <> 100;
    cecToggleWordWrap: Checked := FEditor.Options.WordWrap;
    cecToggleLineNumbers: Checked := FEditor.Options.ShowLineNumbers;
    cecToggleIndentGuides: Checked := FEditor.Options.ShowIndentGuides;
  end;
end;
function AttachCodeEditorActions(Actions: TActionList; Editor: TCustomThemedCodeEditor): TArray<TCodeEditorAction>;
var Command: TCodeEditorCommand; Action: TCodeEditorAction;
begin
  if (Actions = nil) or (Editor = nil) then raise EArgumentNilException.Create('Actions and Editor are required');
  SetLength(Result, Ord(High(TCodeEditorCommand)) + 1);
  for Command := Low(TCodeEditorCommand) to High(TCodeEditorCommand) do
  begin Action := TCodeEditorAction.Create(Actions); Action.Command := Command; Action.Editor := Editor; Action.ActionList := Actions; Result[Ord(Command)] := Action; end;
end;

end.
