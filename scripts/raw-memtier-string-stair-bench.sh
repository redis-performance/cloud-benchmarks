#!/usr/bin/env bash
# Raw memtier STRING staircase benchmark:
#
#   - 30-minute connection staircase: 10 threads × (1→100 clients/thread),
#     +5 clients/thread every 60s for 20 steps, then 10-min hold at 1000 conns
#   - 50/50 read/write mix: SET __key__ <data> / GET __key__
#   - 100K-key working set, --command-key-pattern=R (random)
#   - --cluster-mode for OSS-cluster routing
#
# Args:
#   $1 REDIS_HOST   (required)
#   $2 REDIS_PORT   (default 6379)
#   $3 DEPLOYMENT   (required — used as filename prefix)
#   $4 TEST_TIME    (default 1800 — full staircase incl. 10-min peak hold)
#   $5 TLS          (default 0)
#   $6 DATA_SIZE    (default 100 — bytes per SET payload)
#
# Env vars:
#   WORK_DIR      where to write outputs (default /home/ubuntu)
#   CLUSTER_MODE  1 → pass --cluster-mode (default 1 — blog uses cluster mode)
#   MEMTIER_AUTH  if set, passes -a <pass> to memtier

set -uo pipefail

REDIS_HOST="${1:?missing REDIS_HOST}"
REDIS_PORT="${2:-6379}"
DEPLOYMENT="${3:?missing DEPLOYMENT}"
TEST_TIME="${4:-1800}"
TLS="${5:-0}"
DATA_SIZE="${6:-100}"

TLS_FLAGS=""
if [ "$TLS" = "1" ]; then
  TLS_FLAGS="--tls --tls-skip-verify"
fi

CLUSTER_FLAG=""
if [ "${CLUSTER_MODE:-1}" = "1" ]; then
  CLUSTER_FLAG="--cluster-mode"
fi

AUTH_FLAG=""
REDIS_CLI_AUTH=""
if [ -n "${MEMTIER_AUTH:-}" ]; then
  AUTH_FLAG="-a ${MEMTIER_AUTH}"
  REDIS_CLI_AUTH="-a ${MEMTIER_AUTH} --no-auth-warning"
fi
TLS_CLI=""
if [ "$TLS" = "1" ]; then
  TLS_CLI="--tls"
fi

# In cluster mode memtier opens connections to EVERY master shard, so the
# real conn count = threads × clients × N_masters. To compare engines that
# differ in shard count at the same total load, scale the per-thread targets
# by 1/N. Detect N via CLUSTER NODES; default to 1 (non-cluster or detection failure).
NUM_MASTERS=1
if [ "${CLUSTER_MODE:-1}" = "1" ]; then
  DETECTED=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" $REDIS_CLI_AUTH $TLS_CLI CLUSTER NODES 2>/dev/null \
    | awk '$3 ~ /master/ {n++} END {print n+0}')
  if [ -n "$DETECTED" ] && [ "$DETECTED" -gt 0 ]; then
    NUM_MASTERS=$DETECTED
  fi
fi
TARGET_CLIENTS=100
TARGET_STEP=5
TARGET_START=1
TARGET_RAMP_DURATION=1200   # 20 ramp steps × 60s for the canonical N=1 staircase
SCALED_CLIENTS=$(( TARGET_CLIENTS / NUM_MASTERS ))
SCALED_STEP=$(( TARGET_STEP / NUM_MASTERS ))
[ "$SCALED_STEP" -lt 1 ] && SCALED_STEP=1
SCALED_START=$TARGET_START

# Number of ramp steps to climb from SCALED_START to SCALED_CLIENTS at SCALED_STEP/step.
# Ceil((max-start)/step) — the last step may be partial.
NUM_RAMP_STEPS=$(( (SCALED_CLIENTS - SCALED_START + SCALED_STEP - 1) / SCALED_STEP ))
[ "$NUM_RAMP_STEPS" -lt 1 ] && NUM_RAMP_STEPS=1
# Stretch step_duration so the ramp takes the same TARGET_RAMP_DURATION
# regardless of N. Without this, integer step rounding shortens (or lengthens)
# the ramp and the peak-hold window starts at a different wall-clock time
# across vendors.
STEP_DURATION=$(( TARGET_RAMP_DURATION / NUM_RAMP_STEPS ))
[ "$STEP_DURATION" -lt 1 ] && STEP_DURATION=1

# Bump fd limit — at peak (1000 conns × N shards in cluster mode) the default
# 1024 nofile cap on Ubuntu's per-process limit gets shredded. Hard limit is
# usually 1048576 so this raise is safe.
ulimit -Sn 65536 || true

cd "${WORK_DIR:-/home/ubuntu}"

PEAK_TOTAL=$(( 10 * SCALED_CLIENTS * NUM_MASTERS ))
RAMP_WALL=$(( NUM_RAMP_STEPS * STEP_DURATION ))
echo "================================================================"
echo "Target   : $REDIS_HOST:$REDIS_PORT  cluster_mode=${CLUSTER_MODE:-1} tls=$TLS"
echo "Workload : STRING staircase, 50/50 SET/GET, 100K keys, ${DATA_SIZE}B payload"
echo "Topology : detected $NUM_MASTERS master shards via CLUSTER NODES"
echo "Memtier  : --threads=10 --clients=$SCALED_CLIENTS --clients-start=$SCALED_START --clients-step=$SCALED_STEP --step-duration=$STEP_DURATION"
echo "Ramp     : $NUM_RAMP_STEPS steps × ${STEP_DURATION}s = ${RAMP_WALL}s (target ${TARGET_RAMP_DURATION}s) → peak hold ~$(( TEST_TIME - RAMP_WALL ))s"
echo "Effective: 10 × $SCALED_CLIENTS × $NUM_MASTERS = $PEAK_TOTAL total conns at peak"
echo "Duration : ${TEST_TIME}s"
echo "================================================================"

memtier_benchmark \
  -s "$REDIS_HOST" -p "$REDIS_PORT" $TLS_FLAGS $CLUSTER_FLAG $AUTH_FLAG \
  --threads=10 --clients="$SCALED_CLIENTS" \
  --key-minimum=1 --key-maximum=100000 \
  --data-size="$DATA_SIZE" \
  --test-time="$TEST_TIME" \
  --command "SET __key__ __data__" \
  --command "GET __key__" \
  --command-key-pattern=R --command-key-pattern=R \
  --print-percentiles="50,95,99" \
  --hide-histogram \
  --json-out-file="${DEPLOYMENT}-stair.json" \
  --clients-start "$SCALED_START" --clients-step "$SCALED_STEP" --step-duration "$STEP_DURATION" \
  2>&1 | tee "${DEPLOYMENT}-stair.log"

RC=${PIPESTATUS[0]}
echo "(memtier exit=$RC)"
echo ""
echo "=== Output files ==="
ls -la "${DEPLOYMENT}"-*.json "${DEPLOYMENT}"-*.log 2>/dev/null || true

echo ""
echo "=== Summary (from JSON aggregate) ==="
python3 - <<PYEOF
import json
try:
    d = json.load(open("${DEPLOYMENT}-stair.json"))
    s = (d.get("ALL STATS") or {}).get("Totals") or {}
    pl = s.get("Percentile Latencies") or {}
    print(f"ops_sec={s.get('Ops/sec'):>10,.0f}  p50={pl.get('p50.00')}ms  p95={pl.get('p95.00')}ms  p99={pl.get('p99.00')}ms")
except Exception as e:
    print(f"parse error: {e}")
PYEOF
