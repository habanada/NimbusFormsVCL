  LPage := AddTabPage(STabRenderer, STabRendererText);
  FTabControl.SetTabClosable(LPage, True);
  LPage := AddTabPage(STabUnsaved, STabUnsavedText);
  FTabControl.SetTabClosable(LPage, True);
  FTabControl.SetTabUnsaved(LPage, True);
  FTabControl.SetTabBadgeText(LPage, STabBadge);
  LPage := AddTabPage(STabPinned, STabPinnedText);
  FTabControl.SetTabClosable(LPage, True);
  FTabControl.SetTabPinned(LPage, True);
  LPage := AddTabPage(STabLong, STabLongText);
  FTabControl.SetTabClosable(LPage, True);
  FTabControl.ActivePageIndex := 0;
end;

