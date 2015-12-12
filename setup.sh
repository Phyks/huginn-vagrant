#!/bin/bash

# This script will help you set up a Huginn instance inside a VirtualBox
# virtual machine. You will need VirtualBox and Vagrant installed to use
# it. Huginn itself will be automatically downloaded. This script is not
# clever and is not idempotent, so using it more than once might produce
# unexpected results. The files you need to amend are suitably commented
# so you could always change them using your favourite editor if needed.

# -- Functions -----------------------------------------------------------------

DIALOG=$(which dialog) || $(which whiptail)

function genpw {
  echo $(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16})
}

function genkey {
  echo $(< /dev/urandom tr -dc a-f0-9 | head -c${1:-64})
}

function quit {
  $DIALOG --defaultno --title "Quit Installer?" --yesno "Do you want to quit? No changes have been made yet." 6 60
  [[ "$?" = "0" ]] && exit
}


# -- Greetings -----------------------------------------------------------------

read -r -d '' MESSAGE <<"EOMESSAGE"
This script will guide you through providing configuration
information for the Huginn Vagrant setup scripts available from
https://github.com/m0nty/huginn-vagrant. This is mostly passwords,
usernames and email settings. Default passwords are provided so
you don't have to do too much yourself.

Huginn itself is the creation of Andrew Cantino and others,
available from https://github.com/cantino/huginn/. It, and its
dependencies, will be automatically downloaded and installed into
a VirtualBox VM for you when you type 'vagrant up' in this
directory. So you will need VirtualBox and Vagrant installed first.

Note that this script will not check your input - if you want to
provide empty or nonsense values, I'm not sure why you'd do that,
but it's up to you.

Press <Return> to proceed.
EOMESSAGE

OK=$(dialog --title "Huginn/VirtualBox Configurator" --msgbox --stdout "$MESSAGE" 22 72)


# -- Email Parameters ----------------------------------------------------------

SMTP_DOMAIN=example.com
SMTP_USER_NAME=huginn@mail.example.com
SMTP_PASSWORD=mailpassword
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
EMAIL_FROM_ADDRESS=huginn@example.com

VALUES=$(dialog \
  --ok-label "Submit" \
  --backtitle "Configure Email" \
  --title "Email Config" \
  --form "Enter values in each field and select <Submit>" \
  --stdout \
  16 80 0 \
  "SMTP_DOMAIN"                             1 2   "$SMTP_DOMAIN"               1 42 32 0 \
  "SMTP_USER_NAME (for authentication)"     2 2   "$SMTP_USER_NAME"            2 42 32 0 \
  "SMTP_PASSWORD (for authentication)"      3 2   "$SMTP_PASSWORD"             3 42 32 0 \
  "SMTP_SERVER"                             4 2   "$SMTP_SERVER"               4 42 32 0 \
  "SMTP_PORT (25, 462, 587 etc)"            5 2   "$SMTP_PORT"                 5 42 32 0 \
  "SMTP_AUTHENTICATION (plain, login)"      6 2   "$SMTP_AUTHENTICATION"       6 42 32 0 \
  "SMTP_ENABLE_STARTTLS_AUTO (true, false)" 7 2   "$SMTP_ENABLE_STARTTLS_AUTO" 7 42 32 0 \
  "EMAIL_FROM_ADDRESS"                      8 2   "$EMAIL_FROM_ADDRESS"        8 42 32 0 )
  #                                         | |                                |  |  | |
  #                Label Vertical Offset____/ /       Field Vertical Offset____/  /  / /
  #                                          /                                   /  / /
  #              Label Horizontal Offset____/      Field Horizontal Offset______/  / /
  #                                                                               / /
  #                                    Field Length (cannot be altered if 0)_____/ /
  #                                                                               /
  #                                 Input Length (same as field length when 0)___/

