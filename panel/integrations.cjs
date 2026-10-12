'use strict';
const net=require('node:net');
function reachable(host,port) {
  return new Promise(resolve=>{
    const socket=net.createConnection({host,port});let done=false;
    const finish=result=>{if(done)return;done=true;socket.destroy();resolve(result);};
    socket.setTimeout(1500);socket.once('connect',()=>finish(true));socket.once('error',()=>finish(false));socket.once('timeout',()=>finish(false));
  });
}
async function integrationStatus(host,authority,probe=reachable) {
  const hostname=new URL('http://'+authority).hostname;
  const files=await probe(host,3923);
  return {files:{reachable:files,url:'http://'+hostname+':3923/'},control:{mode:'notebook',requiresPairing:true},timestamp:new Date().toISOString()};
}
module.exports={integrationStatus,reachable};
