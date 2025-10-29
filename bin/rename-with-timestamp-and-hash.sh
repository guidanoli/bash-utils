#!/usr/bin/env bash
# Renames files to: YYYY-MM-DD_HH-MM-SS_<8hexhash>.<ext>
# Based on file's modification time and SHA-256 hash.

set -euo pipefail

# Check that at least one argument was passed
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [files...]" >&2
    exit 1
fi

for file in "$@"; do
    # Ensure file exists and is regular
    if [[ ! -f "$file" ]]; then
        echo "Skipping '$file' (not a regular file)" >&2
        continue
    fi

    # Get modification time components (GNU stat format)
    read -r year month day hour minute second < <(
        stat -c '%y' "$file" | awk -F'[-:. ]' '{print $1, $2, $3, $4, $5, $6}'
    )

    # Get SHA-256 hash truncated to 8 hex digits
    hash=$(sha256sum "$file" | cut -c1-8)

    # Extract extension (preserve if exists)
    base=$(basename "$file")
    ext=""
    if [[ "$base" == *.* && "$base" != .* ]]; then
        ext=".${base##*.}"
    fi

    newname="${year}-${month}-${day}_${hour}-${minute}-${second}_${hash}${ext}"

    # Avoid overwriting existing file
    if [[ -e "$newname" ]]; then
        echo "Skipping '$file': target '$newname' already exists" >&2
        continue
    fi

    mv -- "$file" "$newname"
    echo "Renamed '$file' -> '$newname'"
done
