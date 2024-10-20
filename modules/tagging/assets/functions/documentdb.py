import os
import boto3

# Initialize the boto3 client for DocumentDB
docdb_client = boto3.client('docdb')

def lambda_handler(event, context):
    """
    This function tags all Amazon DocumentDB clusters with the 'Schedule' tag if it doesn't already exist.
    The 'Schedule' tag is added with the value specified in the environment variable 'SCHEDULE_TAG_VALUE'.
    The function also skips tagging clusters that have any of the tags specified in the environment variable 'EXCLUDE_TAG_KEYS'. 
    """

    # Retrieve the environment variables
    exclude_tag_keys = os.getenv('EXCLUDE_TAG_KEYS', '').split(',')
    tag_name = os.getenv('SCHEDULE_TAG_NAME', 'Schedule')
    tag_value = os.getenv('SCHEDULE_TAG_VALUE', '')

    # List all DocumentDB clusters
    try:
        clusters = docdb_client.describe_db_clusters()['DBClusters']
    except Exception as e:
        print(f"Error retrieving DocumentDB clusters: {str(e)}")
        return

    for cluster in clusters:
        cluster_arn = cluster['DBClusterArn']
        cluster_id = cluster['DBClusterIdentifier']

        try:
            # Retrieve current tags for the DocumentDB cluster
            current_tags = docdb_client.list_tags_for_resource(ResourceName=cluster_arn)['TagList']
        except Exception as e:
            print(f"Error retrieving tags for DocumentDB cluster {cluster_id}: {str(e)}")
            continue

        # Check if the cluster has any of the excluded tags
        exclude_instance = any(tag['Key'] in exclude_tag_keys for tag in current_tags)
        if exclude_instance:
            print(f"Skipping tagging for DocumentDB cluster {cluster_id} because it has an excluded tag.")
            continue

        # Check if the 'Schedule' tag is already present
        has_schedule_tag = any(tag['Key'] == tag_name for tag in current_tags)

        if not has_schedule_tag:
            try:
                # Add the 'Schedule' tag to the cluster
                docdb_client.add_tags_to_resource(
                    ResourceName=cluster_arn,
                    Tags=[
                        {
                            'Key': tag_name,
                            'Value': tag_value
                        }
                    ]
                )
                print(f"Added '{tag_name}' tag to DocumentDB cluster {cluster_id}.")
            except Exception as e:
                print(f"Error adding '{tag_name}' tag to DocumentDB cluster {cluster_id}: {str(e)}")
        else:
            print(f"'{tag_name}' tag already exists for DocumentDB cluster {cluster_id}.")

    return {
        'statusCode': 200,
        'body': 'DocumentDB tagging process completed'
    }
