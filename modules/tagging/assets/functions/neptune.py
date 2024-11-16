import os
import boto3

# Initialize the boto3 client for Neptune
neptune_client = boto3.client('neptune')

def lambda_handler(event, context):
    """
    This function tags all Amazon Neptune clusters with the 'Schedule' tag if it doesn't already exist.
    The 'Schedule' tag is added with the value specified in the environment variable 'SCHEDULE_TAG_VALUE'.
    The function also skips tagging clusters that have any of the tags specified in the environment variable 'EXCLUDE_TAG_KEYS'. 
    """

    # Retrieve the environment variables
    exclude_tag_keys = list(filter(None, os.getenv('EXCLUDE_TAG_KEYS', '').split(',')))
    tag_name = os.getenv('SCHEDULE_TAG_NAME', 'Schedule')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    # List all Neptune clusters
    try:
        clusters = neptune_client.describe_db_clusters()['DBClusters']
    except Exception as e:
        print(f"Error retrieving Neptune clusters: {str(e)}")
        return

    print(f"Found {len(clusters)} Neptune clusters.")
    print(f"Tag name: {tag_name}")
    print(f"Tag value: {tag_value}")
    print(f"Excluded tags: {exclude_tag_keys}")

    for cluster in clusters:
        cluster_arn = cluster['DBClusterArn']
        cluster_id = cluster['DBClusterIdentifier']

        try:
            # Retrieve current tags for the Neptune cluster
            current_tags = neptune_client.list_tags_for_resource(ResourceName=cluster_arn)['TagList']
        except Exception as e:
            print(f"Error retrieving tags for Neptune cluster {cluster_id}: {str(e)}")
            continue

        # Skip if the tag already exists
        if tag_name in current_tags:
            print(f"Skipping {cluster_id} due to already tagged")
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
            print(f"Skipping {cluster_id} because it has an excluded tag.")
            continue

        try:
            # Add the 'Schedule' tag to the cluster
            neptune_client.add_tags_to_resource(
                ResourceName=cluster_arn,
                Tags=[
                    {
                        'Key': tag_name,
                        'Value': tag_value
                    }
                ]
            )
            print(f"Added '{tag_name}' tag to Neptune cluster {cluster_id}.")
        except Exception as e:
            print(f"Error adding '{tag_name}' tag to Neptune cluster {cluster_id}: {str(e)}")

    return {
        'statusCode': 200,
        'body': 'Neptune tagging process completed'
    }
