import re, os, sys, json
SRC='/tmp/grid/Grid/Events'
OUT='/tmp/out/NimbusForms.Grid/src'
# C#-Typ -> (Delphi-Typ, Unit)
T={'int':('Integer',None),'bool':('Boolean',None),'string':('string',None),'long':('Int64',None),'double':('Double',None),
 'object':('TValue','System.Rtti'),'Rectangle':('TRect','System.Types'),'Point':('TPoint','System.Types'),'Size':('TSize','System.Types'),
 'Color':('TThemeColor','NimbusForms.Theming.Types'),'MouseButtons':('TThemedGridMouseButtons','NimbusForms.Grid.Events'),
 'Graphics':('TGPGraphics','Winapi.GDIPOBJ'),'IFormatProvider':('TFormatSettings','System.SysUtils'),
 'IDataObject':('IDataObject','Winapi.ActiveX'),'DragDropEffects':('TThemedGridDragDropEffects','NimbusForms.Grid.Events.DragDrop'),
 'ThemedGridColumn':('TThemedGridColumn','NimbusForms.Grid.Column'),'ThemedGridRow':('TThemedGridRow','NimbusForms.Grid.Row'),
 'ThemedGridCell':('TThemedGridCell','NimbusForms.Grid.Cell'),'ThemedGridHitInfo':('TThemedGridHitInfo','NimbusForms.Grid.HitInfo'),
 'ThemedGridColumnBand':('TThemedGridColumnBand','NimbusForms.Grid.ColumnBand'),'ThemedGridFormatStyle':('TThemedGridFormatStyle','NimbusForms.Grid.FormatStyle'),
 'ThemedGridFormatCondition':('TThemedGridFormatCondition','NimbusForms.Grid.FormatCondition'),'ThemedGridCellRange':('TThemedGridCellRange','NimbusForms.Grid.Primitives'),
 'ThemedGridSortDirection':('TThemedGridSortDirection','NimbusForms.Grid.Types'),'ThemedGridCellState':('TThemedGridCellState','NimbusForms.Grid.Types'),
 'ThemedGridSummaryType':('TThemedGridSummaryType','NimbusForms.Grid.Types'),'ThemedGridFilterDescriptor':('TThemedGridFilterDescriptor','NimbusForms.Grid.FilterDescriptor'),'ThemedGridRenderContext':('TThemedGridRenderContext','NimbusForms.Grid.RenderContext')}
SKIP={'ThemedGridFormatConditionChangedEventArgs'}   # bereits in FormatConditionEvents
KW={'unit','type','end','begin','class','record','array','set','file','label','object','of','in','is','as','to','do','or','and','not','xor','mod','div','shl','shr','string','var','const','procedure','function','property','program','uses','with','case','else','except','finally','try','raise','repeat','until','while','for','if','then','goto','nil','inherited','initialization','finalization','interface','implementation','constructor','destructor','packed','out','inline','library','exports','resourcestring','threadvar','dispinterface','asm'}
def esc(n): return '&'+n if n.lower() in KW else n
def strip(t): return re.sub(r'//.*','',t.replace('\r\n','\n'))
def classes(text):
    res=[]
    for m in re.finditer(r'public\s+(sealed\s+)?class\s+(\w+)\s*(?::\s*(\w+))?\s*\{',text):
        i=m.end(); d=1
        while d and i<len(text):
            d+= (text[i]=='{') - (text[i]=='}'); i+=1
        res.append(dict(name=m.group(2),sealed=bool(m.group(1)),base=m.group(3),body=text[m.end():i-1]))
    return res
def parse(c):
    b=c['body']
    props=re.findall(r'public\s+([\w<>\[\]\.]+)\s+(\w+)\s*\{\s*get;\s*(private\s+)?set;\s*\}',b)
    ctor=re.search(r'public\s+'+c['name']+r'\s*\(([^)]*)\)\s*(?::\s*base\s*\(([^)]*)\))?\s*\{(.*?)\}',b,re.S)
    c['props']=[(t,n,bool(p)) for t,n,p in props]
    c['ctor']=None
    if ctor:
        params=[tuple(x.strip().rsplit(' ',1)) for x in ctor.group(1).split(',') if x.strip()]
        base=[x.strip() for x in (ctor.group(2) or '').split(',') if x.strip()]
        assigns=re.findall(r'(\w+)\s*=\s*(\w+)\s*;',ctor.group(3))
        extra=re.findall(r'(\w+)\s*=\s*new\s',ctor.group(3))
        c['ctor']=dict(params=params,base=base,assigns=assigns,new=extra)
    c['manual']=bool(re.search(r'\b(EnsureStyle|HasStyle|void\s+Apply)\b',b))
    return c
