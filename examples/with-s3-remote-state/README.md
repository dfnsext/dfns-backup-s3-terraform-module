# With Terraform remote state on S3

This example showcases how to use the module, to provision a Dfns backup bucket [Terraform](https://www.terraform.io/) is the Infra-As-Code tool used to provision the bucket.

## Prerequisites

- You need an AWS account where you want to create the final Dfns backup bucket.
- You need an AWS account where you want to create the final Dfns backup bucket.
- On AWS console, move to the region where you want the final backup bucket to live (eg `eu-west-3`)
- Go to S3 to create an bucket which will keep the terraform state (so that the state is not saved on your local machine, and don't get lost). Call it eg `terraform-remote-state`
- In `backend.tf` file, update `remote_state.config.bucket` with the bucket name you just created.
- [Install terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) on your local machine.


## Provision the bucket

- Fill the `vars.tfvars` file with the necessary variables.
- Open a new terminal, and export your AWS account credentials in the environment (or use existing aws profiles in your `~/.aws/credentials`)
```
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```
- Go to this example directory
```
cd examples/with-s3-remote-state/
```
- Run terraform:
```
terraform init -var-file="vars.tfvars"
terraform apply -var-file="vars.tfvars"
```

There you go, you have a new S3 backup bucket where Dfns will be able to backup your assets.