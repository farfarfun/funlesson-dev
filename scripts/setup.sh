#!/usr/bin/env bash
# funlesson-dev dispatcher: <action> <target>, resolving action -> service -> env
# one level up per bash-service-guide. Missing action/target fall back to a gum
# menu (see references/skeleton.md's choose()); fully specified calls never touch gum.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

readonly -a ACTIONS=(start stop restart run status install publish build)
readonly -a TARGETS=(api web all)

usage() {
  printf 'Usage: %s <start|stop|restart|run|status|install|publish> <api|web|all>\n' "${0##*/}" >&2
  printf '       %s build <api|web|all|apps/<name>>\n' "${0##*/}" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 2
}

contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

choose() {
  command -v gum >/dev/null 2>&1 ||
    die "missing argument and gum is unavailable; run with explicit arguments"
  gum choose "$@"
}

# CLI-bearing apps only: short alias -> submodule path. Only these implement
# the Entrypoint Contract and their own scripts/setup.sh.
resolve_cli_app() {
  case "$1" in
    api) printf '%s\n' "apps/funlesson-api" ;;
    web) printf '%s\n' "apps/funlesson-web" ;;
    *) return 1 ;;
  esac
}

# build's target additionally accepts an explicit "apps/<name>" path (any
# submodule, CLI-bearing or not, e.g. the core library apps/funlesson).
resolve_build_path() {
  case "$1" in
    apps/*) printf '%s\n' "$1" ;;
    *) resolve_cli_app "$1" 2>/dev/null || printf 'apps/%s\n' "$1" ;;
  esac
}

# Every submodule under apps/, CLI-bearing or not (core library + plugins).
all_app_paths() {
  git submodule status | awk '{print $2}'
}

dispatch_service() {
  local action="$1" target="$2" app path
  local -a apps
  if [[ "${target}" == "all" ]]; then
    apps=(api web)
  else
    apps=("${target}")
  fi
  for app in "${apps[@]}"; do
    path="$(resolve_cli_app "${app}")" || die "not a CLI-bearing app: ${app}"
    printf '== %s: %s ==\n' "${app}" "${action}"
    (cd "${path}" && ./scripts/setup.sh "${action}")
  done
}

dispatch_build() {
  local target="$1" path
  local -a paths
  if [[ "${target}" == "all" ]]; then
    mapfile -t paths < <(all_app_paths)
  else
    paths=("$(resolve_build_path "${target}")")
  fi
  for path in "${paths[@]}"; do
    printf '== %s: build ==\n' "${path}"
    git -C "${path}" switch master
    (cd "${path}" && funbuild build)
  done
  funbuild push
}

main() {
  local action="${1:-}"
  local target="${2:-}"

  [[ -n "${action}" ]] || action="$(choose "${ACTIONS[@]}")"
  contains "${action}" "${ACTIONS[@]}" || {
    usage
    die "unknown action: ${action}"
  }

  [[ -n "${target}" ]] || target="$(choose "${TARGETS[@]}")"

  case "${action}" in
    build) dispatch_build "${target}" ;;
    *)
      contains "${target}" "${TARGETS[@]}" || {
        usage
        die "unknown target: ${target}"
      }
      dispatch_service "${action}" "${target}"
      ;;
  esac
}

main "$@"
