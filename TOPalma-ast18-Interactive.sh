#!/bin/sh

echo "TOP DIALER installation AlmaLinux/Ast18/ Interactive Mode"

# Function to ask a yes/no question
ask_yes_no() {
    local prompt="$1"
    local default="$2"
    local response

    read -p "$prompt (y/n) [default: $default]: " response
    # Set response to default if the user presses enter without any input
    response=${response:-$default}

    # Convert response to lowercase to handle both 'y' and 'Y'
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    # Interpret any input other than 'y' as 'n'
    if [[ "$response" == "y" ]]; then
        echo "y"
    else
        echo "n"
    fi
}

# Function to ask for general input
ask_input() {
    local prompt="$1"
    local default="$2"
    read -p "$prompt [default: $default]: " response
    response=${response:-$default}
    echo "$response"
}

# Question 1
CONTINUE_INSTALL=$(ask_yes_no "Are you ready for the installation?" "y")
if [[ "$CONTINUE_INSTALL" == "n" ]]; then
    echo "Installation aborted."
    exit 0
fi

# Question 2
CLUSTER_INSTALL=$(ask_yes_no "Is this a cluster installation?" "y")
if [[ "$CLUSTER_INSTALL" == "n" ]]; then
    SS_INSTALL="y"
    echo "Single server installation script coming soon."
fi

# Internal IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
EXTERNAL_IP=$(curl -s checkip.amazonaws.com)
echo "The Internal IP address found was $LOCAL_IP."
USE_IP=$(ask_yes_no "Do you want to use this IP address for this server?" "y")
if [[ $USE_IP == "n" || $USE_IP == "N" ]]; then
    read -p "Please enter the IP address for this server: " LOCAL_IP
fi

# Question 3
USE_DATABASE=$(ask_yes_no "Will this server be used as the Database?" "y")
if [[ "$USE_DATABASE" == "y" ]]; then
    db_username=$(ask_input "DB Username" "cron")
    db_password=$(ask_input "DB Password" "1234")
    db_name=$(ask_input "DB Name" "asterisk")
    db_custom_username=$(ask_input "DB Custom Username" "custom")
    db_custom_password=$(ask_input "DB Custom Password" "custom1234")
    db_port=$(ask_input "DB Port" "3306")
    db_slave_user=$(ask_input "DB Slave User" "slave")
    db_slave_pass=$(ask_input "DB Slave Pass" "slave1234")
else
    db_server_ip=$(ask_input "DB Server IP" "$LOCAL_IP")
    db_username=$(ask_input "DB Username" "cron")
    db_password=$(ask_input "DB Password" "1234")
    db_name=$(ask_input "DB Name" "asterisk")
    db_custom_username=$(ask_input "DB Custom Username" "custom")
    db_custom_password=$(ask_input "DB Custom Password" "custom1234")
    db_port=$(ask_input "DB Port" "3306")
    db_slave_user=$(ask_input "DB Slave User" "slave")
    db_slave_pass=$(ask_input "DB Slave Pass" "slave1234")
fi

# Question 4
USE_WEB=$(ask_yes_no "Will this server be used as a Web server?" "y")

# Question 5
USE_TELEPHONY=$(ask_yes_no "Will this server be used as a Telephony server?" "y")
if [[ $USE_TELEPHONY == "y" ]]; then
        FIRST_TELEPHONY=$(ask_yes_no "Is this your Telephony server?" "y")
fi

# Question 6
USE_ARCHIVE=$(ask_yes_no "Will this server be used as an Archive server?" "y")

# Question 7
USE_TDGUI=$(ask_yes_no "Will this server use the TOP DIALER GUI?" "n")

if [[ $USE_TELEPHONY == "y" || $USE_WEB == "y" ]]; then
        domain_name=$(ask_input "Please set your Domain Name" "xxxx.xxxxxx.xxx")
        admin_email=$(ask_input "Domain Admin Email Address" "certs@topit.solutions")
fi

SERVER_ID=$(ask_input "Please set an ID for your server:(No space or special char)" "topd")

SERVER_DESC=$(ask_input "Please set a Description for your server" "top test")

# Print summary
echo -e "\nInstallation Summary:"
echo "Cluster installation: $CLUSTER_INSTALL"
echo "Server IP: $LOCAL_IP"
echo "External Server IP: $EXTERNAL_IP"
echo "Used as Database: $USE_DATABASE"
if [[ "$USE_DATABASE" == "y" ]]; then
    echo "DB Username: $db_username"
    echo "DB Password: $db_password"
    echo "DB Name: $db_name"
    echo "DB Custom Username: $db_custom_username"
    echo "DB Custom Password: $db_custom_password"
    echo "DB Port: $db_port"
    echo "DB Slave User: $db_slave_user"
    echo "DB Slave Pass: $db_slave_pass"
