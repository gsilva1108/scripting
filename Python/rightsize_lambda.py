import boto3
import pandas as pd
import time

ec2 = boto3.client('ec2')
s3 = boto3.client('s3')

#Get CSV file from S3
def get_csv():
    #Get CSV file
    csv = s3.get_object(
        Bucket='gus-code',
        Key='test.csv'
    )
    return csv
#Merge instance ID and instance type as key value pair
def merge_info():
    csv = get_csv()
    #Change file type to dictionary
    csv_file = pd.read_csv(csv['Body']).to_dict()

    #Dictionary where instance ID will be linked to instance type
    new_instances = {}

    #All lists
    headers = []
    instance_ids = []
    instance_types = []

    #Put headers into 'headers' list
    for header in csv_file:
        headers.append(header)
        for h in headers:
            if h == 'InstanceId':
                #If header is 'InstanceId', get the value for the instance ID, and add it to the 'instance_ids' list
                for values in csv_file[h]:
                    instance_ids.append(csv_file[h][values])
            elif h == 'NewInstanceType':
                #If header is 'NewInstanceType', get the value for the instance type, and add it to the 'instance_types' list
                for values in csv_file[h]:
                    instance_types.append(csv_file[h][values])
    for i in instance_ids:
        for t in instance_types:
            #Merge the instance ID and type to key/value pairs
            new_instances[i] = t
            
    return new_instances
#Start instances function
def start_instance(id):
    response = ec2.start_instances(
            InstanceIds=[
                id
                ],
            )
    return response
#Stop instances function
def stop_instance(id):
    response = ec2.stop_instances(
            InstanceIds=[
                id
                ],
            )
    return response
#Modify instance type
def modify_instance_type(id,t):
    response = ec2.modify_instance_attribute(
            InstanceId = id,
            InstanceType={
            'Value': t
            },
        )
    return response
#Enable ENA Support
def ena_enabled(id):
    response = ec2.modify_instance_attribute(  
        InstanceId = id,
        EnaSupport={
        'Value': True
        },
    )
    return response
#Disable ENA Support
def ena_disabled(id):
    response = ec2.modify_instance_attribute(
        InstanceId = id,
        EnaSupport={
        'Value': True
        },
    )
    return response
#Continuously checks state of instance 
def state_checker(id):
    InstanceState = None
    while (InstanceState != 'stopped'):
        status_response = ec2.describe_instance_status(
            InstanceIds=[
                id
                ],
            IncludeAllInstances=True
        )
        InstanceState = status_response['InstanceStatuses'][0]['InstanceState']['Name']
        #6 second throttle
        time.sleep(6)    
    return InstanceState
#Main function
def lambda_handler(event, context):
    ena_required = ['c4','d2','m4','t2']
    instances = merge_info()
    #List of instances that have already been rightsized
    instances_completed = []
    for l in ena_required:
        ena = l

    for instance, new_type in instances.items():
        #If instance is in the 'instances_completed' list, skip it
        if instance in instances_completed:
            pass
        else:
            print('Stopping {0}...'.format(instance))
            stop_instance(instance)
            if state_checker(instance) == 'stopped':
                print('Changing instance type of {0} to {1}...'.format(instance,new_type))
                modify_instance_type(instance,new_type)
            #Enables ENA support if instance type is not one of the instance families listed in 'ena_required'
            if ena in new_type:
                try:
                    ena_disabled(instance)
                    print('ENA Support has been removed for {0} as {1} does not require ENA Support.'.format(instance,new_type))
                    print('Starting {0}'.format(instance))
                    start_instance(instance)
                    instances_completed.append(instance)
                    print('{0} has successfully been rightsized to {1}'.format(instance,new_type))
                except Exception:
                    continue
            else:
                try:
                    ena_enabled(instance)
                    print('ENA Support has been enabled for {0} as {1} requires ENA Support.'.format(instance,new_type))
                    print('Starting {0}'.format(instance))
                    start_instance(instance)
                    instances_completed.append(instance)
                    print('{0} has successfully been rightsized to {1}'.format(instance,new_type))
                except Exception:
                    continue
          