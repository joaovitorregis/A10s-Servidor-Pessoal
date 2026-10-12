'use strict';
const {test}=require('node:test');const assert=require('node:assert/strict');
const {integrationStatus,reachable}=require('../panel/integrations.cjs');
const net=require('node:net');
test('integration status probes only fixed services and never claims paired remote control',async()=>{
  const calls=[];const s=await integrationStatus('127.0.0.1','a10s:8787',async(host,port)=>{calls.push([host,port]);return port===3923;});
  assert.deepEqual(calls,[['127.0.0.1',3923]]);
  assert.deepEqual(s.files,{reachable:true,url:'http://a10s:3923/'});assert.deepEqual(s.control,{mode:'notebook',requiresPairing:true});
  assert.equal(JSON.stringify(s).includes('password'),false);
});
test('TCP probe closes after success and reports unreachable listeners',async()=>{
  const server=net.createServer(socket=>socket.end());await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  const port=server.address().port;assert.equal(await reachable('127.0.0.1',port),true);
  await new Promise(resolve=>server.close(resolve));assert.equal(await reachable('127.0.0.1',port),false);
});
