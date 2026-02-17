#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HTTP_PORT="${PORT:-3000}"
HTTPS_PORT="${HTTPS_PORT:-3443}"
USE_HTTPS="${USE_HTTPS:-0}"
HOST="${HOST:-localhost}"

if [ "$USE_HTTPS" = "1" ]; then
  BASE_URL="https://${HOST}:${HTTPS_PORT}"
  CURL_OPTS="-kfsS"
else
  BASE_URL="http://${HOST}:${HTTP_PORT}"
  CURL_OPTS="-fsS"
fi

echo "[1/4] Health check: ${BASE_URL}/api/health"
# shellcheck disable=SC2086
curl ${CURL_OPTS} "${BASE_URL}/api/health" >/dev/null

echo "[2/4] Readiness check: ${BASE_URL}/api/ready"
# shellcheck disable=SC2086
curl ${CURL_OPTS} "${BASE_URL}/api/ready" >/dev/null

echo "[3/4] Auth endpoint reachability: ${BASE_URL}/api/auth/login"
# shellcheck disable=SC2086
HTTP_CODE="$(curl ${CURL_OPTS} -o /tmp/wt-auth-smoke.out -w "%{http_code}" -H "Content-Type: application/json" -d '{}' "${BASE_URL}/api/auth/login" || true)"
if [ "$HTTP_CODE" != "400" ] && [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "401" ] && [ "$HTTP_CODE" != "429" ]; then
  echo "Unexpected auth response code: ${HTTP_CODE}"
  cat /tmp/wt-auth-smoke.out || true
  exit 1
fi

echo "[4/4] Static app reachability: ${BASE_URL}/"
# shellcheck disable=SC2086
curl ${CURL_OPTS} "${BASE_URL}/" >/dev/null

echo "Smoke check passed: ${BASE_URL}"