else
    echo "DB Server IP: $db_server_ip"
    echo "DB Username: $db_username"
    echo "DB Password: $db_password"
    echo "DB Custom Username: $db_custom_username"
    echo "DB Custom Password: $db_custom_password"
    echo "DB Port: $db_port"
    echo "DB Slave User: $db_slave_user"
    echo "DB Slave Pass: $db_slave_pass"
fi
echo "Used as Web server: $USE_WEB"
echo "Used as Telephony server: $USE_TELEPHONY"
echo "First Telephony server: $FIRST_TELEPHONY"
echo "Used as Archive server: $USE_ARCHIVE"
echo "Used as TOP DIALER GUI: $USE_TDGUI"
echo "Your Server ID: $SERVER_ID"
echo "Your Server Description: $SERVER_DESC"

# Ask if the user wants to continue
CONTINUE_INSTALL_FINAL=$(ask_yes_no "Do you want to continue with the installation?" "y")
if [[ "$CONTINUE_INSTALL_FINAL" == "y" ]]; then
    echo "Installation started, sit tight."
sleep 5
export LC_ALL=C

yum groupinstall "Development Tools" -y

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum -y install yum-utils
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
dnf module enable php:remi-7.4 -y
dnf module enable mariadb:10.5 -y

dnf -y install dnf-plugins-core

yum install -y php screen php-mcrypt subversion php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-opcache -y 
yum in -y wget unzip make patch gcc gcc-c++ subversion php php-devel php-gd gd-devel readline-devel php-mbstring php-mcrypt 
yum in -y php-imap php-ldap php-mysqli php-odbc php-pear php-xml php-xmlrpc curl curl-devel perl-libwww-perl ImageMagick 
sleep 3
yum in -y newt-devel libxml2-devel kernel-devel sqlite-devel libuuid-devel sox sendmail lame-devel htop iftop perl-File-Which
yum in -y php-opcache libss7 mariadb-devel libss7* libopen*
yum in -y initscripts
yum copr enable irontec/sngrep -y
dnf install sngrep -y

dnf --enablerepo=crb install libsrtp-devel -y
dnf config-manager --set-enabled crb
yum install libsrtp-devel -y

tee -a /etc/httpd/conf/httpd.conf <<EOF

CustomLog /dev/null common

Alias /RECORDINGS/MP3 "/var/spool/asterisk/monitorDONE/MP3/"

<Directory "/var/spool/asterisk/monitorDONE/MP3/">
    Options Indexes MultiViews
    AllowOverride None
    Require all granted
</Directory>
EOF

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

tee -a /etc/php.ini <<EOF

error_reporting  =  E_ALL & ~E_NOTICE
memory_limit = 448M
short_open_tag = On
max_execution_time = 3330
max_input_time = 3360
post_max_size = 448M
upload_max_filesize = 442M
default_socket_timeout = 3360
date.timezone = America/New_York
EOF

systemctl restart httpd

yum in -y sqlite-devel httpd mod_ssl nano chkconfig htop atop mytop iftop
yum in -y libedit-devel uuid* libxml2* speex-devel speex* postfix dovecot s-nail roundcubemail inxi
dnf install -y mariadb-server mariadb

dnf -y install dnf-plugins-core
dnf config-manager --set-enabled powertools

cp /etc/my.cnf /etc/my.cnf.original
echo "" > /etc/my.cnf
cd /usr/src/topdialer
#wget https://topt.topdialer.solutions:8080/autoinstall/mysqlconf.tar.gz
wget http://10.7.78.25/autoinstall/mysqlconf.tar.gz
tar -xzf mysqlconf.tar.gz
cat my.cnf > /etc/my.cnf

mkdir /var/log/mysqld
touch /var/log/mysqld/slow-queries.log
chown -R mysql:mysql /var/log/mysqld
systemctl restart mariadb

systemctl restart httpd.service

#Install Perl Modules

echo "Install Perl"

yum install -y perl-CPAN perl-YAML perl-CPAN-DistnameInfo perl-libwww-perl perl-DBI perl-DBD-MySQL perl-GD perl-Env perl-Term-ReadLine-Gnu perl-SelfLoader perl-open.noarch 

#CPM install
cd /usr/src/topdialer
curl -fsSL https://raw.githubusercontent.com/skaji/cpm/main/cpm | perl - install -g App::cpm
/usr/local/bin/cpm install -g

read -p 'Press Enter to continue: '
#Install Asterisk Perl
cd /usr/src
wget http://download.vicidial.com/required-apps/asterisk-perl-0.08.tar.gz
tar xzf asterisk-perl-0.08.tar.gz
cd asterisk-perl-0.08
perl Makefile.PL
make all
make install 

yum install libsrtp-devel -y
yum install -y elfutils-libelf-devel libedit-devel


#Install Lame
cd /usr/src
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar -zxf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure
make
make install


#Install Jansson
cd /usr/src/
wget https://digip.org/jansson/releases/jansson-2.13.tar.gz
tar xvzf jansson*
cd jansson-2.13
./configure
make clean
make
make install 
ldconfig

