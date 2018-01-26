# lircdo
Linux Inrared Remote Control (LIRC) Do. Node.js web application that provides actions that can be invoked by lircdo_ask Alexa Skills Kit lambda function. The lircdo application invokes shell scripts local to the server which emit IR signals using the LIRC service. IR emitter hardware is required.


# Installation

## Debian Jessie

### Upgrade to node.js v4.x
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install nodejs

### Create unprivileged lirc user
sudo adduser lirc
sudo su - lirc
Change directory to where you want lircdo installed
git clone https://github.com/actsasrob/lircdo.git
cd lircdo
npm install

### reate the directory where LIRC scripts will reside. The steps below assume this directory is named 'lircscripts' inside the top-level lircdo directory
mkdir lircscripts
<See section regarding how to create LIRC scripts>

### Create node.js application .env file. This file is read by node.js application at startup to set various required environment variables.
cp env_file_example .env
chmod 600 .env

Edit .env and update environment variables as needed.
Set PORT to the port the application will listen on. This port must be accessible via internet.
Set APP_FQDN to fully qualified domain name (FQDN) of application. This address must resolve to your application from the internet.
Change value of all variables that end in \_SECRET. For security purposes DO NOT use the default values.
Set LIRCSCRIPTS_LOCATION to location of directory which contains LIRC shell scripts. Must be accessible to lirc user.
Initially set TEST_MODE to false. Set to true to test receiving LIRC actions from alexa lircdo skill without actually executing shell script.

NOTE: After updating .env you must restart the node.js application for changes to take effect.

### Generate self-signed cert/key.
Edit openssl/openssl-server.cnf and change DNS.1 to be the FQDN for your application. Add additional DNS aliases as desired by adding additional DNS.N lines.

Execute the openssl/make-all.sh script to create a CA cert/key, server key, server certificate signing request (CSR), and then sign the CSR using CA cert/key to create a self-signed server cert.

cd openssl
./make-all.sh




