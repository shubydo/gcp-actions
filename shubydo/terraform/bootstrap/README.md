# Bootstrap

**NOTE:** The resources in this file are used to bootstrap the Terraform remote backend in a new project. Creating and applying changes to resources in this folder should be done rarely and not be used as part of any automated CI/CD pipeline used to deploy the main infra resources for the project.

**Scenarios when `plan/apply` would be used on these resources:**

1. New project was created and has no existing Terraform configuration (remote backend, resources, modules, etc.)
   - Instructions: [Create Remote Backend](#create_remote_backend)
2. Remote backend bucket created needs to be modified (ex. Adding tags or updating the bucket policy)
   - Instructions: run `plan/apply` in this folder.

#### Bootstrapping components:

- Terraform remote state bucket and policies