#Install Dahdi
echo "Install Dahdi"
ln -sf /usr/lib/modules/$(uname -r)/vmlinux.xz /boot/
mkdir /etc/include
cp /usr/src/topdialer/newt.h /etc/include/

cd /usr/src/
mkdir dahdi-linux-complete-3.4.0+3.4.0
cd dahdi-linux-complete-3.4.0+3.4.0
#cp /usr/src/topdialer/dahdi-alma9.zip /usr/src/dahdi-linux-complete-3.2.0+3.2.0/
#wget https://topt.topdialer.solutions:8080/autoinstall/dahdi-alma9-4.tar.gz
wget http://10.7.78.25/autoinstall/dahdi-alma9-4.tar.gz
tar -xzf dahdi-alma9-4.tar.gz
yum in newt* -y

##sudo sed -i 's|(netdev, \&wc->napi, \&wctc4xxp_poll, 64);|(netdev, \&wc->napi, \&wctc4xxp_poll);|g' /usr/src/dahdi-linux-complete-3.2.0+3.2.0/linux/drivers/dahdi/wctc4xxp/base.c
##sudo sed -i 's|<linux/pci-aspm.h>|<linux/pci.h>|g' /usr/src/dahdi-linux-complete-3.2.0+3.2.0/linux/include/dahdi/kernel.h

make clean
make
make install
make install-config

yum -y install dahdi-tools-libs

cd tools
make clean
make
make install
make install-config

cp /etc/dahdi/system.conf.sample /etc/dahdi/system.conf
modprobe dahdi
modprobe dahdi_dummy
/usr/sbin/dahdi_cfg -vvvvvvvvvvvvv

systemctl enable dahdi
service dahdi start
service dahdi status

if [[ "$USE_TELEPHONY" == "y" ]]; then
read -p 'Press Enter to continue: '
fi

echo 'Continuing...'

#Install Asterisk and LibPRI
mkdir /usr/src/asterisk
cd /usr/src/asterisk
wget https://downloads.asterisk.org/pub/telephony/libpri/libpri-1.6.1.tar.gz
wget https://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-18.18.1.tar.gz
tar -xvzf asterisk-*
tar -xvzf libpri-*

cd /usr/src
wget https://github.com/cisco/libsrtp/archive/v2.1.0.tar.gz
tar xfv v2.1.0.tar.gz
cd libsrtp-2.1.0
./configure --prefix=/usr --enable-openssl
make shared_library && sudo make install
ldconfig

cd /usr/src/asterisk/asterisk-18.18.1/
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/amd_stats-18.patch
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/iax_peer_status-18.patch
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/sip_peer_status-18.patch
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/timeout_reset_dial_app-18.patch
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/timeout_reset_dial_core-18.patch
cd apps/
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/enter.h
wget http://download.vicidial.com/asterisk-patches/Asterisk-18/leave.h
yes | cp -rf enter.h.1 enter.h
yes | cp -rf leave.h.1 leave.h

cd /usr/src/asterisk/asterisk-18.18.1/
patch < amd_stats-18.patch apps/app_amd.c
patch < iax_peer_status-18.patch channels/chan_iax2.c
patch < sip_peer_status-18.patch channels/chan_sip.c
patch < timeout_reset_dial_app-18.patch apps/app_dial.c
patch < timeout_reset_dial_core-18.patch main/dial.c

yum in libuuid-devel libxml2-devel -y

: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}
./configure --libdir=/usr/lib64 --with-gsm=internal --enable-opus --enable-srtp --with-ssl --enable-asteriskssl --with-pjproject-bundled --with-jansson-bundled

make menuselect/menuselect menuselect-tree menuselect.makeopts
#enable app_meetme
menuselect/menuselect --enable app_meetme menuselect.makeopts
#enable res_http_websocket
menuselect/menuselect --enable res_http_websocket menuselect.makeopts
#enable res_srtp
menuselect/menuselect --enable res_srtp menuselect.makeopts
make samples
sed -i 's|noload = chan_sip.so|;noload = chan_sip.so|g' /etc/asterisk/modules.conf
make -j ${JOBS} all
make install

if [[ "$USE_TELEPHONY" == "y" ]]; then
read -p 'Press Enter to continue: '
fi

echo 'Continuing...'

#Install astguiclient
echo "Installing astguiclient"
mkdir /usr/src/astguiclient
cd /usr/src/astguiclient
svn checkout svn://svn.eflo.net/agc_2-X/trunk
cd /usr/src/astguiclient/trunk

