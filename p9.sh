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
      echo "'${char}' means take the upper half (${i}) of ${min} to ${max}" >&2
      min=$(( (${max} - ${min}) / 2 + ${min}  + 1))
      echo "New range: ${min} to ${max}" >&2
    elif [ "${value:${i}:1}" == 'F' ] || [ "${char}" == 'L' ]
    then
      echo "'${char}' means take the lower half (${i}) of ${min} to ${max}" >&2
      max=$(( (${max} - ${min}) / 2 + ${min} ))
      echo "New range: ${min} to ${max}" >&2
    fi
  done
  echo "${min}"
}

highest=0
for value in "${values[@]}"
do
  echo "Checking seat assignment ${value}"
  row="$( bin_bf ${value:: -3} )"
  col="$( bin_bf ${value: -3} )"
  seat_id=$(( ${row} * 8 + ${col} ))
  if [ "${seat_id}" -gt "${highest}" ]
  then
    highest="${seat_id}"
  fi
done
echo "Highest seat id on a boarding pass is ${highest}"
