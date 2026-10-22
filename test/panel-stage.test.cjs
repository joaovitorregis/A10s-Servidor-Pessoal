'use strict';
const test=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),os=require('node:os'),path=require('node:path'),vm=require('node:vm');
const {spawnSync}=require('node:child_process');
const root=path.resolve(__dirname,'..');

test('public Install uploads every installer candidate before isolated staged tests', {skip:process.platform!=='win32',timeout:120000},t=>{
  const stage=fs.mkdtempSync(path.join(os.tmpdir(),'rota-panel-stage-'));
  try {
    // Run the real PowerShell entry point; only external boundaries are replaced.
    const upload=spawnSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(__dirname,'helpers/panel-stage.ps1'),'-Repository',root,'-Stage',stage],{encoding:'utf8',timeout:30000});
    assert.equal(upload.status,0,upload.stdout+upload.stderr);
    const installer=fs.readFileSync(path.join(stage,'panel/install.cjs'),'utf8');
    // Read the installer's complete inventory without executing the installer.
    const inventory=installer.slice(installer.indexOf('const files ='),installer.indexOf('const protectedFiles ='));
    const files=vm.runInNewContext(inventory+'; files;');
    const missing=files.filter(file=>!fs.existsSync(path.join(stage,file)));
    assert.deepEqual(Array.from(missing),[],'Incomplete staging: '+missing.join(', '));
    // The SSH double reproduces preparation copies from local fixtures, never live data.
    fs.symlinkSync(path.join(root,'socket/node_modules'),path.join(stage,'socket/node_modules'),'junction');
    const tests=files.filter(file=>/\.test\.(cjs|mjs)$/.test(file));
    const childEnv={...process.env};
    delete childEnv.NODE_TEST_CONTEXT;
    const result=spawnSync(process.execPath,['--test',...tests],{cwd:stage,encoding:'utf8',timeout:90000,env:childEnv});
    assert.equal(result.status,0,result.stdout+result.stderr);
    t.diagnostic('Staged installer candidates: '+files.length+'; '+result.stdout.split(/\r?\n/).filter(line=>/^(?:ℹ|#) (?:tests|pass|fail|skipped) /.test(line)).join('; '));
  } finally { fs.rmSync(stage,{recursive:true,force:true}); }
});
