#!/usr/bin/env bash
# configure.sh: Point the example files at your fork of this repository.
#
# Usage:
#   GITHUB_ORG=my-org bash configure.sh [--no-push]
#
# Rewrites the canonical kargobook org in every YAML file in place, then
# commits the result and pushes it to your fork so the remote is ready for
# Kargo to clone. The commit and push happen only when the working tree was
# clean before the run. Pass --no-push to rewrite and commit without pushing.

set -euo pipefail

GITHUB_ORG="${GITHUB_ORG:-}"
NO_PUSH=false
for arg in "$@"; do
  case "$arg" in
    --no-push) NO_PUSH=true ;;
    *) echo "ERROR: unknown argument: $arg"; exit 1 ;;
  esac
done

if [[ -z "$GITHUB_ORG" ]]; then
  echo "ERROR: GITHUB_ORG must be set to the GitHub user or org that owns your fork."
  echo ""
  echo "  GITHUB_ORG=your-github-org bash configure.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
  CLEAN=false
else
  CLEAN=true
fi

echo "Configuring example files..."
echo "  GITHUB_ORG: ${GITHUB_ORG}"
echo ""

# Only the GitHub git repo URLs change; the image stays at ghcr.io/kargobook/demo-app
# so readers don't need to build or push anything.
find "$SCRIPT_DIR" -name "*.yaml" -not -path "*/.git/*" | sort | while read -r file; do
  sed -i.bak \
    -e "s|github\.com/kargobook/demo-gitops|github.com/${GITHUB_ORG}/demo-gitops|g" \
    "$file"
  rm -f "${file}.bak"
  echo "  configured: ${file#"$SCRIPT_DIR/"}"
done

echo ""
if [[ "$CLEAN" != true ]]; then
  echo "The working tree had uncommitted changes before this run, so nothing was"
  echo "committed or pushed. Review with 'git status', then commit and push yourself."
elif [[ -z "$(git status --porcelain)" ]]; then
  echo "Nothing changed (the files already point at ${GITHUB_ORG})."
else
  git add -A
  git commit -q -m "Point at ${GITHUB_ORG}/demo-gitops"
  echo "Committed: $(git log -1 --format='%h %s')"
  if [[ "$NO_PUSH" == true ]]; then
    echo "Skipped the push (--no-push). Push when ready: git push"
  else
    git push
    echo "Pushed to $(git remote get-url origin)"
  fi
fi

echo ""
echo "Done. Next steps (from the demo-gitops repo root):"
echo "  1. Create the Argo CD Applications for all three environments:"
echo "     argocd appset create setup/01-applicationset.yaml"
echo "  2. Create the Kargo Project and its Git credentials:"
echo "     kargo create project demo"
echo "     kargo create repo-credentials --project demo demo-git-creds --git \\"
echo "       --repo-url https://github.com/${GITHUB_ORG}/demo-gitops.git \\"
echo "       --username <your-github-username> --password \"\$(gh auth token)\""
echo "  3. Create the Warehouse and the Stages:"
echo "     kargo apply -f setup/03-warehouse.yaml"
echo "     kargo apply -f setup/04-stage-dev.yaml"
echo "     kargo apply -f setup/05-stage-pre-prod.yaml"
echo "     kargo apply -f setup/06-stage-prod.yaml"
echo "  4. After running the manual promotions, enable auto-promotion for dev:"
echo "     kargo apply -f setup/07-projectconfig.yaml"
