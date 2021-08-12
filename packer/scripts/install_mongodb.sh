#!/bin/bash
#DEBIAN_FRONTEND=noninteractive
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sleep 30s
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get install -y apt-transport-https ca-certificates
apt-get update
apt-get install -y mongodb-org
systemctl start mongod
systemctl enable mongod
