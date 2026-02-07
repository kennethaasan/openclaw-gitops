# OpenClaw 2026 Custom Image
# Using the latest stable version
FROM ghcr.io/openclaw/openclaw:latest

# Install dependencies for the Antigravity bridge
USER root

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Install OpenCode AI CLI and Antigravity plugin
RUN bun install -g opencode-ai
RUN opencode plugin add opencode-antigravity-auth@latest

# Switch back to the non-root user
USER node
WORKDIR /app
