#SSH into the Docker Host with service account
*insert SSH command here*

#Switch to super user
sudo su

#Now you will need to run the following command to save all running container ID’s into a text file:
docker ps -q > runningcontainers.txt

#Exit from root, and then exit docker host
exit
exit

#Change directories to the credpkg
cd /home/centos/credpkg

#Run the following command to source into vault:
source set-env-vault.sh

#Grab key from SSM
key=*insert grab key command here*

#Next, associate the paths, and login to vault:
export PATH=$PATH:/usr/local/bin/

vault login $key

########## Reboot docker host ##########
*insert SSH command here* reboot

#Ping server until it is back online
while true; do ping -c 1 *IP_HERE* > /dev/null && break; done
########################################

#Now, the three following commands are used to unseal Vault
vault unseal -address=https://<ServerIPOfTheDockerHost>:8200 <UNSEAL KEY>
vault unseal -address=https://<ServerIPOfTheDockerHost>:8200 <UNSEAL KEY>
vault unseal -address=https://<ServerIPOfTheDockerHost>:8200 <UNSEAL KEY>

#SSH back into the Docker Host with service account
*insert SSH command here*

#Switch to super user
sudo su

#Restart all containers
docker start $(cat runningcontainers.txt)