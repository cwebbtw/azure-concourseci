#!/bin/bash

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Install Azure CLI and ansible together due to known compatibility issues
apt-get update
apt-get install apt-transport-https -y azure-cli libssl-dev libffi-dev python-dev python-pip
pip install ansible[azure]

cd /root

git clone https://github.com/cwebbtw/azure-concourseci.git

cd azure-concourseci/ansible

# Concourse requires being told its external URL
export EXTERNAL_URL=%EXTERNAL_URL%

ansible-playbook --connection=local --inventory localhost, playbook.yml --tags all

exit 0
