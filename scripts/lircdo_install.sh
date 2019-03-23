#!/bin/bash

#set -x

# TODO Add logic to test for valid FQDN and PORT???
# TODO test lircdo_install.sh script

LIRCDO_USER="lirc"
LIRCDO_SERVER_PATH="/home/${LIRCDO_USER}"
LIRCDO_SERVER_DIR="/home/${LIRCDO_USER}/lircdo"
GIT_BRANCH=master
NVM_VERSION="0.33.11"
NODEJS_VERSION="8.10.0"
LIRC_DRIVER="default"
LIRC_DEVICE="/dev/lirc0"

DIG_COMMAND="dig +short myip.opendns.com @resolver1.opendns.com"

NEEDS_REBOOT=0
NEEDS_LIRCSERVICE_RESTART=0

EXTRA_PACKAGES="git openssl"

current_dir="$(pwd)"

if [ "$EUID" -ne 0 ]; then
    echo "error: this script must be run as root. exiting..."
    exit 1
fi

if [ ! -w $current_dir ]; then
   echo "error: the current directory must be writable. exiting..."
   exit 1
fi

# Check OS version
echo
echo "info: this install script and the lircdo service has only been verified to work with debian jessie"
echo "info: check for debian jessie operating system using /etc/os-release..."
if [ -e /etc/os-release ]; then
   grep -i jessie /etc/os-release > /dev/null 2>&1
   if [ "$?" -ne 0 ]; then
      echo "***"
      echo "warn: operating system doesn't appear to be debian jessie. cannot guarantee install or lircdo service will work. continuing anyway..."
      echo "***"
   else
      echo "info: verified debian jessie operating system. continuing..."
   fi
else
   echo "***"
   echo "warn: could not determine operating system using /etc/os-release. cannot guarentee install or lirdo service will work. continuing anyway..."
   echo "***"
fi

echo
echo "info: this install script and the lirdo service has only been verified to work with Raspberry Pi 3 Model B"
echo "info: check for firmware version..."
if [ -e /sys/firmware/devicetree/base/model ]; then
   grep -i "3 model b" /sys/firmware/devicetree/base/model > /dev/null 2>&1
   if [ "$?" -eq 0 ]; then
      echo "info: verified Raspberry Pi 3 Model B. continuing..."
   else
      echo "***"
      echo "warn: could not verify firmware is Raspberry Pi 3 Model B. cannot guarantee install or lircdo service will work. continuing anyway..."
      echo "***"
   fi
else
   echo "***"
   echo "warn: could not verify firmware is Raspberry Pi 3 Model B. cannot guarantee install or lircdo service will work. continuing anyway..."
   echo "***"
fi

echo
echo "info: install/configure Linux Infrared Remote Control (LIRC) service"
dpkg -l | grep " lirc " > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "info: installing lirc package..."
   apt-get install -y lirc
   dpkg -l | grep " lirc " > /dev/null 2>&1
   if [ "$?" -ne 0 ]; then
      echo "error: failed to install lirc package. exiting..."
      exit 1
   fi
   NEEDS_LIRCSERVICE_RESTART=0
else
   echo "info: lirc package already installed. nothing to do"
fi

echo
echo "info: install/configure Linux Infrared Remote Control (LIRC) service. configure /boot/config.txt"
grep "^dtoverlay.*lirc" /boot/config.txt > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   cp /boot/config.txt /boot/config.txt.bak
   grep "^dtoverlay" /boot/config.txt > /dev/null 2>&1
   if [ "$?" -ne 0 ]; then
      echo "info: no dtoverlay line exists in /boot/config.txt for lirc-rpi module...adding line..."
      echo "dtoverlay=lirc-rpi,gpio_out_pin=17,gpio_in_pin=18" >> /boot/config.txt
      echo "info: added dtoverlay line in /boot/config.txt for lirc-rpi module using gpio out pin 17 and gpio in pin 18"
   else
      echo "info: dtloverlay line exists in /boot/config.txt but doesn't include lirc-rpi module...adding it..."
      sed -ie "s/^\(dtoverlay.*\)$/\1,lirc-rpi,gpio_out_pin=17,gpio_in_pin=18/" /boot/config.txt
      echo "info: added dtoverlay line in /boot/config.txt for lirc-rpi module using gpio out pin 17 and gpio in pin 18"
   fi
   NEEDS_REBOOT=1
