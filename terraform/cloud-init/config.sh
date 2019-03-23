#!/bin/bash

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install -y azure-cli libssl-dev libffi-dev python-dev python-pip
sudo pip install ansible[azure]

cd $HOME

git clone https://github.com/cwebbtw/azure-concourseci.git

cd azure-concourseci/ansible

ansible-playbook --connection=local --inventory localhost, tasks/main.yml

exit 0
