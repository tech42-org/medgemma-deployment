#!/usr/bin/env bash
set -euo pipefail

width=700
prefix="resized-"

usage() {
  cat <<'USAGE'
Usage:
  scripts/resize-images.sh [--width 700] [--prefix resized-] IMAGE...
  scripts/resize-images.sh [--width 700] [--prefix resized-] --all [DIRECTORY]

Examples:
  scripts/resize-images.sh benchmark/imgs/g7e/*.png
  scripts/resize-images.sh --width 700 --all benchmark/imgs/g7e

Environment:
  Requires macOS sips.

Note:
  Each run removes old output images matching the configured prefix first.
USAGE
}

images=()
resize_all=false
directory="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--width)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 1
      fi
      width="$2"
      shift 2
      ;;
    --prefix)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        exit 1
      fi
      prefix="$2"
      shift 2
      ;;
    --all)
      resize_all=true
      shift
      if [[ $# -gt 0 && "$1" != -* ]]; then
        directory="$1"
        shift
      fi
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      images+=("$1")
      shift
      ;;
  esac
done

if ! command -v sips >/dev/null 2>&1; then
  echo "sips is required, but it was not found on PATH." >&2
  exit 1
fi

if ! [[ "$width" =~ ^[0-9]+$ ]] || [[ "$width" -lt 1 ]]; then
  echo "Width must be a positive integer." >&2
  exit 1
fi

if [[ "$resize_all" == true ]]; then
  if [[ ${#images[@]} -gt 0 ]]; then
    echo "Use either IMAGE... or --all, not both." >&2
    exit 1
  fi
  if [[ ! -d "$directory" ]]; then
    echo "Directory not found: $directory" >&2
    exit 1
  fi

  find "$directory" -maxdepth 1 -type f -name "${prefix}*.png" -delete

  while IFS= read -r -d '' image; do
    images+=("$image")
  done < <(find "$directory" -maxdepth 1 -type f -name '*.png' ! -name "${prefix}*" -print0)
fi

if [[ ${#images[@]} -eq 0 ]]; then
  usage >&2
  exit 1
fi

for image in "${images[@]}"; do
  if [[ ! -f "$image" ]]; then
    echo "Skipping missing file: $image" >&2
    continue
  fi

  dir="$(dirname "$image")"
  base="$(basename "$image")"
  output="${dir}/${prefix}${base}"

  rm -f "$output"
  sips --resampleWidth "$width" "$image" --out "$output"
done
