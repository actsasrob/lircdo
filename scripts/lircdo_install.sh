#!/bin/bash

set -x

# TODO Add logic to test for valid FQDN and PORT???
# TODO test lircdo_install.sh script

LIRCDO_USER="lirc"
LIRCDO_SERVER_PATH="/home/${LIRCDO_USER}"
LIRCDO_SERVER_DIR="/home/${LIRCDO_USER}/lircdo"
#GIT_BRANCH=master
GIT_BRANCH="nodejsv8"
NVM_VERSION="0.33.11"
NODEJS_VERSION="8.10.0"
LIRC_DRIVER="default"
LIRC_DEVICE="/dev/lirc0"

NEEDS_REBOOT=0
NEEDS_LIRCSERVICE_RESTART=0

current_dir="$(pwd)"

if [ "$EUID" -ne 0 ]; then
    echo "error: this script must be run as root. exiting..."
    exit 1
fi

if [ ! -w $current_dir ]; then
   echo "error: the current directory must be writable. exiting..."
   exit 1
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
      echo "dtoverlay=lirc-rpi,gpio_in_pin=17,gpio_out_pin=18" >> /boot/config.txt
      echo "info: added dtoverlay line in /boot/config.txt for lirc-rpi module using gpio in pin 17 and gpio out pin 18"
   else
      echo "info: dtloverlay line exists in /boot/config.txt but doesn't include lirc-rpi module...adding it..."
      sed -ie "s/^\(dtoverlay.*\)$/\1,lirc-rpi,gpio_in_pin=17,gpio_out_pin=18/" /boot/config.txt
      echo "info: added dtoverlay line in /boot/config.txt for lirc-rpi module using gpio in pin 17 and gpio out pin 18"
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
   sed -ie "s/^DEVICE=/DEVICE='${LIRC_DEVICE}'/" /etc/lirc/hardware.conf
   sed -ie "s/^DRIVER=/DRIVER='${LIRC_DRIVER}'/" /etc/lirc/hardware.conf
   echo "info: /etc/lirc/hardware.conf has been updated."
   NEEDS_LIRCSERVICE_RESTART=1
else
   echo "info: latest /etc/lirc/hardware.conf file already installed. nothing to do"
fi

