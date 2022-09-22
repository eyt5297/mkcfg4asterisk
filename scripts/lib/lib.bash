#!/bin/bash
PREFIX_VAR="T"

get_column() {
  local col_name=${1}
  local line=${2}
  local spliter=${3}
  printf ${line} | tr "${spliter}" "\n" | nl |grep -w ${col_name} | tr -d " " | cut -f1
}

export_vars() {
  IFS=${SPLITER}
  local columns
  read -a columns <<< "${1}"
  local values
  read -a values <<< "${2}"
  if [[ "${3}" != "" ]]; then local col_line=$((${3} - 1)); fi
  IFS=

  for i in ${!columns[@]}; do
    export ${PREFIX_VAR}_${columns[i]^^}="${values[i]}"
    if [[ "${col_line}" != "" ]]; then
      export ${PREFIX_VAR}_${columns[i]^^}_${values[${col_line}]}="${values[i]}"
    fi
  done
}
