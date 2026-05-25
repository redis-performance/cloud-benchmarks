# Agent guidelines

Instructions for AI coding agents (Claude Code, Copilot, Cursor, etc.) working in this repo.

## Project overview

`cloud-benchmarks` publishes reproducible, head-to-head throughput comparisons between Redis-compatible managed cloud services. The repo contains Terraform modules that provision the infrastructure under test (currently GCP Memorystore for Valkey 9 and Redis Cloud Pro 8.4 on GCP, plus a GCP benchmark-client VM), and Bash scripts that drive `memtier_benchmark` through a 30-minute connection-staircase workload (STRING, HASH, and JSON datatypes). Raw memtier JSON results are committed to `results/` so anyone can re-analyse or verify the numbers independently.

## Local setup

This repo is Terraform + Bash scripts — no build step is required.

```bash
git clone git@github.com:redis-performance/cloud-benchmarks.git
cd cloud-benchmarks

# Initialise provider plugins for the module you are working on, e.g.:
cd terraform/bench-client-gcp-ubuntu24.04-c2-standard-16/
terraform init
```

GCP authentication uses Application Default Credentials:

```bash
gcloud auth application-default login
```

Redis Cloud modules additionally require:

```bash
export REDIS_CLOUD_PAYMENT_4DIGITS=<last-4-digits-of-card>
export REDIS_CLOUD_DEFAULT_PASSWORD=<db-password>
export REDISCLOUD_ACCESS_KEY=<api-account-key>
export REDISCLOUD_SECRET_KEY=<api-secret-key>
```

To run a benchmark manually on the bench-client VM (SSH in after `terraform apply`):

```bash
ulimit -Sn 65536
CLUSTER_MODE=1 ./scripts/raw-memtier-string-stair-bench.sh <host> <port> my-run 1800 0
```

## Branch naming

Same as human contributors: `<type>/<short-description>` (e.g. `fix/off-by-one-in-pipeline`).

## Coding standards

- Match the style already in the file you are editing.
- Prefer clear, minimal changes over large refactors unless explicitly asked.
- Do not add comments that describe *what* the code does — only add comments when the *why* is non-obvious.
- Do not introduce new dependencies without checking with the maintainer.

## Running tests

There is no automated test suite. Validate changes by running a short benchmark end-to-end:

```bash
# From the bench-client VM, after terraform apply and SSH:
ulimit -Sn 65536
CLUSTER_MODE=1 ./scripts/raw-memtier-string-stair-bench.sh <host> <port> smoke-test 120 0
# Confirm smoke-test-stair.json is produced and the script exits 0.
```

Always run a smoke test before declaring a task complete.

## How to submit changes

1. Create a branch: `git checkout -b <type>/<description>`.
2. Commit with a clear message focused on *why*, not *what*.
3. Open a pull request against `main`.
4. Do **not** push directly to `main`.

## What to avoid

- Do not reformat files unrelated to your change.
- Do not remove error handling or tests.
- Do not commit secrets, credentials, or large binary files.
- Do not amend published commits.
- Do not modify committed results under `results/` — those are the canonical published dataset; raise a PR discussion if numbers need to be corrected.
- Do not change `--threads`, `--clients`, `--clients-step`, or `--step-duration` defaults in the bench scripts without a matching explanation — these values are calibrated so comparisons across providers are apples-to-apples (same total TCP connections at the same wall-clock time).
- Do not add new Terraform provider dependencies without confirming compatibility with the existing provider version constraints in `common.tf`.
