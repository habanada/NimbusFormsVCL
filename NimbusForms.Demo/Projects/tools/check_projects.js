const fs = require('fs');
const path = require('path');
const root = fs.realpathSync(path.resolve(__dirname,'../../..'));
if (!fs.existsSync(path.join(root, 'NimbusForms.Controls', 'src')) || !fs.existsSync(path.join(root, 'LICENSE'))) throw Error('Repository root not found');
const projects = path.join(root,'NimbusForms.Demo','Projects');
const shared = path.join(projects,'Shared');
function read(file) {
  const resolved = fs.realpathSync(file);
  if (!resolved.startsWith(root + path.sep) || /hexeditor/i.test(path.relative(root,resolved)) && !resolved.startsWith(projects + path.sep)) throw Error('Forbidden source read');
  return fs.readFileSync(resolved,'utf8');
}
const manifest = JSON.parse(read(path.join(projects,'projects.json')));
const modules = new Map();
let methods = 0;
for (const file of fs.readdirSync(shared).filter(f=>f.endsWith('.pas'))) {
  const text = read(path.join(shared,file));
  if (/(?<!\r)\n/.test(text)) throw Error('Bare LF: '+file);
  const unitSource = text.replace(/^\uFEFF?\{\r?\n  SPDX-FileCopyrightText:[\s\S]*?\}\r?\n\r?\n/, '');
  if (!unitSource.startsWith('unit '+file.slice(0,-4)+';')) throw Error('Unit mismatch: '+file);
  const header = text.split(/^implementation\b/m)[0];
  const bodies = [...text.matchAll(/^(?:procedure|function|constructor|destructor)\s+(\w+)\.(\w+)/gm)].map(m=>m[1]+'.'+m[2]);
  for (const cls of header.matchAll(/^  (\w+)\s*=\s*class(?:\([^\r\n]+\))?\s*\r?\n([\s\S]*?)^  end;/gm)) {
    for (const method of cls[2].matchAll(/^\s+(?:procedure|function|constructor|destructor)\s+(\w+)/gm)) {
      const name = cls[1]+'.'+method[1];
      if (bodies.filter(body=>body===name).length !== 1) throw Error('Missing/duplicate body: '+name);
      methods++;
    }
  }
  const imports = [...header.matchAll(/^uses\s+([\s\S]*?);/gm)].flatMap(m=>m[1].split(',').map(s=>s.trim()));
  modules.set(file.slice(0,-4),imports.filter(name=>name.startsWith('NimbusForms.Demo.')));
  if (/\b(?:TPanel|TLabel|TButton|TEdit|TListBox|TComboBox|TTreeView|TListView|TPageControl)\.Create\(/.test(text)) throw Error('Native UI construction in '+file);
}
const visiting = new Set(), visited = new Set();
function visit(name) {
  if (visiting.has(name)) throw Error('Demo unit cycle: '+name);
  if (visited.has(name) || !modules.has(name)) return;
  visiting.add(name); for (const child of modules.get(name)) visit(child); visiting.delete(name); visited.add(name);
}
for (const name of modules.keys()) visit(name);
let resolvedDependencies = 0;
for (const project of manifest.projects) {
  const source = read(path.join(projects,project.name+'.dpr'));
  if (/(?<!\r)\n/.test(source) || !source.startsWith('program '+project.name+';')) throw Error('Program format: '+project.name);
  if (!source.includes('ThemeManager.ApplyCurrent(Demo)')) throw Error('Missing theme application');
  if (project.name.startsWith('NimbusCodeEditor') && /NimbusForms\.(HexEditor|Grid)\./.test(source)) throw Error('Unrelated subsystem dependency in '+project.name);
  const references = new Map();
  for (const unit of source.matchAll(/\b([\w.]+) in '([^']+)'/g)) {
    const target = path.resolve(projects,unit[2]);
    if (!target.startsWith(root+path.sep)) throw Error('Unit outside workspace');
    if (!/hexeditor/i.test(target) && !fs.existsSync(target)) throw Error('Missing unit file: '+target);
    if (references.has(unit[1].toLowerCase())) throw Error('Duplicate unit reference');
    references.set(unit[1].toLowerCase(), target);
  }
  for (const [name, file] of references) {
    if (/hexeditor/i.test(file)) continue;
    const code = read(file).replace(/'(?:''|[^'])*'|\/\/[^\r\n]*|\{[^}]*\}|\(\*[\s\S]*?\*\)/g, ' ');
    for (const block of code.matchAll(/\buses\s+([\s\S]*?);/gi)) {
      for (const item of block[1].split(',')) {
        const dependency = item.trim().match(/^[\w.]+/)?.[0];
        if (!/^(NimbusForms|NativePattern)\./i.test(dependency || '')) continue;
        if (!references.has(dependency.toLowerCase())) throw Error(`${project.name}: unresolved ${dependency} used by ${name}`);
        resolvedDependencies++;
      }
    }
  }
  const ide = read(path.join(projects, project.name+'.dproj'));
  if (/(?<!\r)\n/.test(ide)) throw Error('Bare LF in IDE project');
  if (!ide.includes('<MainSource>'+project.name+'.dpr</MainSource>')) throw Error('Wrong IDE entry point');
  if (!ide.includes('<DCC_ExeOutput>..\\..\\bin</DCC_ExeOutput>')) throw Error('Wrong EXE output');
  if (!ide.includes('..\\..\\NimbusForms.Controls\\src;..\\..\\NimbusForms.Theming\\src;..;Shared;')) throw Error('Missing common search paths');
  for (const target of references.values()) if (!ide.includes('Include="'+path.relative(projects,target)+'"')) throw Error('Missing IDE unit reference');
}
const group = read(path.join(projects,'NimbusFormsDemos.groupproj'));
for (const project of manifest.projects) if (!group.includes('<Projects Include="'+project.name+'.dproj">')) throw Error('Missing group project');
const registrationPath = path.join(root,'NimbusForms.Controls','packages');
const registration = JSON.parse(read(path.join(registrationPath,'registered-components.json')));
const registerSource = read(path.join(registrationPath,'NimbusForms.Design.Register.pas'));
if (new Set(registration.map(entry=>entry.name)).size !== registration.length) throw Error('Duplicate component registration');
for (const entry of registration) if (!registerSource.includes(entry.name)) throw Error('Missing registration '+entry.name);
for (const file of ['NimbusFormsRuntime.dpk','NimbusFormsDesign.dpk','NimbusForms.Design.Register.pas']) {
  const source = read(path.join(registrationPath,file));
  if (/(?<!\r)\n/.test(source)) throw Error('Bare LF: '+file);
  const units = [...source.matchAll(/^\s*([\w.]+) in '([^']+)'/gm)];
  if (new Set(units.map(unit=>unit[1])).size !== units.length) throw Error('Duplicate package unit: '+file);
  for (const unit of units) {
    const target = path.resolve(registrationPath,unit[2]);
    if (!target.startsWith(root+path.sep)) throw Error('Package unit outside workspace');
    if (!/hexeditor/i.test(target) && !fs.existsSync(target)) throw Error('Missing package unit: '+target);
  }
}
console.log(`${manifest.projects.length} standalone DPRs, ${modules.size} shared units, ${methods} declared class methods verified.`);
console.log(`${registration.length} component registrations; no demo unit cycles or native UI constructors in shared demo units.`);
console.log(`${resolvedDependencies} project-unit dependency edges resolved; nine IDE projects, search paths, output paths and project group verified.`);
console.log('Source checks only; Delphi compilation and GUI behavior remain separate checks.');
