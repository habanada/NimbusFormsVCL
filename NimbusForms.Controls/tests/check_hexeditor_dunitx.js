const fs = require('fs');
const path = require('path');
const root = fs.realpathSync(path.resolve(__dirname, '../..'));
if (root.toLowerCase() !== 'e:\\projects\\nimbusforms') throw Error('Unexpected workspace');
function read(file) {
  const real = fs.realpathSync(file);
  if (!real.startsWith(root + path.sep)) throw Error('Outside workspace');
  const source = fs.readFileSync(real, 'utf8');
  if (source.charCodeAt(0) === 0xfeff || /(?<!\r)\n/.test(source)) throw Error('Pascal format: ' + file);
  return source;
}
const names = ['Support', 'DocumentTests', 'PersistenceTests', 'EditorTests'];
const units = new Map();
for (const name of names) {
  const unit = 'NimbusHexEditor.DUnitX.' + name;
  const file = path.join(__dirname, unit + '.pas');
  const source = read(file);
  if (!source.startsWith('unit ' + unit + ';')) throw Error('Unit name mismatch');
  units.set(unit.toLowerCase(), file);
}
const product = path.join(root, 'NimbusForms.HexEditor', 'src');
for (const entry of fs.readdirSync(product, {withFileTypes: true})) {
  if (entry.isFile() && entry.name.endsWith('.pas')) units.set(entry.name.slice(0, -4).toLowerCase(), path.join(product, entry.name));
}
let fixtures = 0, cases = 0, methods = 0;
for (const name of names) {
  const source = read(path.join(__dirname, 'NimbusHexEditor.DUnitX.' + name + '.pas'));
  const header = source.split(/^implementation\b/m)[0];
  for (const block of source.matchAll(/^  (\w+)\s*=\s*(?:class(?:\([^\r\n]+\))?|record)\s*\r?\n([\s\S]*?)^  end;/gm)) {
    for (const method of block[2].matchAll(/\b(?:procedure|function|constructor|destructor)\s+(\w+)\b/g)) {
      const pattern = new RegExp('^(?:procedure|function|constructor|destructor) ' + block[1] + '\\.' + method[1] + '\\b', 'gm');
      if ([...source.matchAll(pattern)].length !== 1) throw Error('Missing/duplicate body: ' + block[1] + '.' + method[1]);
    }
  }
  if (header.includes('[TestFixture]')) {
    fixtures++;
    const tests = [...header.matchAll(/\[Test\]((?:\s*\[[^\]\r\n]+\])*)\s*procedure\s+(\w+)/g)];
    let count = 0;
    for (const test of tests) count += Math.max(1, [...test[1].matchAll(/\[TestCase\(/g)].length);
    if (!source.includes('TDUnitX.RegisterTestFixture(')) throw Error('Fixture not registered: ' + name);
    methods += tests.length; cases += count;
    console.log(name + ': ' + tests.length + ' test methods, ' + count + ' cases');
  }
  const code = source.replace(/'(?:''|[^'])*'|\/\/[^\r\n]*|\{[^}]*\}|\(\*[\s\S]*?\*\)/g, ' ');
  for (const block of code.matchAll(/\buses\s+([\s\S]*?);/gi)) {
    for (const item of block[1].split(',')) {
      const unit = item.trim().match(/^[\w.]+/)?.[0];
      if (/^Nimbus(?:Forms\.HexEditor|HexEditor\.DUnitX)\./.test(unit || '') && !units.has(unit.toLowerCase())) throw Error('Unresolved unit ' + unit);
    }
  }
}
const runner = read(path.join(__dirname, 'NimbusHexEditorDUnitXTests.dpr'));
const project = read(path.join(__dirname, 'NimbusHexEditorDUnitXTests.dproj'));
if (!project.includes('<MainSource>NimbusHexEditorDUnitXTests.dpr</MainSource>')) throw Error('IDE entry point');
for (const name of names) if (!project.includes('NimbusHexEditor.DUnitX.' + name + '.pas')) throw Error('IDE fixture dependency ' + name);
if (!project.includes('<DCC_ExeOutput>..\\build\\hexeditor-dunitx\\$(Platform)</DCC_ExeOutput>')) throw Error('IDE output path');
if (!runner.startsWith('program NimbusHexEditorDUnitXTests;') || !runner.includes('{$STRONGLINKTYPES ON}')) throw Error('Runner setup');
for (const name of names) if (!runner.includes('NimbusHexEditor.DUnitX.' + name)) throw Error('Runner dependency ' + name);
if (fixtures !== 3 || cases < 50) throw Error('Unexpected fixture coverage');
console.log(`${fixtures} fixtures, ${methods} test methods, ${cases} cases; 16000 document edits and 6000 editor/history steps configured.`);
console.log('Static source and dependency checks only. Delphi compilation and DUnitX execution are separate checks.');
