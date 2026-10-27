const fs = require('fs');
const path = require('path');
const root = fs.realpathSync(path.resolve(__dirname, '../..'));
function check(ok, message) { if (!ok) throw Error(message); }
function read(relative) {
  check(!/hexeditor/i.test(relative), 'Protected path');
  const full = fs.realpathSync(path.join(root, relative));
  check(full.startsWith(root + path.sep), 'Path outside workspace');
  return fs.readFileSync(full, 'utf8');
}
const unitNames = [
  'NimbusForms.Charts.Financial.Indicators', 'NimbusForms.Charts.Financial.Palette',
  'NimbusForms.Charts.Financial.Business.Types', 'NimbusForms.Charts.Financial.Viewport',
  'NimbusForms.Charts.Financial.Workspace', 'NimbusForms.Charts.Financial.Data',
  'NimbusForms.Charts.Financial.Profiles', 'NimbusForms.Rendering.FinancialBusiness',
  'NimbusForms.Controls.FinancialSettings', 'NimbusForms.Controls.FinancialBusinessChart'
];
const newFiles = unitNames.map(n => 'NimbusForms.Controls/src/' + n + '.pas').concat([
  'NimbusForms.Demo/NimbusForms.Demo.Financial.pas', 'NimbusForms.Controls/tests/NimbusFinancialChecks.pas'
]);
let methods = 0;
for (const file of newFiles) {
  const source = read(file);
  check(!/(?<!\r)\n/.test(source), 'Bare LF: ' + file);
  check(!/\/\/|\{(?!\$)|\(\*/.test(source.replace(/'(?:''|[^'])*'/g, '')), 'Comment in new Pascal: ' + file);
  check(!/\bTODO\b/i.test(source), 'Placeholder: ' + file);
  const bodyStart = source.search(/^implementation\b/m);
  const bodies = source.slice(bodyStart);
  for (const cls of source.matchAll(/^  (\w+)\s*=\s*class(?: sealed)?(?:\([^\r\n]+\))?\s*\r?\n([\s\S]*?)^  end;/gm)) {
    for (const method of cls[2].matchAll(/^\s+(?:class )?(?:procedure|function|constructor|destructor)\s+(\w+)/gm)) {
      const pattern = new RegExp('^(?:class )?(?:procedure|function|constructor|destructor)\\s+' + cls[1] + '\\.' + method[1] + '(?:\\b)', 'mi');
      check(pattern.test(bodies), 'Missing method body: ' + cls[1] + '.' + method[1]);
      methods++;
    }
  }
  const imports = part => [...part.matchAll(/\buses\s+([\s\S]*?);/gi)].flatMap(m => m[1].split(',').map(x => x.trim().toLowerCase()));
  const a = imports(source.slice(0, bodyStart)), b = imports(bodies);
  for (const name of b) check(!a.includes(name), 'Duplicate uses: ' + file + ': ' + name);
}
let edges = 0;
for (const project of ['NimbusForms.Demo/Projects/NimbusCharts.dpr', 'NimbusForms.Demo/NimbusFormsDemo.dpr', 'NimbusForms.Controls/packages/NimbusFormsRuntime.dpk']) {
  const text = read(project), references = new Map();
  for (const entry of text.matchAll(/^\s*([\w.]+)\s+in\s+'([^']+)'/gmi)) {
    const key = entry[1].toLowerCase();
    check(!references.has(key), 'Duplicate unit: ' + project + ': ' + key);
    const file = path.relative(root, path.resolve(root, path.dirname(project), entry[2]));
    if (!/hexeditor/i.test(file)) check(fs.existsSync(path.join(root, file)), 'Missing file: ' + file);
    references.set(key, file);
  }
  for (const name of unitNames) check(references.has(name.toLowerCase()), 'Missing financial unit: ' + name);
  if (project.endsWith('NimbusCharts.dpr')) {
    for (const [name, file] of references) {
      const code = read(file).replace(/'(?:''|[^'])*'|\/\/[^\r\n]*|\{[^}]*\}|\(\*[\s\S]*?\*\)/g, ' ');
      for (const block of code.matchAll(/\buses\s+([\s\S]*?);/gi)) {
        for (const dependency of block[1].split(',').map(x => x.trim())) {
          if (!/^(NimbusForms|NativePattern)\./i.test(dependency)) continue;
          check(references.has(dependency.toLowerCase()), 'Unresolved dependency: ' + name + ': ' + dependency);
          edges++;
        }
      }
    }
  }
}
const theme = read('NimbusFormsC#/Rendering/Charts/Financial/FinancialChartTheme.cs');
const factory = read('NimbusFormsC#/Rendering/Charts/Financial/FinancialChartThemePresetFactory.cs');
function method(source, name) {
  const start = source.search(new RegExp('(?:public|private) static FinancialChartTheme ' + name + '\\(\\)')); check(start >= 0, 'Missing C# palette factory: ' + name);
  const open = source.indexOf('{', start); let depth = 1, end = open + 1;
  for (; end < source.length && depth; end++) { if (source[end] === '{') depth++; else if (source[end] === '}') depth--; }
  return source.slice(open + 1, end - 1);
}
const named = { White: [255,255,255,255], Black: [255,0,0,0], Lime: [255,0,255,0], Red: [255,255,0,0], Yellow: [255,255,255,0], Cyan: [255,0,255,255], Orange: [255,255,165,0], Magenta: [255,255,0,255] };
function color(expression) {
  if (expression.startsWith('Color.FromArgb')) {
    const args = expression.slice(expression.indexOf('(') + 1, -1).split(',').map(x => x.trim());
    if (args.length === 2) return [Number(args[0]), ...color(args[1]).slice(1)];
    const values = args.map(Number); return args.length === 3 ? [255, ...values] : values;
  }
  check(named[expression.slice(6)], 'Unknown C# color: ' + expression); return named[expression.slice(6)];
}
function palette(name) {
  const body = method(name === 'Dark' || name === 'Light' ? theme : factory, 'Create' + name);
  const parent = body.match(/FinancialChartTheme theme = (?:FinancialChartTheme\.)?Create(\w+)\(\)/);
  const values = parent ? { ...palette(parent[1]) } : {};
  for (const m of body.matchAll(/(?:theme\.)?(\w+)\s*=\s*(Color\.(?:FromArgb\([^)]*\)|\w+))/g)) values[m[1]] = color(m[2]);
  return values;
}
const pascal = read('NimbusForms.Controls/src/NimbusForms.Charts.Financial.Palette.pas');
const presets = ['NimbusDark','NimbusLight','TradingDark','TradingBlue','TerminalBlack','OfficeBlue','Nord','Dracula','HighContrast'];
let colors = 0;
for (const name of presets) {
  const original = palette(name.replace(/^Nimbus/, ''));
  const start = pascal.indexOf('    nftp' + name + ':');
  const end = pascal.indexOf('\n    nftp', start + 1);
  const block = pascal.slice(start, end < 0 ? pascal.indexOf('\n  end;', start) : end);
  const actual = new Map([...block.matchAll(/F(\w+) := ThemeColor\(([^)]*)\)/g)].map(m => [m[1], m[2].split(',').map(Number)]));
  check(actual.size === 66 && Object.keys(original).length === 66, 'Palette property coverage: ' + name);
  for (const [key, value] of Object.entries(original)) { check(JSON.stringify(actual.get(key)) === JSON.stringify(value), 'Palette mismatch: ' + name + '.' + key); colors++; }
}
console.log('PASS: ' + methods + ' financial method declarations, ' + edges + ' demo dependency edges, unique project/package units, ' + colors + ' C# ARGB values, CRLF and comment checks.');
console.log('Static source validation only; Delphi compilation and GUI behavior require RAD Studio.');
