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
OLDIFS=$IFS; IFS=, tokens=( ${lines[0]} ) ; IFS=$OLDIFS
debug 1 "Chunked numbers into ( ${tokesn[*]} )"

declare -A numbers_at_index
declare -A last_index
declare -A second_last_index
for ((i=0;i<${#tokens[@]};i++))
do
  numbers_at_index[${i}]=${tokens[${i}]}
  last_index[${tokens[${i}]}]=${i}
  second_last_index[${tokens[${i}]}]=${i}
done

debug 2 "Starting list of numbers: ${numbers_at_index[*]}"

function number_at_index() {
  local index_n index_n_1 val_n_1 last_idx second_to_last_idx diff last_nth second_to_last_nth
  index_n=${1}
  the_number=
  if [ -n "${numbers_at_index[${index_n}]}" ]
  then
    the_number="${numbers_at_index[${index_n}]}"
    debug "Index ${index_n} has value: ${the_number}"
    return 0
  fi
  index_n_1=$(( ${index_n} - 1 ))
  debug "Index ${index_n} has no value, RECURSE to index n-1 (${index_n_1})"
  number_at_index ${index_n_1}
  val_n_1=${the_number} 
  debug "Recursion yields index n-1 (${index_n_1}) has value ${val_n_1}"
  last_idx="${last_index[${val_n_1}]}"
  second_to_last_idx="${second_last_index[${val_n_1}]}"
  diff=$(( "${last_idx}" - "${second_to_last_idx}" ))
  if [ 0 -eq ${diff} ]
  then
    # last index and second-to-last index are the same -> Only appeared once
    # nth number must be 0
    debug 2 "Index ${index_n} must be 0 ( ${numbers_at_index[*]} )"
    numbers_at_index[${index_n}]=0
    test -n "${last_index[0]}" && second_last_index[0]="${last_index[0]}" || second_last_index[0]="${index_n}"
    last_index[0]=${index_n}
    the_number=0
    return 0
  else
    # get previous two indices of number at n_1
    number_at_index ${last_idx}
    last_nth=${the_number}
    last_idx="${last_index[${last_nth}]}"
    number_at_index ${second_to_last_idx}
    second_to_last_nth=${the_number}
    second_to_last_idx="${second_last_index[${second_to_last_nth}]}"
    diff=$(( ${last_idx} - ${second_to_last_idx} ))
    numbers_at_index[${index_n}]=${diff}
    test -n "${last_index[${diff}]}" && second_last_index[${diff}]="${last_index[${diff}]}" || second_last_index[${diff}]="${index_n}"
    last_index[${diff}]=${index_n}
    the_number="${diff}"
    return 0
  fi
}

for ((i=0;i<=2019;i++))
do
  echo "Check $(( 1 + ${i} ))th number, index ${i}:"
  number_at_index ${i}
  echo "The $(( 1 + ${i} ))th number is ${the_number}"
  debug "${numbers_at_index[*]}"
done
