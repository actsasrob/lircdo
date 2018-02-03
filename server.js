var fs = require('fs');
const util = require('util')
var http = require('http');
var https = require('https');

// Load environment variables if not in production (NODE_ENV=production)
//if (process.env.NODE_ENV !== 'production') {
  require('dotenv').load();
//}

const PORT = process.env.PORT || 8843;
const APP_FQDN = process.env.APP_FQDN || '127.0.0.1';
const LIRCSCRIPTS_LOCATION = process.env.LIRCSCRIPTS_LOCATION || './lircscripts';
const SESSION_SECRET = process.env.SESSION_SECRET || 'shh its a secret';
if (process.env.LIRCDO_PAGE_SECRET !== 'undefined' && process.env.IRCDO_PAGE_SECRET !== null) {
   const LIRCDO_PAGE_SECRET = process.env.LIRCDO_PAGE_SECRET;
   console.log('info: LIRCDO_PAGE_SECRET is ' + LIRCDO_PAGE_SECRET);
} else {
   console.log('error: LIRCDO_PAGE_SECRET environment variable MUST be set in .env');
   exit(1);
}
const TEST_MODE = process.env.TEST_MODE && /^true$/i.test(process.env.TEST_MODE);
console.log('TEST_MODE=' + TEST_MODE);

const PAIR_MODE = process.env.PAIR_MODE && /^true$/i.test(process.env.PAIR_MODE);
console.log('PAIR_MODE=' + PAIR_MODE);

var privateKey  = fs.readFileSync('sslcert/serverkey.pem', 'utf8');
var certificate = fs.readFileSync('sslcert/servercert.pem', 'utf8');

var credentials = {key: privateKey, cert: certificate};
var options = {
   ca: [fs.readFileSync('sslcert/cacert.pem')],
   cert: fs.readFileSync('sslcert/servercert.pem'),
   key: fs.readFileSync('sslcert/serverkey.pem')
   };

var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var multer = require('multer');
var upload = multer(); 
var session = require('express-session');
var cookieParser = require('cookie-parser');

app.set('view engine', 'pug');
app.set('views','./views');

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true })); 
app.use(upload.array());
app.use(cookieParser());
app.use(session({secret: "Your secret key", cookie: { secure: true }}));

var Users = [];

// Create an admin user which can view protected pages
var adminUser = {id: 'admin', password: process.env.PROTECTED_PAGE_SECRET };
Users.push(adminUser);

// Create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: false })

// Allow use of static objects under 'public' directory
app.use(express.static('public'));

var lirc_catalog = require('./catalog_internal.json') 

//console.log("lirc_catalog: ", lirc_catalog);
//console.log("just intents: ", lirc_catalog.intents);

function lookup_intent_by_name(intentname) {
   console.log('lookup_intent_by_name: intentname=' + intentname);
   var retVal = null;
   var intents = lirc_catalog.intents;
   for (i=0; i < intents.length; i++) {
      //console.log("lookup_intent_by_name: intentname=" + intentname + " " + intents[i].name);
      if (intentname === intents[i].name) {
         return intents[i];
      }   
   }
   return retVal;
}

function lookup_intent(intent, action, component, argument) {
   console.log('lookup_intent: intent=' + intent + " action=" + action + " component=" + component + " argument=" + argument);
   var retVal = null;
   var intents = lirc_catalog.intents;
   var argumenttype = typeof(argument);
   for (i=0; i < intents.length; i++) {
      if (intent.toUpperCase() === intents[i].intent.toUpperCase()) {
         var upperCaseActions = intents[i].action.map(function(value) {
                return value.toUpperCase();
              });
         if (upperCaseActions.indexOf(action.toUpperCase()) > -1) {
            if (!component || !component.length) { // no component specified
               // Check if intent acts as default component
               if (intents[i].default_component) {
                  //console.log('thetype=' + argumenttype + " numargs=" + intents[i].numargs);
                  if (argumenttype === 'string' && argument.length > 0) {
                     if (intents[i].numargs === '1') {
                        return intents[i];
                     }
                  } else {
                      return intents[i];
                  }
               }
            } else {
               var upperCaseComponents = intents[i].component.map(function(value) {
                      return value.toUpperCase();
                   });
               if (upperCaseComponents.indexOf(component.toUpperCase()) > -1) {
                  //console.log('thetype=' + argumenttype + " numargs=" + intents[i].numargs);
                  if (argumenttype === 'string' && argument.length > 0) {
                     if (intents[i].numargs === '1') {
                        return intents[i];
                     }
                  } else {
                      return intents[i];
                  }
               }  
            }
         }
      }
   }
   return retVal;
}

