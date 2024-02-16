#!/bin/bash
# ************************************************************************
# * THIS SHOULD ONLY BE RAN WITHIN THE NEW-INFRASTRUCTURE-LIVE DIRECTORY *
# * IF THIS SCRIPT IS RAN WITHIN THE SCRIPTS DIRECTORY, JUST USE 'cd ..' *
# ************************************************************************

main_dir=$(pwd)
# These variables need to be set here to get list of roles for user selection
list_of_roles=$(ls $main_dir/sandbox/iam/roles)
n_list_of_roles=$(ls $main_dir/sandbox/iam/roles | cat -n)

# Get user input on which role (Gitlab project) needs to be updated
echo "Which role would you like to update?"
echo $n_list_of_roles
echo "Select the role with its corresponding number."

# Get user input and associate number selection with role (Gitlab project)
read role
role=$(awk NR==$role <<< $list_of_roles)

# Variables that create numerated lists for users to select from
list_of_accounts=$(ls -d */)
n_list_of_accounts=$(ls -d */ | cat -n)
list_of_branches=$(cd $main_dir/sandbox/iam/roles/$role ; git branch)
n_list_of_branches=$(cd $main_dir/sandbox/iam/roles/$role ; git branch | cat -n)

select_account(){
    regular_wording=$(cat) << EOT 
Which accounts need to be updated?
$n_list_of_accounts
Select the accounts with its corresponding number.
Note: 
    - If selecting multiple accounts, please separate each selection with a space
    - To select all accounts, please type 'all'
EOT
    copy_wording=$(cat) << EOT
Which accounts do the files need to be copied to?
$n_list_of_accounts
Select the accounts with its corresponding number.
Note: 
    - If selecting multiple accounts, please separate each selection with a space
    - To select all accounts, please type 'all'
EOT   
    if [ $1 = "copy" ]; then;
        $copy_wording
        read accounts
        if [ $accounts = "all" ]; then
            accounts=$(ls)
        else;
            accounts=$(awk NR==$accounts <<< $list_of_accounts)
        fi
    else;
        $regular_wording
        read accounts
        if [ $accounts = "all" ]; then
            accounts=$(ls)
        else;
            accounts=$(awk NR==$accounts <<< $list_of_accounts)
        fi
    fi
}


select_branch() {
    cat << EOT
What is the branch name?
$n_list_of_branches
Note: The branch with the '*' is the current branch.
If the branch you want to push to is the current branch, please press 'Enter'.
Otherwise, select the branch with its corresponding number
EOT
    read branch
    branch=$(awk NR==$branch <<< $list_of_branches)
}

select_source_directory() {
    echo "What is the source directory?"
    echo $n_list_of_accounts
    read accounts
    local account=$(awk NR==$accounts <<< $list_of_accounts)
    source_directory=$main_dir/$account/iam/roles/$role
}


create_branch() {
    local accounts=$1
    local role=$2
    cat << EOT
What is the branch name?
**************************************************
Remember to put 'feature/' before the custom name!
**************************************************
EOT  
    read branch

    for a in $accounts; do
        cd $a/iam/roles/$role
        git checkout -b $branch
        cd $main_dir
    done
}


delete_branch() {
    local accounts=$1
    local branch=$2
    local role=$3
    cat << EOT
What is the branch name?
Select the accounts with its corresponding number.
$n_list_of_branches
*** The branch with the '*' is the current branch ***
***     You CANNOT select the current branch.     ***
EOT
    for a in $accounts; do
        cd $a/iam/roles/$role
        if [[ $branch == *"*"* ]]; then
            echo "DO NOT SELECT THE CURRENT BRANCH!"
            break
        else
            git branch -D $branch
            cd $main_dir
        fi
    done
}


pull() {
    local accounts=$1
    local branch=$2
    for a in $accounts; do
        cd $a/iam/roles/$role
        if [ -n $branch ]; then    
            git switch $branch
        else
            continue
        fi
        git pull
        cd $main_dir
    done
}


push(){
    local accounts=$1
    local branch=$2
    echo "What is the commit message?"
    read commit
    for a in $accounts; do
        cd $a/iam/roles/$role
        if [ -n $branch ]; then    
            git switch $branch
        else
            continue
        fi
        git add .
        git commit -am $commit
        git push
        cd $main_dir
    done
}

copy_all() {
    local accounts=$1
    for a in $accounts; do
        cd $a/iam/roles/$role
        cp * $main_dir/$i/iam/roles/$role
        cd $main_dir
    done
}

copy_selection() {
    local account=$1
    local role=$2
    local n_list_of_files=$(ls $main_dir/$account/iam/roles/$role | cat -n)
    local list_of_files=$(ls $main_dir/$account/iam/roles/$role)
    local source_directory=$3
    echo "Which files do you need to copy?"
    echo $n_list_of_files
    echo "Select the files with its corresponding number."
    echo "To select all files, type 'all'"
    read files
    files=$(awk NR==$files <<< $list_of_files)
    directory=$(select_account "copy")
    
    for d in $directory; do
        cd $source_directory
        cp $files $main_dir/$d/iam/roles/$role
        cd -
    done
}


func_help_doc(){
    cat << EOT
Functions:
    use_git - Access to git functions
    copy - Access to git functions
EOT
}


git_help_doc() {
    cat <<EOT
Functions:
    create_branch - Creates branch in selected projects
    delete_branch - Deletes branch in selected projects
    pull          - Pulls from selected branch in selected projects
    push          - Pushes selected changes to selected branch in selected projects
    help          - Explains all functions
EOT
}


copy_help_doc() {
    cat << EOT
Functions:
    copy_all - Copies all files within a directory to all projects
    copy_selection - Copies inputted files within a directory to inputted/all projects
EOT
}


main(){
    cat <<EOT
What would you like to do with this role?
    1    - use_git
    2    - copy
    help - Explains all functions
EOT
    read selection
    case $selection in
        1)  # use_git
            cat << EOT
Which git function would you like to use?
    1 - create_branch
    2 - delete_branch
    3 - pull
    4 - push
    help - Explains all functions
EOT
            read function
            case $function in
                1)  
                    select_account
                    create_branch $accounts $role
                    ;;
                2)
                    select_account
                    delete_branch 
                    ;;
                3)
                    select_account
                    select_branch
                    pull $accounts $branch $role
                    ;;
                4)
                    select_account
                    select_branch
                    push $accounts $branch $role
                    ;;
                help)
                    git_help_doc
                    ;;
                *)
                    echo "Invalid input. Please try again"
                    echo "Exiting..."
                    ;;
            esac
            ;;
        2)  # copy
            cat << EOT
Which copy function would you like to use?
    1 - copy_all
    2 - copy_selection
    help - Explains all functions
EOT
            read function
            case $function in
                1)
                    select_account
                    copy_all $accounts
                    ;;

                2)
                    select_source_directory
                    copy_selection $accounts $role $source_directory
                    ;;
                help)
                    copy_help_doc
                    ;;
                *)
                    echo "Invalid input. Please try again"
                    echo "Exiting..."
                    ;;
            esac
            ;;
        help)
            func_help_doc
        ;;
        *)
            Invalid input. Please try again
            Exiting...
            ;;
    esac
}

main
