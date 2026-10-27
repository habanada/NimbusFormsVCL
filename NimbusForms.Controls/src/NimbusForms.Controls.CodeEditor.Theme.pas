{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Theme;

interface

uses System.Classes, NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Controls.CodeEditor.Types;

type
  TThemedCodeEditorTheme = class(TPersistent)
  private
    FColors: array[0..114] of TThemeColor;
    FOnChange: TNotifyEvent;
    function GetColor(const Index: Integer): TThemeColor;
    procedure SetColor(const Index: Integer; const Value: TThemeColor);
  public
    constructor Create(const OnChange: TNotifyEvent);
    procedure Assign(Source: TPersistent); override;
    function TokenColor(const Kind: TCodeEditorHighlightTokenKind; const Palette: TThemePalette): TThemeColor;
    function Resolve(const Custom, DefaultColor: TThemeColor): TThemeColor;
  published
    property BackColor: TThemeColor index 0 read GetColor write SetColor default 0;
    property ForeColor: TThemeColor index 1 read GetColor write SetColor default 0;
    property GutterBackColor: TThemeColor index 2 read GetColor write SetColor default 0;
    property GutterForeColor: TThemeColor index 3 read GetColor write SetColor default 0;
    property CurrentLineBackColor: TThemeColor index 4 read GetColor write SetColor default 0;
    property SelectionBackColor: TThemeColor index 5 read GetColor write SetColor default 0;
    property CaretColor: TThemeColor index 6 read GetColor write SetColor default 0;
    property BookmarkColor: TThemeColor index 7 read GetColor write SetColor default 0;
    property FoldingColor: TThemeColor index 8 read GetColor write SetColor default 0;
    property IndentGuideColor: TThemeColor index 9 read GetColor write SetColor default 0;
    property NamespaceGuideColor: TThemeColor index 10 read GetColor write SetColor default 0;
    property TypeGuideColor: TThemeColor index 11 read GetColor write SetColor default 0;
    property MemberGuideColor: TThemeColor index 12 read GetColor write SetColor default 0;
    property ConditionalGuideColor: TThemeColor index 13 read GetColor write SetColor default 0;
    property LoopGuideColor: TThemeColor index 14 read GetColor write SetColor default 0;
    property SwitchGuideColor: TThemeColor index 15 read GetColor write SetColor default 0;
    property TryCatchGuideColor: TThemeColor index 16 read GetColor write SetColor default 0;
    property UsingGuideColor: TThemeColor index 17 read GetColor write SetColor default 0;
    property OtherScopeGuideColor: TThemeColor index 18 read GetColor write SetColor default 0;
    property SearchMatchBackColor: TThemeColor index 19 read GetColor write SetColor default 0;
    property SearchMatchBorderColor: TThemeColor index 20 read GetColor write SetColor default 0;
    property BracketMatchBackColor: TThemeColor index 21 read GetColor write SetColor default 0;
    property BracketMatchBorderColor: TThemeColor index 22 read GetColor write SetColor default 0;
    property ScrollBarBackColor: TThemeColor index 23 read GetColor write SetColor default 0;
    property ScrollBarThumbColor: TThemeColor index 24 read GetColor write SetColor default 0;
    property ScrollBarThumbHoverColor: TThemeColor index 25 read GetColor write SetColor default 0;
    property ScrollBarThumbPressedColor: TThemeColor index 26 read GetColor write SetColor default 0;
    property KeywordColor: TThemeColor index 27 read GetColor write SetColor default 0;
    property ControlKeywordColor: TThemeColor index 28 read GetColor write SetColor default 0;
    property AccessKeywordColor: TThemeColor index 29 read GetColor write SetColor default 0;
    property ModifierKeywordColor: TThemeColor index 30 read GetColor write SetColor default 0;
    property TypeKeywordColor: TThemeColor index 31 read GetColor write SetColor default 0;
    property DeclarationKeywordColor: TThemeColor index 32 read GetColor write SetColor default 0;
    property AccessorKeywordColor: TThemeColor index 33 read GetColor write SetColor default 0;
    property IdentifierColor: TThemeColor index 34 read GetColor write SetColor default 0;
    property NamespaceColor: TThemeColor index 35 read GetColor write SetColor default 0;
    property ModuleColor: TThemeColor index 36 read GetColor write SetColor default 0;
    property ClassColor: TThemeColor index 37 read GetColor write SetColor default 0;
    property StructColor: TThemeColor index 38 read GetColor write SetColor default 0;
    property InterfaceColor: TThemeColor index 39 read GetColor write SetColor default 0;
    property EnumColor: TThemeColor index 40 read GetColor write SetColor default 0;
    property DelegateColor: TThemeColor index 41 read GetColor write SetColor default 0;
    property TypeColor: TThemeColor index 42 read GetColor write SetColor default 0;
    property TypeParameterColor: TThemeColor index 43 read GetColor write SetColor default 0;
    property MethodColor: TThemeColor index 44 read GetColor write SetColor default 0;
    property FunctionColor: TThemeColor index 45 read GetColor write SetColor default 0;
    property ProcedureColor: TThemeColor index 46 read GetColor write SetColor default 0;
    property ConstructorColor: TThemeColor index 47 read GetColor write SetColor default 0;
    property PropertyColor: TThemeColor index 48 read GetColor write SetColor default 0;
    property FieldColor: TThemeColor index 49 read GetColor write SetColor default 0;
    property VariableColor: TThemeColor index 50 read GetColor write SetColor default 0;
    property LocalVariableColor: TThemeColor index 51 read GetColor write SetColor default 0;
    property ParameterColor: TThemeColor index 52 read GetColor write SetColor default 0;
    property ConstantColor: TThemeColor index 53 read GetColor write SetColor default 0;
    property EnumMemberColor: TThemeColor index 54 read GetColor write SetColor default 0;
    property EventColor: TThemeColor index 55 read GetColor write SetColor default 0;
    property AttributeColor: TThemeColor index 56 read GetColor write SetColor default 0;
    property LabelColor: TThemeColor index 57 read GetColor write SetColor default 0;
    property StringColor: TThemeColor index 58 read GetColor write SetColor default 0;
    property VerbatimStringColor: TThemeColor index 59 read GetColor write SetColor default 0;
    property InterpolatedStringColor: TThemeColor index 60 read GetColor write SetColor default 0;
    property CharacterColor: TThemeColor index 61 read GetColor write SetColor default 0;
    property NumberColor: TThemeColor index 62 read GetColor write SetColor default 0;
    property BooleanColor: TThemeColor index 63 read GetColor write SetColor default 0;
    property NullColor: TThemeColor index 64 read GetColor write SetColor default 0;
    property CommentColor: TThemeColor index 65 read GetColor write SetColor default 0;
    property DocumentationCommentColor: TThemeColor index 66 read GetColor write SetColor default 0;
    property XmlDocColor: TThemeColor index 67 read GetColor write SetColor default 0;
    property PreprocessorColor: TThemeColor index 68 read GetColor write SetColor default 0;
    property OperatorColor: TThemeColor index 69 read GetColor write SetColor default 0;
    property PunctuationColor: TThemeColor index 70 read GetColor write SetColor default 0;
    property BracketColor: TThemeColor index 71 read GetColor write SetColor default 0;
    property BraceColor: TThemeColor index 72 read GetColor write SetColor default 0;
    property ParenthesisColor: TThemeColor index 73 read GetColor write SetColor default 0;
    property DelimiterColor: TThemeColor index 74 read GetColor write SetColor default 0;
    property ErrorColor: TThemeColor index 75 read GetColor write SetColor default 0;
    property WarningColor: TThemeColor index 76 read GetColor write SetColor default 0;
    property CompletionBackColor: TThemeColor index 77 read GetColor write SetColor default 0;
    property CompletionForeColor: TThemeColor index 78 read GetColor write SetColor default 0;
    property CompletionSelectedBackColor: TThemeColor index 79 read GetColor write SetColor default 0;
    property CompletionBorderColor: TThemeColor index 80 read GetColor write SetColor default 0;
    property FoldGlyphColor: TThemeColor index 81 read GetColor write SetColor default 0;
    property FoldGlyphBackColor: TThemeColor index 82 read GetColor write SetColor default 0;
    property FoldTextColor: TThemeColor index 83 read GetColor write SetColor default 0;
    property FoldPreviewBackColor: TThemeColor index 84 read GetColor write SetColor default 0;
    property FoldPreviewBorderColor: TThemeColor index 85 read GetColor write SetColor default 0;
    property FoldPreviewForeColor: TThemeColor index 86 read GetColor write SetColor default 0;
    property OverviewRulerBackColor: TThemeColor index 87 read GetColor write SetColor default 0;
    property OverviewRulerSearchColor: TThemeColor index 88 read GetColor write SetColor default 0;
    property OverviewRulerBookmarkColor: TThemeColor index 89 read GetColor write SetColor default 0;
    property OverviewRulerCaretColor: TThemeColor index 90 read GetColor write SetColor default 0;
    property OverviewRulerErrorColor: TThemeColor index 91 read GetColor write SetColor default 0;
    property BracketPairColor1: TThemeColor index 92 read GetColor write SetColor default 0;
    property BracketPairColor2: TThemeColor index 93 read GetColor write SetColor default 0;
    property BracketPairColor3: TThemeColor index 94 read GetColor write SetColor default 0;
    property BracketPairColor4: TThemeColor index 95 read GetColor write SetColor default 0;
    property NavigationLinkColor: TThemeColor index 96 read GetColor write SetColor default 0;
    property NavigationLinkUnderlineColor: TThemeColor index 97 read GetColor write SetColor default 0;
    property NavigationLinkHoverBackColor: TThemeColor index 98 read GetColor write SetColor default 0;
    property ImportKeywordColor: TThemeColor index 99 read GetColor write SetColor default 0;
    property ImportNameColor: TThemeColor index 100 read GetColor write SetColor default 0;
    property LoopKeywordColor: TThemeColor index 101 read GetColor write SetColor default 0;
    property BlockKeywordColor: TThemeColor index 102 read GetColor write SetColor default 0;
    property ResultColor: TThemeColor index 103 read GetColor write SetColor default 0;
    property XmlDocTagColor: TThemeColor index 104 read GetColor write SetColor default 0;
    property XmlDocAttributeColor: TThemeColor index 105 read GetColor write SetColor default 0;
    property XmlDocValueColor: TThemeColor index 106 read GetColor write SetColor default 0;
    property MarkdownHeadingColor: TThemeColor index 107 read GetColor write SetColor default 0;
    property MarkdownEmphasisColor: TThemeColor index 108 read GetColor write SetColor default 0;
    property MarkdownLinkColor: TThemeColor index 109 read GetColor write SetColor default 0;
    property MarkdownCodeColor: TThemeColor index 110 read GetColor write SetColor default 0;
    property BreakpointColor: TThemeColor index 111 read GetColor write SetColor default 0;
    property DisabledBreakpointColor: TThemeColor index 112 read GetColor write SetColor default 0;
    property ExecutionLineColor: TThemeColor index 113 read GetColor write SetColor default 0;
    property InfoColor: TThemeColor index 114 read GetColor write SetColor default 0;
  end;

implementation

uses NimbusForms.Rendering.Types;

constructor TThemedCodeEditorTheme.Create(const OnChange: TNotifyEvent);
begin inherited Create; FOnChange := OnChange; end;

procedure TThemedCodeEditorTheme.Assign(Source: TPersistent);
begin
  if not (Source is TThemedCodeEditorTheme) then begin inherited; Exit; end;
  FColors := TThemedCodeEditorTheme(Source).FColors;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TThemedCodeEditorTheme.GetColor(const Index: Integer): TThemeColor;
begin Result := FColors[Index]; end;

procedure TThemedCodeEditorTheme.SetColor(const Index: Integer; const Value: TThemeColor);
begin
  if FColors[Index] = Value then Exit;
  FColors[Index] := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TThemedCodeEditorTheme.Resolve(const Custom, DefaultColor: TThemeColor): TThemeColor;
begin if Custom <> 0 then Result := Custom else Result := DefaultColor; end;

function TThemedCodeEditorTheme.TokenColor(const Kind: TCodeEditorHighlightTokenKind; const Palette: TThemePalette): TThemeColor;
begin
  Result := Resolve(ForeColor, NimbusControlForeColor(Palette));
  case Kind of
    chtKeyword: Result := Resolve(KeywordColor, ThemeColor(255, 86, 156, 214));
    chtControlKeyword: Result := Resolve(ControlKeywordColor, ThemeColor(255, 197, 134, 192));
    chtAccessKeyword: Result := Resolve(AccessKeywordColor, ThemeColor(255, 86, 156, 214));
    chtModifierKeyword: Result := Resolve(ModifierKeywordColor, ThemeColor(255, 86, 156, 214));
    chtTypeKeyword: Result := Resolve(TypeKeywordColor, ThemeColor(255, 79, 193, 255));
    chtDeclarationKeyword: Result := Resolve(DeclarationKeywordColor, ThemeColor(255, 86, 156, 214));
    chtAccessorKeyword: Result := Resolve(AccessorKeywordColor, ThemeColor(255, 86, 156, 214));
    chtIdentifier: Result := Resolve(IdentifierColor, ThemeColor(255, 220, 220, 220));
    chtNamespaceName: Result := Resolve(NamespaceColor, ThemeColor(255, 78, 201, 176));
    chtModuleName: Result := Resolve(ModuleColor, ThemeColor(255, 78, 201, 176));
    chtClassName: Result := Resolve(ClassColor, ThemeColor(255, 78, 201, 176));
    chtStructName: Result := Resolve(StructColor, ThemeColor(255, 78, 201, 176));
    chtInterfaceName: Result := Resolve(InterfaceColor, ThemeColor(255, 184, 215, 163));
    chtEnumName: Result := Resolve(EnumColor, ThemeColor(255, 184, 215, 163));
    chtDelegateName: Result := Resolve(DelegateColor, ThemeColor(255, 78, 201, 176));
    chtTypeName: Result := Resolve(TypeColor, ThemeColor(255, 78, 201, 176));
    chtTypeParameterName: Result := Resolve(TypeParameterColor, ThemeColor(255, 78, 201, 176));
    chtMethodName: Result := Resolve(MethodColor, ThemeColor(255, 220, 220, 170));
    chtFunctionName: Result := Resolve(FunctionColor, ThemeColor(255, 220, 220, 170));
    chtProcedureName: Result := Resolve(ProcedureColor, ThemeColor(255, 220, 220, 170));
    chtConstructorName: Result := Resolve(ConstructorColor, ThemeColor(255, 220, 220, 170));
    chtPropertyName: Result := Resolve(PropertyColor, ThemeColor(255, 156, 220, 254));
    chtFieldName: Result := Resolve(FieldColor, ThemeColor(255, 156, 220, 254));
    chtVariableName: Result := Resolve(VariableColor, ThemeColor(255, 156, 220, 254));
    chtLocalVariableName: Result := Resolve(LocalVariableColor, ThemeColor(255, 156, 220, 254));
    chtParameterName: Result := Resolve(ParameterColor, ThemeColor(255, 255, 201, 163));
    chtConstantName: Result := Resolve(ConstantColor, ThemeColor(255, 220, 220, 170));
    chtEnumMemberName: Result := Resolve(EnumMemberColor, ThemeColor(255, 184, 215, 163));
    chtEventName: Result := Resolve(EventColor, ThemeColor(255, 156, 220, 254));
    chtAttributeName: Result := Resolve(AttributeColor, ThemeColor(255, 78, 201, 176));
    chtLabelName: Result := Resolve(LabelColor, ThemeColor(255, 220, 220, 170));
    chtString: Result := Resolve(StringColor, ThemeColor(255, 214, 157, 133));
    chtVerbatimString: Result := Resolve(VerbatimStringColor, ThemeColor(255, 214, 157, 133));
    chtInterpolatedString: Result := Resolve(InterpolatedStringColor, ThemeColor(255, 214, 157, 133));
    chtCharacter: Result := Resolve(CharacterColor, ThemeColor(255, 214, 157, 133));
    chtNumber: Result := Resolve(NumberColor, ThemeColor(255, 181, 206, 168));
    chtBoolean: Result := Resolve(BooleanColor, ThemeColor(255, 86, 156, 214));
    chtNull: Result := Resolve(NullColor, ThemeColor(255, 86, 156, 214));
    chtComment: Result := Resolve(CommentColor, ThemeColor(255, 87, 166, 74));
    chtDocumentationComment: Result := Resolve(DocumentationCommentColor, ThemeColor(255, 87, 166, 74));
    chtXmlDocComment: Result := Resolve(XmlDocColor, ThemeColor(255, 87, 166, 74));
    chtPreprocessor: Result := Resolve(PreprocessorColor, ThemeColor(255, 155, 155, 155));
    chtOperator: Result := Resolve(OperatorColor, ThemeColor(255, 220, 220, 220));
    chtPunctuation: Result := Resolve(PunctuationColor, ThemeColor(255, 220, 220, 220));
    chtBracket: Result := Resolve(BracketColor, ThemeColor(255, 220, 220, 220));
    chtBrace: Result := Resolve(BraceColor, ThemeColor(255, 220, 220, 220));
    chtParenthesis: Result := Resolve(ParenthesisColor, ThemeColor(255, 220, 220, 220));
    chtDelimiter: Result := Resolve(DelimiterColor, ThemeColor(255, 220, 220, 220));
    chtError: Result := Resolve(ErrorColor, ThemeColor(255, 244, 71, 71));
    chtWarning: Result := Resolve(WarningColor, ThemeColor(255, 255, 204, 102));
    chtImportKeyword: Result := Resolve(ImportKeywordColor, $FFC586C0);
    chtImportName: Result := Resolve(ImportNameColor, $FFD7BA7D);
    chtLoopKeyword: Result := Resolve(LoopKeywordColor, $FFD7BA7D);
    chtBlockKeyword: Result := Resolve(BlockKeywordColor, $FFC586C0);
    chtResultName: Result := Resolve(ResultColor, $FFCE9178);
    chtXmlDocTag: Result := Resolve(XmlDocTagColor, $FF569CD6);
    chtXmlDocAttribute: Result := Resolve(XmlDocAttributeColor, $FF9CDCFE);
    chtXmlDocValue: Result := Resolve(XmlDocValueColor, $FFCE9178);
    chtMarkdownHeading: Result := Resolve(MarkdownHeadingColor, $FF569CD6);
    chtMarkdownEmphasis: Result := Resolve(MarkdownEmphasisColor, $FFC586C0);
    chtMarkdownLink: Result := Resolve(MarkdownLinkColor, $FF4EC9B0);
    chtMarkdownCode: Result := Resolve(MarkdownCodeColor, $FFCE9178);
  end;
end;

end.