else
   echo "info: dtoverlay line for lirc-rpi already exists in /boot/config.txt. nothing to do"
fi


echo
echo "info: install/configure Linux Infrared Remote Control (LIRC) service. configure /etc/lirc/hardware.conf"
grep "^DEVICE=\"${LIRC_DEVICE}\"" /etc/lirc/hardware.conf > /dev/null 2>&1
devicestatus=$?
grep "^DRIVER=\"${LIRC_DRIVER}\"" /etc/lirc/hardware.conf > /dev/null 2>&1
driverstatus=$?
if [ "$devicestatus" -ne 0 ] || [ "$driverstatus" -ne 0 ]; then
   echo "info: configuring DEVICE and DRIVER in /etc/lirc/hardware.conf..."
   cp -p /etc/lirc/hardware.conf /etc/lirc/hardware.conf.bak
   sed -ie "s|^DEVICE=.*$|DEVICE='${LIRC_DEVICE}'|" /etc/lirc/hardware.conf
   sed -ie "s|^DRIVER=.*$|DRIVER='${LIRC_DRIVER}'|" /etc/lirc/hardware.conf
   echo "info: /etc/lirc/hardware.conf has been updated."
   NEEDS_LIRCSERVICE_RESTART=1
else
   echo "info: latest /etc/lirc/hardware.conf file already installed. nothing to do"
fi

systemctl enable lirc
if [ "$NEEDS_LIRCSERVICE_RESTART" -eq 1 ]; then
   echo
   echo "info: restarting lirc service..."
   systemctl restart lirc
fi

echo
echo "info: lirc has been installed/configured/started"
if [ "$NEEDS_REBOOT" -eq 1 ]; then
   echo "info: *** you need to reboot the server to properly load the lirc_rpi module before using lirc ***"
   echo
fi

echo "info: you can stop here and test lirc or continue with the remainder of the lirdo server install"
while true; do
   read -p " continue? y/n: " YN
   case $YN in
     [Yy]*)
             break 
         ;;
     [Nn]*)
             echo "info: note: you need to populate /etc/lirc/lircd.conf with the configuration for the"
             echo "            infrared remote control hardware used in your home."
             exit 0 
         ;;

         *)
             continue
         ;;
   esac
done

echo "info: installing extra packages needed for lircdo service install..."
for package in $EXTRA_PACKAGES; do
   echo "info: installing ${package}..."
   apt-get install -y $package > /dev/null 2>&1
done

echo
echo "info: checking if unprivileged user ${LIRCDO_USER} exists..."
grep $LIRCDO_USER /etc/passwd > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "info: creating unprivileged user ${LIRCDO_USER}..."
   useradd --comment "lircdo user" --home-dir /home/$LIRCDO_USER --create-home $LIRCDO_USER
else
   echo "info: unprivileged user ${LIRCDO_USER} already exists. skipping create."
fi

echo
echo "info: checking if node.js version manager (nvm) is installed..."
if [ ! -d /home/$LIRCDO_USER/.nvm ]; then
   echo "info: installing nvm..."
   sudo -H -u $LIRCDO_USER bash -c "curl https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash"
   cat << EOT >> /home/$LIRCDO_USER/.bashrc
export NVM_DIR="/home/lirc/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
EOT
   sudo -H -u $LIRCDO_USER bash -i -c "nvm install $NODEJS_VERSION"
   sudo -H -u $LIRCDO_USER bash -i -c "nvm alias default $NODEJS_VERSION"

   if [ ! -d /home/$LIRCDO_USER/.nvm/versions/node/v${NODEJS_VERSION} ]; then
      echo "error: failed to install nvm and node.js version $NODEJS_VERSION. exiting..."
      exit 1
   fi
else
   echo "info: nvm is installed"
fi


