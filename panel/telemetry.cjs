'use strict';
// Read-only probes. No shell strings, external traffic or service mutations.
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const net = require('node:net');
const {execFile} = require('node:child_process');
const {promisify} = require('node:util');
const exec = promisify(execFile);
const {executorHealthy} = require('../src/health.cjs');
const {tailJson} = require('./model.cjs');
const missing = reason => ({available:false, reason});
const value = data => ({available:true,...data});
async function read(file, max=65536) {
  const handle=await fs.open(file,'r');
  try { const buffer=Buffer.alloc(max); const {bytesRead}=await handle.read(buffer,0,max,0); return buffer.subarray(0,bytesRead).toString('utf8'); }
  finally { await handle.close(); }
}
function memoryInfo(text) {
  const get=name=>Number(text.match(new RegExp('^'+name+':\\s+(\\d+) kB','m'))?.[1])*1024;
  const total=get('MemTotal'), available=get('MemAvailable');
  return total>0 && available>=0 && available<=total ? value({total,available,used:total-available,percent:100*(total-available)/total}) : missing('Memória disponível não informada pelo sistema.');
}
function cpuTicks(text) {
  const fields=text.match(/^cpu\s+(.+)$/m)?.[1].trim().split(/\s+/).map(Number);
  if(!fields || fields.length<4 || fields.some(n=>!Number.isFinite(n)||n<0)) return null;
  return {total:fields.slice(0,8).reduce((a,b)=>a+b,0),idle:fields[3]+(fields[4]||0)};
}
function alertsFor(s) {
  const alerts=[];
  const add=(code,level,text)=>alerts.push({code,level,text});
  if(s.storage.available && (s.storage.free<1024**3 || s.storage.percent>=90)) add('storage','critical','Pouco espaço livre. Revise logs e backups antes de remover arquivos.');
  if(s.memory.available && s.memory.percent>=90) add('memory','warning','Memória disponível baixa.');
  if(s.cpu.available && s.cpu.percent>=90) add('cpu','warning','Uso elevado de CPU nesta amostra.');
  if(s.battery.available && s.battery.percent<=20 && !s.battery.charging) add('battery','warning','Bateria baixa e sem alimentação.');
  if(s.battery.available && s.battery.temperature>=40) add('temperature','warning','Temperatura da bateria elevada. Confira ventilação e carregamento.');
  if(!s.executor.healthy) add('executor','critical','Executor sem sinal de vida saudável.');
  if(!s.backup.available) add('backup','warning','Nenhum snapshot com manifesto encontrado nos diretórios monitorados.');
  else if(s.backup.ageHours>168) add('backup_age','warning','O último snapshot tem mais de sete dias.');
  if(s.delivery.uncertainCount) add('uncertain','warning',s.delivery.uncertainCount+' tentativa(s) sem confirmação no histórico. Confira a conversa antes de repetir.');
  return alerts;
}
function createTelemetry(root,{clock=Date.now,command=exec}={}) {
  let current=null, pending=null, ticks=null, lastOwn=process.cpuUsage(), ownTime=clock(), history=[], stopped=false, persistenceError=false,backupSize=null,backupSizeAt=0;
  const historyPath=path.join(root,'runtime/server-metrics.json');
  const ready=read(historyPath,1024*1024).then(text=>{
    const data=JSON.parse(text);
    if(data.version===1 && Array.isArray(data.samples)) history=data.samples.filter(x=>x && Number.isFinite(Date.parse(x.timestamp)) && Date.parse(x.timestamp)<=clock()).slice(-1440).map(x=>Object.fromEntries(['timestamp','memoryPercent','freeBytes','cpuPercent','batteryPercent','panelRss','panelPid','executorPid'].map(k=>[k,k==='timestamp'?x[k]:Number.isFinite(x[k])&&x[k]>=0?x[k]:null])));
  }).catch(()=>{});
  const probe=async fn=>{try{return await fn();}catch{return missing('Não disponível nesta versão do Android ou sem permissão.');}};
  async function service(name) {
    return probe(async()=>{
      const dir=path.join(root,'runtime/services',name);
      let stdout;
      try { ({stdout}=await command('sv',['status',dir],{timeout:2500,maxBuffer:4096})); }
      catch(error) {if(typeof error.stdout==='string' && error.stdout.startsWith('down:'))stdout=error.stdout;else throw error;}
      const match=stdout.match(/^run: .*: \(pid (\d+)\) (\d+)s/);
      return value({running:!!match,pid:match?Number(match[1]):null,uptime:match?Number(match[2]):null});
    });
  }
  async function backup() {
    let latest=null;
    for(const dir of [path.join(root,'backups'),path.join(root,'../.local/share/rota-recovery')]) {
      const entries=await fs.readdir(dir,{withFileTypes:true}).catch(()=>[]);
      for(const entry of entries.slice(0,200)) {
        if(!entry.isDirectory() || entry.name.startsWith('restored')) continue;
        try {
          const manifest=JSON.parse(await read(path.join(dir,entry.name,'snapshot-manifest.json'),1024*1024));
          const timestamp=Date.parse(manifest.createdAt);
          if(manifest.version===1 && Array.isArray(manifest.entries) && Number.isFinite(timestamp) && timestamp<=clock() && (!latest || timestamp>latest.time)) latest={time:timestamp,name:entry.name,files:manifest.entries.length};
        }catch{}
      }
    }
    return latest ? value({name:latest.name,timestamp:new Date(latest.time).toISOString(),ageHours:(clock()-latest.time)/3600000,files:latest.files,verified:false}) : missing('Nenhum manifesto encontrado. Backups de instalação não são snapshots completos.');
  }
  async function collect() {
    await ready;
    const now=clock();
    const ssh = new Promise(resolve=>{
      const socket=net.createConnection({host:'127.0.0.1',port:8022});
      let finished=false;
      const done=available=>{if(finished)return;finished=true;socket.destroy();resolve({available:true,listening:available});};
      socket.setTimeout(1500,()=>done(false));socket.once('connect',()=>done(true));socket.once('error',()=>done(false));
    });
    const [memory,storage,cpu,load,battery,boot,services,backupInfo,logs,heartbeat,state,sshInfo]=await Promise.all([
      probe(async()=>memoryInfo(await read('/proc/meminfo'))),
      probe(async()=>{const s=await fs.statfs(root);const total=s.blocks*s.bsize,free=s.bavail*s.bsize;return total>0?value({total,free,used:total-s.bfree*s.bsize,percent:100*(s.blocks-s.bfree)/s.blocks}):missing('Capacidade desconhecida.');}),
      probe(async()=>{const next=cpuTicks(await read('/proc/stat'));if(!next)return missing('CPU não informada.');const previous=ticks;ticks=next;if(!previous || next.total<=previous.total)return missing('Aguardando a segunda amostra.');return value({percent:Math.max(0,Math.min(100,100*(1-(next.idle-previous.idle)/(next.total-previous.total))))});}),
      probe(async()=>{const numbers=(await read('/proc/loadavg')).trim().split(/\s+/).slice(0,3).map(Number);return numbers.length===3 && numbers.every(Number.isFinite)?value({values:numbers}):missing('Carga não informada.');}),
      probe(async()=>{const {stdout}=await command('termux-battery-status',[],{timeout:3500,maxBuffer:8192});const b=JSON.parse(stdout);if(!Number.isFinite(b.percentage)||b.percentage<0||b.percentage>100)return missing('Bateria não informada.');return value({percent:b.percentage,temperature:Number.isFinite(b.temperature)?b.temperature:null,charging:['AC','USB','WIRELESS'].includes(b.plugged)||b.status==='CHARGING',status:b.status,health:b.health});}),
      probe(async()=>{const seconds=Number((await read('/proc/uptime')).split(' ')[0]);return Number.isFinite(seconds)&&seconds>=0?value({seconds}):missing('Tempo desde o boot desconhecido.');}),
      Promise.all(['whatsapp','rota-panel'].map(async name=>({name,...await service(name)}))),backup(),
      Promise.all(['runtime/scheduler.log','runtime/recovery.log','runtime/panel-audit.jsonl','socket/runtime/events.jsonl','runtime/automation.jsonl'].map(async name=>({name,bytes:await fs.stat(path.join(root,name)).then(s=>s.size).catch(()=>null)}))),
      read(path.join(root,'runtime/heartbeat.json')).then(JSON.parse).catch(()=>null),
      read(path.join(root,'runtime/state.json'),1024*1024).then(JSON.parse).catch(()=>null),ssh
    ]);
    const own=process.cpuUsage(),elapsed=now-ownTime;
    const panelCpu=elapsed>0?100*((own.user-lastOwn.user)+(own.system-lastOwn.system))/(elapsed*1000):null;
    lastOwn=own;ownTime=now;
    const records=Object.values(state?.deliveries||{});
    const confirmed=records.filter(r=>r && ['sent','server_accepted'].includes(r.status)&&Number.isFinite(Date.parse(r.confirmedAt))).sort((a,b)=>String(b.confirmedAt).localeCompare(String(a.confirmedAt)))[0];
    const age=heartbeat? (now-Date.parse(heartbeat.timestamp))/1000:null;
    const executorService=services.find(s=>s.name==='whatsapp');
    const pid=await read(path.join(root,'runtime/scheduler.lock'),32).then(Number).catch(()=>null);
    let running=false;try {if(Number.isInteger(pid)&&pid>1){process.kill(pid,0);running=true;}}catch{}
    const executor={healthy:executorHealthy({schedulerRunning:running,pid,heartbeat,supervisionStatus:executorService.available?0:1,supervisionPid:executorService.pid,now}),heartbeatAgeSeconds:Number.isFinite(age)&&age>=0?Math.round(age):null};
    const delivery={lastConfirmedAt:confirmed?.confirmedAt||null,uncertainCount:records.filter(r=>r && ['attempting','uncertain'].includes(r.status)).length,stateReadable:state?.version===1 && !!state?.deliveries && typeof state.deliveries==='object' && !Array.isArray(state.deliveries)};
    if(!backupSizeAt || now-backupSizeAt>=300000) {
      backupSize=await probe(async()=>{const {stdout}=await command('du',['-sk',path.join(root,'backups')],{timeout:4000,maxBuffer:4096});const size=Number(stdout.match(/^(\d+)\s/)?.[1])*1024;return Number.isFinite(size)?value({bytes:size}):missing('Tamanho não informado.');});backupSizeAt=now;
    }
    let events=[];try{events=tailJson(path.join(root,'socket/runtime/events.jsonl'),80).filter(e=>Number.isFinite(Date.parse(e.timestamp))).map(e=>({timestamp:e.timestamp,event:typeof e.event==='string'?e.event.slice(0,120):'Evento'}));}catch{}
    const sample={timestamp:new Date(now).toISOString(),memory,storage,cpu,load,battery,boot,services,backup:backupInfo,backupSize,logs,events,executor,delivery,ssh:sshInfo,panel:{uptime:Math.floor(process.uptime()),rss:process.memoryUsage().rss,cpuPercent:panelCpu},system:{platform:process.platform,architecture:process.arch,node:process.version,cores:os.availableParallelism?.()||null},network:missing('Tráfego global não coletado: depende das permissões do Android.')};
    sample.alerts=alertsFor(sample);
    if(!delivery.stateReadable) sample.alerts.push({code:'state',level:'critical',text:'Não foi possível ler o estado dos envios.'});
    history.push({timestamp:sample.timestamp,memoryPercent:memory.available?memory.percent:null,freeBytes:storage.available?storage.free:null,cpuPercent:cpu.available?cpu.percent:null,batteryPercent:battery.available?battery.percent:null,panelRss:sample.panel.rss,panelPid:process.pid,executorPid:executorService.pid});
    history=history.filter(x=>now-Date.parse(x.timestamp)<=86400000).slice(-1440);
    sample.restarts={panel:0,executor:0};
    for(let i=1;i<history.length;i++)for(const kind of ['panel','executor']) {const key=kind+'Pid';if(history[i][key] && history[i-1][key] && history[i][key]!==history[i-1][key])sample.restarts[kind]++;}
    try {const tmp=historyPath+'.tmp';await fs.writeFile(tmp,JSON.stringify({version:1,samples:history}),{mode:0o600});await fs.rename(tmp,historyPath);persistenceError=false;}catch{persistenceError=true;}
    if(persistenceError) sample.alerts.push({code:'history',level:'warning',text:'Histórico de métricas não pôde ser salvo.'});
    current=sample;
    return sample;
  }
  function refresh() { if(stopped)return Promise.resolve(current); if(pending)return pending; pending=collect().finally(()=>pending=null); return pending; }
  const timer=setInterval(()=>refresh().catch(()=>{}),60000);timer.unref();
  return {async get(){if(!current || clock()-Date.parse(current.timestamp)>120000)await refresh();return {...current,history:[...history],intervalSeconds:60};},refresh,close(){stopped=true;clearInterval(timer);}};
}
module.exports={createTelemetry,memoryInfo,cpuTicks,alertsFor};
