{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.GridTypes;

interface

uses
  System.Rtti, Vcl.Controls, NimbusForms.Rendering.Canvas,
  NimbusForms.Grid.EditorIntf, NimbusForms.Grid.RenderContext, NimbusForms.Grid.Cell;

type
  TNimbusGridControlKind = (ngckCustom, ngckCheckBox, ngckToggle, ngckRating, ngckComboBox,
    ngckDateTime, ngckAvatar, ngckButton);
  TNimbusGridValueGetter = reference to function(const AControl: TWinControl): TValue;
  TNimbusGridValueSetter = reference to procedure(const AControl: TWinControl; const AValue: TValue);
  TNimbusGridConfigureEvent = procedure(Sender: TObject; const AControl: TWinControl;
    const AContext: TThemedGridCellEditContext) of object;
  TNimbusGridDrawEvent = reference to procedure(const ACanvas: INimbusRenderCanvas;
    const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
  TNimbusGridPopupGetter = reference to function(const AControl: TWinControl): Boolean;
  TNimbusGridPopupCloser = reference to procedure(const AControl: TWinControl);

implementation

end.
