# SecureCloud DevSecOps Lab — Progress Tracker

> Single source of truth for learning progress. A step is marked `[x]` only after its commands were run and the result was verified.
> Status legend: `[ ]` Not started · `[>]` In progress · `[x]` Completed and verified · `[!]` Blocked / needs attention

## 1. Project name and objective
**SecureCloud DevSecOps Lab** — build a small Python FastAPI application and take it from source code to a low-cost AWS deployment through a secure GitHub Actions pipeline, with security testing at every important stage (SAST, SCA, secrets, container, IaC, cloud identity, monitoring). Goal: hands-on, interview-ready Senior DevSecOps / AppSec Architect / Cloud Security experience.

## 2. Lab architecture (simple explanation)
Code is written on a Windows laptop and pushed to GitHub on a feature branch. A pull request triggers GitHub Actions, which acts like an assembly line with security inspectors: unit tests → Semgrep (code flaws) → pip-audit (vulnerable libraries) → Gitleaks (leaked secrets) → Docker build → Trivy (image vulnerabilities). Terraform describes the AWS infrastructure and is scanned by Checkov/Trivy before it is applied. Only changes that pass the security gates are merged. The deployment job gets a short-lived AWS credential through GitHub OIDC (no stored access keys), pushes the image to Amazon ECR and runs it on a low-cost AWS compute service, reachable only from an allowed IP. CloudTrail and CloudWatch Logs record what happens for monitoring and investigation.

```
Laptop ──push──▶ GitHub (branch + PR + review)
                    │
                    ▼
            GitHub Actions CI ── tests · Semgrep · pip-audit · Gitleaks · docker build · Trivy · Checkov
                    │  (security gate: block on agreed severity)
                    ▼
            GitHub Actions CD ──OIDC (temporary creds)──▶ AWS IAM role (least privilege)
                    │                                        │
                    ▼                                        ▼
               Amazon ECR (image by digest) ──────▶ Low-cost compute (decided in Phase 7)
                                                         │
                                         CloudWatch Logs · CloudTrail · Budgets/alerts
```

## 3. Current phase and exact step
- **Sprint:** 1 — Setup + application
- **Step:** 1.5 — Unit tests with pytest
- **Status:** `[ ]` Ready to start (after committing Step 1.4 on `feature/notes-api`)

## 4. Phase and step checklist (Fast track, ~25 hours, cost ₹0)

### Sprint 1 — Setup + application (~4 h)
- [x] 1.1 Read-only environment check (`scripts/env-check.ps1`) — verified 2026-10-19
- [x] 1.2 Verify installed tools work: Docker engine + hello-world, Git identity, Python venv — verified 2026-10-19
- [x] 1.3 GitHub account 2FA + noreply commit email (A); public repo `securecloud-devsecops-lab` + first commit (B) — verified 2026-10-19
- [x] 1.4 FastAPI "SecureCloud Notes API" + virtual env + pinned dependencies — verified 2026-10-19
- [ ] 1.5 Unit tests with pytest (health, notes CRUD)

### Sprint 2 — Secure container (~3 h)
- [ ] 2.1 Scenario: insecure Dockerfile (root user, full base image, unpinned) — build, run, Trivy scan (baseline count)
- [ ] 2.2 Harden: slim pinned base, non-root user, .dockerignore, healthcheck — rescan, compare counts

### Sprint 3 — CI pipeline + security gates (~6 h)
- [ ] 3.1 `ci.yml`: tests → Semgrep → pip-audit → Gitleaks → docker build → Trivy → reports as artifacts
- [ ] 3.2 Security policy: severity gates and documented exceptions
- [ ] 3.3 Branch ruleset: PR required, required checks, no force-push
- [ ] 3.4 Scenario: SQL-injection endpoint — Semgrep blocks PR — fix + regression test
- [ ] 3.5 Scenario: vulnerable dependency — pip-audit blocks PR — upgrade
- [ ] 3.6 Scenario: fake committed secret — Gitleaks blocks PR — remove + rotate procedure
- [ ] 3.7 Harden workflow: SHA-pinned actions, least-privilege permissions, Dependabot

