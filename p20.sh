#!/usr/bin/env bash

INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

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

function maximum() {
  max=
  local element
  for element
  do
    [[ -n "${max}" ]] || max=${element}
    (( ${element} > max )) && max=${element}
  done
}

function is_valid_wout_n() {
  local pivot left_cmp right_cmp array=() left=() right=() next_array=()
  pivot=$1
  shift
  (($#==0)) && return 0 # don't count empty list
  for i
  do
    array+=( "${i}" )
  done
  if [ "${pivot}" -ge $(( "${#array[@]}" - 1 )) ] # do not include your device
  then
    return 0
  fi
  left=( "${array[@]::${pivot}}" )
  left_cmp="${left[-1]}"
  right=( "${array[@]:$(( 1 + ${pivot} ))}" )
  right_cmp="${right[0]}"
  if [ $(( "${right_cmp}" - "${left_cmp}" )) -gt 3 ]
  then
    # not a valid chain, advance pivot on same chain
    next_array=( "${left[@]}" "${right[@]}" )
    echo "NON-VALID chain found: ( ${next_array[@]} )"
  else
    # valid chain, count it
    count=$(( ${count} + 1 ))
    next_array=( "${left[@]}" "${right[@]}" )
    echo "Found a valid chain: ( ${next_array[*]} ), count increased to ${count}"
    # echo "Valid chain found: ( ${next_array[@]} )"
    # we removed item at index 'pivot' so do not advance pivot to check valid chains missing at least this pivot
    is_valid_wout_n $(( ${pivot} )) "${next_array[@]}"
    # also advance the pivot to check valid chains *including* this pivot
  fi
  is_valid_wout_n $(( ${pivot} + 1 )) "${array[@]}"
}


maximum "${values[@]}" # initialize: find maximum (joltage of device)
values+=( 0 $(( 3 + ${max} )) ) # add outlet and device to list of adapters
qsort "${values[@]}" # sort adapters
echo "Sorted list: ${qsort_ret[*]}"
for i in $(seq 0 "${#qsort_ret[@]}")
do
  i_2=$(( ${i} + 2 ))
  required_index=$(( ${i} + 1 ))
  if [ ${i_2} -ge "${#qsort_ret[@]}" ]
  then
    break # wandered off the list
  fi
  if [ $(( ${qsort_ret[${i_2}]} - ${qsort_ret[${i}]} )) -gt 3 ]
  then
    echo "Found an inflection point at ${required_index}, value ${qsort_ret[${required_index}]}"
    required_indices+=( "${required_index}" )
  fi
done

total=1
count=1
start=0
for index in "${required_indices[@]}"
do
  length=$(( ${index} - ${start} + 1))
  sublist=( "${qsort_ret[@]:${start}:${length}}" )
  echo "Checking number of paths across indices ${start} to ${index} ( ${sublist[*]} )"
  is_valid_wout_n 1 "${sublist[@]}" # count paths between start and required index
  echo "Found ${count} paths across ( ${sublist[*]} )"
  total=$(( ${total} * ${count} ))
  echo "Updating total to ${total}"
  count=1
  start=$(( ${index} ))
done

echo "${total}"
