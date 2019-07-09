#!/bin/sh
set -x

OS_FLAVOR=$(grep ID | sed -n 1p |cut -d'=' -f2 < /etc/os-release)
VERSION=$(grep VERSION_ID | sed -n 1p |cut -d\" -f2 < /etc/os-release)
centos=centos
ubuntu=ubuntu

if [ "$OS_FLAVOR" -eq "$centos" ] && [ "$VERSION" -eq 7 ]; then
	echo "----------- Installing Dependacy for CentOS 7 ----------------- "
	yum groupinstall "Development Tools" -y
    yum install pcre pcre-devel zlib zlib-devel openssl openssl-devel -y

elif [ "$OS_FLAVOR" -eq "$ubuntu" ] && [ "$VERSION" -ge 15 ]; then
    echo " Installing Dependacy for Ubuntu $VERSION"
    apt-get install build-essentials -y
    apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev -y

else

	echo " Unsupported OS VERSION ...Try with CentOS 7 or ubuntu 15+ "
fi


nginx-version='1.17.1'  # Set the version you want to install
echo "------------ Downloading binary nginx-\"$(nginx-version)\" from source ------------- "
cd opt/ && wget http://nginx.org/download/nginx-"$(nginx-version)".tar.gz

echo "-------------- Extracting tar file ----------"
tar -zxvf nginx-"$(nginx-version)".tar.gz
cd nginx-"$(nginx-version)"/ || exit


echo " ---------- Setting up some common flags by custom configurtion ------------"
./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module

echo "------------- Compile the Source  and  Install the compiled source ------------- "
make && make install

echo "---------- Check the configuration file exists------------"

ls -lsrt /usr/bin/nginx || exit
ngnix -V || exit

echo "============= CREATE SYSTEMD SERVICE ============="

cat <<EOT >> /lib/systemd/system/nginx.service

[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/bin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOT


echo "------------- Enable & Start nginx ------------"
systemctl enable nginx &&  systemctl start nginx
