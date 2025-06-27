"""
The purpose of this lambda function is to add default tags to the resources in the template.

Args:
    event: The event object containing the template
    context: The context object containing the lambda function context

Returns:
    The event object with the template containing the default tags
"""
import logging
import json
import os

logger = logging.getLogger(__name__)

## Read the default tags from the environment variable
DEFAULT_TAGS = json.loads(os.getenv("DEFAULT_TAGS", "[]"))

def lambda_handler(event, context):
    # If no default tags are provided, we error out
    if not DEFAULT_TAGS or len(DEFAULT_TAGS) == 0:
        raise ValueError("No default tags provided")

    logger.info(f"Default tags: {DEFAULT_TAGS}")
    
    # Lets get the template from the event
    template = event["fragment"]
    resources = template.get("Resources", {})

    # Lets iterate over the resources and add the default tags
    for name, resource in resources.items():
        properties = resource.setdefault("Properties", {})
        

        # Only process resources that support 'Tags'
        if "Tags" in properties or resource["Type"].startswith("AWS::"):
            logger.info(f"Adding default tags to resource: {name}, type: {resource['Type']}")
            existing_tags = properties.get("Tags", [])

            # Merge tags, avoiding duplicates (existing tags take precedence)
            existing_keys = {tag["Key"] for tag in existing_tags}
            merged_tags = existing_tags + [tag for tag in DEFAULT_TAGS if tag["Key"] not in existing_keys]

            properties["Tags"] = merged_tags

    return {
        "requestId": event["requestId"],
        "status": "success",
        "fragment": template
    }