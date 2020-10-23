import boto3
import csv

ec2 = boto3.client('ec2')
s3 = boto3.client('s3')

def get_instance_ids():
    csv = s3.get_object(
        Bucket='gus_code',
        Key='test.csv'
    )
"""
    data = pd.read_csv(csv['Body']).todict()
    headers = []
    reformatted_data = {}
    for header in data:
        headers.append(header)
        list_data = []
        for values in data[header]:
            list_data.append(data[header][values])

        reformatted_data[header] = list_data

    newdata = {}
"""
    with open('test.csv', 'r') as instances_csv:
        reader = csv.reader(instance_csv)

        for line in reader:
            print(line)
"""
    for item in reformatted_data:
        if item == 'InstanceId':
            instance_id = reformatted_data[item][i]
            newdata[reformatted_data[item][i]] = {}
        elif item == 'NewInstanceType':
            new_instance_type = reformatted_data[item][t]
            newdata[reformatted_data[item][t]] = {}
        else:
            newdata[instance_id][item] = reformatted_data[item][i]

    for key, value in newdata[a].items():
        try:
            ec2.modify_instance_attribute(
                InstanceId=[a],
                Attribute='instanceType',
                InstanceType={
                    'Value':''
                }
            )
"""
