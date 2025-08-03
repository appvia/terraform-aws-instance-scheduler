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
from datetime import datetime, timezone

class JsonFormatter(logging.Formatter):
    """Custom JSON formatter for structured logging."""

    def format(self, record):
        # Get all standard logging fields
        log_record = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Get all standard LogRecord attributes
        standard_attrs = set(dir(logging.LogRecord("", 0, "", 0, "", (), None)))
        
        # Add any extra fields that were passed in
        for key, value in record.__dict__.items():
            if key not in standard_attrs and not key.startswith('_'):
                log_record[key] = value

        return json.dumps(log_record)

# Configure JSON logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Remove existing handlers
for handler in logger.handlers[:]:
    logger.removeHandler(handler)

# Add JSON formatter
handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger.addHandler(handler)

## Read the default tags from the environment variable
DEFAULT_TAGS = json.loads(os.getenv("DEFAULT_TAGS", "[]"))

def does_not_support_tags(resource_type):
    """
    Check if the given AWS resource type does NOT support tags.
    
    Args:
        resource_type (str): The AWS resource type (e.g., "AWS::IAM::Role")
    
    Returns:
        bool: True if the resource type does NOT support tags, False otherwise
    """
    # List of AWS resource types that do NOT support tags
    # This is much smaller and easier to maintain than a comprehensive list of taggable resources
    non_taggable_resources = {
        # KMS 
        "AWS::KMS::Alias",
      
        # IAM Resources (most don't support tags)
        "AWS::IAM::Role",
        "AWS::IAM::Policy",
        "AWS::IAM::User",
        "AWS::IAM::Group",
        "AWS::IAM::InstanceProfile",
        "AWS::IAM::ManagedPolicy",
        "AWS::IAM::AccessKey",
        "AWS::IAM::UserToGroupAddition",
        "AWS::IAM::ServiceLinkedRole",
        
        # Lambda Permissions and Triggers
        "AWS::Lambda::Permission",
        "AWS::Lambda::EventSourceMapping",
        "AWS::Lambda::Version",
        "AWS::Lambda::Alias",
        
        # CloudFormation Resources
        "AWS::CloudFormation::CustomResource",
        "AWS::CloudFormation::WaitCondition",
        "AWS::CloudFormation::WaitConditionHandle",
        "AWS::CloudFormation::Macro",
        
        # API Gateway Resources (some don't support tags)
        "AWS::ApiGateway::Account",
        "AWS::ApiGateway::ApiKey",
        "AWS::ApiGateway::Authorizer",
        "AWS::ApiGateway::BasePathMapping",
        "AWS::ApiGateway::ClientCertificate",
        "AWS::ApiGateway::Deployment",
        "AWS::ApiGateway::DocumentationPart",
        "AWS::ApiGateway::DocumentationVersion",
        "AWS::ApiGateway::DomainName",
        "AWS::ApiGateway::GatewayResponse",
        "AWS::ApiGateway::Method",
        "AWS::ApiGateway::Model",
        "AWS::ApiGateway::RequestValidator",
        "AWS::ApiGateway::Resource",
        "AWS::ApiGateway::UsagePlan",
        "AWS::ApiGateway::UsagePlanKey",
        "AWS::ApiGateway::VpcLink",
        
        # S3 Bucket Policies and Configurations
        "AWS::S3::BucketPolicy",
        "AWS::S3::BucketNotification",
        
        # EC2 Resources that don't support tags
        "AWS::EC2::VPCGatewayAttachment",
        "AWS::EC2::SubnetRouteTableAssociation",
        "AWS::EC2::Route",
        "AWS::EC2::SecurityGroupEgress",
        "AWS::EC2::SecurityGroupIngress",
        "AWS::EC2::NetworkAclEntry",
        "AWS::EC2::VPCEndpointService",
        "AWS::EC2::VPCEndpointServicePermissions",
        
        # CloudWatch Events
        "AWS::Events::Rule",
        "AWS::Events::EventBusPolicy",
        
        # RDS Resources that don't support tags
        "AWS::RDS::DBSecurityGroup",
        "AWS::RDS::DBSecurityGroupIngress",
        "AWS::RDS::OptionGroup",
        "AWS::RDS::EventSubscription",
        
        # Route53 Resources
        "AWS::Route53::RecordSet",
        "AWS::Route53::RecordSetGroup",
        "AWS::Route53::HealthCheck",
        
        # SNS/SQS Policies
        "AWS::SNS::TopicPolicy",
        "AWS::SQS::QueuePolicy",
        
        # CloudTrail Resources
        "AWS::CloudTrail::EventDataStore",
        
        # ElastiCache Resources
        "AWS::ElastiCache::SecurityGroup",
        "AWS::ElastiCache::SecurityGroupIngress",
        
        # Auto Scaling Resources
        "AWS::AutoScaling::LifecycleHook",
        "AWS::AutoScaling::ScalingPolicy",
        "AWS::AutoScaling::ScheduledAction",
        
        # ECS Resources
        "AWS::ECS::CapacityProvider",
        
        # Logs Resources
        "AWS::Logs::Destination",
        "AWS::Logs::LogStream",
        "AWS::Logs::MetricFilter",
        "AWS::Logs::SubscriptionFilter",
        
        # CloudWatch Resources
        "AWS::CloudWatch::CompositeAlarm",
        "AWS::CloudWatch::InsightRule",
        "AWS::CloudWatch::MetricStream",
        
        # CloudWatch Dashboard
        "AWS::CloudWatch::Dashboard",
        
        # Systems Manager Resources
        "AWS::SSM::Association",
        "AWS::SSM::ResourceDataSync",
        
        # Config Resources
        "AWS::Config::RemediationConfiguration",
        "AWS::Config::OrganizationConfigRule",
        "AWS::Config::OrganizationConformancePack",
        
        # Certificate Manager
        "AWS::CertificateManager::DomainValidationOption",
        
        # Directory Service
        "AWS::DirectoryService::MicrosoftAD",
        "AWS::DirectoryService::SimpleAD",
        
        # Organizations
        "AWS::Organizations::Account",
        "AWS::Organizations::OrganizationalUnit",
        "AWS::Organizations::Policy",
        
        # Resource Groups
        "AWS::ResourceGroups::Group",
        
        # Service Discovery
        "AWS::ServiceDiscovery::HttpNamespace",
        "AWS::ServiceDiscovery::Instance",
        "AWS::ServiceDiscovery::PrivateDnsNamespace",
        "AWS::ServiceDiscovery::PublicDnsNamespace",
        "AWS::ServiceDiscovery::Service",
        
        # Service Catalog App Registry
        "AWS::ServiceCatalogAppRegistry::Application"
    }
    
    return resource_type in non_taggable_resources

