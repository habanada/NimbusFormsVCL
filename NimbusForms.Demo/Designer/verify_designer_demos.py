from collections import defaultdict
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent
workspace = root.parent.parent
registration = workspace / 'NimbusForms.Controls' / 'packages' / 'NimbusForms.Design.Register.pas'
registered = set(re.findall(r'\bTThemed\w+\b', registration.read_text(encoding='utf-8-sig'))) if registration.exists() else set()
issues = []
counts = defaultdict(int)

for project in ('GridWorkbench', 'ControlsGallery'):
    folder = root / project
    names = {suffix: list(folder.glob('*' + suffix)) for suffix in ('.dpr', '.dproj', '.pas', '.dfm')}
    if any(len(files) != 1 for files in names.values()):
        issues.append(f'{project}: exactly one DPR, DPROJ, PAS and DFM required')
        continue
    dpr, dproj, pas, dfm = (names[ext][0] for ext in ('.dpr', '.dproj', '.pas', '.dfm'))
    code = pas.read_text(encoding='utf-8-sig')
    interface_uses = re.search(r'\binterface\s+uses\s+(.*?);', code, re.IGNORECASE | re.DOTALL)
    if interface_uses is None:
        issues.append(f'{project}: interface uses clause missing')
    else:
        used_units = [item.strip().casefold() for item in interface_uses.group(1).split(',')]
        duplicates = sorted({unit for unit in used_units if used_units.count(unit) > 1})
        for unit in duplicates:
            issues.append(f'{project}: duplicate interface uses unit {unit}')
    text = dfm.read_text(encoding='utf-8-sig')
    entry = dpr.read_text(encoding='utf-8-sig')
    tree = ET.parse(dproj).getroot()
    ns = {'d': 'http://schemas.microsoft.com/developer/msbuild/2003'}
    main = tree.find('.//d:MainSource', ns)
    if main is None or main.text != dpr.name:
        issues.append(f'{project}: invalid MainSource')
    if pas.name not in entry or '{$R *.dfm}' not in code:
        issues.append(f'{project}: main form not linked to text DFM')
    if not any(x.get('Include') == pas.name for x in tree.findall('.//d:DCCReference', ns)):
        issues.append(f'{project}: designer form missing DCCReference')
    if not re.search(r'\bNimbusForms\.Controls\.TabControl\b', code):
        issues.append(f'{project}: NimbusForms tab control unit missing')
    if not re.search(r'\bPages:\s*TThemedTabControl\s*;', code):
        issues.append(f'{project}: NimbusForms tab field missing')
    for native in ('TPanel', 'TGroupBox', 'TLabel', 'TPageControl'):
        if re.search(r'\b' + native + r'\b', code + '\n' + text):
            issues.append(f'{project}: native visual class {native} used')
    stack = []
    objects = {}
    properties = defaultdict(dict)
    order = defaultdict(list)
    events = []
    for number, line in enumerate(text.splitlines(), 1):
        opened = re.match(r'^\s*(object|inherited)\s+(\w+):\s+(\w+)\s*$', line)
        if opened:
            name, cls = opened.group(2), opened.group(3)
            if name in objects:
                issues.append(f'{project}:{number}: duplicate object {name}')
            parent = stack[-1] if stack else None
            objects[name] = (cls, parent, number)
            if cls == 'TTabSheet':
                counts['pages'] += 1
                if parent != 'Pages':
                    issues.append(f'{project}:{number}: tab {name} must be a direct child of Pages')
            elif cls != 'TThemedTabControl' and not (cls.startswith('TThemed') or not stack):
                issues.append(f'{project}:{number}: unsupported visual component {cls}')
            if cls.startswith('TThemed') and registered and cls not in registered:
                issues.append(f'{project}:{number}: {cls} not registered in NimbusForms design package')
            if cls == 'TThemedGridView':
                counts['grids'] += 1
                if not any(objects[x][0] == 'TTabSheet' for x in stack):
                    issues.append(f'{project}:{number}: {name} is not on a tab page')
            stack.append(name)
            counts['objects'] += 1
            continue
        if line.strip() == 'end':
            if stack:
                stack.pop()
            else:
                issues.append(f'{project}:{number}: extra DFM end')
            continue
        prop = re.match(r'^\s*(\w+(?:\.\w+)*)\s*=\s*(.*)$', line)
        if not prop or not stack:
            continue
        name = stack[-1]
        key, val = prop.group(1), prop.group(2)
        properties[name][key] = val
        if key == 'PageControl':
            issues.append(f'{project}:{number}: PageControl is not streamable on TTabSheet')
        if key == 'BevelOuter' and objects[name][0] == 'TThemedPanel':
            issues.append(f'{project}:{number}: BevelOuter invalid on TThemedPanel')
        if key == 'TabOrder':
            order[objects[name][1]].append((name, val))
        if key.startswith('On'):
            events.append((number, key, val))
    if stack:
        issues.append(f'{project}: unclosed objects: {stack}')
    if not objects:
        issues.append(f'{project}: empty DFM')
        continue
    root_name, (form_class, parent, _) = next(iter(objects.items()))
    if parent is not None or not re.search(r'\b' + re.escape(form_class) + r'\s*=\s*class\(TForm\)', code):
        issues.append(f'{project}: root form and Pascal form class mismatch')
    for name, (cls, parent, line) in objects.items():
        if parent is not None and not re.search(r'\b' + re.escape(name) + r'\s*:\s*' + re.escape(cls) + r'\s*;', code):
            issues.append(f'{project}:{line}: Pascal field {name}: {cls} missing')
    if 'Pages' not in objects or objects['Pages'][0] != 'TThemedTabControl':
        issues.append(f'{project}: Pages must use TThemedTabControl')
    else:
        options = properties['Pages']
        expected = {'CloseButtonMode': 'tcbmNone', 'CloseOnMiddleClick': 'False', 'AllowTabReorder': 'False'}
        for name, val in expected.items():
            if options.get(name) != val:
                issues.append(f'{project}: Pages.{name} must equal {val}')
        active = options.get('ActivePage')
        if active not in objects or objects[active][0] != 'TTabSheet' or objects[active][1] != 'Pages':
            issues.append(f'{project}: ActivePage is not a direct TTabSheet child')
    for parent, entries in order.items():
        values = [val for _, val in entries]
        if len(values) != len(set(values)):
            issues.append(f'{project}: conflicting TabOrder on {parent}')
    for number, key, handler in events:
        if not re.search(r'\bprocedure\s+' + re.escape(handler) + r'\s*\(', code):
            issues.append(f'{project}:{number}: missing handler {key}={handler}')
    page_count = sum(cls == 'TTabSheet' for cls, _, _ in objects.values())
    if page_count != (5 if project == 'GridWorkbench' else 3):
        issues.append(f'{project}: unexpected page count {page_count}')
    if project == 'GridWorkbench' and sum(cls == 'TThemedGridView' for cls, _, _ in objects.values()) != 5:
        issues.append(f'{project}: five grids required')
    if project == 'GridWorkbench':
        required = {'tabShowcase': 'TTabSheet', 'gridShowcase': 'TThemedGridView',
                    'progressShowcase': 'TThemedProgressBar', 'badgeVolume': 'TThemedBadgeLabel',
                    'badgeDetails': 'TThemedBadgeLabel', 'badgeVisuals': 'TThemedBadgeLabel'}
        for name, klass in required.items():
            if name not in objects or objects[name][0] != klass:
                issues.append(f'{project}: missing showcase object {name}: {klass}')
        if objects.get('tabShowcase', (None,))[1] != 'Pages':
            issues.append(f'{project}: showcase page is not nested below Pages')
        for child in ('gridShowcase', 'pnlShowcaseHero', 'pnlShowcaseTools'):
            if objects.get(child, (None, None))[1] != 'tabShowcase':
                issues.append(f'{project}: {child} is not directly on designer-visible tabShowcase')
        for pattern in (r'for\s+I\s*:=\s*1\s+to\s+200000', r'ExpandDetailRow\(0\)',
                        r'TThemedGridCellRenderKind\.ProgressBar', r'TThemedGridCellRenderKind\.Badge',
                        r'TThemedGridCellRenderKind\.Rating', r'TThemedGridCellRenderKind\.ColorSwatch',
                        r'OnMasterDetailDataNeeded\s*:=\s*ShowcaseDetailNeeded',
                        r'OnCellVisualNeeded\s*:=\s*ShowcaseVisualNeeded'):
            if not re.search(pattern, code):
                issues.append(f'{project}: showcase capability missing: {pattern}')
    if project == 'GridWorkbench' and 'dlgSave: TSaveDialog' in code:
        issues.append(f'{project}: save dialog should be instantiated on demand')
    print(f'{project}: {page_count} tabs, {len(objects)} DFM objects, {len(events)} events; NimbusForms classes only (except TTabSheet / TForm)')

if issues:
    print('\n'.join(issues), file=sys.stderr)
    sys.exit(1)
print(f'OK: {counts["objects"]} DFM objects, {counts["pages"]} pages, {counts["grids"]} grids; static checks passed. Delphi IDE validation still required.')
