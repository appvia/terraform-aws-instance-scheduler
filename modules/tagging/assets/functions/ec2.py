import boto3
import os

# Initialize the boto3 client for EC2
client = boto3.client('ec2')


def lambda_handler(event, context):
    """
    This function tags all EC2 instances with the 'Schedule' tag if it
    doesn't already exist. The 'Schedule' tag is added with the value
    specified in the environment variable 'TAG_VALUE'.split. The function
    also skips tagging instances that have any of the tags specified in
    the environment variable 'EXCLUDE_TAG_KEYS'.
    """
    # Retrieve the environment variables
    exclude_tag_keys = list(filter(None, os.getenv('EXCLUDE_TAG_KEYS', '').split(',')))
    tag_name = os.getenv('SCHEDULE_TAG_NAME', 'Schedule')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    try:
        instances = client.describe_instances()
    except Exception as e:
        print(f"Error retrieving EC2 instances: {str(e)}")
        return

    print(f"Found {len(instances['Reservations'])} EC2 instances.")
    print(f"Tag name: {tag_name}")
    print(f"Tag value: {tag_value}")
    print(f"Excluded tags: {exclude_tag_keys}")

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']

            # Get tags for the instance
            current_tags = {
                tag['Key']: tag['Value'] for tag in instance.get('Tags', [])
            }

            # Skip if the tag already exists
            if tag_name in current_tags:
                print(f"EC2 {instance_id} already tagged, skipping.")
                continue

            # Skip if the instance has any of the excluded tags
            exclude_instance = False
            for pairs in exclude_tag_keys:
                exclude_key, exclude_value = pairs.split("=")
                exclude_instance = any(
                    tag == exclude_key and value == exclude_value
                    for tag, value in current_tags.items()
                )
                if exclude_instance:
                    break

            if exclude_instance:
                print(f"Skipping {instance_id} due to excluded tag.")
                continue

            # Add the tag if it's missing
            print(f"Adding tag {tag_name}: {tag_value} to instance {instance_id}")

            client.create_tags(
                Resources=[instance_id],
                Tags=[{'Key': tag_name, 'Value': tag_value}]
            )

    return {
        'statusCode': 200,
        'body': "Processed ec2 instance reservations."
    }

#lambda_handler(None, None)