if [[ "$USE_DATABASE" == "y" ]]; then
#Add mysql users and Databases
mysql -u root <<MYSQLCREOF
CREATE DATABASE asterisk DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'cron'@'localhost' IDENTIFIED BY '$db_password';
GRANT SELECT, CREATE, ALTER, INSERT, UPDATE, DELETE, LOCK TABLES ON asterisk.* TO 'cron'@'%' IDENTIFIED BY '$db_password';
GRANT SELECT, CREATE, ALTER, INSERT, UPDATE, DELETE, LOCK TABLES ON asterisk.* TO 'cron'@'localhost' IDENTIFIED BY '$db_password';
GRANT RELOAD ON *.* TO 'cron'@'%';
GRANT RELOAD ON *.* TO 'cron'@'localhost';
CREATE USER 'custom'@'localhost' IDENTIFIED BY '$db_custom_password';
GRANT SELECT, CREATE, ALTER, INSERT, UPDATE, DELETE, LOCK TABLES ON asterisk.* TO 'custom'@'%' IDENTIFIED BY '$db_custom_password';
GRANT SELECT, CREATE, ALTER, INSERT, UPDATE, DELETE, LOCK TABLES ON asterisk.* TO 'custom'@'localhost' IDENTIFIED BY '$db_custom_password';
GRANT RELOAD ON *.* TO 'custom'@'%';
GRANT RELOAD ON *.* TO 'custom'@'localhost';
CREATE USER 'slave'@'localhost' IDENTIFIED BY '$db_slave_pass';
GRANT SELECT, CREATE, ALTER, INSERT, UPDATE, DELETE, LOCK TABLES ON asterisk.* TO 'slave'@'%' IDENTIFIED BY '$db_slave_pass';
GRANT SELECT, CREATE, ALTER, INSERT, UPDATE, DELETE, LOCK TABLES ON asterisk.* TO 'slave'@'localhost' IDENTIFIED BY '$db_slave_pass';
GRANT RELOAD ON *.* TO 'slave'@'%';
GRANT RELOAD ON *.* TO 'slave'@'localhost';
FLUSH PRIVILEGES;

SET GLOBAL connect_timeout=60;

USE asterisk;
\. /usr/src/astguiclient/trunk/extras/MySQL_AST_CREATE_tables.sql
QUIT
MYSQLCREOF

read -p 'Press Enter to continue: '
fi

echo 'Continuing...'

#Get astguiclient.conf file
cd /usr/src/topdialer
#wget https://topt.topdialer.solutions:8080/autoinstall/astgui.tar.gz
wget http://10.7.78.25/autoinstall/astgui.tar.gz
tar -xzf astgui.tar.gz
cp astguiclient.conf /etc/astguiclient.conf

echo "Replace Default parameters"
if [[ "$USE_DATABASE" == "y" ]]; then    
    sed -i s/MAINDBIP/localhost/g /etc/astguiclient.conf
    if [[ "$USE_TELEPHONY" == "y" ]]; then
        sed -i s/SKEEPALIVES/123456789ESC/g /etc/astguiclient.conf
    else
        sed -i s/SKEEPALIVES/579EC/g /etc/astguiclient.conf
    fi
else
    if [[ "$USE_TELEPHONY" != "y" ]]; then
        sed -i s/MAINDBIP/"$db_server_ip"/g /etc/astguiclient.conf
        sed -i s/SKEEPALIVES/X/g /etc/astguiclient.conf
    else
        sed -i s/MAINDBIP/"$db_server_ip"/g /etc/astguiclient.conf
        sed -i s/SKEEPALIVES/123468SC/g /etc/astguiclient.conf
    fi
fi
sed -i s/SERVERIP/"$LOCAL_IP"/g /etc/astguiclient.conf
sed -i s/DBNAME/"$db_name"/g /etc/astguiclient.conf
sed -i s/DBUSER/"$db_username"/g /etc/astguiclient.conf
sed -i s/DBPASS/"$db_password"/g /etc/astguiclient.conf
sed -i s/CUSER/"$db_custom_username"/g /etc/astguiclient.conf
sed -i s/CPASS/"$db_custom_password"/g /etc/astguiclient.conf
sed -i s/DBPORT/"$db_port"/g /etc/astguiclient.conf

echo "Install VICIDIAL"
cd /usr/src/astguiclient/trunk
perl install.pl --no-prompt --copy_sample_conf_files=Y

#Secure Manager 
sed -i s/0.0.0.0/127.0.0.1/g /etc/asterisk/manager.conf

if [[ "$USE_DATABASE" == "y" && "$USE_TELEPHONY" != "y" ]]; then
    {
    echo "INSERT INTO servers (server_id,server_description,server_ip,active,asterisk_version)values('$SERVER_ID','$SERVER_DESC', '$LOCAL_IP','Y','18.18.1');"
    echo "UPDATE servers SET active_asterisk_server='N', active_agent_login_server='N' WHERE server_id='$SERVER_ID';"
    } | mysql -u "$db_username" -p"$db_password" -D "$db_name"
    else
