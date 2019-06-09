var https = require('https');
var fs = require('fs');    

var cacertificate = fs.readFileSync('./sslcert/cacert.pem');
//var cacertificate = fs.readFileSync('./sslcert/fullchain.pem');
var certificate = fs.readFileSync('./sslcert/servercert.pem');

var theOptions = {
	host: 'lirc.example.com',
	port: 8845, 
	path: '/',
	ca: [cacertificate],
	cert: [certificate],
	//rejectUnauthorized: false,
	timeout: 500,
};

//https://stackoverflow.com/questions/8381198/catching-econnrefused-in-node-js-with-http-request
var badNews = function (e) {
	console.log (e.name + ' error: ', e.message);
	res.send({'ok': false, 'msg': e.message});
}; // sends failure messages to log and client  

function httpGet(options) {
	return new Promise(((resolve, reject) => {
		const request = https.request(options, (response) => {
			response.setEncoding('utf8');
			let returnData = '';

			if (response.statusCode < 200 || response.statusCode >= 300) {
				return reject(new Error(`${response.statusCode}: ${response.req.getHeader('host')} ${response.req.path} blash`));
			}

			response.on('data', (chunk) => {
				returnData += chunk;
			});

			response.on('end', () => {
				resolve(JSON.parse(returnData));
			});


			response.on('error', (error) => {
				reject(error);
			});

		});
		// use its "timeout" event to abort the request
		request.on('timeout', () => {
			console.log('in httpGet: in request.on timeout request timed out. aborting request');
			var e = new Error ('Timeout1 connecting to ' + options.host);
			e.name = 'timeout';
			request.abort();
			reject(e);
		});
		request.on('socket', function(socket) { 
			socket.setTimeout(500, function () {   // set short timeout so discovery fails fast
				var e = new Error ('Timeout2 connecting to ' + options.host );
				e.name = 'timeout';
				console.log(`in httpGet: request.on socket: ${JSON.stringify(e)}`);
				//badNews(e);
				request.abort();    // kill socket
				reject(e);
			});
			socket.on('error', function (err) { // this catches ECONNREFUSED events
				var currdatetime = new Date().getTime();
				console.log(`${currdatetime} in httpGet: in socket.on error: ${JSON.stringify(err)}`);
				//badNews(err);
				request.abort();    // kill socket
				reject(err);
			});
		}); // handle connection events and errors

		request.on('error', function (e) {  // happens when we abort
			var currdatetime = new Date().getTime();
			console.log(`${currdatetime} in httpget: in request.on error: ${JSON.stringify(e)}`);
			reject(e);
		});
		request.end();
	}));
}

async function doHttpGet(options) {
	let outputSpeech = "got here";

	try {
		const response = await httpGet(options);

		console.log(`CompletedPairServerIntent.handler: response: ${JSON.stringify(response)}`);
		if (response.status !== 'success') {
			outputSpeech = `Pairing was not successful. The server-side application returned message ${response.message}`;
		} else {
			outputSpeech = 'The server-side LIRC Do application has been paired successfully. You should now restart the server-side LIRC Do application in non-pairing mode.';
			console.log(`CompletedPairServerIntent.handler: after await`);
		}
	} catch (error) {
		outputSpeech = `Sorry, there was a problem performing the requested action. error is ${JSON.stringify(error)}`;
		console.log(`catch error: ${JSON.stringify(error)}`);
		if (error.message.match(/ECONNREFUSED/)) {
			outputSpeech = `received ECONNREFUSED `;
		}
		// handle the special case where the LIRC Do service was probably not started in pairing mode
		else if ((error.name.match(/timeout/) || error.code.match(/ECONNRESET/))) {
			outputSpeech = `Sorry the connection to the LIRC do server timed out. Please try again`;
		} else {
			outputSpeech = `Sorry, there was a problem pairing with the LIRC Do service. Please ensure the LIRC Do service is started in pairing mode and try again`;
		}
	}

	console.log(outputSpeech);

}

doHttpGet(theOptions);
console.log("after doHttpGet()");

//https.request(options, function(res) {
//    res.pipe(process.stdout);
//}).end();