echo
echo "info: checking if lircdo server application has been installed at ${LIRCDO_SERVER_DIR}..."
if [ ! -e "${LIRCDO_SERVER_DIR}/server.js" ]; then
   echo "info: installing lircdo server application..."
   sudo -H -u $LIRCDO_USER bash -c "mkdir -p ${LIRCDO_SERVER_PATH}"
   sudo -i -H -u $LIRCDO_USER bash -i -c "cd ${LIRCDO_SERVER_PATH}; git clone https://github.com/actsasrob/lircdo.git ${LIRCDO_SERVER_DIR}; cd $LIRCDO_SERVER_DIR; git checkout $GIT_BRANCH; ./scripts/npm_install.sh" 
   cd $current_dir
   if [ ! -e "${LIRCDO_SERVER_DIR}/server.js" ]; then
      echo "error: failed to install lircdo server application. exiting..."
      exit 1
   fi
else
   echo "info: lircdo server application installed."
fi

echo
echo "info: checking if lircdo systemd service is installed..."
cat << EOT > /tmp/node-server.service
[Unit]
Description=lircdo nodejs HTTP server

[Service]
WorkingDirectory=$LIRCDO_SERVER_DIR
ExecStart=${LIRCDO_SERVER_PATH}/.nvm/versions/node/v${NODEJS_VERSION}/bin/node server.js
Type=simple
Restart=always
RestartSec=10
User=$LIRCDO_USER

[Install]
WantedBy=basic.target
EOT

if [ ! -e /etc/systemd/system/node-server.service ]; then
   echo "info: installing lircdo systemd service to /etc/systemd/system/node-server.service..."
   cp /tmp/node-server.service /etc/systemd/system/node-server.service
   chmod 644 /etc/systemd/system/node-server.service
   systemctl enable node-server
   systemctl daemon-reload
else
   echo "info: lircdo system service installed"
fi

echo
echo "info: checking if lircdo systemd service is up-to-date..."
installedmd5=$(md5sum /etc/systemd/system/node-server.service)
incomingmd5=$(md5sum /tmp/node-server.service)
if [ "$installedmd5" != "$incomingmd5" ]; then
   echo "info: installing updated node-server.service to /etc/systemd/system..."
   cp /tmp/node-server.service /etc/systemd/system/node-server.service
   chmod 644 /etc/systemd/system/node-server.service
   systemctl enable node-server
   systemctl daemon-reload
else
   echo "info: lircdo system service is up-to-date"
fi
rm -f /tmp/node-server.service

echo
echo "info: checking if lircdo server application environment file ${LIRCDO_SERVER_DIR}/.env exists..."
if [ ! -e ${LIRCDO_SERVER_DIR}/.env ]; then
   echo "info: creating initial lircdo server application environment file" 
   cp ${LIRCDO_SERVER_DIR}/env_file_example ${LIRCDO_SERVER_DIR}/.env
   chown ${LIRCDO_USER}:${LIRCDO_USER} ${LIRCDO_SERVER_DIR}/.env
   chmod 644 ${LIRCDO_SERVER_DIR}/.env
   SECRET1="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | tr 'A-Z' 'a-z' | head -n 1)"
   SECRET2="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | tr 'A-Z' 'a-z' | head -n 1)"
   SECRET3="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | tr 'A-Z' 'a-z' | head -n 1)"
   sed -ie "s/^PROTECTED_PAGE_SECRET.*/PROTECTED_PAGE_SECRET=${SECRET1}/" ${LIRCDO_SERVER_DIR}/.env
   sed -ie "s/^LIRCDO_PAGE_SECRET.*/LIRCDO_PAGE_SECRET=${SECRET2}/" ${LIRCDO_SERVER_DIR}/.env
   sed -ie "s/^LIRCDO_SESSION_SECRET.*/LIRCDO_SESSION_SECRET=${SECRET3}/" ${LIRCDO_SERVER_DIR}/.env
   if [ ! -e ${LIRCDO_SERVER_DIR}/.env ]; then
      echo "error: failed to create lircdo server application environment file ${LIRCDO_SERVER_DIR}/.env. exiting..."
      exit 1
   fi
else
   echo "info: lircdo server application environment file exists. no need to create"
fi

