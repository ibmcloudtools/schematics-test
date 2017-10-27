#!/bin/bash
apt-get update -y
apt-get upgrade -y
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs
mkdir app
echo "All Done!"
