procedure TMainForm.TreeFilterChanged(Sender: TObject);
begin
  if (FTreeView <> nil) and (FTreeFilter <> nil) then FTreeView.FilterText := FTreeFilter.Text;
end;

procedure TMainForm.TreeNodeClicked(Sender: TObject; ANode: TTreeNode; const ALocation: TPoint; AButton: TMouseButton; AClicks: Integer);
begin
  if ANode <> nil then FStatusLabel.Caption := Format(STreeNodeStatusFormat, [ANode.Text]);
end;

procedure TMainForm.TreeNodeCheckChanged(Sender: TObject; ANode: TTreeNode; AOldState, ANewState: TThemedTreeCheckState);
begin
  if ANode <> nil then FStatusLabel.Caption := Format(STreeCheckStatusFormat, [ANode.Text]);
end;

procedure TMainForm.TreeNodeRenamed(Sender: TObject; ANode: TTreeNode; const AOldText: string; var ANewText: string; var ACancel: Boolean);
begin
  ACancel := Trim(ANewText) = '';
  if not ACancel then
  begin
    ANewText := Trim(ANewText);
    FStatusLabel.Caption := Format(STreeRenamedStatusFormat, [AOldText, ANewText]);
  end;
end;

procedure TMainForm.TreeNodeDropped(Sender: TObject; ANode, ATargetNode, AOldParent, ANewParent: TTreeNode; AOldIndex, ANewIndex: Integer; ADropPosition: TThemedTreeDropPosition);
begin
  if ANode <> nil then FStatusLabel.Caption := Format(STreeDroppedStatusFormat, [ANode.Text]);
end;

procedure TMainForm.TreeNodeLazyLoad(Sender: TObject; ANode: TTreeNode);
var
  LNode: TThemedTreeNode;
begin
  if FTreeLazyLoaded or (ANode <> FTreeLazyNode) then Exit;
  FTreeLazyLoaded := True;
  ANode.DeleteChildren;
  LNode := TThemedTreeNode(FTreeView.Items.AddChild(ANode, STreeLazyChildOne));
  LNode.ThemedCheckState := ttcsChecked;
  LNode.BadgeText := '1';
  LNode := TThemedTreeNode(FTreeView.Items.AddChild(ANode, STreeLazyChildTwo));
  LNode.ThemedCheckState := ttcsUnchecked;
  LNode.IsFavorite := True;
  FStatusLabel.Caption := Format(STreeLazyStatusFormat, [ANode.Text]);
end;

