{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.VScrollBar;

interface

uses
  System.Classes,
  NimbusForms.Controls.ScrollBarBase;

type
  TThemedVScrollBar = class(TCustomThemedScrollBar)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property StyleMode;
    property Anchors;
    property BiDiMode;
    property ButtonSize;
    property Constraints;
    property Enabled;
    property LargeChange;
    property Maximum;
    property Minimum;
    property MinimumThumbSize;
    property ParentBiDiMode;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property SmallChange;
    property TabOrder;
    property TabStop default False;
    property Value;
    property Visible;
    property OnContextPopup;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnValueChanged;
  end;

implementation

uses
  NimbusForms.Rendering.ScrollBar;

constructor TThemedVScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitializeOrientation(nsboVertical);
  SetBounds(Left, Top, 18, 100);
end;

end.
