echo What is the INC?
read d

while read v; do
    aws ec2 create-snapshot --region us-east-1 --volume-id $v --description "$d - $v" --query "SnapshotId" --output text >> snapshot_ids
done < vol_ids

#Empty variables
state_completed=0
volumes_deleted=[]
#Number of volumes in 'vol_ids' file
count=$(wc -l vol_ids | cut -d ' ' -f 1)

while [[ $state_completed != $count ]]; do
    while read s; do
        state=$(aws ec2 describe-snapshots --region us-east-1 --snapshot-id $s --query "Snapshots[*].{state:State,id:VolumeId}" --output text)
        if [[ $state != **"completed"** ]]; then
            continue
        elif [[ $state == **"completed"** ]]; then
            volume_id=$(echo $state | cut -d " " -f 1)
            aws ec2 delete-volume --volume-id $volume_id
            ((state_completed++))
        fi
    done < snapshot_ids
done

#while read v; do
#    check=$(aws ec2 describe-volumes --volume-id $v)
#   if [[ $check ==  ]]

rm -rf snapshot_ids