import os
import boto3

rds_client = boto3.client('rds')

def lambda_handler(event, context):
    /**
    * This function tags all RDS instances with the 'Schedule' tag if it doesn't already exist.
    * The 'Schedule' tag is added with the value specified in the environment variable 'SCHEDULE_TAG_VALUE'.split
    * The function also skips tagging instances that have any of the tags specified in the environment variable 'EXCLUDE_TAG_KEYS'. 
    */


    # Retrieve the environment variables
    exclude_tag_keys = os.getenv('EXCLUDE_TAG_KEYS', '').split(',')
    tag_name = os.getenv('SCHEDULE_TAG_NAME', 'Schedule')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    # List all RDS instances
    try:
        instances = rds_client.describe_db_instances()['DBInstances']
    except Exception as e:
        print(f"Error retrieving RDS instances: {str(e)}")
        return

    for instance in instances:
        instance_arn = instance['DBInstanceArn']
        instance_id = instance['DBInstanceIdentifier']

        try:
            # Retrieve current tags for the RDS instance
            current_tags = rds_client.list_tags_for_resource(ResourceName=instance_arn)['TagList']
        except Exception as e:
            print(f"Error retrieving tags for RDS instance {instance_id}: {str(e)}")
            continue

        # Skip if the tag already exists
        if tag_name in current_tags:
            print(f"RDS {instance_id} already has the tag {tag_name}. Skipping.")
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
            print(f"Skipping RDS {instance_id} because it has an excluded tag.")
            continue

        try:
            # Add the 'Schedule' tag to the instance
            rds_client.add_tags_to_resource(
                ResourceName=instance_arn,
                Tags=[
                    {
                        'Key': 'Schedule',
                        'Value': tag_value
                    }
                ]
            )
            print(f"Added 'Schedule' tag to RDS instance {instance_id}.")
        except Exception as e:
            print(f"Error adding 'Schedule' tag to RDS instance {instance_id}: {str(e)}")

    return {
        'statusCode': 200,
        'body': 'RDS tagging process completed'
    }
