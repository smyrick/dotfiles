# Guidance for humans and coding agents

## This repository is public

Treat everything committed here as **world-readable**. Do not add:

- API keys, tokens, passwords, or session cookies
- Private keys (SSH, TLS, signing), certificates, or keystores
- Connection strings with embedded credentials
- Internal-only hostnames, VPN endpoints, or unreleased product details that should stay private
- Personal data beyond what the repo owner intentionally publishes

Use **`$HOME`** and placeholders in documentation instead of real machine paths or usernames unless the owner explicitly wants them published.

## Safe patterns for local-only secrets

Keep machine-specific or sensitive configuration **outside** git (for example `~/.zshrc.local`, `~/.env`, or a private repo) and source it from your local shell config—not from committed files in this repo.

## Before committing

Scan changes for accidental paste of environment exports (`export …_TOKEN=`, `AWS_SECRET_`, etc.) and remove them.
