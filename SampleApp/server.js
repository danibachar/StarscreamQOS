// server.js
 
const WebSocket = require('ws');

function serverPing() {
	console.log("serverPing")
}

function clientPing() {
	console.log("clientPing")
}

const pingData = new Array(125).join("c") // Maximal mping msg size for ws library (npm package limitation probably due to bandwidth consumption)

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', function connection(client) {

	// Configure Server
	client.on('message', function incoming(message) {
		console.log('received: %s', message);
	});

  	client.on('pong', function pong(data) {
		console.log("pong", Buffer.byteLength(data))
		client.isAlive = true;
	});

	// client.on('ping', function ping(data) {
	// 	console.log("client ping", Buffer.byteLength(data))
	// 	client.isAlive = true;
	// 	client.pong(pingData, clientPing)
	// });

  	client.send('something');
});



// setInterval(function ping() {
//   wss.clients.forEach(function each(client) {
//   	console.log("ping", client._isServer)
//   	// console.log("ping 2.2", ws.isAlive)
//    //  if (ws.isAlive === false) && (ws.isServer) return ws.terminate();
//    //  console.log("ping 3")
//     // ws.isAlive = false;

//     if (client === wss) { return; }
//     if (client.isAlive === false) { return client.terminate(); }
//     client.isAlive = false;
//     console.log("ping send", client.isAlive)
//     client.ping(pingData, serverPing);
//   });
// }, 5000);



// const WebSocket = require('ws');



// function heartbeat() {
// 	console.log("heartbeat")
//   	this.isAlive = true;
// }

// const wss = new WebSocket.Server({ port: 8080 });

// console.log("new server")

// wss.on('connection', function connection(ws) {
// 	console.log("connection register pong")
//   	ws.isAlive = true;	
//   	ws.on('pong', heartbeat);
// });

// const interval = setInterval(function ping() {
//   wss.clients.forEach(function each(ws) {
//   	console.log("ping 1")
//     if (ws.isAlive === false) return ws.terminate();
//     console.log("ping 2")
//     ws.isAlive = false;
//     ws.ping(noop);
//   });
// }, 10000);

// wss.on('close', function close() {
// 	console.log("close")
//   	clearInterval(interval);
// });

// wss.on('open', function open() {
// 	console.log("open")
// });

// wss.on('message', function message(data) {
// 	console.log("message", data)
// });

// NODE_DEBUG=ws,net,http,fs,tls,module,timers node server.js