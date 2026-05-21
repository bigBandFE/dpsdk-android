#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/release_aar.sh <version> <aar_path> [repo]

Examples:
  ./scripts/release_aar.sh 1.0.0 /path/to/dpsdk-1.0.0.aar
  ./scripts/release_aar.sh 2.0.0 /path/to/output.aar bigBandFE/dpsdk-android

Environment overrides:
  GITHUB_REPO     GitHub repo slug, default: bigBandFE/dpsdk-android
  AAR_BASE_NAME   AAR asset base name, default: dpsdk
EOF
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 1
fi

require_command gh

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

raw_version="$1"
input_aar="$2"
repo="${3:-${GITHUB_REPO:-bigBandFE/dpsdk-android}}"
aar_base_name="${AAR_BASE_NAME:-dpsdk}"

if [[ ! -f "$input_aar" ]]; then
  echo "AAR file not found: $input_aar" >&2
  exit 1
fi

version="${raw_version#v}"
tag="${version}"
asset_name="${aar_base_name}-${version}.aar"

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

upload_aar="${tmp_dir}/${asset_name}"
cp "$input_aar" "$upload_aar"

echo "Repo       : $repo"
echo "Tag        : $tag"
echo "Asset      : $asset_name"
echo "Source AAR : $input_aar"

if gh release view "$tag" --repo "$repo" >/dev/null 2>&1; then
  echo "Release already exists, uploading asset with overwrite"
  gh release upload "$tag" "$upload_aar" --clobber --repo "$repo"
else
  echo "Creating release and uploading asset"
  gh release create "$tag" "$upload_aar" \
    --repo "$repo" \
    --title "$tag" \
    --notes "Release ${tag}"
fi

echo "Done. Release asset URL pattern:"
echo "https://github.com/${repo}/releases/download/${tag}/${asset_name}"
