#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]
then
    echo "Adjust modification timestamp of files based solely on their names" >&2
    echo "Patterns: CCYY.MMDDHH and CCYYMMDD" >&2
    echo "Usage: $0 [FILES...]" >&2
    exit 1
fi

for file in "$@"
do
    if [[ "$file" =~ [0-9]{8}[^0-9][0-9]{6} ]]
    then
        timestamp=`echo "$file" | sed -E 's/.*([0-9]{8})[^0-9]([0-9]{4})([0-9]{2}).*/\1\2.\3/'`
        touch "$file" -t "$timestamp"
    elif [[ "$file" =~ [0-9]{8} ]]
    then
        timestamp=`echo "$file" | sed -E 's/.*([0-9]{8}).*/\11200/'`
        touch "$file" -t "$timestamp"
    else
        echo "Missing: $file"
    fi
done
