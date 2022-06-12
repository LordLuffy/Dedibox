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
echo -n "${CYELLOW}Nom de domaine : ${CEND}"
read -r DOMAIN_NAME
echo -n "${CYELLOW}Adresse mail : ${CEND}"
read -r EMAIL

echo -n "${CYELLOW}OVH Endpoind : ${CEND}"
read -r OVH_ENDPOINT
echo -n "${CYELLOW}OVH Application Key : ${CEND}"
read -r OVH_APPKEY
echo -n "${CYELLOW}OVH Application Secret : ${CEND}"
read -r OVH_APP_SECRET
echo -n "${CYELLOW}OVH Consumer Key : ${CEND}"
read -r OVH_CONSUMER_KEY

######################################################################
######################## INSTALLATION DE BASE ########################
######################################################################
# Install requirements
sudo apt-get update -y
sudo apt-get install ca-certificates curl wget gnupg2 lsb-release software-properties-common nftables fail2ban -y

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
#################### INSTALLATION DOCKER COMPOSE #####################
######################################################################
curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
chmod +x docker-compose-linux-x86_64
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose

######################################################################
########################### DOCKER CONFIG ############################
######################################################################
# Launch service
sudo systemctl enable --now docker

# Création d'un groupe docker et ajout d'un utilisateur (pour ne pas utiliser le compte root)
sudo groupadd $DOCKER_GROUP
sudo useradd $DOCKER_USER
sudo usermod -aG $DOCKER_GROUP $DOCKER_USER
PUID=$(id -u $DOCKER_USER)
PGID=$(id -g $DOCKER_USER)

######################################################################
######################## SECURISATIOH DOCKER  ########################
######################################################################
rm /etc/docker/daemon.json
cp ../files/daemon.json /etc/docker
sudo systemctl restart docker

######################################################################
#################### DOCKER : CONFIG FICHIER YAML ####################
######################################################################
# Création des dossiers
mkdir /etc/traefik/logs/traefik.log
mkdir /etc/traefik/letsencrypt
touch /etc/traefik/letsencrypt/acme.json
sudo chown 1001:1001 /etc/traefik/letsencrypt/acme.json
sudo chmod 600 /etc/traefik/letsencrypt/acme.json
mkdir /etc/traefik/logs
touch /etc/traefik/logs/traefik.log
sudo chown 1001:1001 /etc/traefik/logs/traefik.log
sudo chmod 600 /etc/traefik/logs/traefik.log
mkdir /etc/traefik/config
mkdir /etc/traefik/secrets
touch /etc/traefik/secrets/ovh_endpoint.secret
touch /etc/traefik/secrets/ovh_application_key.secret
touch /etc/traefik/secrets/ovh_application_secret.secret
touch /etc/traefik/secrets/ovh_consumer_key.secret

echo "ovh-eu" > /etc/traefik/secrets/ovh_endpoint.secret
echo "b09850173ee353cf" > /etc/traefik/secrets/ovh_application_key.secret
echo "184fcd21049b773968c2b784487981a0" > /etc/traefik/secrets/ovh_application_secret.secret
echo "57b95eb6e1a1f2af64924d0b9e8e38f3" > /etc/traefik/secrets/ovh_consumer_key.secret
