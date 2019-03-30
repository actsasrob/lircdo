var https = require('https');
var fs = require('fs');    

//var cacertificate = fs.readFileSync('./sslcert/cacert.pem');
var cacertificate = fs.readFileSync('./sslcert/fullchain.pem');
var certificate = fs.readFileSync('./sslcert/servercert.pem');

var options = {
    host: 'lirc.example.com',
    port: 8844, 
    path: '/',
    ca: [cacertificate],
    cert: [certificate],
    //rejectUnauthorized: false
};
https.request(options, function(res) {
    res.pipe(process.stdout);
}).end();
