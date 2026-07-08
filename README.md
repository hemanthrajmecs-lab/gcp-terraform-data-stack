# gcp-terraform-data-stack

I got tired of clicking through the GCP console every time I needed to spin up a new data environment. Built this to provision a full GCP data stack from scratch using Terraform: datasets, buckets, IAM, the works. Now I can have a new environment running in minutes.

It also means dev and prod can't drift apart, because they're built from the exact same modules with different tfvars.

## What gets provisioned

* BigQuery: three datasets following the medallion pattern. `raw` (bronze), `staging` (silver), `analytics` (gold). Raw partitions auto-expire after 90 days so old junk doesn't pile up.
* GCS: three buckets. `landing` for incoming files, `archive` on Nearline that moves to Coldline after a year, and `temp` that deletes anything older than 7 days.
* IAM: three service accounts. `pipeline-sa` for jobs, `analyst-sa` with read-only BigQuery access, and `admin-sa` for the rare times you need full control.
* Cloud Composer: an Airflow 2 environment, off by default (see below).
* Remote state in a GCS bucket, separate prefixes per environment.

## Layout

```
                 environments/
                 ├── dev/  ── terraform.tfvars ──┐
                 └── prod/ ── terraform.tfvars ──┤
                                                 │  both call the
                                                 ▼  same root module
                            main.tf (root)
                                 │
        ┌──────────────┬────────┴───────┬──────────────┐
        ▼              ▼                ▼              ▼
  modules/bigquery  modules/gcs    modules/iam   modules/composer
  raw / staging /   landing /      pipeline-sa   Airflow 2 env
  analytics         archive / temp analyst-sa    (opt-in)
                                   admin-sa

  state: gs://tf-state-gcp-data-stack/env/{dev,prod}
```

## How to use it

You need Terraform >= 1.5 and gcloud auth set up (`gcloud auth application-default login`).

One-time: create the state bucket, since Terraform can't manage the bucket its own state lives in.

```bash
gsutil mb gs://tf-state-gcp-data-stack
```

Then:

```bash
cd environments/dev
# put your project id in terraform.tfvars first
terraform init
terraform plan
terraform apply
```

## Switching environments

Each environment is its own directory with its own state prefix, so there's no workspace juggling. `cd environments/prod` and run the same three commands. Prod defaults to deploying Composer and sizes the workers up to 5, dev skips Composer entirely.

## Why Composer is off by default

A Composer environment takes about 25 minutes to create and costs money even when it's idle. For dev work I almost never need it, so it's behind a `deploy_composer` flag. Flip it to true in tfvars when you actually want Airflow.

## Known limitations / what I'd add next

* No CI yet. I run plan and apply by hand. Next step is a Cloud Build trigger that runs `terraform plan` on PRs and posts the diff as a comment.
* The IAM module grants roles at the project level. Dataset-level grants would be tighter, I just haven't needed that granularity yet.
* State bucket creation is still a manual step. A small bootstrap script would fix that.
