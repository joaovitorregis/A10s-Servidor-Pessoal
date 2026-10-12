'use strict';
const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const os=require('node:os');
const path=require('node:path');
const {createTelemetry,memoryInfo,cpuTicks,alertsFor}=require('../panel/telemetry.cjs');
test('telemetry distinguishes unavailable memory and ignores guest CPU double counting',()=>{
  assert.equal(memoryInfo('MemTotal: 100 kB').available,false);
  assert.equal(memoryInfo('MemTotal: 100 kB\nMemAvailable: 25 kB').percent,75);
  const exhausted=memoryInfo('MemTotal: 100 kB\nMemAvailable: 0 kB');assert.equal(exhausted.available,true);assert.equal(exhausted.free,0);assert.equal(exhausted.percent,100);
  assert.deepEqual(cpuTicks('cpu 10 20 30 40 5 6 7 8 9 10'),{total:126,idle:45});
  assert.equal(cpuTicks('cpu broken'),null);
});
test('resource alerts never label unknown measurements as zero or claim delivery',()=>{
  const s={storage:{available:false},memory:{available:false},cpu:{available:false},battery:{available:false},executor:{healthy:true},backup:{available:false},delivery:{uncertainCount:2}};
  assert.deepEqual(alertsFor(s).map(a=>a.code),['backup','uncertain']);
  s.storage={available:true,free:10,percent:99};s.battery={available:true,percent:5,temperature:45,charging:false};
  assert.ok(alertsFor(s).some(a=>a.code==='storage'));assert.ok(alertsFor(s).some(a=>a.code==='temperature'));
});
test('collector coalesces requests, preserves private state and persists bounded history',async t=>{
  const root=fs.mkdtempSync(path.join(os.tmpdir(),'rota-telemetry-'));fs.mkdirSync(path.join(root,'runtime'));
  const state=JSON.stringify({deliveries:{x:{status:'uncertain'},y:{status:'sent',confirmedAt:'2026-01-01T00:00:00Z',text:'PRIVATE'}}});
  fs.writeFileSync(path.join(root,'runtime/state.json'),state);fs.writeFileSync(path.join(root,'config.json'),'PRIVATE_CONFIG');
  let calls=0;
  const telemetry=createTelemetry(root,{command:async command=>{calls++;if(command==='termux-battery-status')return {stdout:JSON.stringify({percentage:70,temperature:28,status:'DISCHARGING'})};return {stdout:'down: fixture: 1s'};}});
  t.after(()=>{telemetry.close();fs.rmSync(root,{recursive:true,force:true});});
  const [a,b]=await Promise.all([telemetry.get(),telemetry.get()]);
  assert.equal(a.timestamp,b.timestamp);assert.equal(calls,4);assert.equal(a.history.length,1);
  assert.equal(a.delivery.uncertainCount,1);assert.equal(a.executor.healthy,false);
  assert.equal(a.backup.available,false);assert.equal(a.battery.percent,70);
  assert.ok(!JSON.stringify(a).includes('PRIVATE'));assert.equal(fs.readFileSync(path.join(root,'runtime/state.json'),'utf8'),state);
  assert.equal(fs.readFileSync(path.join(root,'config.json'),'utf8'),'PRIVATE_CONFIG');
  assert.equal(JSON.parse(fs.readFileSync(path.join(root,'runtime/server-metrics.json'),'utf8')).samples.length,1);
});
test('collector recognizes complete manifests larger than one MiB and preserves old uncertain dates',async t=>{
  const root=fs.mkdtempSync(path.join(os.tmpdir(),'rota-manifest-'));fs.mkdirSync(path.join(root,'runtime'));fs.mkdirSync(path.join(root,'backups','snapshot'),{recursive:true});
  const createdAt='2026-10-03T13:04:26Z';
  fs.writeFileSync(path.join(root,'backups','snapshot','snapshot-manifest.json'),JSON.stringify({version:1,createdAt,entries:[{path:'x'.repeat(1100000)}]}));
  const state=JSON.stringify({version:1,deliveries:{'2026-09-20|grupo|manual':{status:'attempting'},'2026-09-22|grupo|manual':{status:'uncertain'}}});
  fs.writeFileSync(path.join(root,'runtime/state.json'),state);
  const telemetry=createTelemetry(root,{clock:()=>Date.parse('2026-10-12T00:00:00Z'),command:async()=>({stdout:'down: fixture: 1s'})});
  t.after(()=>{telemetry.close();fs.rmSync(root,{recursive:true,force:true});});
  const s=await telemetry.get();assert.equal(s.backup.available,true);assert.equal(s.backup.files,1);assert.equal(s.backup.verified,false);
  assert.deepEqual(s.delivery.uncertainDates,['2026-09-20','2026-09-22']);assert.match(s.alerts.find(a=>a.code==='uncertain').text,/20\/09\/2026, 22\/09\/2026/);
  assert.equal(fs.readFileSync(path.join(root,'runtime/state.json'),'utf8'),state);
});
