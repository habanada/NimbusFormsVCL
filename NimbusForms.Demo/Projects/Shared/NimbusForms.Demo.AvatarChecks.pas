{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.AvatarChecks;

interface

uses System.Classes;

function RunAvatarChecks(ADemoClass: TComponentClass = nil): string;

implementation

uses Winapi.Windows, System.SysUtils, System.Types, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  NimbusForms.Controls.Avatar, NimbusForms.Controls.Avatar.Badges, NimbusForms.Rendering.Avatar,
  NimbusForms.Rendering.Canvas;

type
  TAvatarDemoControlAccess = class(TWinControl);

  TAvatarChangeProbe = class
  public
    Changes: Integer;
    procedure Changed(Sender: TObject);
  end;

resourcestring
  SFailure = 'Avatar check failed: %s';
  SPassed = 'Information Passed %d avatar checks.';
  SNoHandle = 'Construction or streaming created a window handle';
  SCount = 'Counter clamping or saturation';
  SKey = 'Duplicate or empty badge key accepted';
  SBatch = 'BeginUpdate/EndUpdate notification count';
  SClone = 'Badge collection copy is not independent';
  SStream = 'DFM round trip lost badge or legacy properties';
  SLayout = 'Badge bounds, overflow text or hit test';
  SOverlap = 'Visible badges overlap';
  SZero = 'Zero counter visibility';
  SDisabled = 'Disabled badge hit-test state';
  SDemoBuild = 'Deferred avatar demo creation or duplicate controls after handle recreation';

procedure TAvatarChangeProbe.Changed(Sender: TObject);
begin Inc(Changes); end;

function RunAvatarChecks(ADemoClass: TComponentClass): string;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Source, Clone: TThemedAvatar; Probe: TAvatarChangeProbe; Stream: TMemoryStream;
  Bitmap: TBitmap; Canvas: INimbusRenderCanvas; Badge: TThemedAvatarBadge;
  Items: TArray<TThemedAvatarBadgeInfo>; Layout: TArray<TThemedAvatarBadgeLayout>;
  Hit: TThemedAvatarHitInfo; I, J, PPI, Size, Checks: Integer; Rejected: Boolean; R, Intersection: TRect;
  procedure Check(Condition: Boolean; const Name: string);
  begin if not Condition then raise EInvalidOperation.CreateFmt(SFailure, [Name]); Inc(Checks); end;
  procedure CheckDemoLifecycle;
  var Form: TForm; Demo: TWinControl; Window: HWND; OwnedCount: Integer;
  begin
    if ADemoClass = nil then Exit;
    Check(ADemoClass.InheritsFrom(TWinControl), SDemoBuild);
    Form := TForm.CreateNew(nil);
    try
      Demo := TWinControl(ADemoClass.Create(Form));
      Check(not Demo.HandleAllocated and (Demo.ControlCount = 0), SNoHandle);
      Demo.Parent := Form; Window := Demo.Handle;
      Check(IsWindow(Window) and (Demo.ControlCount > 0), SDemoBuild);
      OwnedCount := Demo.ComponentCount;
      TAvatarDemoControlAccess(Demo).RecreateWnd; Window := Demo.Handle;
      Check(IsWindow(Window) and (Demo.ComponentCount = OwnedCount), SDemoBuild);
    finally Form.Free; end;
  end;
begin
  Source := nil; Clone := nil; Probe := nil; Stream := nil; Bitmap := nil; Checks := 0;
  try
    CheckDemoLifecycle;
    Source := TThemedAvatar.Create(nil); Clone := TThemedAvatar.Create(nil); Probe := TAvatarChangeProbe.Create;
    Stream := TMemoryStream.Create; Bitmap := TBitmap.Create;
    Check(not Source.HandleAllocated and not Clone.HandleAllocated, SNoHandle);
    Source.SetUnreadCount(-1); Check(Source.Counter = 0, SCount);
    Source.IncrementCounter(MaxInt); Source.IncrementCounter(MaxInt); Check(Source.Counter = MaxInt, SCount);
    Source.IncrementCounter(-MaxInt); Check(Source.Counter = 0, SCount);
    Badge := Source.SetBadgeCounter('messages', 125); Badge.Increment(MaxInt); Check(Badge.Count = MaxInt, SCount);
    Badge.Increment(-MaxInt); Check(Badge.Count = 0, SCount);
    Rejected := False;
    try Source.Badges.AddNamed('MESSAGES'); except on E: EArgumentException do Rejected := True; end;
    Check(Rejected and (Source.Badges.Count = 1), SKey);
    Rejected := False;
    try Source.Badges.Ensure(' '); except on E: EArgumentException do Rejected := True; end;
    Check(Rejected and (Source.Badges.Count = 1), SKey);
    Source.OnBadgesChanged := Probe.Changed; Probe.Changes := 0;
    Source.Badges.BeginUpdate;
    try Badge.Count := 125; Badge.Tone := tabtInfo; Badge.OffsetX := 2; Badge.Enabled := False;
    finally Source.Badges.EndUpdate; end;
    Check(Probe.Changes = 1, SBatch); Source.OnBadgesChanged := nil;
    Clone.Badges.Assign(Source.Badges); Clone.Badges[0].Count := 7;
    Check((Source.Badges[0] <> Clone.Badges[0]) and (Source.Badges[0].Count = 125), SClone);
    Source.Name := 'AvatarProbe'; Source.SetUnreadCount(8); Source.SetPresence(tavsBusy); Source.ShowStar := True;
    Stream.WriteComponent(Source); Stream.Position := 0; Stream.ReadComponent(Clone);
    Check((Clone.Counter = 8) and (Clone.Status = tavsBusy) and Clone.ShowStar and (Clone.Badges.Count = 1), SStream);
    Check((Clone.Badges[0].Key = 'messages') and (Clone.Badges[0].Count = 125) and
      (Clone.Badges[0].Tone = tabtInfo) and not Clone.Badges[0].Enabled and (Clone.Badges[0].OffsetX = 2), SStream);
    Check(not Source.HandleAllocated and not Clone.HandleAllocated, SNoHandle);
    Bitmap.SetSize(256, 256); Canvas := TNimbusRenderCanvas.Create; Canvas.BeginRender(Bitmap.Canvas);
    try
      SetLength(Items, 4);
      for PPI in PPIs do
      begin
        Source.BadgeFont.Height := -MulDiv(11, PPI, 96); Size := MulDiv(96, PPI, 96); R := Rect(0, 0, Size, Size);
        for I := 0 to 3 do
        begin
          Items[I] := Badge.RenderInfo; Items[I].ID := I; Items[I].Anchor := TThemedAvatarBadgeAnchor(I);
          Items[I].OffsetX := 0; Items[I].Enabled := True;
        end;
        Layout := TThemedAvatarRenderer.BuildBadgeLayout(Canvas, R, Source.BadgeFont, PPI, Items);
        Check(Length(Layout) = 4, SLayout);
        for I := 0 to High(Layout) do
        begin
          Hit := TThemedAvatarRenderer.HitTest(Point((Layout[I].Bounds.Left + Layout[I].Bounds.Right) div 2,
            (Layout[I].Bounds.Top + Layout[I].Bounds.Bottom) div 2), R, tasCircle, Layout);
          Check((Hit.Part = tapBadge) and (Hit.BadgeID = I) and Hit.Enabled and (Layout[I].Text = '99+') and
            (Layout[I].Bounds.Left >= 0) and (Layout[I].Bounds.Top >= 0) and
            (Layout[I].Bounds.Right <= Size) and (Layout[I].Bounds.Bottom <= Size), SLayout);
          for J := 0 to I - 1 do Check(not System.Types.IntersectRect(Intersection, Layout[I].Bounds, Layout[J].Bounds), SOverlap);
        end;
        Items[0].Count := 0;
        Layout := TThemedAvatarRenderer.BuildBadgeLayout(Canvas, R, Source.BadgeFont, PPI, Items);
        Check(Length(Layout) = 3, SZero);
        Items[0].HideWhenZero := False; Items[0].Enabled := False;
        Layout := TThemedAvatarRenderer.BuildBadgeLayout(Canvas, R, Source.BadgeFont, PPI, Items);
        Check(Length(Layout) = 4, SZero);
        Hit := TThemedAvatarRenderer.HitTest(Point(Layout[0].Bounds.Left + Layout[0].Bounds.Width div 2,
          Layout[0].Bounds.Top + Layout[0].Bounds.Height div 2), R, tasCircle, Layout);
        Check((Hit.BadgeID = 0) and not Hit.Enabled, SDisabled);
      end;
      Layout := TThemedAvatarRenderer.BuildBadgeLayout(Canvas, Rect(0, 0, 0, 0), Source.BadgeFont, 96, Items);
      Check(Length(Layout) = 0, SLayout);
    finally Canvas.EndRender; end;
    Result := Format(SPassed, [Checks]);
  finally Canvas := nil; Bitmap.Free; Stream.Free; Probe.Free; Clone.Free; Source.Free; end;
end;

end.
