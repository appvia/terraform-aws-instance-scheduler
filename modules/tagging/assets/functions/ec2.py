import boto3
import os

# Initialize the boto3 client for EC2
client = boto3.client('ec2')

def lambda_handler(event, context):
    /*
    * This function tags all EC2 instances with the 'Schedule' tag if it doesn't already exist.
    * The 'Schedule' tag is added with the value specified in the environment variable 'TAG_VALUE'.split
    * The function also skips tagging instances that have any of the tags specified in the environment variable 'EXCLUDE_TAG_KEYS'. 
    */ 
    
    # Retrieve the environment variables
    exclude_tag_keys = os.getenv('EXCLUDE_TAG_KEYS', '').split(',')
    tag_name = os.getenv('SCHEDULE_TAG_NAME', '')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    try:
        instances = client.describe_instances()
    except Exception as e:
        print(f"Error retrieving EC2 instances: {str(e)}")
        return

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            # Get tags for the instance
            tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
            # Check if the instance should be excluded based on the EXCLUDE_TAG_KEYS
            if any(exclude_key in tags for exclude_key in exclude_tag_keys):
                print(f"Skipping EC2 instance {instance_id} due to exclusion tags.")
                continue

            # Check if the instance already has the specified tag
            if tag_name in tags:
                print(f"EC2 instance {instance_id} already has the tag {tag_name}. Skipping.")
                continue

            # Add the tag if it's missing
            print(f"Adding tag {tag_name}: {tag_value} to EC2 instance {instance_id}")
            client.create_tags(
                Resources=[instance_id],
                Tags=[{'Key': tag_name, 'Value': tag_value}]
            )
    
    return {
        'statusCode': 200,
        'body': f"Processed {len(response['Reservations'])} reservations."
    }
    except Exception as e:
        print(f"Error processing EC2 instances: {e}")
        return {
            'statusCode': 500,
            'body': f"Error processing EC2 instances: {str(e)}"
        }