### Sprint 4 — Terraform security (~4 h)
- [ ] 4.1 Terraform for ECR, ECS Fargate, security group, log group, IAM, OIDC — fmt/validate/plan only
- [ ] 4.2 Scenario: SG open to 0.0.0.0/0, `iam:*` policy, no encryption — Checkov detects — fix — rescan
- [ ] 4.3 Checkov added to CI as a gate

### Sprint 5 — AWS deployment, Free plan (~6 h) — explicit approval before apply
- [ ] 5.1 Create AWS Free plan account: root MFA, no root keys, admin identity, credit check
- [ ] 5.2 Credit-usage estimate + approval — `terraform apply`
- [ ] 5.3 `deploy.yml`: GitHub OIDC → push image to ECR → deploy by digest, `production` environment approval
- [ ] 5.4 Verify: app reachable from my IP only, running image digest matches, logs in CloudWatch
- [ ] 5.5 Scenario: unauthorized request + CloudTrail review of the deploy role
- [ ] 5.6 `terraform destroy` + verify zero resources and credit usage

### Sprint 6 — Interview pack (~2 h)
- [ ] 6.1 README, architecture diagram, threat model (STRIDE), security decisions
- [ ] 6.2 Interview notes + mock interview

### Optional later (not in fast track)
- [ ] Kubernetes (kind), Helm, policy as code, SBOM, image signing, ZAP DAST, runtime security

## 5. Completed steps (with dates)
| Step | Completed | Evidence |
|---|---|---|
| 1.1 Environment check | 2026-10-19 | `reports/env-check.txt` (run 14:43 IST) |
| 1.2 Tool verification | 2026-10-19 | `reports/verify-tools.txt` (run 14:46 IST) |
| 1.4 Notes API + venv + pinned deps | 2026-10-19 | `reports/smoke-test.txt` (15:14 IST): 7/7 expected status codes; 14 pinned packages |
| 1.3 GitHub repo + first commit | 2026-10-19 | Commit `1683a7b` (noreply author) on `origin/main` at github.com/rahulkumar4814/securecloud-devsecops-lab; Gitleaks 0 leaks pre-commit |

## 6. Pending and blocked steps
- Pending: commit Step 1.4 on feature branch; then Step 1.5.
- Blocked: none.

## 7. Commands executed and verified results
| Date | Command | Verified result |
|---|---|---|
| 2026-10-19 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\env-check.ps1` | Win 11 Pro 64-bit build 26200; PowerShell 5.1; 15.6 GB RAM; 229 GB free; i5-10400H; CurrentUser policy RemoteSigned. FOUND: winget 1.29, Git 2.55, Python 3.14.3, pip 26.0.1, Docker 29.0.1, WSL 3.0.3 (kali-linux v2, docker-desktop v2), VS Code 1.142, AWS CLI 2.32.5, Terraform 1.15.8, Trivy 0.74.0, Gitleaks 8.30.1. Semgrep present but crashes (traceback). MISSING: gh, checkov. "Virtualization in firmware: False" reported. |
| 2026-10-19 | `git switch -c feature/notes-api`; `python -m venv .venv`; `pip install -r requirements.in`; `pip freeze \| Out-File -Encoding ascii requirements.txt` | Branch created; venv Python 3.14.3; requirements.txt ASCII, 14 pins (fastapi 0.146.0, starlette 1.9.0, pydantic 2.14.1, pydantic_core 2.50.1, uvicorn 0.54.0, …) |
| 2026-10-19 | `scripts/smoke-test.ps1` | Server on 127.0.0.1 started; GET /health 200, POST /notes 201, GET /notes 200, GET /notes/1 200, GET /notes/9999 404, POST empty title 422, GET /notes/abc 422; server stopped |
| 2026-10-19 | `gitleaks dir . --redact --verbose` | no leaks found (reported by Rahul) |
| 2026-10-19 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-tools.ps1` | Hypervisor detected (VBS + HVCI running); Git user.name set, user.email = personal Gmail, init.defaultBranch unset; Docker client/server 29.0.1 linux/amd64; `hello-world` printed "Hello from Docker!"; Python 3.14.3 venv OK, OpenSSL 3.0.18 |

