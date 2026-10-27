const fs = require('fs');
const path = require('path');
const root = fs.realpathSync(path.resolve(__dirname, '../..'));
if (!fs.existsSync(path.join(root, 'NimbusForms.Controls', 'src')) || !fs.existsSync(path.join(root, 'LICENSE'))) throw Error('Repository root not found');
const src=path.join(root,'NimbusForms.Controls','src');
const files=fs.readdirSync(src).filter(f=>f.includes('CodeEditor')&&f.endsWith('.pas'));
let failed=false;
const declarations=new Set();
for(const file of files) {
  const text=fs.readFileSync(path.join(src,file),'utf8');
  for(const m of text.matchAll(/\b(?:cnm|cnk|cic|cdi|ctc|cha|crb|ccs|csm|cci|cct|cht|cds|csk|csb|cec)\w+/g)) {
    if(text.indexOf('implementation')>m.index && /Types|Services|Actions/.test(file)) declarations.add(m[0]);
  }
}
for(const file of files) {
  const text=fs.readFileSync(path.join(src,file),'utf8');
  const stripped=text.replace(/'(?:''|[^'])*'/g,"''");
  const unitSource=text.replace(/^\uFEFF?\{\r?\n  SPDX-FileCopyrightText:[\s\S]*?\}\r?\n\r?\n/, '');
  if(!unitSource.startsWith('unit '+file.slice(0,-4)+';')) { console.error(file+': unit mismatch/BOM'); failed=true; }
  if(/\bdefault\s+(value|Next)\b/i.test(stripped)) { console.error(file+': invalid default'); failed=true; }
  if(/\bFHidden\b/.test(stripped)) { console.error(file+': undeclared field'); failed=true; }
  for(const m of stripped.matchAll(/\b(?:cnm|cnk|cic|cdi|ctc|cha|crb|ccs|csm|cci|cct|cht|cds|csk|csb|cec)\w+/g))
    if(!declarations.has(m[0])) { console.error(file+': unknown enum '+m[0]); failed=true; }
  const implementations=[...stripped.matchAll(/^(?:class )?(?:procedure|function|constructor|destructor) (\w+)\.(\w+)/gm)].map(m=>m[1]+'.'+m[2]);
  const interfaceText=stripped.split(/\bimplementation\b/i)[0];
  for(const cls of interfaceText.matchAll(/^\s+(\w+)\s*=\s*class(?:\([^\n]+\))?\s*\n([\s\S]*?)^\s+end;/gm)) {
    let methods=false;
    for(const line of cls[2].split(/\r?\n/)) {
      if(/^\s*(?:strict\s+)?(?:private|protected|public|published)\s*$/i.test(line)) methods=false;
      else if(/^\s*(?:(?:class|static)\s+)?(?:procedure|function|constructor|destructor|property)\b/i.test(line)) methods=true;
      else if(methods && /^\s*\w+(?:\s*,\s*\w+)*\s*:\s*[^;]+;\s*$/.test(line)) {
        console.error(file+': field after method/property in '+cls[1]+': '+line.trim()); failed=true;
      }
    }
    for(const method of cls[2].matchAll(/\b(?:procedure|function|constructor|destructor)\s+(\w+)/g)) {
      const name=cls[1]+'.'+method[1];
      if(!implementations.includes(name)) { console.error(file+': missing method body '+name); failed=true; }
    }
  }
  const seen=new Set();
  for(const method of implementations) { if(seen.has(method)&&!['TCustomThemedCodeEditor.FindAll','TCodeCommentStyles.AddKeyword','TCodeDocumentSnapshot.Create'].includes(method)) { console.error(file+': duplicate '+method); failed=true; } seen.add(method); }
  console.log(file+': '+text.split(/\r?\n/).length+' lines; '+implementations.length+' method bodies');
}
if(failed) process.exitCode=1;
else console.log('Static unit/enum/default/field-order/method-body/duplicate checks passed; this is not a Delphi build');
