######################################################################
################### INSTALLATION DE BASE ET DOCKER ###################
######################################################################
# Install requirements
sudo apt-get install ca-certificates curl gnupg lsb-release -y

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

######################################################################
########################### SECURITE : SSH ###########################
######################################################################
rm /etc/ssh/sshd_config
cp ../files/sshd_config /etc/ssh
sudo systemctl restart sshd

######################################################################
######################## SECURITE : FIREWALL #########################
######################################################################
# Supression de nftables (remplaçant de iptables)
sudo apt-get remove --auto-remove nftables -y
sudo apt-get purge nftables -y
sudo apt-get install iptables -y
cp ../files/iptables.conf /etc
cp ../files/iptables.service /etc/systemd/system
sudo iptables-restore -n /etc/iptables.conf
sudo systemctl enable --now iptables
sudo systemctl restart iptables

######################################################################
######################### SECURITE : DOCKER ##########################
######################################################################
sudo apt-get install auditd -y
rm /etc/audit/rules.d/audit.rules
cp ../files/audit.rules /etc/audit/rules.d
sudo systemctl restart auditd
cd /tmp
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo ./docker-bench-security.sh -c host_configuration
