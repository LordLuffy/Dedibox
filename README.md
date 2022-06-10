# Dedibox

1. Installation du serveur

2. A la première connexion SSH, changer le mot de passe root via la commande su passwd root

3. Installation via le script bash
 
sudo apt-get update -y && apt-get upgrade -y && apt-get install apt-transport-https ca-certificates git -y
cd /tmp
git clone https://github.com/LordLuffy/Dedibox.git
cd Dedibox/source
chmod a+x install.sh && ./install.sh


51.38.125.42

9458