def lambda_handler(event, context):
    # If no default tags are provided, we error out
    if not DEFAULT_TAGS or len(DEFAULT_TAGS) == 0:
        raise ValueError("No default tags provided")

    logger.info("Lambda execution started", extra={
        "action": "lambda_handler_start",
        "default_tags": DEFAULT_TAGS,
        "default_tags_count": len(DEFAULT_TAGS)
    })
    
    # Lets get the template from the event
    template = event["fragment"]
    resources = template.get("Resources", {})

    # Lets iterate over the resources and add the default tags
    for name, resource in resources.items():
        properties = resource.setdefault("Properties", {})
        resource_type = resource.get("Type", "Unknown")

        # Only process resources that actually support 'Tags'
        if not does_not_support_tags(resource_type):
            existing_tags = properties.get("Tags", [])
            
            logger.info("Adding default tags to resource", extra={
                "action": "add_tags",
                "resource_name": name,
                "resource_type": resource_type,
                "existing_tags_count": len(existing_tags),
                "default_tags_count": len(DEFAULT_TAGS)
            })

            # Handle different tag formats
            if isinstance(existing_tags, dict):
                # Tags are in key-value format, convert to list format
                existing_tags_list = [{"Key": k, "Value": v} for k, v in existing_tags.items()]
                existing_keys = set(existing_tags.keys())
            elif isinstance(existing_tags, list):
                # Tags are already in list format
                existing_tags_list = existing_tags
                existing_keys = {tag["Key"] for tag in existing_tags if isinstance(tag, dict) and "Key" in tag}
            else:
                # Empty or invalid tags
                existing_tags_list = []
                existing_keys = set()

            # Merge tags, avoiding duplicates (existing tags take precedence)
            merged_tags = existing_tags_list + [tag for tag in DEFAULT_TAGS if tag["Key"] not in existing_keys]

            properties["Tags"] = merged_tags
        else:
            logger.info("Skipping resource (does not support tags)", extra={
                "action": "skip_resource",
                "resource_name": name,
                "resource_type": resource_type,
                "reason": "resource_does_not_support_tags"
            })

    logger.info("Lambda execution completed successfully", extra={
        "action": "lambda_handler_complete",
        "request_id": event["requestId"],
        "resources_processed": len(resources),
        "status": "success"
    })

    return {
        "requestId": event["requestId"],
        "status": "success",
        "fragment": template
    }