systemctl enable lirc
if [ "$NEEDS_LIRCSERVICE_RESTART" -eq 1 ]; then
   echo
   echo "info: restarting lirc service..."
   systemctl start lirc
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
   sudo -H -u $LIRCDO_USER bash -c "nvm install $NODEJS_VERSION"
   sudo -H -u $LIRCDO_USER bash -c "nvm alias default $NODEJS_VERSION"

   if [ ! -d /home/$LIRCDO_USER/.nvm/versions/node/$NODEJS_VERSION ]; then
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
   apt-get install -y git > /dev/null 2>&1
   sudo -H -u $LIRCDO_USER bash -c "mkdir -p ${LIRCDO_SERVER_PATH}"
   sudo -H -u $LIRCDO_USER bash -c "cd ${LIRCDO_SERVER_PATH}; git clone https://github.com/actsasrob/lircdo.git ${LIRCDO_SERVER_DIR}; cd $LIRCDO_SERVER_DIR; git checkout $GIT_BRANCH" 
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
   sudo -H -u $LIRCDO_USER bash -c 'cat "${LIRCDO_SERVER_DIR}/env_file_example" > "${LIRCDO_SERVER_DIR}/.env"'
   PROTECTED_PAGE_SECRET='ce287cfce8bd11e7ba96d746a6e2ce6e'
   LIRCDO_PAGE_SECRET='1840216ee8be11e7b124e36493f1a3ef'
   SESSION_SECRET='73abf97ee8c811e79bd35bb4b7a148ff'
   SECRET1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
   SECRET2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
   SECRET3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
   sed -ie "s/^PROTECTED_PAGE_SECRET/PROTECTED_PAGE_SECRET=${SECRET1}/" ${LIRCDO_SERVER_DIR}/.env
   sed -ie "s/^LIRCDO_PAGE_SECRET/LIRCDO_PAGE_SECRET=${SECRET1}/" ${LIRCDO_SERVER_DIR}/.env
   sed -ie "s/^SESSION_SECRET/SESSION_SECRET=${SECRET1}/" ${LIRCDO_SERVER_DIR}/.env
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
   echo "info: Please select an unused port which the lircdo server application will listen on for incoming requests from the lircd Alexa Skills Kit (ASK) lambda function."
   echo "info: DO NOT use port 80 as this port is needed by the Lets Encrypt service to renew server certificates."
   echo "info: for a little more safety recommend not using port 443 as this port must be exposed to the internet."

   re="^[0-9]+$"
   while true; do
       read -p "Enter lircdo server port: " APP_PORT
       if [[ $APP_PORT =~ $re ]] && [ "$APP_PORT" -gt 0 ] && [ "$APP_PORT" -lt 65537 ] && ! [ "$APP_PORT" -eq 80 ]; then
	  sed -i -e "s/^APP_PORT=/APP_PORT=$APP_PORT/" "$LIRCDO_SERVER_DIR/.env"
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
   echo "info:       It is likely you will need to configure your home router to forward incoming traffic"
   echo "info:         to the lircdo server in your home network and port selected above." 
   echo "info:       DO NOT use port 80 as this port is needed by the Let\'s Encrypt service to renew server certificates."
   echo "info:       For a little more safety recommended not using port 443 as this port must be exposed to the internet."
   echo "info:       Port 80 on the lircdo server must also be exposed to the internet. The Let\'s Encrypt"
   echo "info:        service will initiate a request to the FQDN and port entered to verify you actually own"
   echo "info:        the domain for the FQDN before issuing the signed server certificate used to "
   echo "info:        enable secure HTTPS connections from the lircdo ASK lambda skill."

   while true; do
       read -p "Enter lircdo server FQDN: " APP_FQDN
       host $APP_FQDN > /dev/null 2>&1
       if [ "$?" -ne 0 ]; then
	  echo "error: the entered FQDN does not resolve in DNS."
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
          sed -i -e "s/^APP_FQDN=/APP_FQDN=$APP_FQDN/" $LIRCDO_SERVER_DIR/.env
          break
       fi
   done
else
   echo "info: lircdo server FQDN set to ${APP_FQDN}"
   echo "info: NOTE: you can change this setting by editing $LIRCDO_SERVER_DIR/.env" 
fi

echo
echo "info: checking if Let\'s Encrypt certbot-auto script has been downloaded..."
if [ ! -e ./certbot-auto ]; then
   echo "info: installing Let\'s Encrypt certbot-auto script used to generate TLS certificates..."
   wget https://dl.eff.org/certbot-auto
   if [ "$?" -ne 0  ]; then
      echo "error: could not download certbot-auto. exiting..."
      exit 1
   fi
else
   echo "info: certbot-auto successfully downloaded."
fi

echo
echo "info: checking if certbot-auto.asc file exists..."
if [ ! -e ./certbot-auto.asc ]; then
   echo "info: downloading certbot-auto.asc to verify integrity of certbot-auto..."
   wget -N https://dl.eff.org/certbot-auto.asc
   if [ "$?" -ne 0  ]; then
      echo "error: could not download certbot-auto.asc to verify certbox-auto install. exiting..."
      exit 1
   fi
else
   echo "info: certbot-auto.asc successfully downloaded."
fi

echo
echo "info: installing trusted gpg key for Let\'s Encrypt certbot-auto..."
gpg2 --keyserver pool.sks-keyservers.net --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2

if [ "$?" -ne 0 ]; then
   echo "error: failed to install trusted gpg key. exiting..."
   exit 1
else
   echo "info: gpg key installed"
fi

echo
echo "info: verifying integrity of Let\'s Encrypt certbox-auto script..."
gpg2 --trusted-key 4D17C995CD9775F2 --verify certbot-auto.asc certbot-auto 2>&1 | grep "gpg: Good signature"

