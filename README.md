# **L**inux **I**nfrared **R**emote **C**ontrol ([LIRC](http://www.lirc.org/))

lircdo is a "voice first" interface for controlling your home audio/video equipment. There are two components:

1. lircdo Alexa Skill
2. lircdo server/service

## lircdo [Alexa](https://en.wikipedia.org/wiki/Amazon_Echo) Skill 

This component is written in node.js and implements the [AWS](https://aws.amazon.com/what-is-aws/) [lambda](https://aws.amazon.com/lambda/) function that is called by the Amazon Alexa service when you invoke the lircdo skill via your Alexa-enabled device. You invoke the skill by saying something like \*Alexa, open lircdo\*. **NOTE: The lircdo Alexa skill has not yet been published and is not currently available to the public. Hopefully it will be available soon.**

To learn more about this component navigate to to this [link](https://github.com/actsasrob/lircdo_ask)

I recommend you start at the README page for the above link to learn about the lircdo Alexa skill and then navigate back here to learn about the lircdo server/service.

## lircdo server/service 

This component is implemented using a small computer(e.g. Raspberry Pi 3 Model B) residing in your home and running the lircdo service. The lircdo server refers to the physical hardware. The lircdo service refers to the lircdo sofware running on the server. The lircdo server requires additional hardware capable of emitting infrared (IR) signals. The lircdo server/IR emitter combination control your home audio/video (AV) equipment using IR signals. **YOU MUST BUILD THIS COMPONENT YOURSELF USING THE INSTRUCTIONS BELOW!!!**.

You are currently reading the README page for the lircdo server/service component.

The Linux Inrared Remote Control (LIRC) Do service is a Node.js web application that provides actions that can be invoked by the lircdo Alexa Skills Kit lambda function. The lircdo application invokes shell scripts local to the server which emit IR signals using the LIRC service. IR emitter hardware is required.

The lircdo server/service is composed of the following components:
1. lircdo server
2. Infrared Emitter/Receiver
3. The lircdo service
4. [LIRC](http://www.lirc.org/) service
5. LIRC shell scripts
6. catalog_internal.json
7. DNS/Domain name/SSL Cert

The sections below discuss each of the components in more detail including what you have to do to implement that component.

### lircdo server

This component is implemented using a small computer(e.g. Raspberry Pi 3 Model B) residing in your home. You must provide the server and an attached IR emitter.

#### Install Debian Jessie/Raspbian

Highly recommend using Raspbian with Debian Jessie operating system. I found the LIRC libraries under Debian Stretch to be unstable. After reverting back to Debian Jessie I've had no problems with the linux LIRC libraries.) Raspberry Pi Model 3 computers have additional gpio pins not available via Raspberry Pi Model 2 computers. Recommend using a Raspberry Pi Model 3.

##### Download Raspian image
You can find the zip file containing Raspbian using Debian Jessie [here](http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05/)

I use the Rapsbian 2017-07-05 image and all my testing has used this image. Please use this image.

##### Write image to SD Card
I found instructions [here](https://www.raspberrypi.org/documentation/installation/installing-images/) to use etcher to burn images to SD cards.

###### Download etcher from [here](https://www.balena.io/etcher/).

Run etcher and follow the instructions. I have tried a number of approaches to burn images to SD cards with mixed results. So far etcher has consistently worked for me. Thank You to the etcher folks.

### Infrared Emitter/Receiver

First, you don't strictly need an IR receiver to use lircdo. You must populate the /etc/lirc/lircd.conf file containing configuration files that emulate remote controls. Occasionally you can find publically available configuration files. But you may find you need to generate these configuration files yourself by cloning signals from the remote controls in your home. An IR receiver is needed to clone these signals. The lircdo server/service itself does not require an IR receiver.

### lircdo service

Really the lircdo service is composed of two parts. 1) A systemd service running on the lircdo server that makes sure the lircdo Node.js starts at boot time. 2) the lircdo Node.js application. If you care to look, the source code implementing this Node.js application is available via this GitHub project. A shell script is provided to install the lircdo service/application and dependencies.

#### lircdo install script
```wget https://raw.githubusercontent.com/actsasrob/lircdo/nodejsv8/scripts/lircdo_install.sh
chmod u+x lircdo_install.sh
sudo ./lircdo_install.sh
```

### [LIRC](http://www.lirc.org/) service

The LIRC service is componsed of the LIRC library package which exposes an client API for handling the sending/receiving infrared (IR) signals via attached hardware.

### LIRC shell scripts

You must create shell scripts that invoke the LIRC client API to control the AV hardware in your home. Example scripts are provided to help jumpstart this effort.

#### Create the directory where LIRC scripts will reside. The steps below assume this directory is named 'lircscripts' inside the top-level lircdo directory mkdir lircscripts <See section regarding how to create LIRC scripts>

### Create node.js application .env file. This file is read by node.js application at startup to set various required environment variables.
cp env_file_example .env
chmod 600 .env

### catalog_internal.json

File which maps lircdo actions/intents to your custom LIRC shell scripts. A script is provided which generates the catalog_internal.json file by parsing metadata in the lirc shell scripts you create.

Edit .env and update environment variables as needed.
Set PORT to the port the application will listen on. This port must be accessible via internet.
Set APP_FQDN to fully qualified domain name (FQDN) of application. This address must resolve to your application from the internet.
Change value of all variables that end in \_SECRET. For security purposes DO NOT use the default values.
Set LIRCSCRIPTS_LOCATION to location of directory which contains LIRC shell scripts. Must be accessible to lirc user.
Initially set TEST_MODE to false. Set to true to test receiving LIRC actions from alexa lircdo skill without actually executing shell script.

NOTE: After updating .env you must restart the node.js application for changes to take effect.

./generate_json_catalogs.py
<snip>
info: internal catalog written to ./catalog_internal.json

This produces ./catalog_internal.json which is read by the node.js application on startup. This file maps the various HTTPS action callbacks to 0 or 1 LIRC scripts. If a script is found that implements the desired action then it is executed by the node.js application to perform the action (which usually means an IR signal is emitted to control some piece of hardware).

NOTE: Re-run generate_json_catalogs.py anytime changes are made to scripts in the LIRC scripts directory then restart the node.js application.



### DNS/Domain name/SSL Cert

### Pulling It All Together

Recommend you proceed as follows:


### Misc.

#### How to start/restart the lircdo service

After making changes to the .env environment file or after re-generating catalog_internal.json you must restart the lircdo service as follows:
```sudo systemctl restart node-server
````
