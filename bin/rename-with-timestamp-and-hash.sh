#!/usr/bin/env bash
# Renames files to: YYYY-MM-DD_HH-MM-SS_<8hexhash>.<ext>
# Based on file's modification time and SHA-256 hash.

set -euo pipefail

# Check that at least one argument was passed
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [files...]" >&2
    exit 1
fi

for filepath in "$@"; do
    # Ensure file exists and is regular
    if [[ ! -f "$filepath" ]]; then
        echo "Skipping '$filepath' (not a regular file)" >&2
        continue
    fi

    # Get modification time components (GNU stat format)
    read -r year month day hour minute second < <(
        stat -c '%y' "$filepath" | awk -F'[-:. ]' '{print $1, $2, $3, $4, $5, $6}'
    )

    # Get SHA-256 hash truncated to 8 hex digits
    hash=$(sha256sum "$filepath" | cut -c1-8)

    # Separate filepath into directory and filename
    directory=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Extract extension (preserve if exists)
    ext=""
    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        ext=".${filename##*.}"
    fi

    newfilepath="${directory}/${year}-${month}-${day}_${hour}-${minute}-${second}_${hash}${ext}"

    # Avoid overwriting existing file
    if [[ -e "$newfilepath" ]]; then
        echo "Skipping '$filepath': target '$newfilepath' already exists" >&2
        continue
    fi

    mv -- "$filepath" "$newfilepath"
    echo "Renamed '$filepath' -> '$newfilepath'"
done
