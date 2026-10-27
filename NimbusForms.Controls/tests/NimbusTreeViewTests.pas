{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusTreeViewTests;

{$APPTYPE CONSOLE}

uses System.SysUtils, Vcl.Forms, Vcl.Menus, Vcl.ComCtrls,
  NimbusForms.Controls.TreeView;

procedure Check(const Value: Boolean; const MessageText: string);
begin if not Value then raise Exception.Create(MessageText); end;

procedure HandlelessMenuChecks;
var Tree: TThemedTreeView; Menu: TPopupMenu;
begin
  Tree := TThemedTreeView.Create(nil);
  try
    Check(not Tree.HandleAllocated, 'construction does not create a tree HWND');
    Menu := TPopupMenu.Create(Tree); Menu.Free;
    Check(not Tree.HandleAllocated, 'unrelated menu removal does not create a tree HWND');
    Menu := TPopupMenu.Create(Tree); Tree.NodeContextMenu := Menu; Menu.Free;
    Check((Tree.NodeContextMenu = nil) and not Tree.HandleAllocated, 'menu reference removal is handleless');
    TPopupMenu.Create(Tree);
  finally Tree.Free; end;
end;

procedure NodeMenuChecks;
var Host: TForm; Tree: TThemedTreeView; First, Second: TThemedTreeNode; OldMenu, SharedMenu: TPopupMenu;
begin
  Host := TForm.CreateNew(nil);
  try
    Tree := TThemedTreeView.Create(Host); Tree.Parent := Host;
    First := TThemedTreeNode(Tree.Items.Add(nil, 'First'));
    Second := TThemedTreeNode(Tree.Items.AddChild(First, 'Second'));
    OldMenu := TPopupMenu.Create(Host); SharedMenu := TPopupMenu.Create(Host);
    First.ThemedContextMenu := OldMenu; First.ThemedContextMenu := SharedMenu;
    Second.ThemedContextMenu := SharedMenu; Tree.NodeContextMenu := SharedMenu;
    OldMenu.Free;
    Check(First.ThemedContextMenu = SharedMenu, 'old menu notification preserves replacement');
    SharedMenu.Free;
    Check((First.ThemedContextMenu = nil) and (Second.ThemedContextMenu = nil) and (Tree.NodeContextMenu = nil),
      'shared menu notification clears every reference');
    SharedMenu := TPopupMenu.Create(Host);
    First.ThemedContextMenu := SharedMenu; Second.ThemedContextMenu := SharedMenu;
    Second.Delete; SharedMenu.Free;
    Check(First.ThemedContextMenu = nil, 'deleted node is removed from menu reference tracking');
    SharedMenu := TPopupMenu.Create(Tree); First.ThemedContextMenu := SharedMenu;
    Tree.Free;
  finally Host.Free; end;
end;

begin
  try
    Application.Initialize;
    HandlelessMenuChecks; NodeMenuChecks;
    Writeln('TreeView menu lifecycle checks passed');
  except on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end; end;
end.
