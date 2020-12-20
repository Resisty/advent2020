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

maximum "${values[@]}"
values+=( 0 $(( 3 + ${max} )) ) # outlet and device
qsort "${values[@]}"
declare -A diffs
for i in $(seq 1 $(( ${#qsort_ret[@]} - 1 )) )
do
  prev_index=$(( ${i} - 1 ))
  val="${qsort_ret[${i}]}"
  prev="${qsort_ret[${prev_index}]}"
  diff=$(( ${val} - ${prev} ))
  echo "Subtracting: ${val} - ${prev}: ${diff}"
  if [ -z "${diffs[${diff}]}" ]
  then
    diffs[${diff}]=1
  else
    diffs[${diff}]=$(( ${diffs[${diff}]} + 1 ))
  fi
done
declare -p diffs
diff_1s="${diffs[1]}"
diff_3s="${diffs[3]}"
echo "Number of 1 jolt diffs * number of 3 jolt diffs = $(( ${diff_1s} * ${diff_3s} ))"
