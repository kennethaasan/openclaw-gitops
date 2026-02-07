AGENT QUICK REFERENCE

1. Setup: This project runs on GCP Spot VMs using Terraform Cloud for CI/CD. The AI engine is OpenClaw, bridged via opencode-antigravity-auth to access Gemini 3 Pro/Flash.
2. Deployment: Push to main triggers GitHub Actions (Docker Build & Push) -> Terraform Cloud -> GCP Stockholm (europe-north2).
3. Secrets: Never commit secrets. Use GitHub Secrets for TF_API_TOKEN, GCP_PROJECT_ID, GCP_CREDENTIALS, and SIGNAL_PHONE_NUMBER.
4. Security Mandate: CRITICAL: Secrets, semi-secrets, raw IPs, and internal project IDs must never be committed to this repository.
5. Persistence: Data is stored on a persistent GCP disk mounted at /mnt/openclaw. This includes Signal sessions and Agent memory.
6. Signal: Operates as a "Linked Device". Pairing requires running `signal-cli-rest-api link` on the server and scanning the QR code with an iPhone.
7. Brain: Uses Gemini 3 Pro (reasoning) and Gemini 3 Flash (tasks) via the Antigravity provider.
8. Infrastructure: IaC is located in /iac. Startup logic is in /iac/scripts/startup.sh.
9. Style: 2-space indent. Linting and formatting via Biome.
10. Naming: Files kebab-case. Env vars UPPER_SNAKE_CASE.
11. Errors: Never swallow. Log via appropriate channels.
12. Versioning: OpenClaw version is pinned in `docker/Dockerfile`. Deployment uses a private Google Artifact Registry (`openclaw-repo`).
13. Documentation: Always update `README.md` when there is an architecture or setup change.

## Active Technologies
- OpenClaw (Agentic Runtime)
- opencode-antigravity-auth (Gemini 3 Bridge)
- Terraform (IaC)
- Google Cloud Platform (Spot VMs, Stockholm region)
- Signal (Communication Channel)
- Docker & Docker Compose (Containerization)

## Recent Changes
- Initial project scaffold with Stockholm-based GCP Spot architecture.
- Integrated Signal sidecar for instant messaging.
- Configured Gemini 3 Pro/Flash via Antigravity auth.
- Configured Cloudflare DNS for openclaw.aasan.dev.