echo
echo "info: checking if lircdo server env variables have been set..."
. $LIRCDO_SERVER_DIR/.env
if [ -z "$APP_PORT" ]; then
   echo "info: setting lircdo server application port."
   echo "info: Please select an unused port which the lircdo server application will listen on for incoming requests from the lircdo Alexa Skills Kit (ASK) lambda function."
   echo "info: for a little more safety recommend not using port 443 as this port must be exposed to the internet."

   re="^[0-9]+$"
   while true; do
       read -p "Enter lircdo server port: " APP_PORT
       if [[ $APP_PORT =~ $re ]] && [ "$APP_PORT" -gt 0 ] && [ "$APP_PORT" -lt 65537 ] && ! [ "$APP_PORT" -eq 80 ]; then
	  sed -i -e "s/^APP_PORT=.*/APP_PORT=$APP_PORT/" "$LIRCDO_SERVER_DIR/.env"
          break 
       else
          echo "error: port number must be between [1 and 65536] and not equal to 80."
       fi
   done
else
   echo "info: lircdo server port set to ${APP_PORT}"
   echo "info: NOTE: you can change this setting by editing $LIRCDO_SERVER_DIR/.env" 
fi

if [ -z "$APP_FQDN" ]; then
   echo "info: setting lircdo server application fully qualified domain name (FQDN)."
   echo "info: you will be prompted to enter the FQDN for the lircdo server." 
   echo "info: NOTE: The FQDN must resolve in DNS."
   echo "info:       It is likely that the FQDN will resolve to the WAN-side IP address for your home router"
   echo "info:       It is also likely you will need to configure your home router to forward incoming traffic"
   echo "info:         to the lircdo server in your home network and port selected above." 
   echo "info:       For a little more safety recommend not using port 443 as this port must be exposed to the internet."

   while true; do
       read -p "Enter lircdo server FQDN: " APP_FQDN
       host_output=$(host "$APP_FQDN")
       host_status="$?"
       host_ip=""
       dig_output=$("$DIG_COMMAND")
       dig_output_status="$?"
       compare_ip_check=0
       if [ "$host_status" -ne 0 ]; then
	  echo "error: the entered FQDN does not resolve in DNS using 'host $APP_FQDN' command"
       else
	  host_ip=$(echo "$host_output" | awk '{ print $NF }')
	  if [ "$dig_output_status" -eq 0 ] && [ -n "$dig_output" ]; then
	     echo "$host_output" | grep "$dig_output" > /dev/null 2>&1
	     if [ "$?" -ne 0 ]; then
		echo "error: WAN IP address, ${dig_output}, reported by '$DIG_COMMAND' does not match IP address, "${host_ip}", as reported by 'host $APP_FQDN'. This will likely prevent the lircdo service from being able to receive incoming requests from the lircdo alexa skills kit (ASK) lambda function."
		compare_ip_check=1
	     fi
	  fi
       fi

       if [ "$host_status" -ne 0 ] || [ "$compare_ip_check" -ne 0 ]; then
	  echo "error: could not verify $APP_FQDN resolves to your WAN IP"
          read -p "do you wish to use this FQDN? y/n: " YN
          case $YN in
            [Yy]*) 
                    :
                ;;  
            [Nn]*) 
                    continue 
                ;;

                *) 
                    continue
                ;;
          esac
          sed -i -e "s/^APP_FQDN=.*/APP_FQDN=$APP_FQDN/" $LIRCDO_SERVER_DIR/.env
       else
          sed -i -e "s/^APP_FQDN=.*/APP_FQDN=$APP_FQDN/" $LIRCDO_SERVER_DIR/.env
       fi
       break
   done
else
   echo "info: lircdo server FQDN set to ${APP_FQDN}"
   echo "info: NOTE: you can change this setting by editing $LIRCDO_SERVER_DIR/.env" 
fi

mkdir -p $LIRCDO_SERVER_DIR/sslcert
chown ${LIRCDO_USER}:${LIRCDO_USER} $LIRCDO_SERVER_DIR/sslcert
chmod 700 $LIRCDO_SERVER_DIR/sslcert

echo "info: checking if server certificates have been created..."
if [ ! -f $LIRCDO_SERVER_DIR/sslcert/cacert.pem  ] || [ ! -f $LIRCDO_SERVER_DIR/sslcert/servercert.pem  ] || [ ! -f $LIRCDO_SERVER_DIR/sslcert/serverkey.pem  ]; then 

   echo "info: creating server certificates..."
