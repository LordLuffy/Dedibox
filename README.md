# Dedibox




Prpéparation du DNS CHallenge pour les certificats Let's Encrypt

1. Creation d el'application et récupération de son id

Aller sur https://eu.api.ovh.com/createApp/ pour créer une application
Récupérer le clé de l'application + le secret

Valider les droits d el'application sur https://api.ovh.com/console/

Executer l'api /me/api/application pour récupérer l'id de l'application

Puis lancer l'api pour verifier qu'il s'agit la bonne application

2. Autorisation de l'application

Executer la requete curl

curl -XPOST -H "X-Ovh-Application: {ApplicationKey}" -H "Content-type: application/json" \
https://eu.api.ovh.com/1.0/auth/credential \
-d '{ "accessRules":[{"method":"POST","path":"/domain/zone/{Domain}/record"}, \
{"method":"POST","path":"/domain/zone/{Domain}/refresh"}, \
{"method":"DELETE","path":"/domain/zone/{Domain}/record/*"} ], \
"redirection": "https://www.{Domain}.fr" }'

En retour, on obtient l'URL de validation qu'il faut saisir dans un navigateur


1. Installation du serveur

2. A la première connexion SSH, changer le mot de passe root via la commande su passwd root

3. Installation via le script bash
 
sudo apt-get update -y && apt-get upgrade -y && apt-get install apt-transport-https ca-certificates git -y
cd /tmp
git clone https://github.com/LordLuffy/Dedibox.git
cd Dedibox
chmod a+x install.sh && ./install.sh
