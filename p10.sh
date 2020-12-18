#!/usr/bin/env bash

INPUT=${0%sh}input

IFS=$'\n' read -d'' -r -a values<${INPUT}
length_input="${#values[@]}"

function bin_bf () {
  value=$1
  min=0
  max=$(( 2 ** ${#value} - 1 ))
  for i in $(seq 0 ${#value})
  do
    char="${value:${i}:1}"
    if [ "${char}" == 'B' ] || [ "${char}" == 'R' ]
    then
      min=$(( (${max} - ${min}) / 2 + ${min}  + 1))
    elif [ "${value:${i}:1}" == 'F' ] || [ "${char}" == 'L' ]
    then
      max=$(( (${max} - ${min}) / 2 + ${min} ))
    fi
  done
  echo "${min}"
}

qsort() {
  # lovingly stolen from SO: https://stackoverflow.com/a/30576368
  local pivot i smaller=() larger=()
  qsort_ret=()
  (($#==0)) && return 0
  pivot=$1
  shift
  for i; do
     if (( i < pivot )); then
        smaller+=( "$i" )
     else
        larger+=( "$i" )
     fi
  done
  qsort "${smaller[@]}"
  smaller=( "${qsort_ret[@]}" )
  qsort "${larger[@]}"
  larger=( "${qsort_ret[@]}" )
  qsort_ret=( "${smaller[@]}" "$pivot" "${larger[@]}" )
}

declare -A seat_ids
for value in "${values[@]}"
do
  row="$( bin_bf ${value:: -3} )"
  col="$( bin_bf ${value: -3} )"
  seat_id=$(( ${row} * 8 + ${col} ))
  seat_ids[${seat_id}]=1
done

unordered_seats=("${!seat_ids[@]}")
qsort "${unordered_seats[@]}"
keys=("${!qsort_ret[@]}")
for (( i=0; i<"${#qsort_ret[@]}"; i++ ))
do
  key="${keys[$i]}"
  prev=$(( ${key} - 1 ))
  next=$(( ${key} + 1 ))
  if [ "${qsort_ret[${key}]}" -ne $(( "${qsort_ret[${next}]}" - 1 )) ] && [ -n "${qsort_ret[${next}]}" ]
  then
    echo "There is a gap between seats ${qsort_ret[${key}]} and ${qsort_ret[${next}]}"
    echo "Take seat $(( 1 + ${qsort_ret[${key}]}  ))"
  fi
done
