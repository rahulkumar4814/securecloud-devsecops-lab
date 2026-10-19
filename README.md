# SecureCloud DevSecOps Lab

A hands-on, enterprise-style DevSecOps lab: a Python FastAPI service delivered to AWS through a GitHub Actions pipeline with security gates at every stage.

| Stage | Control | Tool |
|---|---|---|
| Code | SAST | Semgrep |
| Dependencies | SCA | pip-audit |
| Repository | Secret detection | Gitleaks |
| Container | Image scanning, hardening | Trivy, Docker |
| Infrastructure | IaC scanning | Terraform, Checkov |
| Cloud identity | Keyless deploy | GitHub Actions OIDC → AWS IAM |
| Runtime | Logging & audit | CloudWatch, CloudTrail |

> Status: **in progress** — see [`docs/DEVSECOPS_PROGRESS.md`](docs/DEVSECOPS_PROGRESS.md) for verified progress.

All intentionally vulnerable examples run only in an isolated local lab. No real credentials are used.
