# Contributing

We treat this repo as "Open Source" within Redis: anyone who clears the bar below is welcome to contribute.

## Local setup

This repo is Terraform + Bash scripts — no build step is required. You need:

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`) authenticated to a GCP project
- `redis-cli` and `memtier_benchmark` on the bench client VM (provisioned automatically by the Terraform modules)

Clone and initialise the provider plugins for whichever setup you plan to work on:

```bash
git clone git@github.com:redis-performance/cloud-benchmarks.git
cd cloud-benchmarks

# Bench client (GCP):
cd terraform/bench-client-gcp-ubuntu24.04-c2-standard-16/
terraform init

# GCP Memorystore shared service connection policy (one-time per project/network):
cd ../gcp-memorystore-shared-scp/
terraform init

# GCP Memorystore Valkey cluster:
cd ../gcp-memorystore-valkey-highmem-xlarge-8vcpus-46gb-cluster-mode/
terraform init

# Redis Cloud Pro subscription (requires env vars below):
cd ../gcp-redis-cloud-50gb-50k-cluster-oss-api/
terraform init
```

**GCP credentials** — authenticate once with Application Default Credentials:

```bash
gcloud auth application-default login
```

**Redis Cloud credentials** — the `gcp-redis-cloud-*` modules read two env vars at plan/apply time via `env.sh`:

```bash
export REDIS_CLOUD_PAYMENT_4DIGITS=<last-4-digits-of-card>
export REDIS_CLOUD_DEFAULT_PASSWORD=<db-password>
```

You also need a Redis Cloud [API key](https://redis.io/docs/latest/operate/rc/api/get-started/manage-api-keys/) exported for the Terraform provider:

```bash
export REDISCLOUD_ACCESS_KEY=<api-account-key>
export REDISCLOUD_SECRET_KEY=<api-secret-key>
```

## Branch naming

```
<type>/<short-description>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Example: `feat/add-pipeline-mode`

## Coding standards

- Keep changes focused; one logical change per PR.
- Follow the conventions already present in the codebase (formatting, naming, error handling).
- No dead code, no commented-out blocks.

## Submitting changes

1. Fork or create a branch from `main`.
2. Make your changes with clear, atomic commits.
3. Open a pull request against `main` with a descriptive title and summary.
4. Address review comments promptly; force-push to the same branch to update.

## Testing

There is no automated test suite — correctness is validated by running the full benchmark end-to-end and inspecting the JSON output.

Before opening a PR, verify your change manually:

1. Deploy the relevant Terraform module (`terraform apply -var project_id=<your-gcp-project>`).
2. SSH to the bench client and raise the file-descriptor limit:
   ```bash
   ulimit -Sn 65536
   ```
3. Run at least one benchmark script against the target cluster, e.g.:
   ```bash
   CLUSTER_MODE=1 ./scripts/raw-memtier-string-stair-bench.sh <host> <port> smoke-test 120 0
   ```
4. Confirm the script exits cleanly and produces a valid `smoke-test-stair.json`.
5. Tear down ephemeral infrastructure with `terraform destroy`.

## Review process

- At least one maintainer approval is required before merge.
- CI must be green.
- Maintainers may request changes or close PRs that don't meet the bar — this is normal and not personal.
