# cloud-benchmarks

Reproducible head-to-head benchmarks of Redis-compatible managed services in
public clouds — Terraform to deploy, scripts to run, raw memtier JSON results.

## What's here

```
scripts/raw-memtier-*.sh     bench client scripts (one per datatype/workload shape)
terraform/<setup>/           one directory per provider/SKU
results/                     raw memtier JSON output from published runs
```

Currently shipped: enough to reproduce a **GCP Memorystore for Valkey 9 vs
Redis Cloud Pro 8.4** comparison in `us-east1`, across STRING / HASH / JSON
workloads. See
[`results/memorystore-vs-redis-cloud-blog-april-2026/`](results/memorystore-vs-redis-cloud-blog-april-2026/)
for the dataset and headline numbers.

## Companion blog post

The data in
[`results/memorystore-vs-redis-cloud-blog-april-2026/`](results/memorystore-vs-redis-cloud-blog-april-2026/)
backs the blog post **"Same price, twice the throughput: Redis Cloud vs GCP
Memorystore for Valkey 9"** (link to be added once published).

## Reproduce

1. Provision a bench client + the cluster you want to test:

   ```bash
   cd terraform/bench-client-gcp-ubuntu24.04-c2-standard-16/   # bench host
   terraform apply -var project_id=<your-gcp-project>

   # one-time per network/region for Valkey:
   cd ../gcp-memorystore-shared-scp/
   terraform apply -var project_id=<your-gcp-project>

   # then either:
   cd ../gcp-memorystore-valkey-highmem-xlarge-8vcpus-46gb-cluster-mode/
   terraform apply -var project_id=<your-gcp-project>
   # --- or ---
   cd ../gcp-redis-cloud-50gb-50k-cluster-oss-api/
   terraform apply
   ```

2. SSH to the bench client and run a workload:

   ```bash
   ulimit -Sn 65536
   MEMTIER_AUTH=<password-if-rcp> CLUSTER_MODE=1 \
     ./scripts/raw-memtier-string-stair-bench.sh <host> <port> my-run 1800 0
   ```

   Each script auto-detects `N` master shards via `CLUSTER NODES` and scales
   `--clients` / `--clients-step` / `--step-duration` so the staircase reaches
   the same **1,000 total TCP connections at t=1200s** regardless of cluster
   topology — keeps comparisons across providers apples-to-apples.

## Workload shape

A 30-min connection staircase: start at 10 concurrent connections, step up by
50 every 60 s, reach 1,000 concurrent connections at minute 20, hold peak load
for 10 minutes. 50/50 read/write mix on a 100,000-key working set.

| Datatype | Read / write commands | Payload |
|---|---|---|
| STRING | `SET __key__ <value>` / `GET __key__` | 100-byte value |
| HASH   | `HSET __key__ <4 fields>` / `HGETALL __key__` | 4 fields, ~68 bytes raw |
| JSON   | `JSON.SET __key__ . <document>` / `JSON.GET __key__` | ~91-byte JSON document, same logical record as HASH |

## License

[Apache 2.0](LICENSE).
