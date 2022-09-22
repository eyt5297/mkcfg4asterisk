#!/bin/bash
. $(dirname "$0")/lib/lib.bash

CSVFILE=$1
DST_DIR=$2
SPLITER=","
TPL_DIR=$(dirname $0)/../templates/phones
status_enebled='^\+,'
perv_mac=


first_line="$(head -1 ${CSVFILE})"
col_mac=$(get_column "mac" "${first_line}" "${SPLITER}")
col_line=$(get_column "line" "${first_line}" "${SPLITER}")


while read line; do
  cur_mac=$(echo ${line} | cut -d, -f${col_mac})
  status=$(echo ${line} | cut -d, -f1)
  if [[ "${perv_mac}" == "" ]]; then perv_mac=${cur_mac}; fi

  if [[ "${status}" == "-end-" ]] || [[ "${perv_mac}" != "${cur_mac}" ]]; then
    echo ==== ${T_MAC} 
    sh ${TPL_DIR}//${T_MODEL}/apply.sh ${DST_DIR}
    unset ${!T_@}
  fi

  export_vars "${first_line}" "${line}" "${col_line}"
  perv_mac=${cur_mac}
done <<< "$(tail -n +2 ${CSVFILE}| egrep "${status_enebled}" | sort -t ',' -k ${col_mac},${col_mac} -k ${col_line},${col_line}; echo -end-)"



