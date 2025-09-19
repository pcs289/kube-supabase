# VPC Module

Virtual Private Cloud where EKS cluster will be installed.

## Network Partitions

The VPC CIDR block specified at input variable `vpc_cidr_block` (i.e `"172.16.0.0/16"`) is partitioned into 3 kinds of subnets in 3 different availability zones (AZs):

| Partition | Net Mask | IPs per Subnet | Total IPs |
|---|---|---|---|
| EKS | /28 | 16 | 48 |
| Public | /21 | 2048 | 6144 |
| Private | /18 | 16384 | 49152 |

For the CIDR block used as example above, this module will partition the `172.16.0.0/16` as follow:

- 3x EKS /28 Subnets with 16 IPs each
    - 172.16.255.0/28
    - 172.16.255.16/28
    - 172.16.255.32/28
- 3x Public /21 Subnets with 2048 IPs each
    - 172.16.192.0/21
    - 172.16.200.0/21
    - 172.16.208.0/21
- 3x Private /18 Subnets with 16384 IPs each
    - 172.16.0.0/18
    - 172.16.64.0/18
    - 172.16.128.0/18

## Security Rules

It also creates `public` and `private` network ACLs.

Public Network ACL for `public` subnets
| Protocol (Port) | In/Out | From/To |
|---|---|---|
| SSH (22) | In | vpc_cidr_block |
| SSH (22) | Out | allow_ssh_cidrs |
| HTTP (80) | In | vpc_cidr_block |
| HTTP (80) | Out | vpc_cidr_block |
| HTTPS (443) | In | anywhere |
| HTTPS (443) | Out | anywhere |
| Ephemeral Ports (1024-65535) | In | anywhere |
| Ephemeral Ports (1024-65535) | Out | anywhere |

Private Network ACL for `private` and `eks` subnets
| Protocol (Port) | In/Out | From/To |
|---|---|---|
| SSH (22) | Out | allow_ssh_cidrs |
| SSH (22) | Out | vpc_cidr_block |
| DNS TCP (53) | In | vpc_cidr_block |
| DNS TCP (53) | Out | vpc_cidr_block |
| DNS UDP (53) | In | vpc_cidr_block |
| DNS UDP (53) | Out | vpc_cidr_block |
| HTTP (80) | In | vpc_cidr_block |
| HTTP (80) | Out | vpc_cidr_block |
| HTTPS (443) | In | vpc_cidr_block |
| HTTPS (443) | Out | anywhere |
| Ephemeral Ports (1024-65535) | In | anywhere |
| Ephemeral Ports (1024-65535) | Out | vpc_cidr_block |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.private_i_dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_i_dns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_i_ephemeral_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_i_http_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_i_https_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_allowed_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_dns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_ephemeral_ports_anywhere](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_http_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_https_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_o_ssh_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_i_ephemeral_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_i_http_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_i_https_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_i_ssh_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_o_allowed_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_o_ephemeral_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_o_http_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_o_https_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_ssh_cidrs"></a> [allow\_ssh\_cidrs](#input\_allow\_ssh\_cidrs) | n/a | `list(string)` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | n/a | `bool` | `true` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_subnets"></a> [eks\_subnets](#output\_eks\_subnets) | n/a |
| <a name="output_nat_gw_ip"></a> [nat\_gw\_ip](#output\_nat\_gw\_ip) | n/a |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | n/a |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->