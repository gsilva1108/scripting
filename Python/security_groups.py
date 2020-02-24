import boto3
import json

ec2 = boto3.client('ec2')
sg = ec2.describe_security_groups()

sg_data = json.dumps(sg, indent=4)

print(security_groups)