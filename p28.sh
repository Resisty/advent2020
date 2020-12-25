#!/usr/bin/env bash

DEBUG=3
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t instructions<${INPUT}; IFS=$OLDIFS

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

function double_mask_maybe() {
  local masked_addr masked_addr_0 masked_addr_1 left_addrs=() right_addrs=()
  masked_addr=$1
  addresses=()
  if [[ ! ${masked_addr} =~ "X" ]]
  then
    addresses+=( ${masked_addr} )
    debug "No 'X' characters detected in address. Add to list of addresses: ( ${addresses[*]} )"
    return 0
  fi
  for power in $( seq 0 $(( ${#masked_addr} - 1 )) )
  do
    mask_index=$(( ${#masked_addr} - ${power} - 1 ))
    mask_bit="${masked_addr:${mask_index}:1}"
    debug 2 "Power ${power}, masked_address bit is ${mask_bit}"
    if [ "${mask_bit}" == "X" ]
    then
      left_to_x="${masked_addr::${mask_index}}"
      right_to_x="${masked_addr:$(( ${mask_index} + 1 ))}"
      debug "Initial masked_addr:                            ${masked_addr}"
      debug "Masked addr left to rightmost X, noninclusive:  ${left_to_x}"
      debug "Masked addr right to rightmost X, noninclusive: ${right_to_x}"
      masked_addr_0="${left_to_x}0${right_to_x}"
      masked_addr_1="${left_to_x}1${right_to_x}"
      debug "Bisect address on first X:                      ${masked_addr_0}"
      debug "    and                                         ${masked_addr_1}"
      double_mask_maybe ${masked_addr_0}
      left_addrs=( "${addresses[@]}" )
      double_mask_maybe ${masked_addr_1}
      right_addrs=( "${addresses[@]}" )
      addresses=( "${left_addrs[@]}" "${right_addrs[@]}" )
      break
    fi
  done
}

function mask_addr () {
  local addr
  addr=$1
  masked_addr=
  debug "Using mask '${mask}'"
  for power in $( seq 0 $(( ${#mask} - 1 )) )
  do
    mask_index=$(( ${#mask} - ${power} - 1 ))
    addr_bit=$(( ${addr} % 2 ))
    addr=$(( ${addr} / 2 ))
    mask_bit="${mask:${mask_index}:1}"
    debug 2 "Mask string index '${mask_index}', current mask bit: ${mask_bit}"
    if [ "${mask_bit}" == "X" ]
    then
      debug 2 "Use bit from address: ${addr_bit}"
      use_bit=${mask_bit}
    else
      debug 2 "OR bit from mask and addr: ${mask_bit} | ${addr_bit}"
      use_bit=$(( ${mask_bit} | ${addr_bit} ))
    fi
    masked_addr=${use_bit}${masked_addr}
  done
}



declare -A memory
num_pattern="^mem\[([0-9]+)\] = ([0-9]+)"
mask_pattern="^mask = ([0-1X]+)"
mask=
for instruction in "${instructions[@]}"
do
  debug 3 "Got instruction: ${instruction}"
  if [[ ${instruction} =~ ${mask_pattern} ]]
  then
    mask="${BASH_REMATCH[1]}"
    continue
  fi

  if [[ ${instruction} =~ ${num_pattern} ]]
  then
    address="${BASH_REMATCH[1]}"
    number="${BASH_REMATCH[2]}"
    mask_addr "${address}"
    debug "Address ${address} masked to ${masked_addr}"
    double_mask_maybe ${masked_addr}
    debug "Got multiple addresses (${#addresses[@]}): ( ${addresses[*]} )"
    for addr in "${addresses[@]}"
    do
      debug "Writing value ${number} to address ${addr}"
      memory[${addr}]=${number}
    done
  fi
done
sum=0
for address in "${!memory[@]}"
do
  sum=$(( ${sum} + ${memory[${address}]} ))
done
echo $sum
