![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Instance Scheduler Spoke

## Description

The purpose of the module is to configure the spoke accounts i.e. those accounts who are being managed by the orchestrator account. The spoke accounts will have the instance scheduler stack deployed to them. Currently this module supports two methods of deployment, either via stackset or a single cloudformation stack. The later is assuming you are running this within the intended account.

## Usage

Add example usage here

```hcl
module "example" {
  source  = "appvia/<NAME>/aws"
  version = "0.0.1"

  # insert variables here
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_spokes"></a> [spokes](#module\_spokes) | appvia/stackset/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources should be created | `string` | n/a | yes |
| <a name="input_scheduler_account_id"></a> [scheduler\_account\_id](#input\_scheduler\_account\_id) | The account id of where the orchcastrator is running | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the resources | `map(string)` | n/a | yes |
| <a name="input_cloudformation_spoke_stack_name"></a> [cloudformation\_spoke\_stack\_name](#input\_cloudformation\_spoke\_stack\_name) | The name of the cloudformation stack in the spoke accounts | `string` | `"lza-instance-scheduler-spoke"` | no |
| <a name="input_enable_organizations"></a> [enable\_organizations](#input\_enable\_organizations) | Whether the stack should be enabled for AWS Organizations | `bool` | `true` | no |
| <a name="input_enable_stackset"></a> [enable\_stackset](#input\_enable\_stackset) | Whether the stackset should be enabled | `bool` | `false` | no |
| <a name="input_enable_standalone"></a> [enable\_standalone](#input\_enable\_standalone) | Whether the stack should be standalone | `bool` | `true` | no |
| <a name="input_kms_key_arns"></a> [kms\_key\_arns](#input\_kms\_key\_arns) | The KMS key ARNs used to encrypt the instance scheduler data | `list(string)` | `[]` | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organizational units to deploy the stack to (when using a stackset) | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
