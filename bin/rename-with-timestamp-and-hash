#!/usr/bin/env bash
# Renames files to: YYYY-MM-DD_HH-MM-SS_<8hexhash>.<ext>
# Based on file's modification time and SHA-256 hash.

set -euo pipefail

# Check that at least one argument was passed
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [files...]" >&2
    exit 1
fi

exit_code=0

for filepath in "$@"; do
    # Ensure file exists and is regular
    if [[ ! -f "$filepath" ]]; then
        echo "Skipping '$filepath' (not a regular file)" >&2
        exit_code=1
        continue
    fi

    # Get modification time components (GNU stat format)
    read -r year month day hour minute second < <(
        stat -c '%y' "$filepath" | awk -F'[-:. ]' '{print $1, $2, $3, $4, $5, $6}'
    )

    # Get SHA-256 hash of file
    filehash=$(sha256sum "$filepath" | awk '{ print $1 }')

    # Separate filepath into directory and filename
    directory=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Extract extension (preserve if exists)
    ext=""
    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        ext=".${filename##*.}"
    fi

    # Truncate the file hash to 5 hexdigits
    shortened_filehash=$(echo $filehash | head -c5)

    newfilepath="${directory}/${year}-${month}-${day}_${hour}-${minute}-${second}__${shortened_filehash}${ext}"

    if
        [[ -f "$newfilepath" ]]
    then
        newfilehash=$(sha256sum "$newfilepath" | awk '{ print $1 }')

        if
            [[ "$filehash" != "$newfilehash" ]]
        then
            echo "Cannot overwrite file '$newfilepath' with different hash than '$filepath'" >&2
            exit_code=1
            continue
        fi
    elif
        [[ -d "$newfilepath" ]]
    then
        echo "Cannot overwrite '$newfilepath', because it is a directory" >&2
        exit_code=1
        continue
    fi

    ## Rename file (if new path is different)

    if
        [[ ! "$filepath" -ef "$newfilepath" ]]
    then
        mv -v "$filepath" "$newfilepath"
    fi
done

## Exit with code

exit $exit_code
