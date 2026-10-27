{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Types;

interface

type
  TThemedControlStyleMode = (stNormal, stCompact);
  TThemedButtonKind = (tbkNormal, tbkPrimary, tbkSuccess, tbkWarning, tbkDanger, tbkGhost, tbkLink, tbkCustom);
  TThemedButtonShape = (tbsRectangle, tbsRounded, tbsPill);
  TThemedButtonStyle = (tbstFilled, tbstFlat, tbstOutline, tbstGhost, tbstLink);
  TThemedButtonHighlightStyle = (tbhsNone, tbhsSubtle, tbhsFilled, tbhsBorder, tbhsAccent, tbhsGlow);
  TThemedButtonDisplayMode = (tbdmAuto, tbdmText, tbdmImage, tbdmImageAndText);
  TThemedButtonIndicatorPlacement = (tbipNone, tbipLeft, tbipTop, tbipRight, tbipBottom);
  TThemedButtonDropDownMode = (tbddNone, tbddDropDown, tbddSplitButton);
  TThemedButtonImagePlacement = (tbimgLeft, tbimgRight, tbimgTop, tbimgBottom, tbimgOverlay);
  TThemedButtonColorMode = (tbcmTheme, tbcmCustom);
  TThemedButtonAnimationMode = (tbamNone, tbamColorFade, tbamPress, tbamColorFadeAndPress);
  TThemedButtonFocusStyle = (tbfsNone, tbfsBorder, tbfsInnerBorder, tbfsContent);
  TThemedContentAlignment = (tcaTopLeft, tcaTopCenter, tcaTopRight, tcaMiddleLeft, tcaMiddleCenter, tcaMiddleRight, tcaBottomLeft, tcaBottomCenter, tcaBottomRight);
  TThemedButtonPart = (tbpNone, tbpMain, tbpDropDown);
  TThemedToolButtonStyle = (ttbsFlat, ttbsFilled, ttbsOutline, ttbsGhost);
  TThemedToolButtonHighlightStyle = (ttbhsNone, ttbhsFlat, ttbhsToolButton, ttbhsDelphiToolButton, ttbhsVisualStudioToolButton, ttbhsOfficeToolButton);
  TThemedToolButtonImagePlacement = (ttbipLeft, ttbipRight, ttbipTop, ttbipBottom, ttbipOverlay);
  TThemedToolButtonDropDownMode = (ttbddNone, ttbddArrow, ttbddSplit);
  TThemedToolButtonPart = (ttbpNone, ttbpMain, ttbpDropDown);
  TThemedSeparatorOrientation = (tsoHorizontal, tsoVertical);
  TThemedTextBoxValidationState = (tvsNormal, tvsSuccess, tvsWarning, tvsError);
  TThemedTextBoxInputMode = (timText, timInteger, timDecimal, timEmail, timUrl);
  TThemedToolTipIcon = (ttiNone, ttiInfo, ttiWarning, ttiError, ttiSuccess);
  TRatingPrecision = (rpFull, rpHalf, rpQuarter, rpExact);
  TRatingShape = (rsStar, rsHeart, rsCircle, rsSquare, rsDiamond);

implementation

end.