## 8. Files created or modified
| Date | File | Change |
|---|---|---|
| 2026-10-19 | `docs/DEVSECOPS_PROGRESS.md` | Created progress tracker |
| 2026-10-19 | `scripts/env-check.ps1` | Read-only environment check (run, verified) |
| 2026-10-19 | `reports/env-check.txt` | Generated by env-check (evidence) |
| 2026-10-19 | `scripts/verify-tools.ps1` | Step 1.2 tool verification (run, verified) |
| 2026-10-19 | `reports/verify-tools.txt` | Generated by verify-tools (evidence) |
| 2026-10-19 | `.gitignore` | Blocks secrets, Terraform state, venv, local reports from Git |
| 2026-10-19 | `.gitattributes` | Normalises line endings (LF; CRLF for .ps1) |
| 2026-10-19 | `README.md` | Initial project overview |
| 2026-10-19 | `reports/.gitkeep` | Keeps empty reports folder in Git |
| 2026-10-19 | `app/__init__.py`, `app/db.py`, `app/main.py` | Notes API: /health, POST/GET /notes, GET /notes/{id}; parameterized SQL; Pydantic input limits (verified by smoke test) |
| 2026-10-19 | `requirements.in` | Top-level deps: fastapi, uvicorn |
| 2026-10-19 | `scripts/smoke-test.ps1` | Smoke test (run, verified) |
| 2026-10-19 | `requirements.txt` | Generated lock file, 14 exact pins |

## 9. Security findings and remediation status
| ID | Date | Finding | Severity | Detected by | Status |
|---|---|---|---|---|---|
| F-001 | 2026-10-19 | Commit `cd5e968` authored with personal Gmail instead of GitHub noreply address; would expose email permanently in public repo history | Low (privacy) | Claude review of `git log` before push | **Fixed 2026-10-19** — commit amended to `1683a7b` with noreply author; never pushed, so never exposed |

## 10. Cloud resources and cleanup status
_No cloud resources created._

## 11. Errors encountered and fixes
| Date | Error | Cause | Resolution |
|---|---|---|---|
| 2026-10-19 | `git push` → `fatal: repository '.../rahulkumar4814/securecloud-devsecops-lab.git/' not found` | GitHub repo not created yet, created under a different name/account, or browser signed in to a different account | **Resolved 2026-10-19:** repo created/confirmed and `origin` reset to `https://github.com/rahulkumar4814/securecloud-devsecops-lab.git`; push succeeded. Note: remote URL was then set to the profile page `https://github.com/rahulkumar4814?tab=repositories` by mistake; must be the repo `.git` URL |
| 2026-10-19 | `semgrep --version` → Python traceback | Semgrep's native Windows support is limited; installed under Python 3.14 | Not fixing locally — Semgrep runs in GitHub Actions (Linux) by design |
| 2026-10-19 | "Virtualization enabled in firmware: False" | Usually a false reading when Hyper-V/WSL 2 is already running (Windows hides the flag); WSL 2 distros exist | **Resolved 2026-10-19:** false reading — `systeminfo` shows "A hypervisor has been detected" (VBS running) and Docker ran `hello-world` |