def used_types(c):
    ts={t for t,_,_ in c['props']}
    if c['ctor']: ts|={p[0] for p in c['ctor']['params']}
    return ts
def dtype(t): return T[t][0]
def pname(n): return 'A'+n[0].upper()+n[1:]
def event_name(cls):
    return 'T'+cls[:-len('EventArgs')]+'Event'
def gen(unit, files, manual, extra_pre='', extra_types='', extra_impl=''):
    all_c={}
    for f in files:
        for c in classes(strip(open(os.path.join(SRC,f+'.cs'),encoding='utf-8-sig').read())): all_c[c['name']]=parse(c)
    emitted=[]; deferred=[]
    known={'EventArgs'}|set(manual)
    for n,c in all_c.items():
        if n in SKIP: continue
        ok=all(t in T for t in used_types(c)) and (c['base'] in known or c['base'] in (None,'EventArgs') or c['base'] in T)
        if n in manual: ok=True
        if ok and c['base'] and c['base'] not in ('EventArgs',) and c['base'] not in [e['name'] for e in emitted] and c['base'] not in ('EventArgs',):
            ok = c['base'] in [e['name'] for e in emitted] or c['base'] in EXTERNAL_BASES
        if ok: emitted.append(c); known.add(n)
        else: deferred.append(n)
    uses={'System.Classes'} if False else set()
    typ=[]; impl=[]
    for c in emitted:
        n=c['name']; dn='T'+n
        if n in manual: typ.append(manual[n][0]); impl.append(manual[n][1]); uses|=manual[n][2]; continue
        base='TThemedGridEventArgs' if c['base'] in (None,'EventArgs') else 'T'+c['base']
        seal=' sealed' if c['sealed'] else ''
        fields=[];props=[]
        ctor=c['ctor']; ro={a for a,_ in ctor['assigns']} if ctor else set()
        for t,pn,priv in c['props']:
            uses.add(T[t][1]) if T[t][1] else None
            if t=='IFormatProvider':
                fields.append(f"    F{pn}: TFormatSettings;\n    FHas{pn}: Boolean;")
                props.append(f"    property {esc(pn)}: TFormatSettings read F{pn} write Set{pn};\n    property Has{pn}: Boolean read FHas{pn};")
                continue
            fields.append(f"    F{pn}: {dtype(t)};")
            if priv: props.append(f"    property {esc(pn)}: {dtype(t)} read F{pn};")
            else: props.append(f"    property {esc(pn)}: {dtype(t)} read F{pn} write F{pn};")
        hasfmt=any(t=='IFormatProvider' for t,_,_ in c['props'])
        priv_sect='  private\n'+'\n'.join(fields)+('\n    procedure SetFormatProvider(const AValue: TFormatSettings);' if hasfmt else '')+'\n' if fields else ''
        pub=''
        if ctor:
            ps='; '.join(f"const {pname(p[1])}: {dtype(p[0])}" for p in ctor['params'])
            pub+=f"    constructor Create({ps});\n"
            for p in ctor['params']: uses.add(T[p[0]][1]) if T[p[0]][1] else None
        typ.append(f"  {dn} = class{seal}({base})\n{priv_sect}  public\n{pub}"+'\n'.join(props)+"\n  end;")
        if ctor:
            ps='; '.join(f"const {pname(p[1])}: {dtype(p[0])}" for p in ctor['params'])
            body=[]
            if ctor['base']:
                bargs=', '.join(pname(x) for x in ctor['base']); body.append(f"  inherited Create({bargs});")
            else: body.append("  inherited Create;")
            for a,v in ctor['assigns']: body.append(f"  F{a} := {pname(v)};")
            impl.append(f"constructor {dn}.Create({ps});\nbegin\n"+'\n'.join(body)+"\nend;\n")
        if hasfmt:
            impl.append(f"procedure {dn}.SetFormatProvider(const AValue: TFormatSettings);\nbegin\n  FFormatProvider := AValue;\n  FHasFormatProvider := True;\nend;\n")
    evs=[f"  {event_name(c['name'])} = procedure(ASender: TObject; const AArgs: T{c['name']}) of object;" for c in emitted]
    return dict(unit=unit,types=typ,impl=impl,events=evs,uses=uses,emitted=[c['name'] for c in emitted],deferred=deferred)
