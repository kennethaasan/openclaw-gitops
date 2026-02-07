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

### 1. Configure GitHub Secrets
Add the following to your GitHub Repo Secrets:
- `TF_API_TOKEN`: Your Terraform Cloud API token.
- `GCP_PROJECT_ID`: Your Google Cloud Project ID.
- `SIGNAL_PHONE_NUMBER`: Your phone number in E.164 format (e.g., `+4712345678`).

### 2. Push to Main
Push this repository to GitHub. The CI/CD pipeline will automatically provision your server in Stockholm.

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
   # Example using SCP (replace <VM_IP> with your server's IP)
   scp -r ~/.config/opencode root@<VM_IP>:/mnt/openclaw/config/
   ```

### 4. Link your Signal account
1. SSH into the VM.
2. Run the linking command:
   ```bash
   docker compose exec signal-sidecar signal-cli-rest-api link -n "OpenClaw-Agent"
   ```
3. Scan the resulting QR code with your Signal app on iPhone (**Settings > Linked Devices**).

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
