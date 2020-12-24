#!/usr/bin/env bash

DEBUG=1t
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t instructions<${INPUT}; IFS=$OLDIFS

function debug () {
  if [ -n "${DEBUG}" ]
  then
    echo "$1"
  fi
}


function mask_num () {
  local num
  num=$1
  newnum=0
  debug "Using mask '${mask}'"
  for power in $( seq 0 $(( ${#mask} - 1 )) )
  do
    mask_index=$(( ${#mask} - ${power} - 1 ))
    num_bit=$(( ${num} % 2 ))
    num=$(( ${num} / 2 ))
    mask_bit="${mask:${mask_index}:1}"
    debug "Mask string index '${mask_index}', current mask bit: ${mask_bit}"
    if [ "${mask_bit}" == "X" ]
    then
      debug "Use bit from number: ${num_bit}"
      use_bit=${num_bit}
    else
      debug "Use bit from mask: ${mask_bit}"
      use_bit=${mask_bit}
    fi
    newnum=$(( $newnum + ( 2 ** ${power} * ${use_bit} ) ))
  done
}



declare -A memory
num_pattern="^mem\[([0-9]+)\] = ([0-9]+)"
mask_pattern="^mask = ([0-1X]+)"
mask=
for instruction in "${instructions[@]}"
do
  if [[ ${instruction} =~ ${mask_pattern} ]]
  then
    mask="${BASH_REMATCH[1]}"
    continue
  fi

  if [[ ${instruction} =~ ${num_pattern} ]]
  then
    address="${BASH_REMATCH[1]}"
    number="${BASH_REMATCH[2]}"
    mask_num ${number}
    memory[${address}]=${newnum}
  fi
done
sum=0
for address in "${!memory[@]}"
do
  sum=$(( ${sum} + ${memory[${address}]} ))
done
echo $sum
