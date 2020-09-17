#Get password for SVC Account from AWS SSM
pw=$(aws ssm get-parameter --name *PARAMETER_NAME* --query "Parameter.Value")

#SSH into the Docker Host with service account
sshpass -f <(printf '%s\n' $pw) ssh *SVC_ACCOUNT*@*IP_HERE*

#Switch to super user
sudo su

#Now you will need to run the following command to save all running container ID’s into a text file:
docker ps -q > runningcontainers.txt

#Exit from root, and then exit docker host
exit
exit

########## Reboot docker host ##########
sshpass -f <(printf '%s\n' $pw) ssh *SVC_ACCOUNT*@*IP_HERE* reboot

#Ping server until it is back online
while true; do 
    ping -c 1 *IP_HERE* > /dev/null && break
done
########################################

#SSH back into the Docker Host with service account
sshpass -f <(printf '%s\n' $pw) ssh *SVC_ACCOUNT*@*IP_HERE*

#Switch to super user
sudo su

#Restart all containers
docker start $(cat runningcontainers.txt)

#Verification step
docker ps -q > new_runningcontainers.txt

if [[ $(diff -q runningcontainers.txt new_runningcontainers.txt) == **differ** ]]; then
    *send email that there are differences*
else
    *send email that there are no differences*
fi