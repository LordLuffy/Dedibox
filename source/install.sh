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
echo -n "${CYELLOW}Nom de l'utilisateur docker : ${CEND}"
read -r DOCKER_USER
echo -n "${CYELLOW}Nom du groupe docker : ${CEND}"
read -r DOCKER_GROUP
echo -n "${CYELLOW}Port SSH : ${CEND}"
read -r PORT_SSH

######################################################################
######################## INSTALLATION DE BASE ########################
######################################################################
# Install requirements
sudo apt-get update -y
sudo apt-get install ca-certificates curl wget gnupg2 lsb-release software-properties-common nftables -y

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

######################################################################
########################### SECURITE : SSH ###########################
######################################################################
rm /etc/ssh/sshd_config
cp ../files/sshd_config /etc/ssh
sed -i "s/@PORTSSH@/$PORT_SSH/g" /etc/ssh/sshd_config
sudo systemctl restart sshd

######################################################################
######################## REGLAGE DU FIREWALL #########################
######################################################################
# Activation du firewall
sudo systemctl enable nftables

# Fichier de configuration
rm /etc/nftables.conf
cp ../files/nftables.conf /etc
sed -i "s/@PORTSSH@/$PORT_SSH/g" /etc/nftables.conf

# Démarrage
sudo systemctl start nftables

######################################################################
########################### DOCKER CONFIG ###########################
######################################################################
# Launch service
#sudo systemctl enable --now docker

# Création d'un groupe docker et ajout d'un utilisateur (pour ne pas utiliser le compte root)
#sudo groupadd $DOCKER_GROUP
#sudo useradd $DOCKER_USER
#sudo usermod -aG $DOCKER_GROUP $DOCKER_USER
#PUID=$(id -u $DOCKER_USER)
#PGID=$(id -u $DOCKER_USER)

#rm /etc/docker/daemon.json
#cp ../files/daemon.json /etc/docker
#sudo systemctl restart docker

######################################################################
#################### INSTALLATION DOCKER COMPOSE #####################
######################################################################
#curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
#chmod +x docker-compose-linux-x86_64
#sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose


######################################################################
################ DOCKER : MISE EN PLACE SERVEUR VPN ##################
######################################################################
#mkdir /ect/letsencrypt
#cd /ect/letsencrypt
#touch acme.json
#sudo chown 1001:1001 acme.json