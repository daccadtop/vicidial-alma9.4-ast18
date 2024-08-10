#!/bin/sh

echo "Upgrade Asterisk 18 to use ConfBridges"


cd /usr/src/
rm -rf topdialer
git clone https://github.com/daccadtop/topdialer.git
cd /usr/src/topdialer
yes | cp -rf extensions.conf /etc/asterisk/extensions.conf
mv confbridge-vicidial.conf /etc/asterisk/

tee -a /etc/asterisk/confbridge.conf <<EOF

#include confbridge-vicidial.conf
EOF

cd /usr/src/astguiclient/trunk/extras/ConfBridge/
cp * /usr/share/astguiclient/
cd /usr/share/astguiclient/
mv manager_send.php.diff vdc_db_query.php.diff vicidial.php.diff /var/www/html/agc/
patch -p0 < ADMIN_keepalive_ALL.pl.diff
patch -p0 < ADMIN_update_server_ip.pl.diff
patch -p0 < AST_DB_optimize.pl.diff
chmod +x AST_conf_update_screen.pl
patch -p0 < AST_reset_mysql_vars.pl.diff
cd /var/www/html/agc/
patch -p0 < manager_send.php.diff
patch -p0 < vdc_db_query.php.diff
patch -p0 < vicidial.php.diff

sed -i 's|vicidial_conferences|vicidial_confbridges|g' /var/www/html/vicidial/non_agent_api.php
mv /var/www/html/admin/non_agent_api.php /var/www/html/admin/BKnon_agent_api.php
cp /var/www/html/vicidial/non_agent_api.php /var/www/html/admin/
chown apache:apache /var/www/html/admin/non_agent_api.php

mv /var/www/html/agents/agents.php /var/www/html/agents/BKagents.php
mv /var/www/html/agents/agentsCB.php /var/www/html/agents/agents.php

echo "%%%%%%%%%%%%%%%Please Enter Mysql Password Or Just Press Enter if you Dont have Password%%%%%%%%%%%%%%%%%%%%%%%%%%"
mysql -u root -p << MYSQLCREOF
use asterisk;
\. /usr/src/topdialer/confbridges.sql
quit
MYSQLCREOF

/usr/share/astguiclient/ADMIN_update_server_ip.pl –-old-server_ip=10.10.10.17
