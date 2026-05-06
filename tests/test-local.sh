#!/usr/bin/env bash
# Wrapper around `act` for the harness. Only the listed jobs run cleanly
# locally; everything else needs a GitHub-hosted runner. See tests/fixtures/README.md.
#
# The synthetic event payload is required because the harness's `detect` job
# uses dorny/paths-filter, which needs `repository.default_branch` to compute
# a base ref - act does not supply it on the default `push` event.
set -euo pipefail

case "${1:-}" in
  action-lint|checkov) ;;
  *)
    echo "Usage: $0 {action-lint|checkov}" >&2
    echo "validate-pr-label and the rest need a GitHub-hosted runner (PR context, paths-filter, SARIF, ReviewDog, real API keys)." >&2
    echo "See tests/fixtures/README.md." >&2
    exit 64
    ;;
esac

EVENT_FILE="$(mktemp)"
trap 'rm -f "$EVENT_FILE"' EXIT
cat > "$EVENT_FILE" <<'JSON'
{
  "pull_request": {
    "number": 1,
    "head": { "ref": "test-local", "sha": "0000000000000000000000000000000000000000" },
    "base": { "ref": "main", "sha": "0000000000000000000000000000000000000000" }
  },
  "repository": {
    "name": "github-actions-public",
    "full_name": "vechain/github-actions-public",
    "owner": { "login": "vechain" },
    "default_branch": "main"
  }
}
JSON

ART_DIR="$(mktemp -d)"
trap 'rm -rf "$EVENT_FILE" "$ART_DIR"' EXIT

exec act \
  -W .github/workflows/test-workflows.yaml \
  -j "test-${1}" \
  -e "$EVENT_FILE" \
  --artifact-server-path "$ART_DIR" \
  --pull=false
