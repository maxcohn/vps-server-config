#!/usr/bin/env bash
# Idempotency notes:
#   - apt-get install -y is idempotent; already-installed packages are skipped
#   - cp overwrites destination files, so re-running always syncs latest config
#   - certbot --expand is idempotent; it only reissues if the domain list changes
#     or the cert is near expiry

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install dependencies
apt-get update -y
apt-get install -y nginx certbot python3-certbot-nginx

# Deploy nginx configs
cp "$REPO_DIR/etc/nginx/sites-available/website.conf" /etc/nginx/sites-available/website.conf
cp "$REPO_DIR/etc/nginx/sites-available/ip.conf"      /etc/nginx/sites-available/ip.conf

# Enable sites if not already symlinked
ln -sf /etc/nginx/sites-available/website.conf /etc/nginx/sites-enabled/website.conf
ln -sf /etc/nginx/sites-available/ip.conf      /etc/nginx/sites-enabled/ip.conf

nginx -t
systemctl reload nginx

# Issue / expand TLS certificate
certbot --nginx --expand \
  -d maxcohn.org \
  -d www.maxcohn.org \
  -d max-cohn.com \
  -d www.max-cohn.com \
  -d ip.maxcohn.org \
  -d ip.max-cohn.com
