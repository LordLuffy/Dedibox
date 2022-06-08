#!/bin/sh

######################################################################
############################# VARIABLES #############################
######################################################################
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

######################################################################
######################### DEMANDE DES SAISIES ########################
######################################################################
echo -n -e "${CYELLOW}Nom de l'utilisateur docker : ${CEND}"
read -r DOCKER_USER
echo -n -e "${CYELLOW}Nom du groupe docker : ${CEND}"
read -r DOCKER_GROUP


######################################################################
######################## INSTALLATION DE BASE ########################
######################################################################
# Install requirements
#sudo apt-get install ca-certificates curl  wget gnupg2 lsb-release software-properties-common -y

######################################################################
######################## INSTALLATION DOCKER #########################
######################################################################
# Add Docker’s official GPG key
#sudo mkdir -p /etc/apt/keyrings
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
#echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
#sudo apt-get update -y
#sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#sudo systemctl enable --now docker

# Création d'un groupe docker et ajout d'un utilisateur (pour ne pas utiliser le compte root)
sudo groupadd $DOCKER_GROUP
sudo adduser $DOCKER_USER
sudo usermod -aG $DOCKER_GROUP $DOCKER_USER
PUID=$(id -u $DOCKER_USER)
echo $PUID
PGID=$(id -u $DOCKER_USER)
echo $PGID

######################################################################
#################### INSTALLATION DOCKER COMPOSE #####################
######################################################################
#curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
#chmod +x docker-compose-linux-x86_64
#sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose

######################################################################
########################### SECURITE : SSH ###########################
######################################################################
#rm /etc/ssh/sshd_config
#cp ../files/sshd_config /etc/ssh
#sudo systemctl restart sshd

######################################################################
######################## SECURITE : FIREWALL #########################
######################################################################
# Supression de nftables (remplaçant de iptables)
#sudo apt-get remove --auto-remove nftables -y
#sudo apt-get purge nftables -y
#sudo apt-get install iptables -y
#cp ../files/iptables.conf /etc
#cp ../files/iptables.service /etc/systemd/system
#sudo iptables-restore -n /etc/iptables.conf
#sudo systemctl enable --now iptables
#sudo systemctl restart iptables

######################################################################
##################### SECURITE : DAEMON DOCKER #######################
######################################################################
#rm /etc/docker/daemon.json
#cp ../files/daemon.json /etc/docker
#sudo systemctl restart docker

######################################################################
################ DOCKER : MISE EN PLACE SERVEUR VPN ##################
######################################################################
#mkdir /ect/letsencrypt
#cd /ect/letsencrypt
#touch acme.json
#sudo chown 1001:1001 acme.json