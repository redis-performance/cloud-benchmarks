# Memorystore Valkey 9 vs Redis Cloud Pro 8.4 — April 2026

Companion data for the blog post **"Same price, twice the throughput: Redis
Cloud vs GCP Memorystore for Valkey 9"** (link to be added on publish).

Each file is the verbatim memtier JSON output (per-second time-series +
percentile histograms + Totals); only the `configuration.server` and
`configuration.authenticate` fields are redacted.

## Setup

Both clusters in `us-east1-b`, dollar-matched at ~$2/hr list price (March 11
2026 pricing).

| | GCP Memorystore for Valkey 9 | Redis Cloud Pro 8.4 |
|---|---|---|
| SKU | `highmem-xlarge` cluster-mode (8 vCPU / 46 GB writable) | 50 GB / 50K ops cluster + OSS Cluster API |
| Replication | enabled | enabled |
| TLS | off | off |
| Bench client | GCP `c2-standard-16` Ubuntu 24.04, same zone | same |

## Workload

For each datatype we run a 50/50 read/write mix, with a 100-byte payload
encoded differently:

```
STRING:  SET __key__ <value>             /  GET __key__
HASH:    HSET __key__ <4 fields>         /  HGETALL __key__
JSON:    JSON.SET __key__ . <document>   /  JSON.GET __key__
```

Run as a 30-min connection staircase: start at 10 concurrent connections (1
per memtier thread), step up by 50 new connections every 60 s, ramp up to
1,000 concurrent connections at minute 20, then hold peak load for ten
minutes. The bench scripts auto-scale `--clients`/`--clients-step`/
`--step-duration` by `1/N` so the connection curve is identical across
vendors regardless of shard count. Random key access on a 100,000-key
working set.

## Headline numbers (peak window, t=1200..1800 mean)

| Metric | Redis Cloud | Google Cloud Memorystore for Valkey | Redis advantage |
|---|---:|---:|:---:|
| **STRING** throughput (ops/sec) | 561,378 | 476,813 | 1.2× |
| **STRING** p50 (ms) | 1.479 | 2.098 | 1.4× lower latency |
| **HASH** throughput (ops/sec)   | 483,863 | 335,250 | 1.4× |
| **HASH** p50 (ms)               | 1.924   | 3.364   | 43% lower latency |
| **JSON** throughput (ops/sec)   | 474,625 | 219,311 | **2.2×** |
| **JSON** p50 (ms)               | 1.986   | 4.790   | **2.4× lower latency** |

## Files

| File | Vendor | Datatype |
|---|---|---|
| `competitive-gcp-blog-memorystore-valkey-string-stair.json` | GCP Memorystore Valkey 9 | STRING |
| `competitive-gcp-blog-memorystore-valkey-hash-stair.json`   | GCP Memorystore Valkey 9 | HASH |
| `competitive-gcp-blog-memorystore-valkey-json-stair.json`   | GCP Memorystore Valkey 9 | JSON |
| `competitive-gcp-blog-rcp-50gb-50k-string-stair.json`       | Redis Cloud Pro 8.4 | STRING |
| `competitive-gcp-blog-rcp-50gb-50k-hash-stair.json`         | Redis Cloud Pro 8.4 | HASH |
| `competitive-gcp-blog-rcp-50gb-50k-json-stair.json`         | Redis Cloud Pro 8.4 | JSON |

## Extracting per-second time-series

```python
import json
d = json.load(open('competitive-gcp-blog-rcp-50gb-50k-json-stair.json'))
ts = d['ALL STATS']['Totals']['Time-Serie']
# ts is a dict keyed by second-index → {Count, p50.00, p95.00, p99.00, …}
for sec in sorted(ts, key=int):
    e = ts[sec]
    print(sec, e['Count'], e.get('p50.00'), e.get('p95.00'), e.get('p99.00'))
```
