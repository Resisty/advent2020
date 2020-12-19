#!/usr/bin/env bash

INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

function is_contained_by () {
  local element match="${1}"
  shift
  for element
  do
    [[ "${element}" == "${match}" ]] && echo "${element} == ${match}" && return 0
  done
  echo "${match} != any element in array"
  return 1
}


function last_n() {
  cmp="${values[${top}]}"
  last_n_items=( )
  for i in $( seq $bottom $(( ${top} - 1 )) )
  do
    last_n_items+=( "${values[${i}]}" )
  done
  echo "Evaluating across the last ${top} - ${bottom} items: ${last_n_items[@]}"
  found=
  for i in "${last_n_items[@]}"
  do
    diff="$(( "${cmp}" - "${i}" ))"
    echo "Check ${cmp} - ${i} (${diff}) for presence in ( ${last_n_items[*]} )"
    if is_contained_by "${diff}" "${last_n_items[@]}" && [ "${diff}" -ne "${i}" ]
    then
      echo "The number ${cmp} is the sum of two different numbers of the previous ${#last_n_items[@]} numbers:"
      echo "${i} + ${diff} = $(( ${i} + ${diff} )) and ${diff} in (${last_n_items[*]})"
      return
    fi
  done
  if [ -z "${found}" ]
  then
    echo "${cmp} was not found to be the sum of two different numbers of the previous ${#last_n_items[@]} numbers (${last_n_items[*]})"
    exit 0
  fi
}

bottom=0
top=25
for i in $(seq ${top} $(( ${#values[@]} -1 )) )
do
  last_n
  bottom=$(( ${bottom} + 1 ))
  top=$(( ${top} + 1 ))
done