## 12. Technical decisions
| Date | Decision | Reason |
|---|---|---|
| 2026-10-19 | Project root: `C:\Users\DELL\Desktop\Learning_Skills\DevSecOps\securecloud-devsecops-lab` | Keeps the lab separate from other learning files; becomes the Git repository in Step 0.7 |
| 2026-10-19 | Progress tracker created before the repository exists | Required to exist before the first lab exercise; it will be the first committed file |
| 2026-10-19 | AWS compute choice deferred to Phase 7 | Pick after the app and pipeline work, with a written cost estimate and explicit approval |
| 2026-10-19 | **Zero-cost constraint: the lab must cost ₹0** | Rahul's requirement. Phases 0–6 and 10 run locally + on a public GitHub repo (free Actions minutes, free GHCR for public images) |
| 2026-10-19 | Cloud phases use an AWS **Free plan** account, created just before Phase 7, never upgraded to Paid | Free plan uses credits (up to $200), cannot bill like a Paid account, ends after 6 months — creating it late saves the window |
| 2026-10-19 | Switched to **fast-track plan** (~25 h, 6 sprints) | Rahul has limited time; Claude writes files, Rahul reviews/runs; one checkpoint per sprint step |
| 2026-10-19 | Scanners (Semgrep, Gitleaks, pip-audit, Checkov) run in GitHub Actions, only Trivy locally | Fewer Windows installs |
| 2026-10-19 | Target deployment: ECS Fargate (0.25 vCPU / 0.5 GB), no load balancer, SG restricted to Rahul's IP, ap-south-1, destroyed after each session | Real container platform + security-group lesson at a few cents/hour of Free plan credits |
| 2026-10-19 | Use Python **3.14** (already installed) locally, in CI and in the Docker base image | One version everywhere avoids "works on my machine"; fall back to 3.13 only if a dependency lacks 3.14 wheels |
| 2026-10-19 | Commit with GitHub **noreply** email, default branch `main` | Repo is public: a personal email in commit metadata is permanently exposed (spam/phishing/OSINT); `main` matches GitHub default |
| 2026-10-19 | Local raw reports are git-ignored; curated evidence goes in `reports/evidence/` | Raw output contains machine details; commit only reviewed evidence |
| 2026-10-19 | `requirements.in` (top-level) + `requirements.txt` (full pinned lock via `pip freeze`) | Reproducible builds; SCA scans exact versions; sub-dependencies are pinned too |
| 2026-10-19 | API binds to 127.0.0.1 locally; SQLite; feature branch `feature/notes-api` | Never expose lab services on the LAN; simplest DB; real branch workflow from first code change |
| 2026-10-19 | Skip installing gh and Checkov locally | gh optional (use github.com); Checkov runs in CI |
| 2026-10-19 | Fallback if AWS signup is not possible: local AWS emulation (LocalStack Hobby plan) + local Kubernetes (kind) | Keeps the lab free; trade-off is no real GitHub-to-AWS OIDC evidence |

## 13. Next exact action
Commit + push Step 1.4 on `feature/notes-api`, reply done.

## 14. Interview concepts learned
- **Step 1.1:** DevSecOps = automated, policy-driven security inside the delivery pipeline; shift-left lowers fix cost. Baseline the build environment first — reproducible tool versions are part of supply-chain hygiene.
- **Step 1.2:** "Installed" is not "working" — verify with a functional test (hello-world). On Windows, VBS/Hyper-V hides the firmware virtualization flag; confirm with `systeminfo`.
- **Step 1.3:** Developer identity is supply-chain identity: enforce 2FA, use noreply commit email in public repos, scan for secrets *before* the first commit, and use `.gitignore` to block secrets/state by default. Always review `git status` and the commit author before pushing — history is permanent.
- **Step 1.4:** Separate top-level deps (`requirements.in`) from a full lock file (`requirements.txt`) for reproducible builds and accurate SCA. Even 2 direct deps pulled 12 transitive ones (incl. `opentelemetry-api`) — most supply-chain risk is transitive. Validate input at the boundary (422) and use parameterized SQL.

