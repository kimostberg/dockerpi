#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

check_internet

sudo docker network create \
  --driver=bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  frontend

sudo docker network create \
  --driver=bridge \
  --subnet=172.21.0.0/16 \
  backend

sudo mkdir -p /docker/container/portainer

sudo docker pull portainer/portainer-ce:latest || error "Failed to pull latest Portainer docker image!"
sudo docker run -d -p 9000:9000 -p 9443:9443 --network=frontend --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/container/portainer:/data portainer/portainer-ce:latest || error "Failed to run Portainer docker image!"

