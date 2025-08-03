<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudformation_transform_name"></a> [cloudformation\_transform\_name](#input\_cloudformation\_transform\_name) | Name of the cloudformation transform | `string` | n/a | yes |
| <a name="input_cloudformation_transform_stack_name"></a> [cloudformation\_transform\_stack\_name](#input\_cloudformation\_transform\_stack\_name) | Name of the cloudformation transform stack | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture | `string` | `"arm64"` | no |
| <a name="input_log_kms_key_id"></a> [log\_kms\_key\_id](#input\_log\_kms\_key\_id) | KMS key ID to use for CloudWatch log encryption | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention period in days | `number` | `14` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory size in MB | `number` | `128` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to be used for naming resources | `string` | `"default-tags"` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda runtime environment | `string` | `"python3.12"` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout in seconds | `number` | `60` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | ARN of the Lambda function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Name of the Lambda function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the Lambda execution role |
| <a name="output_macro_name"></a> [macro\_name](#output\_macro\_name) | Name of the CloudFormation macro |
<!-- END_TF_DOCS -->