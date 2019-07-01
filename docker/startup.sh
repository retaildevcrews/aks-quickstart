#!/bin/sh

echo "processing startup script ..." > /home/aks/status

# add Docker group
groupadd docker
usermod -aG docker aks

# install some stuff
apt-get update
apt-get install -y apt-transport-https ca-certificates curl git wget nano lsb-release software-properties-common jq redis-tools gnupg-agent

git clone https://github.com/fourco/aks-quickstart /home/aks/aks

chown -R aks:aks /home/aks

echo "adding repos ..." > /home/aks/status

# add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# add dotnet repo
apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF
apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list

# add Azure CLI repo
set -v
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg
CLI_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ ${CLI_REPO} main" > /etc/apt/sources.list.d/azure-cli.list
set +v

# add kubectl repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

echo "installing ..." > /home/aks/status

# install latest version of docker compose
curl -sSL https://github.com/docker/compose/releases/download/`curl -s https://github.com/docker/compose/tags | \
grep "compose/releases/tag" | sed -r 's|.*([0-9]+\.[0-9]+\.[0-9]+).*|\1|p' | head -n 1`/docker-compose-`uname -s`-`uname -m` \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

apt-get update
apt-get install -y azure-cli
apt-get install -y docker-ce docker-ce-cli containerd.io kubectl

# apt-get install -y golang-go
# apt-get install -y dotnet-sdk-2.2

apt-get upgrade -y
apt-get dist-upgrade -y

#shutdown -r now

echo " " >> /home/aks/.profile
echo ". ~/setenv" >> /home/aks/.profile
echo "git -C ~/aks pull" >> /home/aks/.profile

echo "ready" > /home/aks/status

# pull the docker images
docker pull ubuntu
docker pull fourco/go-web-aks
docker pull fourco/govote
docker pull redis
