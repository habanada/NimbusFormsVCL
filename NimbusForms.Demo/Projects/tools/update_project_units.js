const fs = require('fs');
const path = require('path');
const root = fs.realpathSync(path.resolve(__dirname, '../../..'));
if (!fs.existsSync(path.join(root, 'NimbusForms.Controls', 'src')) || !fs.existsSync(path.join(root, 'LICENSE'))) throw Error('Repository root not found');
const demo = path.join(root, 'NimbusForms.Demo');
const projects = path.join(demo, 'Projects');
function read(file) {
  const resolved = fs.realpathSync(file);
  if (!resolved.startsWith(root + path.sep) || /hexeditor/i.test(resolved)) throw Error('Forbidden source read: ' + file);
  return fs.readFileSync(resolved, 'utf8');
}
function write(file, source) {
  if (fs.realpathSync(path.dirname(file)) !== projects) throw Error('Invalid output');
  if (fs.existsSync(file) && fs.realpathSync(file) !== file) throw Error('Linked output');
  fs.writeFileSync(file, source.replace(/\r\n|\r|\n/g, '\r\n'), 'utf8');
}
function usesOf(source) {
  const code = source.replace(/'(?:''|[^'])*'|\/\/[^\r\n]*|\{[^}]*\}|\(\*[\s\S]*?\*\)/g, ' ');
  return [...code.matchAll(/\buses\s+([\s\S]*?);/gi)].flatMap(match =>
    match[1].split(',').map(item => item.trim().match(/^[\w.]+/)?.[0]).filter(Boolean));
}
const program = read(path.join(demo, 'NimbusFormsDemo.dpr'));
const originalUses = program.match(/\buses\s+([\s\S]*?);/i)[1];
const entries = [...originalUses.matchAll(/^\s*([\w.]+)(?:\s+in\s+'([^']+)')?\s*,?\s*$/gm)]
  .map(match => ({name: match[1], file: match[2] ? path.resolve(demo, match[2]) : null}));
const map = new Map(entries.map(entry => [entry.name.toLowerCase(), entry]));
const platform = [...entries.filter(entry => !entry.file).map(entry => entry.name), 'System.UITypes', 'System.Actions'];
for (const directory of ['NimbusForms.Controls/src', 'NimbusForms.Theming/src', 'NimbusForms.Grid/src', 'NativePattern/src', 'NimbusForms.Demo', 'NimbusForms.Demo/Projects/Shared']) {
  const resolved = fs.realpathSync(path.join(root, directory));
  if (!resolved.startsWith(root + path.sep)) throw Error('Linked source directory');
  for (const name of fs.readdirSync(resolved).sort()) {
    if (!name.endsWith('.pas') || /hexeditor/i.test(name)) continue;
    const unit = name.slice(0, -4);
    if (!map.has(unit.toLowerCase())) map.set(unit.toLowerCase(), {name: unit, file: path.join(resolved, name)});
  }
}
const manifest = JSON.parse(read(path.join(projects, 'projects.json')));
let dependencyCount = 0;
for (const project of manifest.projects) {
  const seen = new Set();
  function visit(name) {
    const key = name.toLowerCase();
    if (seen.has(key)) return;
    seen.add(key);
    const item = map.get(key);
    if (!item) {
      if (/^(NimbusForms|NativePattern)\./i.test(name)) throw Error('Unresolved project unit: ' + name);
      return;
    }
    if (/hexeditor/i.test(item.file || '')) {
      for (const entry of entries) if (/hexeditor|nativepattern/i.test(entry.name)) seen.add(entry.name.toLowerCase());
      return;
    }
    if (item.file) for (const dependency of usesOf(read(item.file))) visit(dependency);
  }
  for (const unit of [...project.units, 'Vcl.Forms', 'NimbusForms.Theming.Manager']) visit(unit);
  const units = [...new Map([...platform.map(name => ({name, file: null})), ...map.values()]
    .map(item => [item.name.toLowerCase(), item])).values()].filter(item => seen.has(item.name.toLowerCase()));
  const lines = units.map(item => '  ' + item.name + (item.file ? " in '" + path.relative(projects, item.file) + "'" : ''));
  const source = `program ${project.name};

{$APPTYPE GUI}

uses
${lines.join(',\n')};

resourcestring
  SApplicationTitle = '${project.title.replace(/'/g, "''")}';

var
  Demo: ${project.form};
${project.variables || ''}begin
  Application.Initialize; Application.Title := SApplicationTitle; Application.MainFormOnTaskbar := True;
  Demo := ${project.form}.CreateNew(nil);
  try
${project.setup || ''}    ThemeManager.ApplyCurrent(Demo); Demo.ShowModal;
  finally Demo.Free; end;
end.
`;
  write(path.join(projects, project.name + '.dpr'), source);
  dependencyCount += units.filter(item => item.file).length;
}
console.log(`Generated ${manifest.projects.length} DPR projects with ${dependencyCount} resolved source references, including implementation uses.`);
