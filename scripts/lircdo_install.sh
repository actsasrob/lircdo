#!/bin/bash

# Add logic to test for valid FQDN and PORT???
# TODO add logic to install node.js v8.10
# Add logic to test for valid FQDN and PORT???
# TODO test lircdo_install.sh script

LIRCDO_USER=lirc
LIRCDO_SERVER_PATH="/home/${LIRCDO_USER}
LIRCDO_SERVER_DIR="/home/${LIRCDO_USER}/lircdo
#GIT_BRANCH=master
GIT_BRANCH=nodejsv8


current_dir=$(cwd)

#function create_systemd_service {
#   cat << EOT >> /etc/systemd/system/node-server.service
#[Unit]
#Description=lircdo nodejs HTTP server
#
#[Service]
#WorkingDirectory=$LIRCDO_SERVER_DIR
#ExecStart=${LIRCDO_SERVER_PATH}/.nvm/versions/node/v8.10.0/bin/node server.js
#Type=simple
#Restart=always
#RestartSec=10
#User=$LIRCDO_USER
#
#[Install]
#WantedBy=basic.target
#EOT
#
#   chmod 644 /etc/systemd/system/node-server.service
#}

if [ "$EUID" -ne 0 ]; then
    echo "error: this script must be run as root. exiting..."
    exit 1
fi

if [ ! -w $current_dir ]; then
   echo "error: the current directory must be writable. exiting..."
   exit 1
fi

echo "info: checking if unprivileged user ${LIRCDO_USER} exists..."
grep $LIRCDO_USER /etc/passwd > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
   echo "info: creating unprivileged user ${LIRCDO_USER}..."
   useradd --comment "lircdo user" --home-dir /home/$LIRCDO_USER --create-home $LIRCDO_USER
else
   echo "info: unprivileged user ${LIRCDO_USER} already exists. skipping create."
fi

echo
echo "info: checking if lircdo server application has been installed at ${LIRCDO_SERVER_DIR}..."
if [ ! -e "${LIRCDO_SERVER_DIR}/server.js" ]; then
   echo "info: installing lircdo server application..."
   apt-get install -y git > /dev/null 2>&1
   sudo -u $LIRCDO_USER "mkdir -p ${LIRCDO_SERVER_PATH}"
   sudo -u $LIRCDO_USER "cd ${LIRCDO_SERVER_PATH}; git clone https://github.com/actsasrob/lircdo.git ${LIRCDO_SERVER_DIR}; cd $LIRCDO_SERVER_DIR; git checkout $GIT_BRANCH" 
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
if [ ! -e /etc/systemd/system/node-server.service ]; then
   echo "info: installing lircdo systemd service to /etc/systemd/system/node-server.service..."
   create_systemd_service 
   systemctl enable node-server
   systemctl daemon-reload
else
   echo "info: lircdo system service installed."
fi

echo
echo "info: checking if lircdo server application environment file ${LIRCDO_SERVER_DIR}/.env exists..."
if [ ! -e ${LIRCDO_SERVER_DIR}/.env ]; then
   echo "info: creating initial lircdo server application environment file" 
   sudo -u $LIRCDO_USER "cat ${LIRCDO_SERVER_DIR}/env_file_example > ${LIRCDO_SERVER_DIR}/.env"
   PROTECTED_PAGE_SECRET='ce287cfce8bd11e7ba96d746a6e2ce6e'
   LIRCDO_PAGE_SECRET='1840216ee8be11e7b124e36493f1a3ef'
   SESSION_SECRET='73abf97ee8c811e79bd35bb4b7a148ff'
   SECRET1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
   SECRET2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
   SECRET3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
   sudo -u $LIRCDO_USER 'sed -ei "s/^PROTECTED_PAGE_SECRET/PROTECTED_PAGE_SECRET=${SECRET1}"'
   sudo -u $LIRCDO_USER 'sed -ei "s/^LIRCDO_PAGE_SECRET/LIRCDO_PAGE_SECRET=${SECRET1}"'
   sudo -u $LIRCDO_USER 'sed -ei "s/^SESSION_SECRET/SESSION_SECRET=${SECRET1}"'
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
   echo "info: DO NOT use port 80 as this port is needed by the Let\'s Encrypt service to renew server certificates."
   echo "info: for a little more safety recommend not using port 443 as this port must be exposed to the internet."

   re="^[0-9]+$"
   while true; do
       read -p "Enter lircdo server port: " APP_PORT
       if [[ $APP_PORT =~ $re ]] && [ "$APP_PORT" -gt 0 ] && [ "$APP_PORT" -lt 65537 ] && ! [ "$APP_PORT" -eq 80 ]; then
	  sed -i -e "s/^APP_PORT=/APP_PORT=$APP_PORT/" $LIRCDO_SERVER_DIR/.env
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

chmod a+x ./certbot-auto
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
   ./certbot-auto certonly --standalone -n --agree-tos ${emailswitch} --preferred-challenges http  -d $APP_FQDN 
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




echo
echo "info: when ready, you need to start the lircdo server application via: 'sudo systemctl start node-server'"
echo "info: you can view the lircdo server application log via: 'sudo journalctl -a -u ${LIRCDO_USER} -f'"


