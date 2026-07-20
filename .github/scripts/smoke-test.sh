#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:3334}

echo "==> Waiting for Ghostfolio API to be reachable at ${BASE_URL}"
kubectl port-forward svc/ghostfolio 3334:80 >/tmp/pf.log 2>&1 &
pf_pid=$!
trap 'kill $pf_pid 2>/dev/null || true' EXIT
for _ in $(seq 1 30); do
  curl -Ssf "${BASE_URL}/api/v1/health" >/dev/null 2>&1 && break
  sleep 1
done

echo "==> Test: GET /api/v1/info returns server info"
curl -Ssf "${BASE_URL}/api/v1/info" | tee info.json | jq -e '.'

echo "==> Test: POST /api/v1/user creates the first user (becomes ADMIN)"
signup_response=$(curl -Ssf -X POST "${BASE_URL}/api/v1/user")
echo "${signup_response}" | tee signup.json | jq -e '.authToken and .accessToken and .role'

auth_token=$(jq -r .authToken signup.json)
access_token=$(jq -r .accessToken signup.json)
role=$(jq -r .role signup.json)

echo "==> Test: signup returned role=ADMIN"
test "${role}" = "ADMIN"

echo "==> Test: signup returned a non-empty JWT authToken"
test -n "${auth_token}"

echo "==> Test: signup returned a non-empty accessToken"
test -n "${access_token}"

echo "==> Test: GET /api/v1/user with JWT auth succeeds"
curl -Ssf -H "Authorization: Bearer ${auth_token}" \
  "${BASE_URL}/api/v1/user" | tee user.json | jq -e '.id'

echo "==> Test: PUT /api/v1/user/setting persists baseCurrency=EUR"
curl -Ssf -X PUT \
  -H "Authorization: Bearer ${auth_token}" \
  -H "Content-Type: application/json" \
  -d '{"baseCurrency":"EUR"}' \
  "${BASE_URL}/api/v1/user/setting" >/dev/null
curl -Ssf -H "Authorization: Bearer ${auth_token}" \
  "${BASE_URL}/api/v1/user" | tee user.json | jq -e '.settings.baseCurrency == "EUR"'

echo "==> Test: POST /api/v1/platform creates a new platform"
platform_name="ci-test-platform-$$"
curl -Ssf -X POST \
  -H "Authorization: Bearer ${auth_token}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${platform_name}\",\"url\":\"https://example.com\"}" \
  "${BASE_URL}/api/v1/platform" | tee platform.json | jq -e '.id'

echo "==> Test: GET /api/v1/platform lists the new platform"
platform_id=$(jq -r .id platform.json)
curl -Ssf -H "Authorization: Bearer ${auth_token}" \
  "${BASE_URL}/api/v1/platform" | jq -e --arg n "${platform_name}" 'map(select(.name == $n)) | length == 1'

echo "==> Test: DELETE /api/v1/platform removes the new platform"
curl -Ssf -X DELETE -H "Authorization: Bearer ${auth_token}" \
  "${BASE_URL}/api/v1/platform/${platform_id}"

echo "==> Test: POST /api/v1/account creates a new account"
account_name="ci-test-account-$$"
curl -Ssf -X POST \
  -H "Authorization: Bearer ${auth_token}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${account_name}\",\"currency\":\"EUR\",\"balance\":0,\"platformId\":null}" \
  "${BASE_URL}/api/v1/account" | tee account.json | jq -e '.id'

echo "==> Test: GET /api/v1/account lists the new account"
account_id=$(jq -r .id account.json)
curl -Ssf -H "Authorization: Bearer ${auth_token}" \
  "${BASE_URL}/api/v1/account" | jq -e --arg n "${account_name}" '.accounts | map(select(.name == $n)) | length == 1'

echo "==> Test: DELETE /api/v1/account removes the new account"
curl -Ssf -X DELETE -H "Authorization: Bearer ${auth_token}" \
  "${BASE_URL}/api/v1/account/${account_id}"

echo "==> Test: GET /api/v1/health reports OK"
curl -Ssf "${BASE_URL}/api/v1/health" | jq -e '.status == "OK"'

echo "==> All smoke tests passed"