function execute_lirc_script(lircscriptpath, argument) {
   var retVal = '';

   var testcmd = spawnSync('test', ['-f', lircscriptpath ]);
   if (testcmd.status === 0) {
      var lircscript;
      var argument_type = typeof(argument);
      if (argument_type === 'string' && argument.length > 0) {
         lircscript = spawnSync(lircscriptpath, [ argument ]);
         console.log('execute_lirc_script: ' + lircscriptpath + ' ' + argument);
      } else {
         lircscript = spawnSync(lircscriptpath);
      }
      if (lircscript.status === 0){
         retVal = "success";
      } else {
         retVal= "LIRC script non-zero return status";
      }
   } else {
      status="LIRC script not found";
   }
   return retVal;
}

console.log(`env PORT is ${PORT}`);
console.log(`env APP_FQDN is ${APP_FQDN}`);
console.log(`env LIRCSCRIPTS_LOCATION is ${LIRCSCRIPTS_LOCATION}`);

// Execute synchronous shell commands on server
var spawnSync = require('child_process').spawnSync;

function checkSignIn(req, res, next){
   console.log("in checkSignIn()");
   if(req.session.user){
      console.log('checkSignIn: user object exists in session');
      next();     //If session exists, proceed to page
   } else {
      console.log('checkSignIn: user object not in session');
      var err = new Error("Not logged in!");
      next(err);  //Error, trying to access unauthorized page!
   }
}

