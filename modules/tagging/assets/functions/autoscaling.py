import os
import boto3

# Initialize the boto3 client for Auto Scaling
autoscaling_client = boto3.client('autoscaling')

def lambda_handler(event, context):
    """
    This function tags all Auto Scaling Groups (ASGs) with the 'Schedule' tag if it doesn't already exist.
    The 'Schedule' tag is added with the value specified in the environment variable 'SCHEDULE_TAG_VALUE'.
    The function also skips tagging ASGs that have any of the tags specified in the environment variable 'EXCLUDE_TAG_KEYS'. 
    """

    # Retrieve the environment variables
    exclude_tag_keys = os.getenv('EXCLUDE_TAG_KEYS', '').split(',')
    tag_name = os.getenv('SCHEDULE_TAG_NAME', 'Schedule')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    # List all Auto Scaling Groups
    try:
        asgs = autoscaling_client.describe_auto_scaling_groups()['AutoScalingGroups']
    except Exception as e:
        print(f"Error retrieving Auto Scaling Groups: {str(e)}")
        return

    for asg in asgs:
        asg_name = asg['AutoScalingGroupName']

        try:
            # Retrieve current tags for the ASG
            current_tags = {tag['Key']: tag['Value'] for tag in asg.get('Tags', [])}
        except Exception as e:
            print(f"Error retrieving tags for ASG {asg_name}: {str(e)}")
            continue

        # Check if the ASG has any of the excluded tags
        exclude_instance = any(exclude_key in current_tags for exclude_key in exclude_tag_keys)
        if exclude_instance:
            print(f"Skipping tagging for ASG {asg_name} because it has an excluded tag.")
            continue

        # Check if the 'Schedule' tag is already present
        has_schedule_tag = tag_name in current_tags

        if not has_schedule_tag:
            try:
                # Add the 'Schedule' tag to the ASG
                autoscaling_client.create_or_update_tags(
                    Tags=[
                        {
                            'ResourceId': asg_name,
                            'ResourceType': 'auto-scaling-group',
                            'Key': tag_name,
                            'Value': tag_value,
                            'PropagateAtLaunch': False
                        }
                    ]
                )
                print(f"Added '{tag_name}' tag to ASG {asg_name}.")
            except Exception as e:
                print(f"Error adding '{tag_name}' tag to ASG {asg_name}: {str(e)}")
        else:
            print(f"'{tag_name}' tag already exists for ASG {asg_name}.")

    return {
        'statusCode': 200,
        'body': 'ASG tagging process completed'
    }
