#!/bin/sh

# env.sh — emit secret-backed env vars to the rediscloud provider as JSON.
# Mirrors the pattern used by the rest of the gcp-redis-cloud-* cells.

cat <<EOF
{
  "rediscloud_payment_4digits": "$REDIS_CLOUD_PAYMENT_4DIGITS",
  "rediscloud_default_password": "$REDIS_CLOUD_DEFAULT_PASSWORD"
}
EOF
