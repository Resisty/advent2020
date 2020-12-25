#!/usr/bin/env bash

DEBUG=
function debug () {
  local level
  if [ -z "${2}" ]
  then
    level=1
  else
    level=${1}
    shift
  fi
  if [ -n "${DEBUG}" ] && [ ${level} -ge ${DEBUG} ]
  then
    echo "$1"
  fi
}

INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t lines<${INPUT}; IFS=$OLDIFS
debug 1 "Chunking lines[0] = '${lines[0]}'"
OLDIFS=$IFS; IFS=, numbers=( ${lines[0]} ) ; IFS=$OLDIFS
debug 1 "Chunked numbers into ( ${numbers[*]} )"

declare -A spoken
declare -A last_index
declare -A second_last_index

update_number () {
  local num
  num=$1
  if [ -z "${last_index[${num}]}" ]
  then
    last_index[${num}]="$(( ${#numbers[@]} - 1 ))"
    spoken[${num}]=1
  else
    second_last_index[${num}]="${last_index[${num}]}"
    last_index[${num}]="$(( ${#numbers[@]} - 1 ))"
    spoken[${num}]="$(( 1 + ${spoken[${num}]} ))"
  fi
}

for (( i=0; i<"${#numbers[@]}"; i++))
do
  num="${numbers[${i}]}"
  spoken[${num}]=1
  last_index[${num}]=${i}
done

for (( i=${#numbers[@]}; i<2020; i++ ))
do
  last="${numbers[-1]}"
  times_spoken="${spoken[${last}]}"
  if [ 1 -eq ${times_spoken} ]
  then
    # only spoken once, add a 0
    numbers+=( 0 )
    update_number 0
  else
    new_num=$(( ${last_index[${last}]} - ${second_last_index[${last}]} ))
    numbers+=( ${new_num} )
    update_number ${new_num}
  fi
  debug "Numbers so far: ${numbers[*]}"
done
echo "2020th number: ${numbers[-1]}"
