'use strict';
const {test}=require('node:test');const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');
test('standalone BAT embeds control logic and panel no longer launches a custom protocol',()=>{
  const bat=fs.readFileSync(path.join(__dirname,'../notebook/Controlar_A10s.bat'),'utf8');
  assert.match(bat,/^@echo off/);assert.ok(bat.indexOf('exit /b %errorlevel%')<bat.indexOf('\n# A10S_POWERSHELL'));
  assert.ok(!bat.includes('open-control.ps1'));assert.ok(!bat.includes('tcpip 5555'));assert.match(bat,/getprop ro.serialno/);
  const html=fs.readFileSync(path.join(__dirname,'../panel/public/index.html'),'utf8');
  assert.ok(!html.includes('href="a10s-control:'));assert.ok(!html.includes('remote-detail'));
});
