#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SERPANTINUM_DEFAULT="/home/devtrung/orca/workspaces/serpantinum/fix-wallpaper-choosing"
if [ ! -d "$LOCAL_SERPANTINUM_DEFAULT" ] && [ -d "/home/devtrung/serpantinum" ]; then
  LOCAL_SERPANTINUM_DEFAULT="/home/devtrung/serpantinum"
fi
LOCAL_SERPANTINUM="${SERPANTINUM_PATH:-$LOCAL_SERPANTINUM_DEFAULT}"

ACTION="switch"
USE_LOCAL=false
EXTRA_ARGS=()

show_help() {
  cat << 'EOF'
Usage: rebuild.sh [ACTION] [OPTIONS] [-- ADDITIONAL_NIXOS_REBUILD_ARGS]

Actions:
  switch        Build and activate new configuration (default)
  test          Build and activate, but do not add to bootloader
  boot          Build and add to bootloader, but do not activate
  build         Build system without activating

Options:
  -l, --local   Temporarily override serpantinum input with local development repo:
                (/home/devtrung/orca/workspaces/serpantinum/fix-wallpaper-choosing)
  -p, --path    Specify custom path to serpantinum repo
  -h, --help    Show this help message

Examples:
  ./rebuild.sh                      # Normal rebuild from upstream
  ./rebuild.sh --local              # Rebuild with local serpantinum
  ./rebuild.sh test --local         # Test local serpantinum without touching bootloader
  rebuild-local                     # Shell alias for ./rebuild.sh --local
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -l|--local)
      USE_LOCAL=true
      shift
      ;;
    -p|--path)
      LOCAL_SERPANTINUM="$2"
      USE_LOCAL=true
      shift 2
      ;;
    switch|test|boot|build|dry-build|dry-activate)
      ACTION="$1"
      shift
      ;;
    --)
      shift
      EXTRA_ARGS+=("$@")
      break
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

CMD=(sudo nixos-rebuild "$ACTION" --flake "$SCRIPT_DIR#nixos" --impure)

if [ "$USE_LOCAL" = true ]; then
  echo "==> Using local serpantinum repository: $LOCAL_SERPANTINUM"
  if [ -d "$LOCAL_SERPANTINUM/.git" ]; then
    # Stage untracked files with intent-to-add so Nix can copy them
    git -C "$LOCAL_SERPANTINUM" add -N . 2>/dev/null || true
  fi
  CMD+=(--override-input serpantinum "$LOCAL_SERPANTINUM")
fi

if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

echo "==> Running: ${CMD[*]}"
exec "${CMD[@]}"
