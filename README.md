# OpenClaw GitOps (Antigravity Edition)

A professional-grade, zero-cost DevOps stack for running the **OpenClaw AI Agent** on Google Cloud Platform using your **Google AI Subscription (Gemini 3)**.

## Architecture
- **Infrastructure:** GCP Spot VM (`e2-medium`) in Stockholm (`europe-north2`).
- **Storage:** 10GB Persistent Disk for Signal sessions and Agent memory.
- **Brain:** Google Gemini 3 Pro/Flash via the `opencode-antigravity-auth` bridge.
- **Interface:** Signal (as a linked device).
- **CI/CD:** GitHub Actions + Terraform Cloud.

## Prerequisites
1. **GCP Project:** A Google Cloud project with billing enabled (using your $10 credit).
2. **Terraform Cloud:** A free account at [app.terraform.io](https://app.terraform.io).
3. **OpenCode CLI:** Installed locally (`bun install -g opencode-ai`).

## Deployment Steps

### 1. Configure Terraform Cloud
1. Sign up/Login to [app.terraform.io](https://app.terraform.io).
2. Use/Create the organization **`aasan_dev`**.
3. Create a new Workspace named **`openclaw-gitops`** using the **API-driven workflow**.
4. Add the following **Workspace Variables**:
   - `GOOGLE_CREDENTIALS`: Paste your GCP Service Account JSON key (ensure all newlines are removed, it should be a single string).
   - `project_id`: Your Google Cloud Project ID.

### 2. Configure GitHub Secrets
Add the following to your GitHub Repo Secrets:
- `TF_API_TOKEN`: Your Terraform Cloud API token.
- `GCP_PROJECT_ID`: Your Google Cloud Project ID.
- `GCP_CREDENTIALS`: Your GCP Service Account JSON key.
- `SIGNAL_PHONE_NUMBER`: Your phone number in E.164 format.

### 2. Version Management
The version of OpenClaw is pinned in `docker/Dockerfile`. To update:
1. Change the version tag in `docker/Dockerfile` (e.g., `v2026.x.y`).
2. Push to `main`.
The CI/CD pipeline will build a new custom image, push it to your private Google Artifact Registry, and update your server.

### 3. Authenticate Gemini 3 (Antigravity)
Since the server is headless, you must authenticate locally and sync the session:

1. **On your laptop:**
   ```bash
   opencode auth login
   # Select "Antigravity" and complete the browser login.
   ```
2. **Transfer the session to the VM:**
   The session is stored in `~/.config/opencode/`. You need to copy this folder to the VM's persistent mount at `/mnt/openclaw/config/opencode/`.
   ```bash
   # Use the provisioned domain: openclaw.aasan.dev
   scp -r ~/.config/opencode root@openclaw.aasan.dev:/mnt/openclaw/config/
   ```

### 4. Link your Signal account
1. SSH into the VM: `ssh root@openclaw.aasan.dev`
2. Run the linking command:
   ```bash
   docker compose exec signal-sidecar signal-cli-rest-api link -n "OpenClaw-Agent"
   ```
3. Scan the resulting QR code with your Signal app on iPhone (**Settings > Linked Devices**).

## Quality & Security
- **IaC Quality Gates:** Every pull request and push to main is validated via `terraform fmt`, `terraform validate`, and **TFLint** (with Google-specific rules).
- **Code Linting:** Node.js and configuration files are linted and formatted via **Biome**.
- **Immutable Artifacts:** Deployments use specific Docker image tags (Git SHA) pushed to a private **Google Artifact Registry**.
- **Least Privilege:** The system uses a dedicated GCP Service Account with narrowly defined roles for deployment and runtime.

## Budget Management
This setup is designed to stay under **$10/month**:
- **Spot VM:** ~$6.00
- **Static IP:** ~$3.60
- **Storage:** ~$0.40
- **Total:** ~$10.00 (Fully covered by Google's $10 monthly credit).

## Credits
- **OpenClaw:** by Peter Steinberger.
- **Antigravity Auth:** by NoeFabris.
- **Infrastructure:** Designed by Antigravity (Google DeepMind).
