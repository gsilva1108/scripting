#Save instance type to variable
echo What instance type is required?
read t

#Function to ask if ENA support is required, and creates a variable for the 'modify-instance-attribute' AWS CLI calls
ena_function () { 
    echo Do these instances require ENA support enabled? [y/n]
    read ena
    if [[ $ena == "y" ]]; then
        ena="--ena-support"
    elif [[ $ena == "n" ]]; then
        ena="--no-ena-support"
    else
        echo "Sorry, that is not a valid response."
        ena_result  
    fi
}

printf "\nOK. Changing instance type to $t\n"

#Grabs a count of instances in the 'instance_list' file
count=$(wc -l instance_list | cut -d ' ' -f 1)

#Function that checks instance state
state_check () {
    result=$(aws ec2 describe-instance-status --instance-id $a --query "InstanceStatuses[*].InstanceState.Name" --output text)
}
#Empty variable
i=0
#While the empty variable does not equal the count of instances in 'instance_list'...
while [[ $i != $count ]]; do
    #While reading 'instance_list'
    while read a; do
        #Run the function to view status
        state_check
        #If the result doesn't return "stopped", skip it and move to the next one
        if [[ $result != "stopped" ]]; then
            continue
        #If the result does return "stopped", change the ENA attribute and instance type, then start the instance up
        else
            aws ec2 modify-instance-attribute --instance-id $a $ena
            aws ec2 modify-instance-attribute --instance-id $a --instance-type $t
            aws ec2 start-instances --instance-ids $a
            #Add 1 to the empty variable
            ((i++))
        fi
    done < instance_list
done