if [[ "$USE_TELEPHONY" == "y" ]]; then
    if [[ "$FIRST_TELEPHONY" == "y" ]]; then
        sed "s/10.10.10.15/$LOCAL_IP/g" /usr/src/astguiclient/trunk/extras/first_server_install.sql > /usr/src/topdialer/firstserver.sql
        sed -i "s/TESTast/$SERVER_ID/g" /usr/src/topdialer/firstserver.sql
        sed -i "s/Test install of Asterisk server/$SERVER_DESC/g" /usr/src/topdialer/firstserver.sql
        echo "" >> /usr/src/topdialer/firstserver.sql && cat /usr/src/topdialer/confbridges.sql >> /usr/src/topdialer/firstserver.sql 
        sed -i "s/10.10.10.17/$LOCAL_IP/g" /usr/src/topdialer/firstserver.sql
        if [[ "$USE_DATABASE" == "y" ]]; then
            {
              cat /usr/src/topdialer/firstserver.sql
              echo "UPDATE servers SET asterisk_version='16.30.0', max_vicidial_trunks='200', external_server_ip='$EXTERNAL_IP', conf_engine='CONFBRIDGE' WHERE server_id='$SERVER_ID';"
            } | mysql -u "$db_username" -p"$db_password" -D "$db_name"
        else
            {
              cat /usr/src/topdialer/firstserver.sql
              echo "UPDATE servers SET asterisk_version='16.30.0', max_vicidial_trunks='200', external_server_ip='$EXTERNAL_IP', conf_engine='CONFBRIDGE' WHERE server_id='$SERVER_ID';"
            } | mysql -h "$db_server_ip" -u "$db_username" -p"$db_password" -D "$db_name"
        fi
    else
        sed "s/10.10.10.16/$LOCAL_IP/g" /usr/src/astguiclient/trunk/extras/second_server_install.sql > /usr/src/topdialer/secondserver.sql
        sed -i "s/TESTast/$SERVER_ID/g" /usr/src/topdialer/secondserver.sql
        sed -i "s/Test install of Asterisk server/$SERVER_DESC/g" /usr/src/topdialer/secondserver.sql
        echo "" >> /usr/src/topdialer/secondserver.sql && cat /usr/src/topdialer/confbridges.sql >> /usr/src/topdialer/secondserver.sql
        sed -i "s/10.10.10.17/$LOCAL_IP/g" /usr/src/topdialer/secondserver.sql
        if [[ "$USE_DATABASE" == "y" ]]; then
            {
              cat /usr/src/topdialer/secondserver.sql
              echo "UPDATE servers SET asterisk_version='16.30.0', max_vicidial_trunks='200', external_server_ip='$EXTERNAL_IP', conf_engine='CONFBRIDGE' WHERE server_id='$SERVER_ID';"
            } | mysql -u "$db_username" -p"$db_password" -D "$db_name"
        else
            {
              cat /usr/src/topdialer/secondserver.sql
              echo "UPDATE servers SET asterisk_version='16.30.0', max_vicidial_trunks='200', external_server_ip='$EXTERNAL_IP', conf_engine='CONFBRIDGE' WHERE server_id='$SERVER_ID';"
            } | mysql -h "$db_server_ip" -u "$db_username" -p"$db_password" -D "$db_name"
        fi
    fi
fi
fi

#Add chan_sip to Asterisk 18

echo "Populate AREA CODES"
/usr/share/astguiclient/ADMIN_area_code_populate.pl
#echo "Replace OLD IP. You need to Enter your Current IP here"
#/usr/share/astguiclient/ADMIN_update_server_ip.pl --auto --old-server_ip=10.10.10.15 --server_ip=$LOCAL_IP

perl /usr/src/astguiclient/trunk/install.pl --no-prompt

#Install Crontab
if [[ "$USE_DATABASE" == "y" || "$USE_TELEPHONY" == "y" ]]; then
cd /usr/src/topdialer
#wget https://topt.topdialer.solutions:8080/autoinstall/crons.tar.gz
wget http://10.7.78.25/autoinstall/crons.tar.gz
tar -xzf crons.tar.gz
touch /root/crontab-file
cat allcron > /root/crontab-file
fi
if [[ "$USE_DATABASE" == "y" ]]; then
cat dbcron >> /root/crontab-file
fi
if [[ "$USE_TELEPHONY" == "y" ]]; then
cat dialcron >> /root/crontab-file
fi

crontab /root/crontab-file
crontab -l

#Install rc.local
sudo sed -i 's|exit 0|### exit 0|g' /etc/rc.d/rc.local
cd /usr/src/topdialer
#wget https://topt.topdialer.solutions:8080/autoinstall/rclocal.tar.gz
wget http://10.7.78.25/autoinstall/rclocal.tar.gz
tar -xzf rclocal.tar.gz
cat rc.local >> /etc/rc.d/rc.local

