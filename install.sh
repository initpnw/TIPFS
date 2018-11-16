#!/usr/bin/env bash

sudo mkdir -p /opt/tipfs
sudo cp -r * /opt/tipfs
sudo chmod -R 755 /opt/tipfs/bin
echo 'export PATH=$PATH:/opt/tipfs/bin' >> ~/.bash_aliases