## 15. Work log (what was done, why, outcome, next)
| # | Date | What was done | Why | Outcome | Next |
|---|---|---|---|---|---|
| 1 | 2026-10-19 | Claude read `devsecops_prompt.txt` | Understand requirements and rules | Requirements understood | Inspect folder |
| 2 | 2026-10-19 | Claude listed `DevSecOps` folder (read-only) | Avoid redoing existing work | Folder held only the prompt file — fresh start | Create tracker |
| 3 | 2026-10-19 | Created `securecloud-devsecops-lab/docs/DEVSECOPS_PROGRESS.md` | Prompt requires tracker before first lab | Tracker exists, nothing marked complete | Present roadmap |
| 4 | 2026-10-19 | Researched AWS Free plan and LocalStack; recorded zero-cost decisions | Rahul asked for a free lab | Plan: local + public GitHub + AWS Free plan created just before cloud sprint | Estimate time |
| 5 | 2026-10-19 | Created `scripts/env-check.ps1` (read-only check, writes `reports/env-check.txt`) | Make Step 1.1 one command; Claude can read result directly | Script ready, **not yet run** | Rahul runs it |
| 6 | 2026-10-19 | Replaced 12-phase checklist with 6-sprint fast track (~25 h); added decisions (scanners in CI, ECS Fargate target) | Rahul has limited time | Checklist updated | Run env check |
| 7 | 2026-10-19 | Chat only: resource list, flow diagram, project summary | Rahul asked before starting | No file changes | Run env check |
| 8 | 2026-10-19 | Rahul ran `env-check.ps1`; Claude read `reports/env-check.txt` | Know what is installed before installing anything | Almost every tool already present; Semgrep broken locally (CI handles it); gh/Checkov not needed locally; virtualization flag to confirm | Step 1.2 verify tools |
| 9 | 2026-10-19 | Created `scripts/verify-tools.ps1` | Installed ≠ working: prove Docker engine, Git identity, Python venv | Script ready, not yet run | Rahul runs it |
| 10 | 2026-10-19 | Rahul ran `verify-tools.ps1`; Claude read report | Prove tools work | All 5 checks passed; virtualization question resolved; found personal email in Git config (privacy risk for public repo) | Step 1.3A |
| 11 | 2026-10-19 | Rahul confirmed 2FA + noreply email + git config (part A) | Protect account and email privacy | Confirmed by Rahul; Claude will verify email from commit author | Step 1.3B |
| 12 | 2026-10-19 | Claude created `.gitignore`, `.gitattributes`, `README.md`, `reports/.gitkeep` | Prevent secrets/state ever entering Git before the first commit | Files ready, not yet committed | Rahul runs 1.3B |
| 13a | 2026-10-19 | Rahul reported `gitleaks dir . --redact --verbose` → "no leaks found" | Pre-commit secret scan | Verified by Rahul's output: 0 leaks before first commit | — |
| 13 | 2026-10-19 | Rahul ran Gitleaks/init/commit/push; Claude inspected `.git` and `git log` | Verify, don't assume | 7 correct files committed (cd5e968); author email is personal Gmail (F-001); push not completed | Fix email, amend, push |
| 14 | 2026-10-19 | Rahul set noreply email + amended commit; push failed "repository not found" | Fix F-001, publish repo | F-001 fixed (commit 1683a7b, noreply author); push blocked: remote repo missing | Create/confirm GitHub repo, push |
| 15 | 2026-10-19 | Claude re-checked repo after "done" | Verify push | Not pushed: `origin` URL points to GitHub profile page, not the repo | Reset origin URL, push |
| 16 | 2026-10-19 | Rahul fixed remote URL and pushed; Claude verified `origin/main` = `1683a7b` and author = noreply | Publish repo safely | Step 1.3 complete | Commit progress update, then Step 1.4 |
| 17 | 2026-10-19 | Verified 2nd commit `592d115` pushed; Claude wrote app files, `requirements.in`, `smoke-test.ps1` | Start Step 1.4 | Files ready, not yet run | Rahul runs setup + smoke test |
| 18 | 2026-10-19 | Rahul ran setup + smoke test; Claude read report, checked branch, encoding, git status | Prove app works + reproducible deps | 7/7 status codes as expected; 14 pins, ASCII; .venv and smoke.db correctly git-ignored | Commit 1.4, then Step 1.5 |
