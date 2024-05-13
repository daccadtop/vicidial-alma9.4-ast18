
# TOP DIALER AUTO INSTALLER


```

hostnamectl set-hostname xxxxxx.xxxxx.xxx
### Use YOUR SubDomain

vi /etc/hosts
##Change domain name for actual server ip (xxx.xxx.xxx.xxx   complete domain name    subdomain only)

timedatectl set-timezone America/New_York

yum check-update
yum update -y
yum -y install epel-release
yum update -y
yum install git -y
yum install -y kernel*

#Disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config    

cd /usr/src/
git clone https://github.com/daccadtop/topdialer.git

reboot

````
  Reboot Before running this script

# Install TOP DIALER scripts

```
cd /usr/src/
git clone https://github.com/daccadtop/topdialer.git
cd topdialer
```

# Alma/Rocky 9 Installer TOP DIALER GUI, SSL Cert and Asterisk 11

```
cd /usr/src/topdialer
chmod +x alma-rocky9-ast11.sh
./alma-rocky9-ast11.sh
```

# Alma/Rocky 9 Installer TOP DIALER GUI, SSL Cert and Asterisk 16

```
cd /usr/src/topdialer
chmod +x alma-rocky9-ast16.sh
./alma-rocky9-ast16.sh
```

Make sure you update your SSL cert location in /etc/httpd/conf.d/viciportal-ssl.conf

# Alma/Rocky 9 Installer TOP DIALER GUI, SSL cert with Asterisk 18

```
cd /usr/src/topdialer
chmod +x alma-rocky9-ast18.sh
./alma-rocky9-ast18.sh
```

Make sure you update your SSL cert location in /etc/httpd/conf.d/viciportal-ssl.conf

# Install a default database with everything setup ready to go

```
cd /usr/src/topdialer
chmod +x standard-db.sh
./standard-db.sh
```

# Install Webphone and SSL cert for TOP DIALER
# DO THIS IF YOU HAVE PUBLIC DOMAIN WITH PUBLIC IP ONLY

```
cd /usr/src/topdialer
chmod +x vicidial-enable-webrtc.sh
./vicidial-enable-webrtc.sh
```
