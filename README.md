# terraform-aws-vault

This module sets up a Vault cluster that can span 2 AWS regions. It makes use of
the following AWS features:

* AWS DynamodDB global tables
* AWS SecretManager global replication
* AWS KMS cross region replicas
* Cross region VPC peering

By default resources are replicated in another region to act as a DR plan. It is
possible to not run Vault instances on the other region but just keep the
resources replicated.

## Features

### Vault Backend

Vault backend use DynamodDB plugins which allow HA for storage and nodes.

### TLS end to end

This module [generates a pki](https://github.com/particuleio/terraform-tls-pki)
to enable full end to end encryption into the vault instances. Certificates for
vault are generated at startup on the instances and all the cluster internal
communication are done with TLS

### Network Load Balancer

To allow end to end TLS, network load balancer are used in TCP mode. This module
supports 2 NLB per region, 1 internal and 1 external.

#### Health Checks

Health Check by default are done with TCP check, this allow to use the
Vault with TLS Client cert verification enabled. This also improve failover but
route randomly the Vault request to any node, which then in turn forwards to the
cluster leader. This generate east-west traffic across AZ and VPC Peering.

Health checks can also use HTTPS if vault client cert verification is disabled. 2
modes are availabled via the variable `vault_routing_policy` :

* `all` : HTTPS healthcheck with all node `Healthy`
* `leader-only` : HTTPS healthcehck with only leader `Healthy`

When `vault_tls_require_and_verify_client_cert` is set, health checks default to TCP.

### Route53

Support for private and public hosted zone for split horizon DNS. Register automatically the NLB as alias and sets up health check for DNS failover in case an AWS region is not available.

### VPC

VPC peering between the 2 provided VPC is enabled by default, if VPCs are
already peered it can be disable with `vpc_peering_enabled=false`.

:warning: there is a dependency issue when creating everything from scratch in
the example folder. `vpc_peering_enabled` should be turn to true only after the
VPC have been created, or use the `-target` feature.

### AMI

Pariticule build and maintain AMI on AWS region available by default. Please pen an issue if you need us to support another region.

### AWS SSM

Instances have SSM enable by default, no need for SSH keys.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3 |
| <a name="provider_aws.secondary"></a> [aws.secondary](#provider\_aws.secondary) | ~> 3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pki"></a> [pki](#module\_pki) | particuleio/pki/tls | ~> 1.1 |
| <a name="module_primary"></a> [primary](#module\_primary) | ./modules/vault-region | n/a |
| <a name="module_secondary"></a> [secondary](#module\_secondary) | ./modules/vault-region | n/a |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | particuleio/secretsmanager/aws | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_instance_profile.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.seal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.seal_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.seal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_key.seal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_route.acceptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.requestor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.private_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.private_a_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.private_aaaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.private_aaaa_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.public_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.public_a_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.public_aaaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.public_aaaa_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group_rule.peering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.peering_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_peering_connection.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.vault_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_vpc_peering_connection_options.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.elb_sa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.ec2_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route_tables.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_route_tables.vpc_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.vpc_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg"></a> [asg](#input\_asg) | n/a | `any` | n/a | yes |
| <a name="input_asg_defaults"></a> [asg\_defaults](#input\_asg\_defaults) | n/a | `any` | <pre>{<br>  "asg_associate_public_ip_address": false,<br>  "desired_capacity": 3,<br>  "disk_size": 20,<br>  "instance_type": "t3a.micro",<br>  "key_name": null,<br>  "max_size": 3,<br>  "min_size": 0,<br>  "tags": {},<br>  "tags_as_map": {},<br>  "vpc_zone_identifier": []<br>}</pre> | no |
| <a name="input_asg_secondary"></a> [asg\_secondary](#input\_asg\_secondary) | n/a | `any` | n/a | yes |
| <a name="input_cfssl_version"></a> [cfssl\_version](#input\_cfssl\_version) | n/a | `string` | `"1.6.1"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A name to prefix every created resource with | `string` | n/a | yes |
| <a name="input_nlb_defaults"></a> [nlb\_defaults](#input\_nlb\_defaults) | n/a | `any` | <pre>{<br>  "internal": false,<br>  "ip_address_type": "dualstack",<br>  "listener_port": 443,<br>  "subnets": []<br>}</pre> | no |
| <a name="input_nlbs"></a> [nlbs](#input\_nlbs) | n/a | `any` | <pre>{<br>  "external": {},<br>  "internal": {<br>    "internal": true<br>  }<br>}</pre> | no |
| <a name="input_nlbs_secondary"></a> [nlbs\_secondary](#input\_nlbs\_secondary) | n/a | `any` | <pre>{<br>  "external": {},<br>  "internal": {<br>    "internal": true<br>  }<br>}</pre> | no |
| <a name="input_route53_private_zone_name"></a> [route53\_private\_zone\_name](#input\_route53\_private\_zone\_name) | n/a | `string` | `""` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | n/a | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vault_additional_config"></a> [vault\_additional\_config](#input\_vault\_additional\_config) | Additional content to include in the vault configuration file | `string` | `""` | no |
| <a name="input_vault_additional_userdata"></a> [vault\_additional\_userdata](#input\_vault\_additional\_userdata) | Additional content to include in the cloud-init userdata for the EC2 instances | `string` | `""` | no |
| <a name="input_vault_api_address"></a> [vault\_api\_address](#input\_vault\_api\_address) | The address that vault will be accessible at | `string` | n/a | yes |
| <a name="input_vault_cert_dir"></a> [vault\_cert\_dir](#input\_vault\_cert\_dir) | The directory on the OS to store Vault certificates | `string` | `"/usr/local/etc/vault/tls"` | no |
| <a name="input_vault_config_dir"></a> [vault\_config\_dir](#input\_vault\_config\_dir) | The directory on the OS to store the Vault configuration | `string` | `"/usr/local/etc/vault"` | no |
| <a name="input_vault_dns_domain"></a> [vault\_dns\_domain](#input\_vault\_dns\_domain) | The DNS address that vault will be accessible at | `string` | n/a | yes |
| <a name="input_vault_pki_ca_config"></a> [vault\_pki\_ca\_config](#input\_vault\_pki\_ca\_config) | n/a | `any` | `null` | no |
| <a name="input_vault_pki_client_certs"></a> [vault\_pki\_client\_certs](#input\_vault\_pki\_client\_certs) | n/a | `any` | <pre>{<br>  "default": {<br>    "subject": {<br>      "common_name": "default-vault-client"<br>    },<br>    "usages": [<br>      "client_auth",<br>      "key_encipherement",<br>      "digital_signature"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_vault_routing_policy"></a> [vault\_routing\_policy](#input\_vault\_routing\_policy) | n/a | `string` | `"all"` | no |
| <a name="input_vault_tls_require_and_verify_client_cert"></a> [vault\_tls\_require\_and\_verify\_client\_cert](#input\_vault\_tls\_require\_and\_verify\_client\_cert) | n/a | `bool` | `false` | no |
| <a name="input_vault_version"></a> [vault\_version](#input\_vault\_version) | n/a | `string` | `"1.9.3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to use | `string` | n/a | yes |
| <a name="input_vpc_peering_enabled"></a> [vpc\_peering\_enabled](#input\_vpc\_peering\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_vpc_secondary_id"></a> [vpc\_secondary\_id](#input\_vpc\_secondary\_id) | The ID of the VPC to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb"></a> [dynamodb](#output\_dynamodb) | n/a |
| <a name="output_primary"></a> [primary](#output\_primary) | n/a |
| <a name="output_secondary"></a> [secondary](#output\_secondary) | n/a |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | n/a |
| <a name="output_vault_pki"></a> [vault\_pki](#output\_vault\_pki) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
