import boto3
import pandas as pd
import io

s3 = boto3.client('s3')

#def get_account_creds(lifecycle):
#    ssm = boto3.client('ssm')
#    accessKey = ssm.get_parameter(
#        Name=('{0}_accessKey'.format(lifecycle)),
#        WithDecryption=True
#    )
#    secretKey = ssm.get_parameter(
#        Name=('{0}_secretKey'.format(lifecycle)),
#        WithDecryption=True
#    )
#    conn = boto3.Session(
#        aws_access_key_id = accessKey['Parameter']['Value'],
#        aws_secret_access_key = secretKey['Parameter']['Value']
#    )
#    ec2_client = conn.client('ec2')
#    return ec2_client

def lambda_handler(event, context):
    csv = s3.get_object(Bucket='gus-important-info',Key='test.csv')
    data = pd.read_csv(csv['Body']).to_dict()
    headers = []
    reformatted_data = {}
    for header in data:
        headers.append(header)
        list_data = []
        for values in data[header]:
            list_data.append(data[header][values])
        
        reformatted_data[header] = list_data

    new_data = {}

    for v in range(len(reformatted_data['Volume Id'])):
        volume_id = ''
        for item in reformatted_data:
            if item == 'Volume Id':
                volume_id = reformatted_data[item][v]
                new_data[reformatted_data[item][v]] = {}
            else:
                new_data[volume_id][item] = reformatted_data[item][v]

#    for a in new_data:
#        if new_data[a]['Account Name'] == 'NonProd Account':
#            lifecycle = 'NONPROD'
#        if new_data[a]['Account Name'] == 'Prod Account':
#            lifecycle = 'OLDPROD'
#        if new_data[a]['Account Name'] == 'Dycom-UAT':
#            lifecycle = 'UAT'
#        if new_data[a]['Account Name'] == 'Dycom-QA':
#            lifecycle = 'QA'
#        if new_data[a]['Account Name'] == 'Dycom-Sandbox':
#            lifecycle = 'SB'
#        if new_data[a]['Account Name'] == 'Dycom-Dev':
#            lifecycle = 'DEV'
#        if new_data[a]['Account Name'] == 'Dycom-Prod':
#            lifecycle = 'PROD'
#        if new_data[a]['Account Name'] == 'Dycom-Mgmt':
#           lifecycle = 'MGMT'
#       print(f'Deleting Volume in {lifecycle}')
#       ec2 = get_account_creds(lifecycle)

        errorvar = False

        for key, value in new_data[a].items():
            try:
                ec2.describe_volumes(
                    VolumeIds=[a]
                )
            except:
                errorvar = True

        if errorvar == True:
            print(f'Function failed to delete volume for Volume Id {a}.\nConfirm volume exists and retry')