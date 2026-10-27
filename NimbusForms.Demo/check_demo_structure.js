const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const demo = fs.realpathSync(__dirname);
const root = fs.realpathSync(path.dirname(demo));
if (!fs.existsSync(path.join(root, 'NimbusForms.Controls', 'src')) || !fs.existsSync(path.join(root, 'LICENSE'))) throw Error('Repository root not found');
function read(relative) {
  const file = fs.realpathSync(path.join(demo, relative));
  if (!file.startsWith(demo + path.sep) || /hexeditor/i.test(file)) throw Error('Invalid source path');
  return fs.readFileSync(file, 'utf8');
}
const hash = text => crypto.createHash('sha256').update(text, 'utf8').digest('hex');
const baseline = JSON.parse(read('demo-refactor-baseline.json'));
const program = read(baseline.source);
const expected = new Map(baseline.includes.map(entry => [entry.path.replaceAll('/', '\\'), entry]));
const seen = new Set();
const expanded = program.replace(/^\{\$I (Sections\\[^}\r\n]+)\}\r\n/gm, (_, include) => {
  const entry = expected.get(include);
  if (!entry || seen.has(include)) throw Error('Unexpected or repeated include: ' + include);
  seen.add(include);
  const text = read(include);
  if (/(?<!\r)\n/.test(text)) throw Error('Bare LF in ' + include);
  if (hash(text) !== entry.sha256) throw Error('Include differs from extraction baseline: ' + include);
  return text;
});
if (seen.size !== expected.size) throw Error('Missing include');
if (hash(expanded) !== baseline.originalSha256 || Buffer.byteLength(expanded, 'utf8') !== baseline.originalBytes) throw Error('Expanded program differs from original');
const headers = [...expanded.matchAll(/^(?:procedure|function|constructor|destructor)\s+([\w.]+)/gm)].length;
if (headers !== baseline.methodHeaders) throw Error('Method header count changed');
console.log(`${seen.size} includes verified; ${headers} method/function headers retained.`);
console.log(`Expanded program is byte-identical to the ${baseline.originalLines}-line original.`);
console.log(`SHA-256: ${baseline.originalSha256}`);
console.log('This verifies mechanical extraction, not Delphi compilation or runtime behavior.');