if (PAIR_MODE) {
   var applicationPin=Math.floor(Math.random() * 1000);
   console.log(`Application pairing pin number is ${applicationPin}`);

   // This responds to a POST request for /pair_action_ask.
   // Meant to be invoked by Alexa Skills Kit lambda function
   //  when pairing this server-side LIRC DO application.
   // Params: pin. Required. Secret shared pin
   app.get('/pair_action_ask', function (req, res) {
      var status = 'success';
      var message = 'action successful';

      var json_response = { status: success, message: message};

      var pin=req.query.pin;

      console.log(`pair_action_ask: received pin=${pin}`);

      if (typeof pin === 'undefined' || pin === null ||
          pin !== applicationPin) {
          // Error.
          res.writeHead(402, {"Content-Type": "application/json"});
          json_reponse.status = 'error';
          json_response.message = 'invalid application pin';
          console.log(`pair_action_ask: error: received invalid pin=${pin}`);
      } else {
          res.writeHead(200, {"Content-Type": "application/json"});
          json_response.fqdn = APP_FQDN;
          json_response.port = PORT;
          json_response.shared_secret = LIRCDO_PAGE_SECRET;
          json_response.ca_cert = options.ca;
          console.log(`pair_action_ask: success: received valid pin=${pin}`);
      }

      var json = JSON.stringify(json_response);
      res.end(json);
      
   })

} else { // START OF NON-PAIR MODE

   app.get('/', checkSignIn, function(req, res){
      console.log("got a GET request for /");
      //res.render('protected_page', {id: req.session.user.id})
      res.render('protected_page', {id: req.session.user.id, lirc_catalog: lirc_catalog})
   });
   
   app.get('/login', function(req, res){
      console.log('got a GET request for /login');
      res.render('login', {message: "Please login with id and password"});
   });
   
   app.post('/login', function(req, res){
      console.log('got POST request for /login: ', Users);
      if(!req.body.id || !req.body.password){
         console.log('app.post /login. user ID or password are missing. render login page again');
         res.render('login', {message: "User ID or password missing!"});
      } else {
         console.log('app.post /login lookup user...');
         Users.filter(function(user){
            if(user.id === req.body.id && user.password === req.body.password){
               console.log('app.post /login. found user ' + user.id + ' with matching password');
               req.session.user = user;
               //res.redirect('/protected_page');
            }
         });
         
         res.redirect('/');
         //console.log('app.post /login. user lookup failed. redirecting to login form');
         //res.render('login', {message: "Invalid credentials!"});
      }
   });
   
   app.get('/logout', function(req, res){
      console.log('got GET request for /logout');
      req.session.destroy(function(){
         console.log("user logged out.")
      });
      res.render('login', {message: "You have been logged out."});
      //res.redirect('/login', {message: "You have been logged out."});
   });
   
   app.use('/', function(err, req, res, next){
      console.log('in app.use /. ' + err);
      //User should be authenticated! Redirect him to log in.
      res.redirect('/login');
   });
   
   // This responds to a POST request for /lircdo_ask. 
   // Meant to be invoked Alexa Skills Kit(sdk)
   // Params: lircComponent. Not required
   // Params: lircAction. Required
   // Params: shared_secret. Required
   app.get('/lircdo_ask', function (req, res) {
      var status = 'success';
      var message = 'action successful';
   
      var lircComponent=req.query.lircComponent;
      var lircAction=req.query.lircAction;
   
      console.log(`lircdo_ask: lircAction=${lircAction} lircComponent=${lircComponent}`);
   
      var shared_secret=req.query.shared_secret;
      if (typeof shared_secret === 'undefined' || shared_secret === null ||
          shared_secret !== LIRCDO_PAGE_SECRET) {
          // Error.
          res.writeHead(402, {"Content-Type": "application/json"});
          status = 'error';
          message = 'invalid shared secret';
      } else {
          res.writeHead(200, {"Content-Type": "application/json"});
      }
    
      var intent = lookup_intent('lircdo', lircAction, lircComponent, '');
      if (intent) {
         console.log('lircdo_ask: found lircscript=' + intent.lircscript);
         if (!TEST_MODE) {
            var msg = execute_lirc_script(intent.lircscript, '');
            if (msg && msg.length > 0) {
               message = msg;
            }
         }
      } else {
         console.log('lircdo_ask: no matching lircscript found');
         message = 'No matching LIRC script found';
      }
   
      var json = JSON.stringify({ 
        status: status, 
        message: message 
      });
      res.end(json);
   })
    
   // This responds to a POST request for /avr_action_ask.
   // Meant to be invoked Alexa Skills Kit(sdk)
   // Params: lircAVDevice. Required
   // Params: lircAVRAction. Required
   // Params: shared_secret. Required
   app.get('/avr_action_ask', function (req, res) {
      var status = 'success';
      var message = 'action successful';
   
      var lircAVDevice=req.query.lircAVDevice;
      var lircAVRAction=req.query.lircAVRAction;
   
      console.log(`avr_action_ask: lircAVRAction=${lircAVRAction} lircAVDevice=${lircAVDevice}`);
   
      var shared_secret=req.query.shared_secret;
      if (typeof shared_secret === 'undefined' || shared_secret === null ||
          shared_secret !== LIRCDO_PAGE_SECRET) {
          // Error.
          res.writeHead(402, {"Content-Type": "application/json"});
          status = 'error';
          message = 'invalid shared secret';
      } else {
          res.writeHead(200, {"Content-Type": "application/json"});
      }
   
      var intent = lookup_intent('avr_action', lircAVRAction, lircAVDevice, '');
      if (intent) {
         console.log('avr_action_ask: found lircscript=' + intent.lircscript);
         if (!TEST_MODE) {
            var msg = execute_lirc_script(intent.lircscript, '');
            if (msg && msg.length > 0) {
               message = msg;
            }
         }
      } else {
         console.log('avr_action_ask: no matching lircscript found');
         message = 'No matching LIRC script found';
      }
   
      var json = JSON.stringify({
        status: status,
        message: message
      });
      res.end(json);
   })
   
   // This responds to a POST request for /channel_action_ask.
   // Meant to be invoked Alexa Skills Kit(sdk)
   // Params: lircComponent. Not Required
   // Params: lircChannelAction. Required
   // Params: lircArgument. Requred
   // Params: shared_secret. Required
   app.get('/channel_action_ask', function (req, res) {
      var status = 'success';
      var message = 'action successful';
   
      var lircComponent=req.query.lircComponent;
      var lircChannelAction=req.query.lircChannelAction;
      var lircArgument=req.query.lircArgument;
   
      console.log(`channel_action_ask: lircChannelAction=${lircChannelAction} lircComponent=${lircComponent} lircArgument=${lircArgument}`);
   
      var shared_secret=req.query.shared_secret;
      if (typeof shared_secret === 'undefined' || shared_secret === null ||
          shared_secret !== LIRCDO_PAGE_SECRET) {
          // Error.
          res.writeHead(402, {"Content-Type": "application/json"});
          status = 'error';
          message = 'invalid shared secret';
      } else {
          res.writeHead(200, {"Content-Type": "application/json"});
      }
   
      var intent = lookup_intent('channel_action', lircChannelAction, lircComponent, lircArgument);
      if (intent) {
         console.log('channel_action_ask: found lircscript=' + intent.lircscript);
         if (!TEST_MODE) {
            var msg = execute_lirc_script(intent.lircscript, lircArgument);
            if (msg && msg.length > 0) {
               message = msg;
            }
         }
      } else {
         console.log('channel_action_ask: no matching lircscript found');
         message = 'No matching LIRC script found';
      }
   
      var json = JSON.stringify({
        status: status,
        message: message
      });
      res.end(json);
   })
   
   // This responds to a POST request for /volume_action_ask.
   // Meant to be invoked Alexa Skills Kit(sdk)
   // Params: lircComponent. Not Required
   // Params: lircVolumeAction. Required
   // Params: lircArgument. Requred
   // Params: shared_secret. Required
   app.get('/volume_action_ask', function (req, res) {
      var status = 'success';
      var message = 'action successful';
   
      var lircComponent=req.query.lircComponent;
      var lircVolumeAction=req.query.lircVolumeAction;
      var lircArgument=req.query.lircArgument;
   
      console.log(`volume_action_ask: lircVolumeAction=${lircVolumeAction} lircComponent=${lircComponent} lircArgument=${lircArgument}`);
   
      var shared_secret=req.query.shared_secret;
      if (typeof shared_secret === 'undefined' || shared_secret === null ||
          shared_secret !== LIRCDO_PAGE_SECRET) {
          // Error.
          res.writeHead(402, {"Content-Type": "application/json"});
          status = 'error';
          message = 'invalid shared secret';
      } else {
          res.writeHead(200, {"Content-Type": "application/json"});
      }
   
      var intent = lookup_intent('volume_action', lircVolumeAction, lircComponent, lircArgument);
      if (intent) {
         console.log('volume_action_ask: found lircscript=' + intent.lircscript);
         if (!TEST_MODE) {
            var msg = execute_lirc_script(intent.lircscript, lircArgument);
            if (msg && msg.length > 0) {
               message = msg;
            }
         }
      } else {
         console.log('volume_ask: no matching lircscript found');
         message = 'No matching LIRC script found';
      }
   
      var json = JSON.stringify({
        status: status,
        message: message
      });
      res.end(json);
   })
   
   
   
   // This responds to a POST request for /lircdo_gui. 
   // Meant to be used by server-side web GUI and not Alexa Skills Kit(sdk)
   app.post('/lircdo_gui', function (req, res) {
      //console.log(util.inspect(child, {showHidden: false, depth: null}))
      var status = "Success";
      var intentname=req.query.intentname;
      var shared_secret=req.query.shared_secret;
      console.log('debug: lircdo_gui POST: intentname=' + intentname + ' shared_secret=' + shared_secret);
      res.writeHeader(200, {"Content-Type": "text/html"});
      res.write("<html><body>");
      if (typeof intentname !== 'undefined' && intentname !== null &&
          typeof shared_secret !== 'undefined' && shared_secret !== null &&
          shared_secret === LIRCDO_PAGE_SECRET){
            var intentobj=lookup_intent_by_name(intentname);
            if (intentobj !== 'undefined' && intentobj !== null) { 
               var lircscriptpath = intentobj.lircscript;
               console.log("Got a POST request for /lircdo_gui intent=" + intentname + "script=" + lircscriptpath);
               var testcmd = spawnSync('test', ['-f', lircscriptpath ]);
               if (testcmd.status === 0) {
                  var lircscript = spawnSync(lircscriptpath);
                  if (lircscript.status === 0){
                     status = "lirc script successful";
                  } else {
                     status = "non-zero return status for lircscript";
                  } 
               } else {
                  status="Error: lircscriptpath " + lircscriptpath + " not found";
               }
            } else {
               status="Error: no intent with name " + intentname + " found"
            } 
      } else {
         var message="Error no 'intentname' or 'shared_secret' param or incorrect shared secret";
         console.log("Got a POST request for /lircdo. " + message);
         status = message;   
      }
      res.write(status);
      res.write('<br>');
      res.write(`   <form action = "https://${APP_FQDN}:${PORT}/" method = "GET">`);
      res.write('      <button type="submit">Back to home page</button>');
      res.write('   </form>');
      res.write(status + "</body></html>");
      res.end();
   })
   
   app.get('/process_get', function (req, res) {
      // Prepare output in JSON format
      response = {
         first_name:req.query.first_name,
         last_name:req.query.last_name
      };
      console.log(response);
      res.end(JSON.stringify(response));
   })
   
   
   app.post('/process_post', urlencodedParser, function (req, res) {
      // Prepare output in JSON format
      response = {
         first_name:req.body.first_name,
         last_name:req.body.last_name
      };
      console.log(response);
      res.end(JSON.stringify(response));
   })
} // END NOT PAIR MODE

//var httpServer = http.createServer(app);
// httpServer.listen(8080);

var httpsServer = https.createServer(options, app);
httpsServer.listen(PORT, function(){
   var host = httpsServer.address().address;
   var port = httpsServer.address().port;

   console.log("App listening at https://%s:%s", host, port)
});


