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
RUN mkdir -p /home/node/.config/opencode && \
    echo '{"plugins": ["opencode-antigravity-auth@latest"]}' > /home/node/.config/opencode/opencode.json && \
    chown -R node:node /home/node/.config

# Switch back to the non-root user
USER node
WORKDIR /app
