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
- **Step:** 1.3 (part B) — Create public GitHub repo, pre-commit secret scan, first commit and push
- **Status:** `[>]` In progress (part A confirmed by Rahul; noreply email to be verified from first commit's author)

## 4. Phase and step checklist (Fast track, ~25 hours, cost ₹0)

### Sprint 1 — Setup + application (~4 h)
- [x] 1.1 Read-only environment check (`scripts/env-check.ps1`) — verified 2026-10-19
- [x] 1.2 Verify installed tools work: Docker engine + hello-world, Git identity, Python venv — verified 2026-10-19
- [>] 1.3 GitHub account 2FA + noreply commit email (A); public repo `securecloud-devsecops-lab` + first commit (B)
- [ ] 1.4 FastAPI "SecureCloud Notes API" + virtual env + pinned dependencies
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

## 6. Pending and blocked steps
- Pending: Step 1.3B — Rahul creates empty GitHub repo and runs init/scan/commit/push commands.
- Blocked: none.

## 7. Commands executed and verified results
| Date | Command | Verified result |
|---|---|---|
| 2026-10-19 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\env-check.ps1` | Win 11 Pro 64-bit build 26200; PowerShell 5.1; 15.6 GB RAM; 229 GB free; i5-10400H; CurrentUser policy RemoteSigned. FOUND: winget 1.29, Git 2.55, Python 3.14.3, pip 26.0.1, Docker 29.0.1, WSL 3.0.3 (kali-linux v2, docker-desktop v2), VS Code 1.142, AWS CLI 2.32.5, Terraform 1.15.8, Trivy 0.74.0, Gitleaks 8.30.1. Semgrep present but crashes (traceback). MISSING: gh, checkov. "Virtualization in firmware: False" reported. |
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

## 9. Security findings and remediation status
_None yet._

## 10. Cloud resources and cleanup status
_No cloud resources created._

## 11. Errors encountered and fixes
| Date | Error | Cause | Resolution |
|---|---|---|---|
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
| 2026-10-19 | Skip installing gh and Checkov locally | gh optional (use github.com); Checkov runs in CI |
| 2026-10-19 | Fallback if AWS signup is not possible: local AWS emulation (LocalStack Hobby plan) + local Kubernetes (kind) | Keeps the lab free; trade-off is no real GitHub-to-AWS OIDC evidence |

## 13. Next exact action
Create empty public repo `securecloud-devsecops-lab` on GitHub, run Step 1.3B commands, reply done.

## 14. Interview concepts learned
- **Step 1.1:** DevSecOps = automated, policy-driven security inside the delivery pipeline; shift-left lowers fix cost. Baseline the build environment first — reproducible tool versions are part of supply-chain hygiene.
- **Step 1.2:** "Installed" is not "working" — verify with a functional test (hello-world). On Windows, VBS/Hyper-V hides the firmware virtualization flag; confirm with `systeminfo`.

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
