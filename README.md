# Luminating Atlantis

EKS cluster with nginx-ingress controller and Atlantis.

## How to run this project

Create ``terraform.tfvars``file and add variable values from file ``variables.tf``


### Variables

### 1. `aws_region`
- **Description**: AWS region to deploy the resources.
- **Default**: `us-east-1`

### 2. `app_name`
- **Description**: Name of the application.
- **Default**: `luminating_atlantis`

### 3. `vpc_cidr_block`
- **Description**: CIDR block for the VPC.
- **Default**: `10.0.0.0/16`

### 4. `public_subnets_cidr_blocks`
- **Description**: List of CIDR blocks for public subnets.
- **Type**: List of strings
- **Default**: `['10.0.101.0/24', '10.0.102.0/24']`

### 5. `private_subnets_cidr_blocks`
- **Description**: List of CIDR blocks for private subnets.
- **Type**: List of strings
- **Default**: `['10.0.1.0/24', '10.0.2.0/24']`

### 6. `public_access_cidrs`
- **Description**: List of CIDR blocks which can access the Amazon EKS public API server endpoint.
- **Type**: List of strings
- **Default**: `['0.0.0.0/0']`

### 7. `cluster_version`
- **Description**: EKS cluster version.
- **Type**: String
- **Default**: `1.31`

### 8. `github_user`
- **Description**: Name of the Atlantis GitHub user.
- **Type**: String
- **Default**: `octocat_mona`

### 9. `github_token`
- **Description**: Personal access token for the Atlantis GitHub user. Replace this with a valid token.
- **Type**: String
- **Default**: `please_generate_your_token`

### 10. `github_secret`
- **Description**: Repository or organization-wide webhook secret for the Atlantis GitHub integration. All repositories in GitHub that are to be integrated with Atlantis must share the same value.
- **Type**: String
- **Default**: `please_generate_secret_string`

### 11. `github_orgAllowlist`
- **Description**: Allowlist of repositories from which Atlantis will accept webhooks. Accepts wildcard characters (*). Multiple values may be comma-separated.
- **Type**: String
- **Default**: `github.com/YOUR_ORG_OR_USERNAME/*`

## Usage

To use these variables, you can override the default values by creating a `terraform.tfvars` file or passing them as command line options when running Terraform commands.

Example `terraform.tfvars`:
```hcl
aws_region = "us-west-2"
app_name = "my_custom_app"
```

Alternatively, you can pass values via the command line:
```sh
terraform apply -var='aws_region=us-west-2' -var='app_name=my_custom_app'
```

### How to remove the installation

Simply running ``terraform destroy``might end up with null pointing objects in terraform state. To avoid this situation remove applications installed with Helm before. For example removing nginx-ingress controller and Atlantis run ``terraform destroy -target=helm_release.nginx_ingress -target=helm_release.atlantis``

## Notes
- Make sure to generate a valid GitHub token and secret before deploying Atlantis.
- Update the `github_orgAllowlist` to match your organization's GitHub settings.

## Security Considerations
- **Sensitive Information**: Avoid committing sensitive information like `github_token` and `github_secret` to version control. Consider using secure storage options such as environment variables or secret management tools.

## License
This project is licensed under the MIT License.

