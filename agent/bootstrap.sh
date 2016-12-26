#!/bin/bash

echo Installing dependencies...
sudo apt-get update
sudo apt-get install -y unzip curl

echo Fetching Consul, Nomad...
mkdir -p /tmp/zip && cd /tmp/zip
curl -s https://releases.hashicorp.com/consul/0.7.1/consul_0.7.1_linux_amd64.zip -o consul.zip
curl -s https://releases.hashicorp.com/nomad/0.5.0-rc2/nomad_0.5.0-rc2_linux_amd64.zip -o nomad.zip

echo Installing Consul, Nomad...
sudo unzip consul.zip 
sudo unzip nomad.zip
sudo chmod +x consul nomad
sudo mv -f consul /usr/bin/consul
sudo mv -f nomad /usr/bin/nomad

sudo mkdir -p /etc/consul.d
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/consul.d
sudo chmod a+w /etc/nomad.d

echo Starting Consul, Nomad...
sudo mv -f /tmp/consul.service /etc/systemd/system/consul.service
sudo mv -f /tmp/nomad.service /etc/systemd/system/nomad.service
sudo mv -f /tmp/client.hcl /etc/nomad.d/client.hcl

ADVERTISE_IP=$(awk -F= '/PRIVATE_IP/ {print $2}' /etc/environment)
CLIENT_ADVERTISE=/etc/nomad.d/client-advertise.hcl
if [ ! -f $CLIENT_ADVERTISE ]; then
	cat << EOF > $CLIENT_ADVERTISE

advertise {
  http = "$ADVERTISE_IP"
  rpc  = "$ADVERTISE_IP"
  serf = "$ADVERTISE_IP"
}

EOF
fi

sudo systemctl daemon-reload

sudo systemctl restart consul
sudo systemctl enable consul

sudo systemctl restart nomad
sudo systemctl enable nomad