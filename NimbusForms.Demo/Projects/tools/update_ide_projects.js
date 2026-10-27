const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const root = fs.realpathSync(path.resolve(__dirname, '../../..'));
if (!fs.existsSync(path.join(root, 'NimbusForms.Controls', 'src')) || !fs.existsSync(path.join(root, 'LICENSE'))) throw Error('Repository root not found');
const directory = fs.realpathSync(path.join(root, 'NimbusForms.Demo', 'Projects'));
if (!directory.startsWith(root + path.sep)) throw Error('Linked project directory');
const manifest = JSON.parse(fs.readFileSync(path.join(directory, 'projects.json'), 'utf8'));
const xml = value => value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');
function guid(name) {
  const hash = crypto.createHash('sha256').update('NimbusForms.Demo.' + name).digest('hex').slice(0, 32).toUpperCase();
  return '{' + [hash.slice(0, 8), hash.slice(8, 12), hash.slice(12, 16), hash.slice(16, 20), hash.slice(20)].join('-') + '}';
}
function write(name, text) {
  const file = path.join(directory, name);
  if (fs.existsSync(file) && fs.realpathSync(file) !== file) throw Error('Linked output');
  fs.writeFileSync(file, text.replace(/\r\n|\r|\n/g, '\r\n'), 'utf8');
}
for (const project of manifest.projects) {
  const file = fs.realpathSync(path.join(directory, project.name + '.dpr'));
  if (!file.startsWith(directory + path.sep)) throw Error('Linked source');
  const source = fs.readFileSync(file, 'utf8');
  const references = [...source.matchAll(/\bin '([^']+)'/g)].map(match => match[1]);
  const search = ['..\\..\\NimbusForms.Controls\\src', '..\\..\\NimbusForms.Theming\\src', '..', 'Shared'];
  if (/NimbusForms\.Grid\./.test(source)) search.push('..\\..\\NimbusForms.Grid\\src');
  if (/NimbusForms\.HexEditor\./.test(source)) search.push('..\\..\\NimbusForms.HexEditor\\src', '..\\..\\NativePattern\\src');
  write(project.name + '.dproj', `<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <ProjectGuid>${guid(project.name)}</ProjectGuid>
    <MainSource>${project.name}.dpr</MainSource>
    <Base>True</Base>
    <Config Condition="'$(Config)'==''">Debug</Config>
    <Platform Condition="'$(Platform)'==''">Win32</Platform>
    <ProjectName Condition="'$(ProjectName)'==''">${project.name}</ProjectName>
    <TargetedPlatforms>3</TargetedPlatforms>
    <AppType>Application</AppType>
    <FrameworkType>VCL</FrameworkType>
    <ProjectVersion>20.1</ProjectVersion>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Config)'=='Base' or '$(Base)'!=''">
    <Base>true</Base>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Config)'=='Debug' or '$(Cfg_1)'!=''">
    <Cfg_1>true</Cfg_1>
    <CfgParent>Base</CfgParent>
    <Base>true</Base>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Config)'=='Release' or '$(Cfg_2)'!=''">
    <Cfg_2>true</Cfg_2>
    <CfgParent>Base</CfgParent>
    <Base>true</Base>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Base)'!=''">
    <SanitizedProjectName>${project.name}</SanitizedProjectName>
    <DCC_UnitSearchPath>${xml(search.join(';'))};$(DCC_UnitSearchPath)</DCC_UnitSearchPath>
    <DCC_Namespace>Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;$(DCC_Namespace)</DCC_Namespace>
    <DCC_ExeOutput>..\\..\\bin</DCC_ExeOutput>
    <DCC_DcuOutput>..\\..\\bin\\obj\\$(Platform)\\$(Config)\\${project.name}</DCC_DcuOutput>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Cfg_1)'!=''">
    <DCC_Define>DEBUG;FRAMEWORK_VCL;$(DCC_Define)</DCC_Define>
    <DCC_Optimize>false</DCC_Optimize>
    <DCC_GenerateStackFrames>true</DCC_GenerateStackFrames>
    <DCC_DebugInformation>2</DCC_DebugInformation>
    <DCC_LocalDebugSymbols>true</DCC_LocalDebugSymbols>
    <DCC_RangeChecking>true</DCC_RangeChecking>
    <DCC_IntegerOverflowCheck>true</DCC_IntegerOverflowCheck>
    <BT_BuildType>Debug</BT_BuildType>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Cfg_2)'!=''">
    <DCC_Define>RELEASE;FRAMEWORK_VCL;$(DCC_Define)</DCC_Define>
    <DCC_Optimize>true</DCC_Optimize>
    <DCC_DebugInformation>0</DCC_DebugInformation>
    <DCC_LocalDebugSymbols>false</DCC_LocalDebugSymbols>
    <BT_BuildType>Release</BT_BuildType>
  </PropertyGroup>
  <ItemGroup>
    <DelphiCompile Include="$(MainSource)"><MainSource>MainSource</MainSource></DelphiCompile>
${references.map(reference => '    <DCCReference Include="' + xml(reference) + '"/>').join('\n')}
    <BuildConfiguration Include="Base"><Key>Base</Key></BuildConfiguration>
    <BuildConfiguration Include="Debug"><Key>Cfg_1</Key><CfgParent>Base</CfgParent></BuildConfiguration>
    <BuildConfiguration Include="Release"><Key>Cfg_2</Key><CfgParent>Base</CfgParent></BuildConfiguration>
  </ItemGroup>
  <ProjectExtensions>
    <Borland.Personality>Delphi.Personality.12</Borland.Personality>
    <Borland.ProjectType/>
    <BorlandProject>
      <Delphi.Personality><Source><Source Name="MainSource">${project.name}.dpr</Source></Source></Delphi.Personality>
      <Platforms><Platform value="Win32">True</Platform><Platform value="Win64">True</Platform></Platforms>
    </BorlandProject>
    <ProjectFileVersion>12</ProjectFileVersion>
  </ProjectExtensions>
  <Import Project="$(BDS)\\Bin\\CodeGear.Delphi.Targets"/>
</Project>
`);
}
write('NimbusFormsDemos.groupproj', `<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup><ProjectGuid>${guid('Group')}</ProjectGuid></PropertyGroup>
  <ItemGroup>
${manifest.projects.map(project => `    <Projects Include="${project.name}.dproj"><Dependencies/></Projects>`).join('\n')}
  </ItemGroup>
  <ProjectExtensions>
    <Borland.Personality>Default.Personality.12</Borland.Personality>
    <Borland.ProjectType/>
    <BorlandProject><Default.Personality/></BorlandProject>
  </ProjectExtensions>
${manifest.projects.map(project => ['Build', 'Clean', 'Make'].map(target => `  <Target Name="${project.name}${target === 'Build' ? '' : ':' + target}"><MSBuild Projects="${project.name}.dproj" Targets="${target}"/></Target>`).join('\n')).join('\n')}
${['Build', 'Clean', 'Make'].map(target => `  <Target Name="${target}"><CallTarget Targets="${manifest.projects.map(project => project.name + (target === 'Build' ? '' : ':' + target)).join(';')}"/></Target>`).join('\n')}
  <Import Project="$(BDS)\\Bin\\CodeGear.Group.Targets" Condition="Exists('$(BDS)\\Bin\\CodeGear.Group.Targets')"/>
</Project>
`);
console.log(`Generated ${manifest.projects.length} IDE projects and NimbusFormsDemos.groupproj with relative search and bin output paths.`);
