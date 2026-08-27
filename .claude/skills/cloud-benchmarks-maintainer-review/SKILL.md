---
name: cloud-benchmarks-maintainer-review
description: Review a redis-performance/cloud-benchmarks pull request, branch, or diff against this specific repo's own conventions (its AGENTS.md/CONTRIBUTING.md, and the real patterns already in its Terraform modules and memtier bench scripts) rather than generic Terraform/Bash advice. Use this whenever the user asks to review a cloud-benchmarks PR "like a maintainer would", asks whether a cloud-benchmarks PR would pass real review or get merged, wants a cloud-benchmarks-specific pre-merge check, or is deciding accept/reject on a redis-performance/cloud-benchmarks PR. Prefer this over a generic code-review skill for anything touching redis-performance/cloud-benchmarks.
---

# cloud-benchmarks maintainer-style review

## Honesty warning — read this before anything else

This repo has almost no review history to mine. As of the time this skill was written, its entire GitHub
history is: **2 commits, 1 pull request, 0 issues.** PR#1 ("Add CONTRIBUTING.md and AGENTS.md") was opened and
merged same-day by **fcostaoliveira** (Filipe Oliveira, the repo's sole code author to date) and approved by
**paulorsousa** (Paulo Sousa) with a **blank-body `APPROVED`** — no review comments, no requested changes,
nothing to quote. There is no third contributor, no rejected PR, no back-and-forth review thread, and no bug
report to point to anywhere in this repo's real history.

That means, unlike a skill for a repo with hundreds of mined PRs, **this skill cannot give you an authentic
"maintainer voice"** — there simply isn't enough real dialogue on record to characterize how fcostaoliveira or
paulorsousa write a review comment, because neither of them has written one yet. Do not invent one. Do not
imply a review quote, a tone, or a personality trait is evidenced when it is actually just this skill's author
guessing. If you want to sound approving, a plain, short "LGTM" (or silence, if the PR is trivial — the one
real precedent this repo has *is* silent, wordless approval) is the only pattern this repo's history actually
supports. The complete record this is based on — every commit, PR, and review that exists on this repo — is
catalogued in full in `references/history-and-people.md`; read it once so you know exactly how thin the record
actually is, rather than taking this section's word for it.

What this skill *can* ground a review in, honestly:
- This repo's own **`AGENTS.md`** and **`CONTRIBUTING.md`**, which are real, current, written rules — not
  review comments, but explicit maintainer-authored doctrine about what's expected of a change here.
- The real, concrete conventions already followed consistently across the repo's three memtier bench scripts
  and four Terraform modules (see `references/review-checklist.md`) — i.e., does a new PR match the patterns
  this codebase's own existing code already establishes, not some external Terraform/Bash style guide.
- Baseline security hygiene for a repo that provisions real cloud infrastructure and reads real credentials
  from the environment.

Say plainly, in the review itself if relevant, that this repo's review history is too thin to cite precedent
from — reason from the checklist and the code that's actually here instead.

## Scope gate

If the diff touches nothing this checklist covers — no `terraform/`, `scripts/`, `results/`, `AGENTS.md`,
`CONTRIBUTING.md`, or `README.md` change (e.g., a totally unrelated new top-level tool) — say so in one
sentence and treat it as out of scope rather than force-fitting the checklist below onto it.

## Process

1. **Get the material.** `gh pr view <n> --repo redis-performance/cloud-benchmarks --json body,commits,files,author`
   and `gh pr diff <n> --repo redis-performance/cloud-benchmarks`. Given this repo has exactly one prior PR,
   `gh pr list --author <login> --state merged --repo redis-performance/cloud-benchmarks` will almost always
   come back empty or with a single entry — don't lean on author-trust history to calibrate scrutiny here, lean
   on diff risk instead (does it touch a bench script's timing/scaling math, a Terraform module's provider
   versions, or the committed `results/` dataset?).

2. **Work the checklist** in `references/review-checklist.md` — every item there is grounded in either this
   repo's own written `AGENTS.md`/`CONTRIBUTING.md` rules or a concrete pattern already present, consistently,
   across its real scripts/modules (cited by file). Where the checklist has no item that covers something in
   the diff, say so and reason about it on ordinary Terraform/Bash/benchmarking-methodology merits instead of
   forcing a citation that doesn't exist.

3. **Write the review.** Keep it short — a few sentences to a handful of numbered points, matching the only
   real data point this repo has (a wordless approval on a routine PR). Concrete points to make, real gaps to
   flag:
   - If a bench script or its staircase math changed: does it still hold the "apples-to-apples" invariant
     `AGENTS.md` states explicitly ("Do not change `--threads`, `--clients`, `--clients-step`, or
     `--step-duration` defaults... without a matching explanation")? Say if the PR explains the change or not.
   - If `results/` changed: `AGENTS.md` says not to modify committed results — flag any diff under `results/`
     that isn't a wholesale new dataset addition.
   - If a new Terraform provider or version constraint is added: `AGENTS.md` says to confirm compatibility with
     existing constraints in each module's `common.tf` first — check whether the PR does, or at least whether
     the new constraint is consistent with the `~>` bounds already used in the other three modules.
   - If real credentials/secrets are involved (`REDISCLOUD_ACCESS_KEY`, `REDISCLOUD_SECRET_KEY`,
     `REDIS_CLOUD_PAYMENT_4DIGITS`, `REDIS_CLOUD_DEFAULT_PASSWORD`, `MEMTIER_AUTH`, GCP service-account keys):
     confirm the PR reads them from the environment or Terraform variables the way every existing module does,
     never a literal value or a new committed file — and check `.gitignore` still covers any new
     `*.tfvars`/`*.tfstate`-shaped output the change introduces.
   - Hedge like someone who genuinely doesn't have a deep bench of precedent to draw on: "I don't see this
     covered elsewhere in the repo, but..." is an honest, appropriate thing to write here, unlike a project with
     a hundred prior examples to lean on.

4. **Land on a verdict** the way this repo's one real data point does: `APPROVED` for a routine, clearly correct
   change (often with no comment at all, or a bare "LGTM" plus anything concretely worth naming), or
   `COMMENTED` with specific, concrete asks when the checklist above surfaces something real. Never invent a
   maintainer quote or tone to sound more authoritative than a two-commit repo's history actually supports.

   Never write the literal word "Verdict," and never format a labeled summary line, a trailing `---` section,
   or a "TL;DR." End in plain prose; if you need to separately name which GitHub review state you'd pick, say
   so as a short unformatted aside after the review text, not inline.

## What NOT to do

- Don't fabricate a "maintainer personality," a review quote, or a tone and attribute it to fcostaoliveira or
  paulorsousa — this repo's real history has exactly one review event, and it's a blank approval. Any voice
  you'd cite would be invented, not mined.
- Don't claim this repo's thin history is actually rich, and don't apologize for it excessively either — state
  it once, plainly, and move on to reasoning from the checklist and the code that's actually here.
- Don't apply the taxonomy from a different repo's skill (e.g. redisbench-admin's Python-specific categories,
  or memtier_benchmark's C/C++ buffer-sizing categories) here — this is a Terraform + Bash repo with a
  different real risk surface.
- Don't close with a labeled, bolded verdict block — end in plain prose (see step 4).
- Don't literally `@`-mention any GitHub username, ever.
