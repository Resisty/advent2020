#!/usr/bin/env bash

INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS
INVALID=

function is_contained_by () {
  local element match="${1}"
  shift
  for element
  do
    [[ "${element}" == "${match}" ]] && return 0
  done
  return 1
}


function last_n() {
  cmp="${values[${top}]}"
  last_n_items=( )
  for i in $( seq $bottom $(( ${top} - 1 )) )
  do
    last_n_items+=( "${values[${i}]}" )
  done
  found=
  for i in "${last_n_items[@]}"
  do
    diff="$(( "${cmp}" - "${i}" ))"
    if is_contained_by "${diff}" "${last_n_items[@]}" && [ "${diff}" -ne "${i}" ]
    then
      return
    fi
  done
  if [ -z "${found}" ]
  then
    echo "${cmp} was not found to be the sum of two different numbers of the previous ${#last_n_items[@]} numbers (${last_n_items[*]})"
    INVALID="${cmp}"
  fi
}

function minimum() {
  min=
  local element
  for element
  do
    [[ -n "${min}" ]] || min=${element}
    (( ${element} < min )) && min=${element}
  done
}

function maximum() {
  max=
  local element
  for element
  do
    [[ -n "${min}" ]] || max=${element}
    (( ${element} > max )) && max=${element}
  done
}

function sum_from_index() {
  local element sum=0 index="${1}" ciel="${2}"
  shift; shift
  items=( )
  for element
  do
    items+=( "${element}" )
    sum=$(( ${sum} + ${element} ))
    if [ ${sum} -gt ${ciel} ]
    then
      break
    elif [ ${sum} -eq ${ciel} ]
    then
      minimum "${items[@]}"; maximum "${items[@]}"
      echo "Elements of ( ${items[*]} ) sum to ${ciel}. Answer: ${min} + ${max} = $(( ${min} + ${max} ))"
      exit 0
    fi
  done
}

# find INVALID
bottom=0
top=25
for i in $(seq ${top} $(( ${#values[@]} -1 )) )
do
  last_n
  bottom=$(( ${bottom} + 1 ))
  top=$(( ${top} + 1 ))
done

# find contiguous set of items summing to $INVALID
bottom=0
while [ "${bottom}" -lt "${#values[@]}" ]
do
  sum_from_index ${bottom} ${INVALID} ${values[@]:${bottom}}
  bottom=$(( ${bottom} + 1 ))
done

