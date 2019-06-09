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
	//timeout: 500,
};

//https://stackoverflow.com/questions/8381198/catching-econnrefused-in-node-js-with-http-request

function httpGet(options) {
	return new Promise(((resolve, reject) => {
		const request = https.request(options, (response) => {
			response.setEncoding('utf8');
			let returnData = '';

			if (response.statusCode < 200 || response.statusCode >= 300) {
				var error = new Error(`${response.statusCode}: ${response.req.getHeader('host')} ${response.req.path} blash`);
                                error.code = response.statusCode;
                                error.message = "LIRC do server returned unsuccesful HTTP response";
                                return reject(error);
			}

			response.on('data', (chunk) => {
				returnData += chunk;
			});

			response.on('end', () => {
				return resolve(JSON.parse(returnData));
			});


			response.on('error', (error) => {
				return reject(error);
			});

		});
		// use its "timeout" event to abort the request
		request.on('socket', function(socket) { 
			socket.setTimeout(5000, function () {   // set short timeout so discovery fails fast
				   var e = new Error ('Timeout connecting to ' + options.host );
				   e.name = 'timeout';
				   console.log(`in httpGet: request.on socket: ${JSON.stringify(e)}`);
				   request.abort();    // kill socket
				   return reject(e);
			});
			socket.on('error', function (err) { // this catches ECONNREFUSED events
				var currdatetime = new Date().getTime();
				console.log(`${currdatetime} in httpGet: in socket.on error: ${JSON.stringify(err)}`);
				request.abort();    // kill socket
				return reject(err);
			});
		}); // handle connection events and errors

		request.on('error', function (e) {  // happens when we abort
			var currdatetime = new Date().getTime();
			console.log(`${currdatetime} in httpget: in request.on error: ${JSON.stringify(e)}`);
			return reject(e);
		});
		request.end();
	}));
}

async function doHttpGet(options) {
	let outputSpeech = "got here";

	await httpGet(options).then(response => {
		console.log(`doHttpGet: response: ${JSON.stringify(response)}`);
		if (response.status !== 'success') {
			outputSpeech = `Pairing was not successful. The server-side application returned message ${response.message}`;
		} else {
			outputSpeech = 'The server-side LIRC Do application has been paired successfully. You should now restart the server-side LIRC Do application in non-pairing mode.';
		}
	})
	.catch(error => {
                var error_string=JSON.stringify(error);
                console.log(`in .catch: error= ${error_string}`);
		outputSpeech = `Sorry, there was an unkown problem performing the requested action. Please verify LIRC do service I. P. address, port number, and pin number are correct. Also verify the LIRC do server is running in pairing mode then try again`;
		if (error_string.match(/ECONNREFUSED/)) {
			outputSpeech = `Sorry, the connection to the LIRC do server was refused. The most likely reasons for this is that the LIRC do server is not running, or that your home router is not forwarding incoming connections to the correct server and port, or that the LIRC do service is listening on a different address or port number then request. Please verify the LIRC do service is running and that the service is listening on the expected address and port number then try again.`;
		}
		// handle the special case where the LIRC Do service was probably not started in pairing mode
                else if (error_string.match(/302/)) {
			outputSpeech = `Sorry, the pairing request failed. The most likely reason is that the LIRC do service is not running in pairing mode. Please restart the LIRC do server in pairing mode, if needed, and then try again.`;
                }
		else if (error_string.match(/timeout/) || error_string.match(/ECONNRESET/)) {
			outputSpeech = 'Sorry, the connection to the LIRC do server timed out. Please verify the requested LIRC do service I. P. address, port number, and pin number are correct, then try again';
                }		
	});

	console.log(outputSpeech);
}

doHttpGet(theOptions);
console.log("after doHttpGet()");

//https.request(options, function(res) {
//    res.pipe(process.stdout);
//}).end();

