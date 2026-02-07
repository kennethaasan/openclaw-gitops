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
    echo '{\n\
  "plugin": ["opencode-antigravity-auth@latest"],\n\
  "provider": {\n\
    "google": {\n\
      "models": {\n\
        "antigravity-gemini-3-pro": {\n\
          "name": "Gemini 3 Pro (Antigravity)",\n\
          "limit": { "context": 1048576, "output": 65535 },\n\
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },\n\
          "variants": {\n\
            "low": { "thinkingLevel": "low" },\n\
            "high": { "thinkingLevel": "high" }\n\
          }\n\
        },\n\
        "antigravity-gemini-3-flash": {\n\
          "name": "Gemini 3 Flash (Antigravity)",\n\
          "limit": { "context": 1048576, "output": 65536 },\n\
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },\n\
          "variants": {\n\
            "minimal": { "thinkingLevel": "minimal" },\n\
            "low": { "thinkingLevel": "low" },\n\
            "medium": { "thinkingLevel": "medium" },\n\
            "high": { "thinkingLevel": "high" }\n\
          }\n\
        },\n\
        "antigravity-claude-sonnet-4-5-thinking": {\n\
          "name": "Claude Sonnet 4.5 Thinking (Antigravity)",\n\
          "limit": { "context": 200000, "output": 64000 },\n\
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },\n\
          "variants": {\n\
            "low": { "thinkingConfig": { "thinkingBudget": 8192 } },\n\
            "max": { "thinkingConfig": { "thinkingBudget": 32768 } }\n\
          }\n\
        },\n\
        "antigravity-claude-opus-4-6-thinking": {\n\
          "name": "Claude Opus 4.6 Thinking (Antigravity)",\n\
          "limit": { "context": 200000, "output": 64000 },\n\
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },\n\
          "variants": {\n\
            "low": { "thinkingConfig": { "thinkingBudget": 8192 } },\n\
            "medium": { "thinkingConfig": { "thinkingBudget": 16384 } },\n\
            "max": { "thinkingConfig": { "thinkingBudget": 32768 } }\n\
          }\n\
        }\n\
      }\n\
    }\n\
  }\n\
}' > /home/node/.config/opencode/opencode.json && \
    chown -R node:node /home/node/.config

# Switch back to the non-root user
USER node
WORKDIR /app