#Adjust rc.local as needed
# Perform actions based on the enabled services
# When USE_TELEPHONY is not true
if [ "$USE_TELEPHONY" != "y" ]; then
    echo "Disabling telephony-related services."
    sudo sed -i 's|modprobe dahdi|### modprobe dahdi|g' /etc/rc.d/rc.local
    sudo sed -i 's|modprobe dahdi_dummy|### modprobe dahdi_dummy|g' /etc/rc.d/rc.local
    sudo sed -i 's|/usr/sbin/dahdi_cfg -vvvvvvvvvvvvv|### /usr/sbin/dahdi_cfg -vvvvvvvvvvvvv|g' /etc/rc.d/rc.local
    sudo sed -i 's|/usr/share/astguiclient/start_asterisk_boot.pl|### /usr/share/astguiclient/start_asterisk_boot.pl|g' /etc/rc.d/rc.local
    sudo sed -i 's|/usr/share/astguiclient/ADMIN_restart_roll_logs.pl|### /usr/share/astguiclient/ADMIN_restart_roll_logs.pl|g' /etc/rc.d/rc.local
    sudo sed -i 's|/usr/share/astguiclient/AST_reset_mysql_vars.pl|### /usr/share/astguiclient/AST_reset_mysql_vars.pl|g' /etc/rc.d/rc.local
fi
# When USE_DATABASE is not true
if [ "$USE_DATABASE" != "y" ]; then
    echo "Disabling database-related services."
    sudo sed -i 's|systemctl start mariadb.service|### systemctl start mariadb.service|g' /etc/rc.d/rc.local
fi
if [[ "$USE_WEB" != "y" && "$USE_TELEPHONY" != "y" ]]; then
    echo "Disabling web server-related services."
    sudo sed -i 's|systemctl start httpd.service|### systemctl start httpd.service|g' /etc/rc.d/rc.local
fi

chmod +x /etc/rc.d/rc.local
systemctl enable rc-local
systemctl start rc-local

if [[ "$USE_TDGUI" == "y" ]]; then
##Install TOP DIALER GUI
cd /var/www/html
mv favicon.ico faviconBK.icoBK
mv index.html index.BKhtml
#wget https://topt.topdialer.solutions:8080/autoinstall/topdialergui.tar.gz
wget http://10.7.78.25/autoinstall/topdialergui.tar.gz
#cp /usr/src/topdialer/topdialergui.tar.gz /var/www/html/
tar -xzf topdialergui.tar.gz
chmod -R 744 admin agents auth dashboard favicon.ico index.html p_login_logo.png suspended.html
chown -R apache:apache admin agents auth dashboard favicon.ico index.html p_login_logo.png suspended.html
    if [[ "$USE_DATABASE" == "y" ]]; then
        {
            echo "UPDATE system_settings set admin_home_url='../admin/main.php', agent_script='agents.php', admin_web_directory='admin'";
        } | mysql -u "$db_username" -p"$db_password" -D "$db_name"
    else
        {
            echo "UPDATE system_settings set admin_home_url='../admin/main.php', agent_script='agents.php', admin_web_directory='admin'";
        } | mysql -h "$db_server_ip" -u "$db_username" -p"$db_password" -D "$db_name"
    fi
else
    if [ "$USE_WEB" != "y" ]; then
tee /var/www/html/index.html > /dev/null <<EOF
<html>
<body>
    <h1>It works!</h1>
</body>
</html>
EOF
    else
tee /var/www/html/index.html > /dev/null <<EOF
<META HTTP-EQUIV=REFRESH CONTENT="1; URL=/vicidial/welcome.php">
EOF
    fi
fi

##Install Dynamic firewall
cd /home/
#cp /usr/src/topdialer/topfirewall.tar.gz /home/
#wget https://topt.topdialer.solutions:8080/autoinstall/topfirewall.tar.gz
wget http://10.7.78.25/autoinstall/topfirewall.tar.gz
tar -xzf topfirewall.tar.gz

##Fix ip_relay
cd /usr/src/astguiclient/trunk/extras/ip_relay/
unzip ip_relay_1.1.112705.zip
cd ip_relay_1.1/src/unix/
make
cp ip_relay ip_relay2
mv -f ip_relay /usr/bin/
mv -f ip_relay2 /usr/local/bin/ip_relay

if [[ "$USE_TELEPHONY" == "y" ]]; then
cd /usr/lib64/asterisk/modules
wget http://asterisk.hosting.lv/bin/codec_g729-ast160-gcc4-glibc-x86_64-core2-sse4.so
mv codec_g729-ast160-gcc4-glibc-x86_64-core2-sse4.so codec_g729.so
chmod 777 codec_g729.so
fi

##Install Sounds

cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-ulaw-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-wav-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-gsm-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-ulaw-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-gsm-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-moh-opsound-gsm-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-moh-opsound-ulaw-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-moh-opsound-wav-current.tar.gz