EXTERNAL_BASES=set()

def style_class(name, base, fields, extra_apply=None, row=False):
    dn='T'+name
    fl='\n'.join(f"    F{n}: {t};" for n,t in fields)
    props='\n'.join(f"    property {n}: {t} read F{n} write F{n};" for n,t in fields)
    cls=f"""  {dn} = class sealed({base})
  private
{fl}
    FStyle: TThemedGridFormatStyle;
    FOwnedStyle: TThemedGridFormatStyle;
    procedure SetStyle(const AValue: TThemedGridFormatStyle);
    function GetHasStyle: Boolean;
  public
    destructor Destroy; override;
    procedure EnsureStyle;
    function DetachStyle: TThemedGridFormatStyle;
{'    procedure Apply;' if extra_apply else ''}
{props}
    property Style: TThemedGridFormatStyle read FStyle write SetStyle;
    property HasStyle: Boolean read GetHasStyle;
  end;""".replace('\n\n','\n')
    imp=f"""destructor {dn}.Destroy;
begin
  FOwnedStyle.Free;
  inherited Destroy;
end;

procedure {dn}.SetStyle(const AValue: TThemedGridFormatStyle);
begin
  if FStyle = AValue then
    Exit;
  if (FOwnedStyle <> nil) and (FOwnedStyle <> AValue) then
  begin
    FOwnedStyle.Free;
    FOwnedStyle := nil;
  end;
  FStyle := AValue;
end;

function {dn}.GetHasStyle: Boolean;
begin
  Result := FStyle <> nil;
end;

procedure {dn}.EnsureStyle;
begin
  if FStyle = nil then
  begin
    FOwnedStyle := TThemedGridFormatStyle.Create;
    FStyle := FOwnedStyle;
  end;
end;

function {dn}.DetachStyle: TThemedGridFormatStyle;
begin
  Result := FOwnedStyle;
  FOwnedStyle := nil;
end;
"""
    if extra_apply:
        imp+=f"\nprocedure {dn}.Apply;\nbegin\n  EnsureStyle;\n{extra_apply}end;\n"
    return (cls,imp,{'NimbusForms.Grid.FormatStyle','NimbusForms.Theming.Types'})
apply_sel="""  if FSelected then
  begin
    FStyle.SelectionBackColor := FSelectionBackColor;
    FStyle.SelectionForeColor := FSelectionForeColor;
  end;
  if FHovered then
  begin
    FStyle.HoverBackColor := FHoverBackColor;
    FStyle.HoverForeColor := FHoverForeColor;
  end;
  if FCurrent then
    FStyle.CurrentBorderColor := FCurrentBorderColor;
"""
MANUAL={
 'ThemedGridCellStyleEventArgs':style_class('ThemedGridCellStyleEventArgs','TThemedGridCellEventArgs',[('CurrentBackColor','TThemeColor'),('CurrentForeColor','TThemeColor')]),
 'ThemedGridRowStyleEventArgs':style_class('ThemedGridRowStyleEventArgs','TThemedGridEventArgs',[('RowIndex','Integer'),('DataSourceIndex','Integer'),('Row','TThemedGridRow'),('RowObject','TValue'),('Bounds','TRect'),('CurrentBackColor','TThemeColor'),('CurrentForeColor','TThemeColor')]),
 'ThemedGridSelectionStyleEventArgs':style_class('ThemedGridSelectionStyleEventArgs','TThemedGridCellEventArgs',[('CurrentBackColor','TThemeColor'),('CurrentForeColor','TThemeColor'),('SelectionBackColor','TThemeColor'),('SelectionForeColor','TThemeColor'),('HoverBackColor','TThemeColor'),('HoverForeColor','TThemeColor'),('CurrentBorderColor','TThemeColor'),('Selected','Boolean'),('Hovered','Boolean'),('Current','Boolean')],extra_apply=apply_sel),
}
MANUAL['ThemedGridRowStyleEventArgs'][2].update({'NimbusForms.Grid.Row','System.Rtti','System.Types'})
MANUAL['ThemedGridCellStyleEventArgs'][2].update({'NimbusForms.Grid.Cell'})
MANUAL['ThemedGridSelectionStyleEventArgs'][2].update({'NimbusForms.Grid.Cell'})

