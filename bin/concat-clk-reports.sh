#!/usr/bin/env bash

set -euo pipefail

summary=`ls -1 Clockify_Time_Report_Summary_*.pdf | tail -n1`
detailed=`ls -1 Clockify_Time_Report_Detailed_*.pdf | tail -n1`

summary_date=`echo "${summary}" | sed 's/Clockify_Time_Report_Summary_\(.*\)\.pdf/\1/g'`
detailed_date=`echo "${detailed}" | sed 's/Clockify_Time_Report_Detailed_\(.*\)\.pdf/\1/g'`

if [ "${summary_date}" != "${detailed_date}" ]
then
    echo "Dates don't match" >&2
    exit 1
fi

output="Clockify_Time_Report_${summary_date}.pdf"

pdfunite "${summary}" "${detailed}" "${output}"

echo "created '${output}'"

rm -v "${summary}" "${detailed}"
