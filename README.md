# **L**inux **I**nfrared **R**emote **C**ontrol ([LIRC](http://www.lirc.org/)) **Do**

lircdo is a "voice first" interface for controlling your home audio/video equipment. There are two components:

1. lircdo Alexa Skill
2. lircdo server/service

## lircdo [Alexa](https://en.wikipedia.org/wiki/Amazon_Echo) Skill 

This component is written in node.js and implements the [AWS](https://aws.amazon.com/what-is-aws/) [lambda](https://aws.amazon.com/lambda/) function that is called by the Amazon Alexa service when you invoke the lircdo skill via your Alexa-enabled device. You invoke the skill by saying something like \*Alexa, open lircdo\*. **NOTE: The lircdo Alexa skill has not yet been published and is not currently available to the public. Hopefully it will be available soon.**

To learn more about this component navigate to to this [link](https://github.com/actsasrob/lircdo_ask/blob/master/README.md)

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
5. LIRC shell scripts and /etc/lirc/lircd.conf
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

###### Set-up

You will need some mechanism to connect to the server to install the lircdo service. With the Raspian install I initially use an HDMI cable to connect the Raspberry Pi to an HDMI-enabled  monitor or TV. You will need a USB keyboard/mouse to perform the initial configuration. Once you connect via the Raspian console I recommend enabling the server to connect to your home network via Wifi. This will make it easier to place the server in a convenient location without requiring an ether net cable. Enabling VNC and/or SSH will allow you to connect to the server remotely from another computer without requiring an HDMI-enabled monitor.

I won't cover the details here. There are plenty of good Raspberry Pi/Raspian tutorials available via the internet.

### Infrared Emitter/Receiver

You don't strictly need an IR receiver to use lircdo. However, you must populate the /etc/lirc/lircd.conf file (more on that later) containing configuration files that emulate the remote control(s) for your home AV equipment. Often you can find publically available configuration files. But if you cannot find a pre-made configuration file for one or more of your remote controls you may find you need to generate these configuration files yourself by cloning signals from the remote controls in your home. An IR receiver is needed to clone these signals. The lircdo server/service itself does not require an IR receiver.

Here is the [link](https://www.hackster.io/austin-stanton/creating-a-raspberry-pi-universal-remote-with-lirc-2fd581) to the project I used (with a couple of changes) to build the IR emitter/receiver I use in my home.

A big Thank You to Austin Stanton over at [Hackster.io](https://www.hackster.io/) for the awesome project to create an IR emitter/receiver.

Instead of connecting gpio pin 22 (physical pin 15) to the IR emitter and gpio pin 23 (phsical pin 16) to the IR receiver I connect gpio pin 17 (physical pin 11) to the IR emitter and gpio pin 18 (physical pin 12) to the IR receiver. When you install the lircdo service/application below it configures LIRC to use gpio pin 17 as output to the IR emitter and gpio pin 18 as input from the IR receiver. As a result you will want to shift the wires connected to the IR emitter and receiver in Austin's picture two pins to the left (away from the USB ports).

In the article when Austin refers to pin 1 and 6 I believe he means physical pins 1 and 6. When he refers to pin 22 and 23 I believe he means gpio pin 22 and 23.

If you are not familiar with Raspberry Pi gpio pins vs physical pins you may want to read through [this article](https://www.electronicwings.com/raspberry-pi/raspberry-pi-gpio-access) over at [Electronic Wings](https://www.electronicwings.com/).

The IR emitter does not work for me if I use a 10K Ohm resister. If I use a lower Ohm resister the IR emitter works but less reliably. Instead I connect the wire from gpio pin (physical pin 11) to the middle leg of the PN2222 Transistor and bypass the resistor.

Austin also includes a nice section to help troubleshoot issues with the IR emitter/receiver circuit and verify LIRC is working on the Raspberry Pi. I recommend testing using his instructions. You won't have to install/configure LIRC. I recommend you first install the lircdo service using the instructions below which will install and configure LIRC.


### lircdo service

Really the lircdo service is composed of two parts. 1) A systemd service running on the lircdo server that makes sure the lircdo Node.js application starts at boot time. 2) the lircdo Node.js application. If you care to look, the source code (see [server.js](https://raw.githubusercontent.com/actsasrob/lircdo/master/server.js)) implementing this Node.js application is available via this GitHub project. 

A shell script is provided to install the lircdo service/application and dependencies.

#### lircdo install script

    wget https://raw.githubusercontent.com/actsasrob/lircdo/nodejsv8/scripts/lircdo_install.sh
    chmod u+x lircdo_install.sh
    sudo ./lircdo_install.sh

*Always be wary of downloading scripts fron the internet and executing them with root level priviliges. I recommend you download the script and read through it first to verify what it is doing before executing the script.*

Here is a summary of what the script does:
* Attempts to determine the server hardware and operating system (OS) type
  * Will warn if the hardware is not Raspberry Pi 3 Model B
  * Will warn if the OS is other than Debian Jessie
* Installs packages needed for LIRC service
* Confgures LIRC service to use gpio pin 17 as out pin to IR emitter and gpio pin 18 as the in pin from IR receiver. Makes sure the lirc_rpi module is loaded at boot time
* Pauses after LIRC service installation/configuration. Gives you a chance to stop there to test the LIRC installation and the operation of your IR emitter/receiverx
* Installs additional dependent packages. e.g. git and openssl
* Creates an unprivliged user "lirc". The lircdo service will run as this user
* Installs node.js runtime and Node Version Manager (nvm)
* Installs the lircdo application by git cloning the GitHub project
* Creates a systemd service to start the application at boot time
* Creates the initial .env environment file read by the lircdo application
  * Creates randomly generated secrets used to better secure connections to the lircdo service
  * Prompts you for application port the application listens on and the fully qualified domain name (FQDN) of the lircdo server
* Performs some sanity checking to verify the FQDN resolves in DNS and that the FQDN IP resolves to the WAN IP for your home router
* Uses Let's Encrypt to create a free signed server certificate for the lircdo service. The server certificate is used to create secure HTTPS connections from the lircdo Alexa skill lambda function and the lircdo service
  * Prompts for an e-mail address to use when registering with Let's Encrypt. This e-mail address is used by Let's Encrypt to notify you when/if server certificates will expire.
* Creates a CRON job to renew the server certificate
* Creates filesystem access control list (ACLs) to allow the unpriviliged lirc user to read the server certificate certificate authority (CA), public cert, and private key files
* Creates softlinks from the lircdo application installation directory to the CA/cert/key files created when registering with Let's Encrypt
* Creates the initial catalog_internal.json file
* Restarts the lircdo service if needed
* Display installation status an next-steps to be performed.

#### lircdo service requirements: 
1. You need to own a domain name. e.g. mydomain.com, or joesblogspot.net
2. You need to be able to create sub-domains. E.g. lircdo.mydomain.com or lirc.joesblogspot.net
3. You may want to create a new sub-domain for use with the lircdo service. This is not required if you already have a domain or sub-domain that resolves to the WAN-side IP address of your home internet router.
4. The DNS entry for your selected domain/sub-domain **MUST** point to the WAN-side IP address of your home internet router. If your home internet service uses dynamic IPs you must keep the DNS entry for your sub-domain up-to-date.
5. In your home internet router you must forward port 80 to port 80 of the lircdo server. This port is used by Let's Encrypt to verify you own the registered domain and to renew server certificates.
6. In your home internet router you must forward the port the lircdo application listens on (e.g. port 8843) to the lircdo server. The lircdo Alexa skill will connect to the lircdo service using the FQDN and port number selected when installing the lircdo service.




### [LIRC](http://www.lirc.org/) service

The LIRC service is componsed of the LIRC library package which exposes an client API for handling the sending/receiving infrared (IR) signals via attached hardware.

After all is said and done, lircdo wouldn't be possible without the LIRC service. A big **Thank You** to the creators/developers of LIRC.

The LIRC packages are installed/configured as part of the lircdo service installation. You shouldn't have to install/configure LIRC other than to create the remote control definition file /etc/lirc/lircd.conf which is discussed below.

Initially I tried to use Debian Stretch which, I believe, uses verion 0.94 of the LIRC packages. I found version 0.94 of LIRC on Debian Stretch to be unstable. The service would just randomly stop working. After lots of internet searches and troubleshooting I found others experienced similar results. Eventually I switched back to Debian Jessie which uses version 0.90 of the LIRC packages and I haven't had any problems since. I highly recommend you use Debian Jessie as well.


### LIRC shell scripts and /etc/lirc/lircd.conf

The LIRC service and LIRC shell scripts are where the "rubber meets the road" so to speak. Really the lircdo service is just a glorified shell script runner. The lircdo service receives commands from the lricdo Alexa skill, determines the appropriate shell script to run, then executes that shell script.

You must create shell scripts that invoke the LIRC client API to control the AV hardware in your home. Example scripts are provided in the lircscripts_examples directory to help jumpstart this effort.

#### Create the directory where your LIRC shell scripts will reside 

The steps below assume this directory is named 'lircscripts' inside the top-level lircdo directory.

    sudo su - lirc # become the lirc user
    cd lircdo # change dir to the top-level lircdo application directory
    mkdir lircscripts # create the directory where the LIRC shell scripts will reside

**NOTE: If you change the location or name the directory other than lircscripts then you must update the LIRCSCRIPTS_LOCATION variable in the .env file and restart the lircdo application.**

/etc/lirc/lircd.conf contains the definitions of the remote controls that you want to emulate using LIRC. Under LIRC version 0.90 if you have multiple remote control definition files then concatenate them all together in the /etc/lirc/lircd.conf file. *Later versions of LIRC allow you to create multiple files under /etc/lirc/lircd.conf.d/*.

A remote control definition specifies things like the frequency used by the remote control, the time gap between IR signal pulses, and the codes for each remote control button.

The LIRC shell scripts and the remote control definitions go hand-in-hand. A given LIRC shell script will use the LIRC api to invoke a code for a named remote control. The LIRC service uses the definitions in /etc/lirc/lircd.conf to look up the details for the specified remote control and code. 

https://www.raspberrypi.org/forums/viewtopic.php?t=159035

Populating /etc/lirc/lircd.conf with remote control definition files to control your home A/V equipment is likely going to involve a sizeable investment in time. As the steps to do this get involved I have broken out this activity into its own [README_lircd.conf.md](https://github.com/actsasrob/lircdo/blob/master/README_lircd.conf.md) page.


### catalog_internal.json

The catalog_internal.json file maps lircdo actions/intents to your custom LIRC shell scripts. A script is provided which generates the catalog_internal.json file by parsing metadata in the lirc shell scripts you create. Whenever you add or modify LIRC shell scripts you must run the generate_json_catalog.py script to regenerate the catalog_internal.json file then restart the lircdo service. e.g.

    ./generate_json_catalog.py


This produces ./catalog_internal.json which is read by the node.js application on startup. This file maps the various HTTPS action callbacks to 0 or 1 LIRC scripts. If a script is found that implements the desired action then it is executed by the node.js application to perform the action (which usually means an IR signal is emitted to control some piece of hardware).

NOTE: Re-run generate_json_catalog.py anytime changes are made to scripts in the LIRC scripts directory then restart the node.js application.



### DNS/Domain name/SSL Cert

### Pulling It All Together

Recommend you proceed as follows:


### Misc.

#### How to start/restart the lircdo service

After making changes to the .env environment file or after re-generating catalog_internal.json you must restart the lircdo service. The lirc user is an unprivileged user and cannot use the sudo command. Instead use the 'pi' user to execute the following command to restart the lircdo service:

    sudo systemctl restart node-server
