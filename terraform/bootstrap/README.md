# Bootstrap

**NOTE:** The resources in this file are used to bootstrap the Terraform remote backend in a new project. Creating and applying changes to resources in this folder should be done rarely and not be used as part of any automated CI/CD pipeline used to deploy the main infra resources for the project.

**Scenarios when `plan/apply` would be used on these resources:**

1. New project was created and has no existing Terraform configuration (remote backend, resources, modules, etc.)
   - Instructions: [Create Remote Backend](#create_remote_backend)
2. Remote backend bucket created needs to be modified (ex. Adding tags or updating the bucket policy)
   - Instructions: run `plan/apply` in this folder.

#### Bootstrapping components:

- Terraform remote state bucket and policies

## Create Remote Backend

Creating the remote backend for terraform involves the following steps:

_Step 1_: Create a bucket for the remote backend using local state

1. Go to [backend.tf](backend.tf)
2. Ensure the the entire file is commented out.
3. Update [variables.tf](variables.tf) and [terraform.tfvars](terraform.tfvars) to set the bucket name and configuration as needed.
4. Run the following commands to create the remote state bucket:

   ```bash
   	terraform init
      terraform plan -out tfplan
      # Review plan before applying
      terraform apply tfplan
   ```

This will create a bucket for the remote backend. The terraform state at this point is managed locally in a file called `terraform.tfstate`.

_Step 2_: Upload the terraform state to the remote backend

1. Go to back to [backend.tf](backend.tf)
2. Uncomment the entire file.
3. Set the `bucket` variable to the name of the bucket created in step 1.
4. Set the `prefix` variable to the path within the bucket you want to use to store the state for these resources.

   Ex:

   ```hcl
   terraform {
      backend "gcs" {
         bucket = "myproj-terraform-state"
         prefix = "bootstrap"
      }
   }
   ```

5. Run `terraform init` - Terraform will prompt you to upload the local state to the remote backend.
6. Accept or confirm the upload.
7. Run a plan to verify the state is uploaded.
8. Clean up the local state file resources

```bash
   rm -rf .terraform* terraform.tfstate*
```

This bucket now available for use as a remote backend in your GCP project! See below for more information on how to use the remote backend

_Example usage_:

```hcl
   # network/backend.tf
   terraform {
      backend "gcs" {
         bucket = "myproj-terraform-state"
         prefix = "network"  # NOTE: use different prefix than the one for bootstrap resources
      }
   }
```

###### Important notes and considerations

- By uploading the local state as part of step 2, the state bucket is now managing its _own_ state under the `prefix` specified.
  - Use a different prefix than the one used for the bootstrap resources as you build out your infrastructure. This keeps the state isolated.