CORE_PRE="""  TThemedGridMouseButtons = set of TMouseButton;

  TThemedGridEventArgs = class
  end;
"""
DD_PRE="""  TThemedGridDragDropEffect = (Copy, Move, Link, Scroll);
  TThemedGridDragDropEffects = set of TThemedGridDragDropEffect;
"""
DD_FUNCS_DECL="""
function ThemedGridEffectsToOle(const AEffects: TThemedGridDragDropEffects): Integer;
function ThemedGridEffectsFromOle(const AEffects: Integer): TThemedGridDragDropEffects;
"""
DD_FUNCS_IMPL="""function ThemedGridEffectsToOle(const AEffects: TThemedGridDragDropEffects): Integer;
begin
  Result := 0;
  if TThemedGridDragDropEffect.Copy in AEffects then
    Result := Result or DROPEFFECT_COPY;
  if TThemedGridDragDropEffect.Move in AEffects then
    Result := Result or DROPEFFECT_MOVE;
  if TThemedGridDragDropEffect.Link in AEffects then
    Result := Result or DROPEFFECT_LINK;
  if TThemedGridDragDropEffect.Scroll in AEffects then
    Result := Result or Integer(DROPEFFECT_SCROLL);
end;

function ThemedGridEffectsFromOle(const AEffects: Integer): TThemedGridDragDropEffects;
begin
  Result := [];
  if (AEffects and DROPEFFECT_COPY) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Copy);
  if (AEffects and DROPEFFECT_MOVE) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Move);
  if (AEffects and DROPEFFECT_LINK) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Link);
  if (AEffects and Integer(DROPEFFECT_SCROLL)) <> 0 then
    Include(Result, TThemedGridDragDropEffect.Scroll);
end;

"""
def write(spec,pre='',decl_after='',impl_before='',extra_uses=()):
    u=spec['unit']; uses=set(x for x in spec['uses'] if x and x!=u)|set(extra_uses)
    uses.discard(u)
    if u!='NimbusForms.Grid.Events': uses.add('NimbusForms.Grid.Events')
    grp=lambda x:(0 if x.startswith('System') else 1 if x.startswith('Winapi') else 2, x)
    ul=',\n  '.join(sorted(uses,key=grp))
    body='\n\n'.join(spec['types'])
    txt=f"unit {u};\n\n{{$SCOPEDENUMS ON}}\n\ninterface\n\nuses\n  {ul};\n\ntype\n{pre}\n{body}\n\n"+'\n'.join(spec['events'])+"\n"+decl_after+"\nimplementation\n"
    if impl_before or spec['impl']: txt+="\n"+impl_before+'\n'.join(spec['impl'])
    txt+="\nend.\n"
    txt=txt.replace('\n\n\n','\n\n')
    open(os.path.join(OUT,u+'.pas'),'w',newline='').write(txt.replace('\n','\r\n'))
summary={}
core=gen('NimbusForms.Grid.Events',['ThemedGridEvents'],MANUAL)
core['uses']|={'System.UITypes'}
write(core,pre=CORE_PRE); summary['Events']=core
dd=gen('NimbusForms.Grid.Events.DragDrop',['ThemedGridDragDropEvents'],{})
dd['uses']|={'Winapi.ActiveX'}
write(dd,pre=DD_PRE,decl_after=DD_FUNCS_DECL,impl_before=DD_FUNCS_IMPL); summary['DragDrop']=dd
ps=gen('NimbusForms.Grid.Events.Paste',['ThemedGridPasteEvents'],{}); write(ps); summary['Paste']=ps
rw=gen('NimbusForms.Grid.Events.Rows',['ThemedGridRowEditEvents','ThemedGridRowActionEvents','ThemedGridRowMoveEvents'],{}); write(rw); summary['Rows']=rw
tot_e=sum(len(s['emitted']) for s in summary.values()); tot_d=[n for s in summary.values() for n in s['deferred']]
print(f"portiert: {tot_e} Typen | zurückgestellt: {len(tot_d)}")
for k,s in summary.items(): print(f"  {k:<9} emittiert {len(s['emitted']):2d}  zurückgestellt {len(s['deferred'])}: {', '.join(s['deferred'])}")
json.dump({k:s['deferred'] for k,s in summary.items()},open('/tmp/out/NimbusForms.Grid/tools/events_deferred.json','w'),indent=1)
