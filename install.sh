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
echo -n "${CYELLOW}Utilisateur PostgreSQL : ${CEND}"
read -r POSTGRES_USER
echo -n "${CYELLOW}Mot de passe PostgreSQL : ${CEND}"
read -r POSTGRES_PASSWORD
echo -n "${CYELLOW}Nom de la base de données : ${CEND}"
read -r POSTGRES_DATABASE

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
cp ../files/ssh/sshd_config /etc/ssh
sed -i "s/@PORTSSH@/$PORT_SSH/g" /etc/ssh/sshd_config
sudo systemctl restart sshd

######################################################################
######################## REGLAGE DU FIREWALL #########################
######################################################################
# Activation du firewall
#sudo systemctl enable nftables

# Fichier de configuration
#rm /etc/nftables.conf
#cp ../files/nftables/nftables.conf /etc
#sed -i "s/@PORTSSH@/$PORT_SSH/g" /etc/nftables.conf

# Démarrage
#sudo systemctl start nftables

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
rm /etc/docker/daemon.json
cp /tmp/Dedibox/files/docker/daemon.json /etc/docker
sudo systemctl restart docker

######################################################################
###################### CREATION DES REPERTOIRES ######################
######################################################################
sudo mkdir /app
sudo mkdir /app/config
sudo mkdir /app/config/traefik
sudo mkdir /app/config/traefik/letsencrypt
sudo mkdir /app/config/authelia
sudo mkdir /app/data
sudo mkdir /app/logs
sudo mkdir /app/secrets

######################################################################
####################### CREATION DES FICHIERS ########################
######################################################################
touch /app/logs/traefik.log
sudo chmod 600 /app/logs/traefik.log
touch /app/config/traefik/letsencrypt/acme.json
sudo chmod 600 /app/config/traefik/letsencrypt/acme.json
touch /app/secrets/ovh_endpoint.secret
touch /app/secrets/ovh_application_key.secret
touch /app/secrets/ovh_application_secret.secret
touch /app/secrets/ovh_consumer_key.secret

######################################################################
################### COPIE DES DONNEES ET FICHIERS ####################
######################################################################
# Copie des fichiers
cp /tmp/Dedibox/docker-compose.yaml /app
cp /tmp/Dedibox/files/services/traefik/traefik_middlewares.yml /app/config/traefik
cp /tmp/Dedibox/files/services/traefik/traefik_tls.yml /app/config/traefik
cp /tmp/Dedibox/files/services/authelia/authelia_configuration.yml /app/config/authelia
cp /tmp/Dedibox/files/services/authelia/users_database.yml /app/config/authelia

# Copie des secrets
echo "$OVH_ENDPOINT" > /app/secrets/ovh_endpoint.secret
echo "$OVH_APPKEY" > /app/secrets/ovh_application_key.secret
echo "$OVH_APP_SECRET" > /app/secrets/ovh_application_secret.secret
echo "$OVH_CONSUMER_KEY" > /app/secrets/ovh_consumer_key.secret

# Remplacement des variables dans les fichiers de config
cd /etc/docker/web
sed -i "s/@EMAIL@/$EMAIL/g" /app/docker-compose.yaml
sed -i "s/@DOMAIN@/$DOMAIN_NAME/g" /app/docker-compose.yaml
sed -i "s/@POSTGRES_USER@/$POSTGRES_USER/g" /app/docker-compose.yaml
sed -i "s/@POSTGRES_PASSWORD@/$POSTGRES_PASSWORD/g" /app/docker-compose.yaml
sed -i "s/@POSTGRES_DATABASE@/$POSTGRES_DATABASE/g" /app/docker-compose.yaml