sudo -i -H -u $LIRCDO_USER bash -i -c "cd ${LIRCDO_SERVER_DIR}/openssl; ./make-all.sh $APP_FQDN"
   cd $current_dir

   if [ ! -f $LIRCDO_SERVER_DIR/sslcert/cacert.pem  ] || [ ! -f $LIRCDO_SERVER_DIR/sslcert/servercert.pem  ] || [ ! -f $LIRCDO_SERVER_DIR/sslcert/serverkey.pem  ]; then
      echo "error: failed to create one or more lircdo application cert/key files under $LIRCDO_SERVER_DIR/sslcert. exiting..."
      exit 1
   fi
else
   echo "info: lircdo server certificates files already already exist. nothing to do" 
fi

if [ ! -e $LIRCDO_SERVER_DIR/catalog_internal.json ]; then
echo "info: generating the initial catalog_internal.json file which maps intents from the lircdo Alexa Skill to local lircdo shell scripts..."
cat << EOT > $LIRCDO_SERVER_DIR/catalog_internal.json
{
       "SHARED_SECRET": "${LIRCDO_PAGE_SECRET}",
       "intents": []
}	
EOT
fi

chown $LIRCDO_USER:$LIRCDO_USER $LIRCDO_SERVER_DIR/catalog_internal.json > /dev/null 2>&1
chmod 644 $LIRCDO_SERVER_DIR/catalog_internal.json > /dev/null 2>&1

systemctl restart node-server

echo
echo "info: verify the lircdo service is running..."
systemctl is-active node-server | grep "^active$" > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "error: lircdo service is not running"
   echo "       possible causes:"
   echo "       1) there is a configuration issue preventing the lircdo service from starting"
   echo "          use the following commands to troubleshoot:"
   echo "          sudo systemctl status node-server"
   echo "          sudo journalctl -a -u ${LIRCDO_USER} -f"
   echo "       exiting..."
   exit 1
else
   echo "info: the lircdo service is running"
fi

sleep 2

echo
echo "info: verify the lircdo service can be reached at URL: https://${APP_FQDN}:${APP_PORT}..."
echo "Q" | openssl s_client -connect ${APP_FQDN}:${APP_PORT} > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "error: could not connect to lircdo server URL using openssl."
   echo "       possible causes:"
   echo "       1) the lircdo service is not running. verify via 'sudo systemctl status node-server'"
   echo "       2) there is a configuration issue preventing the lircdo service from starting"
   echo "          use 'sudo journalctl -a -u ${LIRCDO_USER} -f' to troubleshoot"
   echo "       3) a firewall is preventing access to port ${APP_PORT}"
   echo "       4) you need to configure your router to forward incoming connections on port "
   echo "          ${APP_PORT} to the lircdo server"
   echo "          Use the following openssl command to troubleshoot:"
   echo "          openssl s_client -connect ${APP_FQDN}:${APP_PORT}"
   echo "       exiting..."
   exit 1
else
   echo "info: successfully connected to https://${APP_FQDN}:${APP_PORT} using openssl"
fi

echo
echo "info: lirc has been installed/configured/started"
if [ "$NEEDS_REBOOT" -eq 1 ]; then
   echo "info: *** you need to reboot the server to properly load the lirc_rpi module before using lirc ***"
   echo
fi

echo
echo "info: note: you need to populate /etc/lirc/lircd.conf with the configuration for the"
echo "            infrared remote control hardware used in your home."
echo "            Then restart the lirc service 'sudo systemctl restart lirc'"
echo "info: note: you need to populate ${LIRCDO_SERVER_DIR}/lircscripts with shell scripts"
echo "            to emit infrared signals via LIRC for the lircdo intents you care to implement."
echo "            Then (re-)generate the catalog as the ${LIRCDO_USER} user as follows:"
echo "            cd $LIRCDO_SERVER_DIR"
echo "            ./generate_json_catalogs.py"
echo "            Then restart the LIRCDO service as root or pi user:"
echo "            sudo systemctl restart node-server"

echo
echo "info: you can view the lircdo server application log via: 'sudo journalctl -a -u node-server -f'"
