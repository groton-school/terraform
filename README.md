# @groton/terraform

Common Terraform modules and scripts

## Install

```sh
pnpm install -D @groton/terraform@groton-school/terraform#main
pnpm setup-terraform
```

## Use

This repo provides a number of re-usable Terraform modules in the [`modules`](./modules/) directory. By convention, these can be added to a Terraform declaration by URL:

```hcl
module "project" {
    source = "git::ssh://git@github.com/groton-school/terraform.git//modules/project?ref=v1.1.0"
    project_id = var.project_id
}
```

In addition there are some convenience scripts that the `setup-terraform` script references when configuring package scripts:

| Script                | Use                                                                                                                                                                                                                        |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `setup-terraform`     | Sets up the local project deploy to Google Cloud using a Terraform `infra` directory and `turbo` monorepo pruning. Invoke with `--help` or `-h` for all options.                                                           |
| `swap-gitignore`      | Swaps between a [default `.gitignore`](./bin/gitignore/commit.gitignore) value for managing a GitHub repository and a [`.gitignore` that is tailored more specifically to `turbo prune`](./bin/gitignore/prune.gitignore). |
| `require-gcloud-auth` | `gcloud` is required for Terraform artifact management using [`modules/artifacts`](./modules/artifacts/). This script ensures that `gcloud` is authorized.                                                                 |
| `op-terraform`        | Requires the 1Password CLI tool `op`. Wraps `terraform init` and `terraform apply` with some useful flags and loads environment variables from the local `.env` file and 1Password.                                        |

## Templates

###### `default`

A basic Google Cloud Run service with a runner service account, deployed from the local monorepo in a project in `/app`.

###### `veracross-delegate`

A [Next.js](https://nextjs.org/) app in `/app` with Veracross SSO using [Auth.js](https://authjs.dev/) and a delegated Veracross service account user whose credentials and refresh token are stored in Google Cloud Secret Manager and managed by a service in `/services/tokens` using [@delegated-token/veracross](https://www.npmjs.com/package/@delegated-token/veracross)
