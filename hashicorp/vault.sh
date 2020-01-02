#!/bin/bash

echo -e " Listing available Vault versions...\n$(curl -s https://releases.hashicorp.com/vault/ | grep "a href" | cut -d '"' -f2 | grep "vault" | cut -d '/' -f3)"
#curl -s https://releases.hashicorp.com/vault/ | grep "a href" | cut -d '"' -f2 | grep "vault" | cut -d '/' -f3

# Select The version to Install
read -p "Select the version of Vault ....: " VERSION
echo $VERSION
wget  https://releases.hashicorp.com/vault/"${VERSION}"/vault_"${VERSION}"_linux_amd64.zip

unzip -qq vault_"${VERSION}"_linux_amd64.zip -d .


sudo cp -rf vault /usr/bin/
sudo mkdir -p  /etc/vault || true                    # Store Vault Configuration Files
sudo mkdir -p /opt/vault-data || true               # Store Secrets
sudo mkdir -p /logs/vault/  || true              # Store Vault Logs



# Setup Vault Configuration
IP="192.168.1.10" # Update the IP as per ifconfig output
cat <<EOF >/etc/vault/config.json

{
"listener": [{
"tcp": {
"address" : "0.0.0.0:8200",
"tls_disable" : 1
}
}],
"api_addr": "http://$IP:8200",
"storage": {
    "file": {
    "path" : "/opt/vault-data"
    }
 },
"max_lease_ttl": "1h",
"default_lease_ttl": "1h",
"ui":true
}
EOF


# Update as Service
cat <<EOF >/etc/systemd/system/vault.service
[Unit]
Description=vault service
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault/config.json

[Service]
EnvironmentFile=-/etc/sysconfig/vault
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/bin/vault server -config=/etc/vault/config.json
StandardOutput=/logs/vault/output.log
StandardError=/logs/vault/error.log
LimitMEMLOCK=infinity
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF


# Enable Service and  Start Service
systemctl enable vault.service && systemctl start vault.service


# Get the status of VAULT

systemctl status vault.service
