#!/bin/bash
set -e

MOUNT_POINT="/mnt/openclaw"
DATA_DIR="$MOUNT_POINT/signal-data"
CONTAINER_IMAGE="bbernhard/signal-cli-rest-api:latest"

# Ensure we are on the server (check for mount point)
if [ ! -d "$MOUNT_POINT" ]; then
  echo "Error: This script must be run on the OpenClaw server."
  echo "Mount point $MOUNT_POINT not found."
  exit 1
fi

echo "Ensuring correct volume mount path in docker-compose.yml..."
if grep -q "/var/lib/signal-api" docker-compose.yml; then
  sed -i 's|/var/lib/signal-api|/home/.local/share/signal-cli|g' docker-compose.yml
  echo "Fixed volume mount path."
fi

echo "Stopping Signal sidecar service..."
docker compose stop signal-sidecar

echo "Starting linking process..."
echo "Please scan the QR code with your Signal app (Settings > Linked Devices > +)"
echo "Generating QR code..."
echo "NOTE: If the QR code below is distorted, copy the 'tsdevice:/...' URI and generate a QR code online."

# Run signal-cli link in a temporary container
# We use --entrypoint to bypass the REST API wrapper and run signal-cli directly
# We mount the data directory to the correct location for signal-cli
# signal-cli link outputs the URI and waits for scan
docker run --rm -it \
  -v "$DATA_DIR:/home/.local/share/signal-cli" \
  --entrypoint signal-cli \
  $CONTAINER_IMAGE \
  link -n openclaw-agent

echo "Linking complete!"
echo "Restarting Signal sidecar service..."
docker compose up -d signal-sidecar

echo "Signal sidecar is now running and linked."