#Place the audio files in their proper places:
cd /var/lib/asterisk/sounds
tar -zxf /usr/src/asterisk-core-sounds-en-gsm-current.tar.gz
tar -zxf /usr/src/asterisk-core-sounds-en-ulaw-current.tar.gz
tar -zxf /usr/src/asterisk-core-sounds-en-wav-current.tar.gz
tar -zxf /usr/src/asterisk-extra-sounds-en-gsm-current.tar.gz
tar -zxf /usr/src/asterisk-extra-sounds-en-ulaw-current.tar.gz
tar -zxf /usr/src/asterisk-extra-sounds-en-wav-current.tar.gz

mkdir /var/lib/asterisk/mohmp3
mkdir /var/lib/asterisk/quiet-mp3
ln -s /var/lib/asterisk/mohmp3 /var/lib/asterisk/default

cd /var/lib/asterisk/mohmp3
tar -zxf /usr/src/asterisk-moh-opsound-gsm-current.tar.gz
tar -zxf /usr/src/asterisk-moh-opsound-ulaw-current.tar.gz
tar -zxf /usr/src/asterisk-moh-opsound-wav-current.tar.gz
rm -f CHANGES*
rm -f LICENSE*
rm -f CREDITS*

cd /var/lib/asterisk/moh
rm -f CHANGES*
rm -f LICENSE*
rm -f CREDITS*

cd /var/lib/asterisk/sounds
rm -f CHANGES*
rm -f LICENSE*
rm -f CREDITS*

yum -y in sox

cd /var/lib/asterisk/quiet-mp3
sox ../mohmp3/macroform-cold_day.wav macroform-cold_day.wav vol 0.25
sox ../mohmp3/macroform-cold_day.gsm macroform-cold_day.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/macroform-cold_day.ulaw -t ul macroform-cold_day.ulaw vol 0.25
sox ../mohmp3/macroform-robot_dity.wav macroform-robot_dity.wav vol 0.25
sox ../mohmp3/macroform-robot_dity.gsm macroform-robot_dity.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/macroform-robot_dity.ulaw -t ul macroform-robot_dity.ulaw vol 0.25
sox ../mohmp3/macroform-the_simplicity.wav macroform-the_simplicity.wav vol 0.25
sox ../mohmp3/macroform-the_simplicity.gsm macroform-the_simplicity.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/macroform-the_simplicity.ulaw -t ul macroform-the_simplicity.ulaw vol 0.25
sox ../mohmp3/reno_project-system.wav reno_project-system.wav vol 0.25
sox ../mohmp3/reno_project-system.gsm reno_project-system.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/reno_project-system.ulaw -t ul reno_project-system.ulaw vol 0.25
sox ../mohmp3/manolo_camp-morning_coffee.wav manolo_camp-morning_coffee.wav vol 0.25
sox ../mohmp3/manolo_camp-morning_coffee.gsm manolo_camp-morning_coffee.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/manolo_camp-morning_coffee.ulaw -t ul manolo_camp-morning_coffee.ulaw vol 0.25

tee -a ~/.bashrc <<EOF
# Commands
/usr/share/astguiclient/ADMIN_keepalive_ALL.pl --cu3way
/usr/bin/systemctl status httpd --no-pager
#/usr/bin/systemctl status firewalld --no-pager
/usr/bin/screen -ls
/usr/sbin/dahdi_cfg -v
/usr/sbin/asterisk -V
EOF
# Perform actions based on the enabled services
# When USE_TELEPHONY is not true
if [ "$USE_TELEPHONY" != "y" ]; then
    echo "Disabling telephony-related services."
    sudo sed -i 's|/usr/sbin/dahdi_cfg|### /usr/sbin/dahdi_cfg|g' ~/.bashrc
    sudo sed -i 's|/usr/sbin/asterisk|### /usr/sbin/asterisk|g' ~/.bashrc
fi
# When USE_DATABASE is true
if [[ "$USE_WEB" != "y" && "$USE_TELEPHONY" != "y" ]]; then
    echo "Disabling web server-related services."
    sudo sed -i 's|/usr/bin/systemctl status http|### /usr/bin/systemctl status http|g' ~/.bashrc
fi

sed -i 's|#Banner none|Banner /etc/ssh/sshd_banner|g' /etc/ssh/sshd_config
tee -a /etc/ssh/sshd_banner <<EOF
Thank you for choosing TOP IT SOLUTIONS!
https://www.topit.solutions
EOF

#add rc-local as a service - thx to ras
tee -a /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local Compatibility

[Service]
Type=oneshot
ExecStart=/etc/rc.local
TimeoutSec=0
StandardInput=tty
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

##fstab entry
tee -a /etc/fstab <<EOF
none /var/spool/asterisk/monitor tmpfs nodev,nosuid,noexec,nodiratime,size=2G 0 0
EOF

systemctl daemon-reload
sudo systemctl enable rc-local.service
sudo systemctl start rc-local.service

chmod 775 /var/spool/asterisk/
chkconfig asterisk off

