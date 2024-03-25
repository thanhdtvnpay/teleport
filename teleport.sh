#!/bin/bash
pkill -f teleport
rm -rf /etc/teleport.yaml
rm -rf /var/lib/teleport
rm -rf /etc/systemd/system/teleport-node.service
curl https://goteleport.com/static/install.sh | bash -s 14.3.4
labels=$(hostname)
ip_address=$(hostname -I | awk '{print $1}')
echo "1. hcm-jump.poc.vnshop.cloud
2. hni-jump.poc.vnshop.cloud
Hi, please choose the number of server: "
read word
if [ $word -eq 1 ]
then
server="hcm-jump.poc.vnshop.cloud"
else
if [ $word -eq 2 ]
then
server="hni-jump.poc.vnshop.cloud"
else
echo "you enter an incorrect value, try again"
fi
fi

echo "Token key: "
read word
token=$word

touch /etc/teleport.yaml
echo "teleport:
  auth_token: $token
  auth_servers:
   - "$server:3025"
ssh_service:
  enabled: yes
  labels:
    env: $labels
  commands:
  - name: hostname
    command: [hostname]
    period: 60m0s
  listen_addr: $ip_address:3022

auth_service:
  enabled: no
proxy_service:
  enabled: no
app_service:
  enabled: no
kubernetes_service:
  enabled: no
db_service:
  enabled: no" > /etc/teleport.yaml

touch /etc/systemd/system/teleport-node.service
echo "[Unit]
Description=Teleport Node Service
After=network.target

[Service]
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/teleport start --config=/etc/teleport.yaml --skip-version-check --pid-file=/run/teleport.pid
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/teleport.pid

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/teleport-node.service

systemctl daemon-reload
systemctl enable teleport-node.service
systemctl start teleport-node.service
systemctl status teleport-node.service
