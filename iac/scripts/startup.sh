#!/bin/bash
set -e

# 1. Mount Persistent Disk
DISK_PATH="/dev/disk/by-id/google-openclaw_data"
MOUNT_POINT="/mnt/openclaw"

if [ ! -d "$MOUNT_POINT" ]; then
  mkdir -p $MOUNT_POINT
fi

# Format disk if it's new
if ! blkid "$DISK_PATH"; then
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard "$DISK_PATH"
fi

# Mount it
if ! mount | grep -q "$MOUNT_POINT"; then
  mount -o discard,defaults "$DISK_PATH" "$MOUNT_POINT"
fi

# 2. Install Docker
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

# 3. Authenticate Docker to Google Artifact Registry
gcloud auth configure-docker ${region}-docker.pkg.dev -q

# 4. Create Docker Compose & Config in the persistent mount
cd $MOUNT_POINT

# Link config to persistent storage
mkdir -p $MOUNT_POINT/config/opencode
mkdir -p /root/.config
ln -sf $MOUNT_POINT/config/opencode /root/.config/opencode

IMAGE_URI="${region}-docker.pkg.dev/${project_id}/openclaw-repo/openclaw:${image_tag}"

cat <<EOF > config.yaml
llm:
  provider: opencode
  model: opencode/gemini-3-pro
  flashModel: opencode/gemini-3-flash
  
providers:
  opencode:
    enabled: true
    settings:
      antigravity:
        enabled: true
        account_strategy: "hybrid"

plugins:
  - "opencode-antigravity-auth"

channels:
  signal:
    enabled: true
    account: ${signal_phone_number}
    httpUrl: http://signal-sidecar:8080
    autoStart: false
EOF

cat <<EOF > docker-compose.yml
services:
  openclaw:
    image: $IMAGE_URI
    restart: always
    environment:
      - OPENCODE_CONFIG_DIR=/root/.config/opencode
    volumes:
      - ./config.yaml:/root/.openclaw/config.yaml
      - .:/root/.openclaw
      - /root/.config/opencode:/root/.config/opencode
    depends_on:
      - signal-sidecar

  signal-sidecar:
    image: bbernhard/signal-cli-rest-api:latest
    restart: always
    environment:
      - MODE=json-rpc
    volumes:
      - ./signal-data:/var/lib/signal-api
EOF

# 5. Run it
docker compose pull
docker compose up -d
