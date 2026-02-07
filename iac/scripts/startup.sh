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

# 2. Install Dependencies (Bun, Node, Docker)
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

if ! command -v bun &> /dev/null; then
  curl -fsSL https://bun.sh/install | bash
  export PATH="/root/.bun/bin:$PATH"
fi

# 3. Install OpenCode & Antigravity Plugin
export PATH="/root/.bun/bin:$PATH"
if ! command -v opencode &> /dev/null; then
  bun install -g opencode-ai
fi

# Link config to persistent storage
mkdir -p $MOUNT_POINT/config/opencode
mkdir -p /root/.config
ln -sf $MOUNT_POINT/config/opencode /root/.config/opencode

# Add the Antigravity plugin
opencode plugin add opencode-antigravity-auth@latest || true

# 4. Create Docker Compose & Config in the persistent mount
cd $MOUNT_POINT

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
    image: openclaw/openclaw:${image_tag}
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

# 4. Run it
docker compose up -d
