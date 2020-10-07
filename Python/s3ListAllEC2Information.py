import boto3
import json
import datetime
import logging
from json import JSONEncoder

#Setup simple logging for INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

#Datetime encoder
class DatetimeEncoder(JSONEncoder):
    def default(self,obj):
        if isinstance(obj, (datetime.date, datetime.datetime)):
            return obj.isoformat()

#Define the connection
def sessionCreator():
    ssm = boto3.client("ssm")
    access_key = ssm.get_parameter(
        Name=('gus_accesskey'), WithDecryption=True
    )
    secret_key = ssm.get_parameter(
        Name=('gus_secretkey'), WithDecryption=True
    )
    session = boto3.session.Session(
        aws_access_key_id=access_key["Parameter"]["Value"],
        aws_secret_access_key=secret_key["Parameter"]["Value"],
    )
    return session
    
def describeInstances(**kwargs):
    #Setup EC2 connection
    ec2 = kwargs["Session"].client("ec2")
    #Get instance information
    instance_info = ec2.describe_instances()
    
    return instance_info

def send_to_s3(**kwargs):
    #Setup S3 connection
    s3 = boto3.client("s3")
    #Create JSON file
    instance_info = describeInstances(
        Session=kwargs["Session"]
    )
    #Put file in S3 bucket
    response = s3.put_object(
        Body = json.dumps(instance_info["Reservations"], indent=4, cls=DatetimeEncoder).encode('utf-8'),
        Bucket = 'gus-code',
        Key = 'python/instance_info.json'
    )
    
    return response
    
def lambda_handler(event, context):
    session = sessionCreator()
    send_to_s3(Session=session)