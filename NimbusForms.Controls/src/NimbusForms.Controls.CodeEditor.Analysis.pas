{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Analysis;

interface

uses System.Classes, System.SysUtils, NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.Document, NimbusForms.Controls.CodeEditor.Syntax,
  NimbusForms.Controls.CodeEditor.Services;

type
  TCodeEditorAnalysisResult = record
    Version: Integer;
    Pairs: TArray<TCodeBracketPair>;
    Folds: TArray<TCodeFoldRegion>;
    Symbols: TArray<TCodeEditorSymbolInfo>;
    Diagnostics: TArray<TCodeDiagnostic>;
    ErrorText: string;
  end;
  TCodeEditorAnalysisJob = class(TThread)
  private
    FSource: ICodeVirtualTextSource;
    FHighlighter: ICodeSyntaxHighlighter;
    FLanguageName: string;
    FFoldProviders: TArray<ICodeFoldProvider>;
    FSymbolProviders: TArray<ICodeEditorSymbolProvider>;
    FDiagnosticProviders: TArray<ICodeDiagnosticProvider>;
    FAnalyzePairs, FAnalyzeFolds, FAnalyzeSymbols: Boolean;
    FResult: TCodeEditorAnalysisResult;
    FDone: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter;
      const LanguageName: string; const FoldProviders: TArray<ICodeFoldProvider>;
      const SymbolProviders: TArray<ICodeEditorSymbolProvider>; const DiagnosticProviders: TArray<ICodeDiagnosticProvider>;
      const AnalyzePairs, AnalyzeFolds, AnalyzeSymbols: Boolean);
    function Done: Boolean;
    function TakeResult: TCodeEditorAnalysisResult;
  end;

implementation

uses System.SyncObjs, System.Generics.Collections;

constructor TCodeEditorAnalysisJob.Create(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter;
  const LanguageName: string; const FoldProviders: TArray<ICodeFoldProvider>;
  const SymbolProviders: TArray<ICodeEditorSymbolProvider>; const DiagnosticProviders: TArray<ICodeDiagnosticProvider>;
  const AnalyzePairs, AnalyzeFolds, AnalyzeSymbols: Boolean);
begin
  inherited Create(True); FreeOnTerminate := False; FSource := Source; FHighlighter := Highlighter;
  FLanguageName := LanguageName; FFoldProviders := FoldProviders; FSymbolProviders := SymbolProviders;
  FDiagnosticProviders := DiagnosticProviders; FAnalyzePairs := AnalyzePairs;
  FAnalyzeFolds := AnalyzeFolds; FAnalyzeSymbols := AnalyzeSymbols; FResult.Version := Source.Version;
end;
function TCodeEditorAnalysisJob.Done: Boolean;
begin Result := TInterlocked.CompareExchange(FDone, 0, 0) <> 0; end;
function TCodeEditorAnalysisJob.TakeResult: TCodeEditorAnalysisResult;
begin if not Done then raise EInvalidOpException.Create('Analysis is still running'); WaitFor; Result := FResult; end;
procedure TCodeEditorAnalysisJob.Execute;
var Analyzer: TCodeEditorAnalyzer; Symbols: TList<TCodeEditorSymbolInfo>;
  Folds: TList<TCodeFoldRegion>; Diagnostics: TList<TCodeDiagnostic>;
  FP: ICodeFoldProvider; SP: ICodeEditorSymbolProvider; DP: ICodeDiagnosticProvider;
begin
  Analyzer := TCodeEditorAnalyzer.Create; Symbols := TList<TCodeEditorSymbolInfo>.Create;
  Folds := TList<TCodeFoldRegion>.Create; Diagnostics := TList<TCodeDiagnostic>.Create;
  try
    try
      if FAnalyzePairs or FAnalyzeFolds then
      begin
        Analyzer.Start(FSource, FHighlighter);
        while not Terminated and not Analyzer.Complete do Analyzer.Advance(256, 10);
        if Terminated then Exit;
        if FAnalyzePairs then FResult.Pairs := Analyzer.Pairs.ToArray;
        if FAnalyzeFolds then Folds.AddRange(Analyzer.Folds.ToArray);
      end;
      if FAnalyzeFolds then for FP in FFoldProviders do
      begin if Terminated then Exit; Folds.AddRange(FP.GetFoldRegions(FSource)); end;
      if FAnalyzeSymbols then for SP in FSymbolProviders do
      begin if Terminated then Exit; Symbols.AddRange(SP.GetSymbols(FSource, FLanguageName)); end;
      for DP in FDiagnosticProviders do
      begin if Terminated then Exit; Diagnostics.AddRange(DP.GetDiagnostics(FSource)); end;
      FResult.Symbols := Symbols.ToArray; FResult.Folds := Folds.ToArray; FResult.Diagnostics := Diagnostics.ToArray;
      CodeBuildSymbolHierarchy(FResult.Symbols);
    except on E: Exception do FResult.ErrorText := E.ClassName + ': ' + E.Message; end;
  finally
    Analyzer.Free; Symbols.Free; Folds.Free; Diagnostics.Free;
    TInterlocked.Exchange(FDone, 1);
  end;
end;

end.
