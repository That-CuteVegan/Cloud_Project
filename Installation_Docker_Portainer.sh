#!/bin/bash

#Script to install Docker and boot Portainer within it with a webinterface.

echo "Booting Docker/Portainer installation script."
echo "Press Enter to continue, or CTRL+C to stop script."
read

#Fetch the servers IP
internal_ip=$(hostname -I | awk '{print $1}')

#Fetch the repo and install docker on to the Linux server.
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

#Start and enable docker in sustemctl.
sudo systemctl start docker
sudo systemctl enable docker

#Allow users that are created on the Linux server to be able to access docker.
sudo usermod -aG docker $USER 

#Creates a docker volume to use for portainer by the name "portainer_data".
docker volume create portainer_data

#Create a docker container to run Portainer on ports 9443 and 8000.
sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

echo "Docker and Portainer have now been installed and startet, you can access portainer on $internal_ip:9443."
echo "Press enter to exit script"
read