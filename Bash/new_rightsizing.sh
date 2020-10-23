#Empty variable
instance_count=0

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

single_function () {
    #Ask for the instance ID
    echo What is the instance ID?
    read i
    echo $i > single_id
    #Save instance type to variable
    echo What instance type is required?
    read t

    if [[ $t == "t3" ]]

    ena_function

    #State that there is only 1 line in the 'single_id' file
    count=$(wc -l single_id | cut -d ' ' -f 1)

    printf "\nOK. Changing instance type to $t\n"

    #Stop the instance
    printf "\nStopping $i\n"
    aws ec2 stop-instances --instance-ids $i

    #While the empty variable does not equal the count of the instance...
    while [[ $instance_count != $count ]]; do
        #'$result' checks instance state
        result=$(aws ec2 describe-instances --instance-id $i --query "Reservations[*].Instances[*].State.Name" --output text)

        #If the result doesn't return "stopped", skip it and move to the next one
        if [[ $result != "stopped" ]]; then
            continue
        #If the result does return "stopped", change the ENA attribute and instance type, then start the instance up
        else
            aws ec2 modify-instance-attribute --instance-id $i $ena
            aws ec2 modify-instance-attribute --instance-id $i --instance-type $t
            printf "\nStarting $i\n"
            aws ec2 start-instances --instance-ids $i
            #Add 1 to the empty variable
            ((instance_count++))
        fi
    done
}

multiple_function () {
    if [ -s 'instance_list' ]; then
        #Save instance type to variable
        echo What instance type is required?
        read t

        ena_function

        #Grabs a count of instances in the 'instance_list' file
        count=$(wc -l instance_list | cut -d ' ' -f 1)

        printf "\nOK. Changing instance type to $t\n"

        #Stop instances in 'instance_list'
        while read a; do
            printf "\nStopping $a\n"
            aws ec2 stop-instances --instance-ids $a
        done < instance_list

        #While the empty variable does not equal the count of instances in 'instance_list'...
        while [[ $instance_count != $count ]]; do
            #While reading 'instance_list'
            while read a; do
                #Function that checks instance state
                result=$(aws ec2 describe-instances --instance-id $a --query "Reservations[*].Instances[*].State.Name" --output text)
                
                #Run the function to view status
                for status in $result; do
                    #If the result doesn't return "stopped", skip it and move to the next one
                    if [[ $status != "stopped" ]]; then
                        continue
                    #If the result does return "stopped", change the ENA attribute and instance type, then start the instance up
                    else
                        aws ec2 modify-instance-attribute --instance-id $a $ena
                        aws ec2 modify-instance-attribute --instance-id $a --instance-type $t
                        printf "\nStarting $a\n"
                        aws ec2 start-instances --instance-ids $a
                        #Add 1 to the empty variable
                        ((instance_count++))
                    fi
                done
            done < instance_list
        done
    else
        echo "There are no instance IDs added to the 'instance_list' text file. Please add instance IDs before proceeding."
        exit
    fi
}

#Function to ask if ENA support is required, and creates a variable for the 'modify-instance-attribute' AWS CLI calls
single_or_multiple () { 
    echo Are you rightsizing a single instance? [y/n]
    read response
    if [[ $response == "y" ]]; then
        single_function
    elif [[ $response == "n" ]]; then
        multiple_function
    else
        echo "Sorry, that is not a valid response."
        single_or_multiple  
    fi
}

single_or_multiple