##Password Encryption
if [ "$USE_DATABASE" == "y" ]; then
cat "yes" |  cpan -T Crypt::Eksblowfish::Bcrypt
/usr/share/astguiclient/ADMIN_bcrypt_convert.pl --debugX --test
/usr/share/astguiclient/ADMIN_bcrypt_convert.pl --debugX
fi

##ConfBridge Setup
if [ "$USE_TELEPHONY" == "y" ]; then
##./vicidial-enable-confbridge.sh
cd /usr/src/topdialer
cp /etc/asterisk/extensions.conf /etc/asterisk/extensions.bk
awk '/include => vicidial-auto/ {print; system("cat /usr/src/topdialer/confbridge_ext.conf"); next} 1' /etc/asterisk/extensions.conf > /etc/asterisk/TempFile && mv -f /etc/asterisk/TempFile /etc/asterisk/extensions.conf
mv -f confbridge-vicidial.conf /etc/asterisk/

tee -a /etc/asterisk/confbridge.conf <<EOF

#include confbridge-vicidial.conf
EOF
tee -a /etc/asterisk/modules.conf <<EOF

noload => res_timing_timerfd.so
noload => res_timing_kqueue.so
noload => res_timing_pthread.so
EOF
tee -a /etc/asterisk/manager.conf <<EOF

[confcron]
secret = 1234
read = command,reporting
write = command,reporting

eventfilter=Event: Meetme
eventfilter=Event: Confbridge
EOF
fi

chmod -R 777 /var/spool/asterisk/monitorDONE
chown -R apache:apache /var/spool/asterisk/monitorDONE

# Perform actions based on the enabled services
    sudo systemctl enable asterisk
    sudo systemctl enable mariadb
    sudo systemctl enable httpd
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
# When USE_TELEPHONY is not true
if [ "$USE_TELEPHONY" != "y" ]; then
    echo "Disabling telephony-related services."
    sudo systemctl stop asterisk
    sudo systemctl disable asterisk
fi
# When USE_DATABASE is not true
if [ "$USE_DATABASE" != "y" ]; then
    echo "Disabling web server-related services."
    sudo systemctl stop mariadb
    sudo systemctl disable mariadb
fi
if [[ "$USE_WEB" != "y" && "$USE_TELEPHONY" != "y" ]]; then
    echo "Disabling web server-related services."
    sudo systemctl stop httpd
    sudo systemctl disable httpd
fi

# SSL Certificate
if [[ "$USE_WEB" == "y" || "$USE_TELEPHONY" == "y" ]]; then
echo "Install certbot for LetsEncrypt"
cd /usr/src/topdialer
#wget https://topt.topdialer.solutions:8080/autoinstall/webrtc.tar.gz
wget http://10.7.78.25/autoinstall/webrtc.tar.gz
tar -xzf webrtc.tar.gz

cp DOMAINNAME.conf /etc/httpd/conf.d/$domain_name.conf
sed -i "s/DOMAINNAME/$domain_name/g" /etc/httpd/conf.d/$domain_name.conf
sed -i "s/DOMAINADMIN/$admin_email/g" /etc/httpd/conf.d/$domain_name.conf

mv /etc/asterisk/http.conf /etc/asterisk/http.BKconf
cp asterisk-http.conf /etc/asterisk/http.conf

mv /etc/asterisk/sip.conf /etc/asterisk/sip.BKconf
cp asterisk-sip.conf /etc/asterisk/sip.conf
sed -i "s/DOMAINNAME/$domain_name/g" /etc/asterisk/sip.conf

yum -y install certbot python3-certbot-apache mod_ssl
systemctl enable certbot-renew.timer
systemctl start certbot-renew.timer
service firewalld stop

certbot --apache --agree-tos -d $domain_name -m $admin_email -n

ln -s /etc/letsencrypt/live/$domain_name/cert.pem /etc/httpd/conf.d/topcert.pem
ln -s /etc/letsencrypt/live/$domain_name/privkey.pem /etc/httpd/conf.d/topprivkey.pem
ln -s /etc/letsencrypt/live/$domain_name/fullchain.pem /etc/httpd/conf.d/topfullchain.pem

sed -i "s/DOMAINNAME/$domain_name/g" /usr/src/topdialer/webrtc.sql
sed -i "s/SERVERID/$SERVER_ID/g" /usr/src/topdialer/webrtc.sql
    
    if [[ "$USE_DATABASE" == "y" ]]; then
        {
          cat /usr/src/topdialer/webrtc.sql
        } | mysql -u "$db_username" -p"$db_password" -D "$db_name"
    else
        {
          cat /usr/src/topdialer/webrtc.sql
        } | mysql -h "$db_server_ip" -u "$db_username" -p"$db_password" -D "$db_name"
    fi
read -p 'If you had any issues during the certificate process please make sure install it manually, press enter to continue:'
echo "Reloading apache"
systemctl restart httpd
fi

read -p 'Press Enter to Reboot: '

echo "Restarting AlmaLinux"

reboot

else
    echo "Installation aborted."
    exit 0
fi