[[ ${#VALUES} -gt 0 ]] || quit
readarray -t EMAIL_SETTINGS <<<"$VALUES"

SMTP_DOMAIN=${EMAIL_SETTINGS[0]}
SMTP_USER_NAME=${EMAIL_SETTINGS[1]}
SMTP_PASSWORD=${EMAIL_SETTINGS[2]}
SMTP_SERVER=${EMAIL_SETTINGS[3]}
SMTP_PORT=${EMAIL_SETTINGS[4]}
SMTP_AUTHENTICATION=${EMAIL_SETTINGS[5]}
SMTP_ENABLE_STARTTLS_AUTO=${EMAIL_SETTINGS[6]}
EMAIL_FROM_ADDRESS=${EMAIL_SETTINGS[7]}


# -- Database Parameters -------------------------------------------------------

unset VALUES

DATABASE_USERNAME=huginn
DATABASE_PASSWORD=$(genpw)
DATABASE_ROOT_PASSWORD=$(genpw)

VALUES=$(dialog \
  --ok-label "Submit" \
  --backtitle "Configure Database" \
  --title "DB Config" \
  --form "Enter values in each field and select <Submit>" \
  --stdout \
  10 80 0 \
  "DATABASE_USERNAME"                       1 2   "$DATABASE_USERNAME"         1 42 32 0 \
  "DATABASE_PASSWORD"                       2 2   "$DATABASE_PASSWORD"         2 42 32 0 \
  "DATABASE_ROOT_PASSWORD"                  3 2   "$DATABASE_ROOT_PASSWORD"    3 42 32 0 )

[[ ${#VALUES} -gt 0 ]] || quit
readarray -t DB_SETTINGS <<<"$VALUES"

DATABASE_USERNAME=${DB_SETTINGS[0]}
DATABASE_PASSWORD=${DB_SETTINGS[1]}
DATABASE_ROOT_PASSWORD=${DB_SETTINGS[2]}


# -- Miscellaneous Parameters -------------------------------------------------------

unset VALUES

LISTEN_IP=0.0.0.0
LISTEN_PORT=3000
DOMAIN=localhost
APP_SECRET_TOKEN=$(genkey)
TIMEZONE=London

VALUES=$(dialog \
  --ok-label "Submit" \
  --backtitle "Configure Miscellaneous" \
  --title "Misc Config" \
  --form "Enter values in each field and select <Submit>" \
  --stdout \
  10 80 0 \
  "LISTEN_IP"                        1 2   "$LISTEN_IP"            1 42 32 0 \
  "LISTEN_PORT"                      2 2   "$LISTEN_PORT"          2 42 32 0 \
  "DOMAIN"                           3 2   "$DOMAIN"               3 42 32 0 \
  "TIMEZONE"                         4 2   "$TIMEZONE"             4 42 32 0 \
  "APP_SECRET_TOKEN (for rails app)" 5 2   "$APP_SECRET_TOKEN"     5 42 32 64 )

[[ ${#VALUES} -gt 0 ]] || quit
readarray -t MISC_SETTINGS <<<"$VALUES"

LISTEN_IP=${MISC_SETTINGS[0]}
LISTEN_PORT=${MISC_SETTINGS[1]}
DOMAIN=${MISC_SETTINGS[2]}
TIMEZONE=${MISC_SETTINGS[3]}
APP_SECRET_TOKEN=${MISC_SETTINGS[4]}

# -- Substitute Values in Files -----------------------------------------------------

# Mail Settings
sed -i "s/^SMTP_DOMAIN=.*$/SMTP_DOMAIN=$SMTP_DOMAIN/" env
sed -i "s/^SMTP_USER_NAME=.*$/SMTP_USER_NAME=$SMTP_USER_NAME/" env
sed -i "s/^SMTP_PASSWORD=.*$/SMTP_PASSWORD=$SMTP_PASSWORD/" env
sed -i "s/^SMTP_SERVER=.*$/SMTP_SERVER=$SMTP_SERVER/" env
sed -i "s/^SMTP_PORT=.*$/SMTP_PORT=$SMTP_PORT/" env
sed -i "s/^SMTP_AUTHENTICATION=.*$/SMTP_AUTHENTICATION=$SMTP_AUTHENTICATION/" env
sed -i "s/^SMTP_ENABLE_STARTTLS_AUTO=.*$/SMTP_ENABLE_STARTTLS_AUTO=$SMTP_ENABLE_STARTTLS_AUTO/" env
sed -i "s/^EMAIL_FROM_ADDRESS=.*$/EMAIL_FROM_ADDRESS=$EMAIL_FROM_ADDRESS/" env

# DB Settings
sed -i "s/^DATABASE_USERNAME=.*/DATABASE_USERNAME=$DATABASE_USERNAME/" env
sed -i "s/^DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$DATABASE_PASSWORD/" env
sed -i "s/DATABASE_USERNAME/$DATABASE_USERNAME/g" provision.sh
sed -i "s/DATABASE_PASSWORD/$DATABASE_PASSWORD/g" provision.sh
sed -i "s/DATABASE_ROOT_PASSWORD/$DATABASE_ROOT_PASSWORD/g" provision.sh

# Misc Settings
sed -i "s/^APP_SECRET_TOKEN=.*/APP_SECRET_TOKEN=$APP_SECRET_TOKEN/" env
sed -i "s/^TIMEZONE=.*/TIMEZONE=\"$TIMEZONE\"/" env
sed -i "s/^DOMAIN=.*/DOMAIN=$DOMAIN:$LISTEN_PORT/" env
sed -ri "s/^  listen [0-9]+.[0-9]+.[0-9]+.[0-9]+:[0-9]+ default_server;/  listen $LISTEN_IP:$LISTEN_PORT default_server;/" huginn
sed -ri "s/PORT-[0-9]+/PORT-$LISTEN_PORT/" Procfile
sed -ri "s/IP-[0-9]+.[0-9]+.[0-9]+.[0-9]+/IP-$LISTEN_IP/" Procfile
sed -ri "s/guest:[0-9]+/guest:$LISTEN_PORT/" Vagrantfile
sed -ri "s/host:[0-9]+/host:$LISTEN_PORT/" Vagrantfile

echo "All done, you should be able to type 'vagrant up' to provision your"
echo "new virtual machine containing a working Huginn installation."