if [ "$?" -ne 0 ]; then
   echo "error: failed to validate certbot-auto script. exiting..."
   exit 1
else
   echo "info: certbot-auto script successfully verified" 
fi   

cp certbox-auto /usr/local/bin
chmod a+x /usr/local/bin/certbot-auto
# ./certbot-auto --help

echo "info: checking if Let\'s Encrypt signed server certificate exists for domain $APP_FQDN..."
if [ ! -e /etc/letsencript/live/$APP_FQDN/cert.pem ]; then
   echo "info: registering $APP_FQDN domain with Let\'s Encrypt and requesting signed certificate..."
   echo "info: when requesting signed server certifates from Let\'s Encrypt you can add an e-mail address"
   echo "       which will be used to send important notifications such as reminders about expiring "
   echo "       certificates."
   emailswitch=""
   email=""
   while true; do
      read -p "Do you wish to register an e-mail address with Let\'s Encrypt? y/n: " YN
      case $YN in
        [Yy]*)
               read -p "What e-mail address would you like to register with Let\'s Encrypt? " email
               char='[[:alnum:]!#\$%&'\''\*\+/=?^_\`{|}~-]'
               name_part="${char}+(\.${char}+)*"
               domain="([[:alnum:]]([[:alnum:]-]*[[:alnum:]])?\.)+[[:alnum:]]([[:alnum:]-]*[[:alnum:]])?"
               begin='(^|[[:space:]])'
               end='($|[[:space:]])'
               
               # include capturing parentheses, 
               # these are the ** 2nd ** set of parentheses (there's a pair in $begin)
               re_email="${begin}(${name_part}@${domain})${end}"
               if [[ $email =~ $re_email ]]; then
                  email=${BASH_REMATCH[2]}
                  echo "info: address ${email} will be registered with Let\'s Encrypt"
               else
                  echo "warn: ${email} doesn't appear to be a valid e-mail address. Will use it anyway."  
               fi
               emailswitch="-m $email"
               break 
            ;;
        [Nn]*)
                break 
            ;;

            *)
                continue
            ;;
      esac
   done
   echo "info: invoking Let\'s Encrypt certbot-auto script tp register/download signed certificate"
   echo "       for domain $APP_FQDN..."
   /usr/local/bin/certbot-auto certonly --standalone -n --agree-tos ${emailswitch} --preferred-challenges http  -d $APP_FQDN 
   certbot_status=$?
   if [ "$certbot_status" -ne 0 ]; then
      echo "error: certbot-auto script returned non-zero status"
   fi
   if [ ! -e /etc/letsencript/live/$APP_FQDN/cert.pem ]; then
      echo "error: the certbot-auto script executed without error but no server certificate was found in"
      echo "         /etc/letsencript/live/$APP_FQDN/cert.pem"
   fi
   if [ "$certbot_status" -ne 0 ] || [ ! -e /etc/letsencript/live/$APP_FQDN/cert.pem ]; then
      echo "error: failed to register/download signed certificate from Let\'s Encrypt"
      echo "       here\'s a list of things that could cause the registration/download to fail:"
      echo "       $APP_FQDN is the incorrect FQDN"
      echo "       $APP_FQDN does not resolve in DNS to the correct IP (probably the WAN-side IP for your home router"
      echo "       You did not configure port forwarding to allow HTTP port 80 to be forwarded to your lircdo server"
      echo "       Possibly some other application is listening on HTTP port 80"
      echo "       exiting..."
      exit 1
   fi
fi

echo
echo "info: checking if cron job exists to renew server certificate..."
grep "certbot-auto" /var/spool/cron/crontabs/root > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "info: setting up cron job for root user to renew certificate using Let\'s Encrypt..."
   echo "30 12,6 * * * /usr/local/bin/certbot-auto renew --renew-hook 'systemctl restart node-server' 2>>/var/log/cert-renew.log >>/var/log/cert-renew.log" >> /var/spool/cron/crontabs/root
else
   echo "info: cron job for root user exists to renew Let\'s Encrypt certificate"
fi


echo
echo "info: setting up file system access control lists (ACLs) to allow $LIRCDO_USER to read Let\'s Encrypt certificates and keys under /etc/letsencrypt directory..."

cd /etc/letsencrypt
getfacl -R live > acl_backup_for_live_folder
getfacl -R archive > acl_backup_for_archive_folder

setfacl -m u:${LIRCDO_USER}:rx /etc/letsencrypt/live
setfacl -m u:${LIRCDO_USER}:rx /etc/letsencrypt/live/$APP_FQDN
setfacl -m u:${LIRCDO_USER}:r /etc/letsencrypt/live/$APP_FQDN/*.pem
setfacl -m u:${LIRCDO_USER}:rx /etc/letsencrypt/archive
setfacl -m u:${LIRCDO_USER}:rx /etc/letsencrypt/archive/$APP_FQDN
setfacl -m u:${LIRCDO_USER}:r /etc/letsencrypt/archive/$APP_FQDN/*.pem

# Set directory default ACLs in case they are deleted/recreated
setfacl -d -m u:${LIRCDO_USER}:rx /etc/letsencrypt/live
setfacl -d -m u:${LIRCDO_USER}:rx /etc/letsencrypt/live/$APP_FQDN
setfacl -d -m u:${LIRCDO_USER}:rx /etc/letsencrypt/archive
setfacl -d -m u:${LIRCDO_USER}:rx /etc/letsencrypt/archive/$APP_FQDN

cd $current_dir

getfacl /etc/letsencrypt/live | grep $LIRCDO_USER > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "error: failed to create file system ACLs. exiting..."
   exit 1
fi

echo "info: file system ACLs have been created"

echo
echo "info: checking if lircdo application cert/key files under $LIRCDO_SERVER_DIR/sslcert have been soft linked to /etc/letsencrypt/live/${APP_FQDN} ..."
if [ ! -h $LIRCDO_SERVER_DIR/sslcert/cacert.pem  ] || [ ! -h $LIRCDO_SERVER_DIR/sslcert/servercert.pem  ] || [ ! -h $LIRCDO_SERVER_DIR/sslcert/serverkey.pem  ]; then
   echo "info: creating soft links for lircdo application cert/key files..."
   ln -f -s $LIRCDO_SERVER_DIR/sslcert/cacert.pem /etc/letsencrypt/live/$APP_FQDN/chain.pem
   ln -f -s $LIRCDO_SERVER_DIR/sslcert/servercert.pem /etc/letsencrypt/live/$APP_FQDN/cert.pem
   ln -f -s $LIRCDO_SERVER_DIR/sslcert/serverkey.pem /etc/letsencrypt/live/$APP_FQDN/privkey.pem

   if [ ! -h $LIRCDO_SERVER_DIR/sslcert/cacert.pem  ] || [ ! -h $LIRCDO_SERVER_DIR/sslcert/servercert.pem  ] || [ ! -h $LIRCDO_SERVER_DIR/sslcert/serverkey.pem  ]; then
      echo "error: failed to soft link one or more lircdo application cert/key files from $LIRCDO_SERVER_DIR/sslcert to /etc/letsencrypt/live/$APP_FQDN/. exiting..."
      exit 1
   fi
else
   echo "info: lircdo application certificates files already linked to /etc/letsencrypt directory" 
fi

systemctl restart node-server

echo "info: you can view the lircdo server application log via: 'sudo journalctl -a -u ${LIRCDO_USER} -f'"

echo "info: lirc has been installed/configured/started"
if [ "$NEEDS_REBOOT" -eq 1 ]; then
   echo "info: *** you need to reboot the server to properly load the lirc_rpi module before using lirc ***"
   echo
fi

echo
echo "info: note: you need to populate /etc/lirc/lircd.conf with the configuration for the"
echo "            infrared remote control hardware used in your home."
