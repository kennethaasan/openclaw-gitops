# OpenClaw 2026 Custom Image
# Using the latest stable version
FROM ghcr.io/openclaw/openclaw:latest

# Install dependencies for the Antigravity bridge
USER root

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Install OpenCode AI CLI
RUN bun install -g opencode-ai

# Pre-configure the Antigravity plugin in opencode.json
RUN mkdir -p /root/.config/opencode && \
    echo '{"plugins": ["opencode-antigravity-auth@latest"]}' > /root/.config/opencode/opencode.json

# Ensure the config is accessible
RUN chmod -R 777 /root/.config

# Switch back to the non-root user
# Note: OpenClaw often runs as root in container or needs access to /root
# but we'll stick to the base image's preference if possible.
# Actually, the base image uses /app and 'node' user.
USER node
WORKDIR /app
