# Review checklist — cloud-benchmarks, grounded in real repo content only

This repo has no mined review-comment history to cite (see SKILL.md's honesty warning: 1 PR, 0 issues, one
blank-body approval). Every item below is instead grounded in one of two things that genuinely exist:
this repo's own written `AGENTS.md`/`CONTRIBUTING.md` rules, or a pattern already consistently present, as
actual code, across its real bench scripts and Terraform modules (as of the state this skill was written
against: 3 scripts under `scripts/`, 4 modules under `terraform/`, 1 published results set under `results/`).
Cite the source (a specific written rule, or a specific existing file) rather than presenting these as
"maintainer preference" — none of them have been articulated by a human reviewer yet.

1. **The connection-staircase scaling math must stay internally consistent if touched.** All three scripts
   (`raw-memtier-string-stair-bench.sh`, `-hash-`, `-json-`) implement the identical pattern: detect
   `NUM_MASTERS` via `CLUSTER NODES`, scale `TARGET_CLIENTS`/`TARGET_STEP` down by `NUM_MASTERS`, then stretch
   `STEP_DURATION` so the ramp still reaches peak at the same wall-clock time (`TARGET_RAMP_DURATION=1200`)
   regardless of shard count — this is what `AGENTS.md` means by "these values are calibrated so comparisons
   across providers are apples-to-apples (same total TCP connections at the same wall-clock time)." A PR that
   changes this math in one script but not the others, or that hardcodes a client/step count instead of
   deriving it from `NUM_MASTERS`, breaks that invariant and should be flagged even if the new number looks
   reasonable in isolation.

2. **A new datatype/command script needs a considered answer on pre-run `FLUSHALL`, not silent copy-paste.**
   Concrete, real difference already in the repo: `raw-memtier-hash-stair-bench.sh` and
   `raw-memtier-json-stair-bench.sh` both FLUSHALL every master shard before running, with a comment explaining
   why (`HSET`/`JSON.SET` against a key left over from a previous differently-typed run fails `WRONGTYPE`);
   `raw-memtier-string-stair-bench.sh` has no such step, because plain `SET` overwrites any existing key
   regardless of its prior type. This is not an inconsistency to "fix" — it's a real, deliberate difference
   that tracks Redis command semantics. If a new script adds a non-`SET`-like write command (anything that can
   `WRONGTYPE` against a stale key), check it either FLUSHALLs first or explicitly documents why it doesn't
   need to.

3. **`results/` is a published, append-only dataset.** `AGENTS.md`: "Do not modify committed results under
   `results/` — those are the canonical published dataset; raise a PR discussion if numbers need to be
   corrected." A diff that edits an existing file under `results/` (as opposed to adding a new, wholly separate
   results directory) is a real concern to name explicitly, not a routine content change.

4. **New Terraform provider versions must be checked against the other three modules' `common.tf`, not just
   the one being edited.** Every existing module's `common.tf` pins `~>` version constraints (e.g.
   `hashicorp/google ~> 6.20`, `required_version >= 1.3`). `AGENTS.md` says explicitly not to add new provider
   dependencies without confirming compatibility with existing constraints — check whether a changed or added
   constraint in one module is still consistent with the same provider's constraint in the others, since these
   modules are meant to be applied together in one benchmark run (bench-client + Memorystore or Redis Cloud).

5. **Credentials stay env-var/Terraform-variable only, never a literal or a new committed file.** Real secret
   surface named explicitly in `AGENTS.md`/`CONTRIBUTING.md`: `REDIS_CLOUD_PAYMENT_4DIGITS`,
   `REDIS_CLOUD_DEFAULT_PASSWORD`, `REDISCLOUD_ACCESS_KEY`, `REDISCLOUD_SECRET_KEY`, plus `MEMTIER_AUTH` in the
   bench scripts and GCP Application Default Credentials for the `google` provider. `AGENTS.md`: "Do not commit
   secrets, credentials, or large binary files." Check any new script or module reads these the same way the
   existing ones do (env var or `-var`/`.tfvars`-at-apply-time, never hardcoded), and that `.gitignore`'s
   existing Terraform coverage (`.terraform/`, `*.tfstate*`, `*.tfplan`, `*.tfvars`) still covers whatever new
   state/plan/vars files a new module would produce.

6. **Bench script argument contract and defaults should match the existing three scripts' shape.** All three
   take the same positional-argument order (`HOST PORT DEPLOYMENT TEST_TIME TLS [...]`) with the same
   `${N:?missing ...}`/`${N:-default}` bash idiom, and the same `WORK_DIR`/`CLUSTER_MODE`/`MEMTIER_AUTH` env
   vars. A new script that reorders positional args, silently changes a default, or introduces a new env var
   with a name that doesn't follow this pattern is worth flagging for consistency, since these scripts are
   meant to be interchangeable drop-ins for different datatypes on the same harness.

7. **Branch naming and PR-only workflow are explicit written rules, not review-culture inference.**
   `CONTRIBUTING.md`/`AGENTS.md`: `<type>/<short-description>` branch names, no direct push to `main`, PR
   required. Trivial to check mechanically from the PR's branch name and the fact that it exists as a PR at
   all — worth a one-line mention only if actually violated (e.g. a PR opened from a branch that pushed
   directly to `main` first).

## What this checklist is honestly silent on

This repo has never had a security-sensitive PR, a rejected PR, a multi-round review thread, or a documented
bug caught in review — because it has had exactly one PR, and it was a docs-only addition. If a real PR raises
a concern not covered above (e.g. a genuinely new class of Terraform resource, a change to how the bench client
authenticates, a new cloud provider entirely), reason about it on ordinary infra/benchmarking-methodology
merits and say plainly that this repo's own history doesn't yet give you a precedent for it — don't stretch one
of the seven items above to cover something it doesn't actually address.
