"""
This module contains the Lambda function that tags all
Auto Scaling Groups (ASGs)
"""

import os
import boto3

# Initialize the boto3 client for Auto Scaling
autoscaling_client = boto3.client('autoscaling')

def lambda_handler(event, context):
    """
    This function tags all Auto Scaling Groups (ASGs) with the 'Schedule' tag
    if it doesn't already exist. The 'Schedule' tag is added with the value
    specified in the environment variable 'SCHEDULE_TAG_VALUE'. The function
    also skips tagging ASGs that have any of the tags specified in the
    environment variable 'EXCLUDE_TAG_KEYS'.
    """

    # Retrieve the environment variables
    exclude_tag_keys = list(filter(None, os.getenv('EXCLUDE_TAG_KEYS', '').split(',')))
    tag_name = os.getenv('SCHEDULE_TAG_NAME', 'Schedule')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    # List all Auto Scaling Groups
    try:
        asgs = autoscaling_client.describe_auto_scaling_groups()['AutoScalingGroups']
    except Exception as e:
        print(f"Error retrieving Auto Scaling Groups: {str(e)}")
        return

    print(f"Found {len(asgs)} Auto Scaling Groups.") 
    print(f"Tag name: {tag_name}") 
    print(f"Tag value: {tag_value}")
    print(f"Excluded tags: {exclude_tag_keys}")

    for asg in asgs:
        asg_name = asg['AutoScalingGroupName']

        try:
            # Retrieve current tags for the ASG
            current_tags = {tag['Key']: tag['Value'] for tag in asg.get('Tags', [])}
        except Exception as e:
            print(f"Error retrieving tags for ASG {asg_name}: {str(e)}")
            continue

        # Skip if the tag already exists
        if tag_name in current_tags:
            print(f"ASG {asg_name} already has the tag {tag_name}. Skipping.")
            continue

        # Skip if the ASG has any of the excluded tags
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
            print(f"Skipping ASG {asg_name} because it has an excluded tag.")
            continue

        try:
            autoscaling_client.create_or_update_tags(
                Tags=[
                    {
                        'ResourceId': asg_name,
                        'ResourceType': 'auto-scaling-group',
                        'Key': tag_name,
                        'Value': tag_value,
                        'PropagateAtLaunch': True
                    }
                ]
            )
            print(f"Added '{tag_name}' tag to ASG {asg_name}.")
        except Exception as e:
            print(f"Error adding '{tag_name}' tag to ASG {asg_name}: {str(e)}")

    return {
        'statusCode': 200,
        'body': 'ASG tagging process completed'
    }

lambda_handler(event=None, context=None)
