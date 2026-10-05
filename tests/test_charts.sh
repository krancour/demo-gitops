#!/usr/bin/env bash
# Renders each chart and asserts the properties the book relies on.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
check() { if ! grep -q -- "$2" <<<"$1"; then echo "FAIL: $3"; fail=1; fi; }
D=sha256:0000000000000000000000000000000000000000000000000000000000000001

out=$(helm template demo-dev charts/demo-app --set image.digest=$D)
check "$out" "image: \"ghcr.io/kargobook/demo-app@$D\"" "demo-app pins by digest"
check "$out" "name: demo-app$" "demo-app keeps its name under release demo-dev"
check "$out" "containerPort: 80$" "demo-app listens on 80"

out=$(helm template demo-dev charts/demo-app)
check "$out" 'image: "ghcr.io/kargobook/demo-app:1.0.0"' "empty digest falls back to tag 1.0.0"

out=$(helm template auth-dev charts/auth-service --set image.digest=$D)
check "$out" "image: \"ghcr.io/kargobook/auth-service@$D\"" "auth pins by digest"
check "$out" "name: auth-service$" "auth keeps its name"
check "$out" "containerPort: 8081$" "auth listens on 8081"
check "$out" "readOnlyRootFilesystem: true" "auth keeps its securityContext"

out=$(helm template payments-dev charts/payments-api --set image.digest=$D)
check "$out" "image: \"ghcr.io/kargobook/payments-api@$D\"" "payments pins by digest"
check "$out" "containerPort: 8080$" "payments listens on 8080"

for c in charts/*/; do helm lint "$c" >/dev/null || { echo "FAIL: helm lint $c"; fail=1; }; done
exit $fail
