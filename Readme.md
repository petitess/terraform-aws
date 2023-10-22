## Terraform-AWS
<details><summary>Setup</summary>
<p>

1. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. Download [terraform](https://developer.hashicorp.com/terraform/downloads)
3. Modify Environment Variables `rundll32 sysdm.cpl,EditEnvironmentVariables`
4. Install [Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
5. Use [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
</p>
</details>

<details><summary>Login</summary>
<p>

1. [Create an AWS access key](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/)
```
aws configure
aws configure get aws_access_key_id
aws configure get aws_secret_access_key
aws configure get region
aws configure list-profiles
aws configure set region us-west-1 --profile integ
```
</p>
</details>

----------
```
terraform apply -auto-approve
```
<details><summary>More terraform</summary>
<p>

```
terraform -help
```
```
terraform init 
```
```
terraform validate
```
```
terraform plan
```
```
terraform apply -auto-approve
```
```
terraform workspace show
```
```
terraform destroy
```
```
terraform workspace show
```
```
terraform workspace list
```
```
terraform workspace new dev
```
```
terraform workspace select dev
```

</p>
</details>

### Content

| Name | Description | 
|--|--|
| xxx01 | xxx
