#!/usr/bin/env bash

INPUT=${0%sh}input
inc=0

function flip_one() {
  unset values
  OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS
  count=0
  for val in "${!values[@]}"
  do
    if [[ "${values[${val}]}" =~ 'nop' ]] || [[ "${values[${val}]}" =~ 'jmp' ]]
    then
      if [ ${count} -eq ${inc} ]
      then
        # echo "'${values[${val}]::3}' flipped to:"
        [[ "${values[${val}]::3}" == "jmp" ]] && values[${val}]="nop${values[${val}]:3}" || values[${val}]="jmp${values[${val}]:3}"
        # echo "${values[${val}]::3}"
        inc=$(( ${inc} + 1 ))
        break
      fi
      count=$(( ${count} + 1 ))
    fi
  done
  # echo "Full set of instructions: "
  # echo "${values[@]}"
}

function evaluate_instructions() {
  accumulator=0
  stack_ptr=0
  unset visited && declare -A visited
  while [ 1 ]
  do
    if [ "${stack_ptr}" -ge "${#values[@]}" ]
    then
      echo "Attempted to execute instruction beyond list of instructions; completed without loop. Accumulator: ${accumulator}"
      exit 0
    fi
    if [ -n "${visited[${stack_ptr}]}" ]
    then
      echo "!!!LOOP DETECTED!!!! Already visited stack instruction ${stack_ptr}."
      break
    fi
    instruction="${values[${stack_ptr}]}"
    visited[${stack_ptr}]=1
    if [ "nop" == "${instruction::3}" ]
    then
      stack_ptr=$(( ${stack_ptr} + 1 ))
    fi
    if [ "acc" == "${instruction::3}" ]
    then
      accumulator=$(( ${accumulator} + "${instruction:3}" ))
      stack_ptr=$(( ${stack_ptr} + 1 ))
    fi
    if [ "jmp" == "${instruction::3}" ]
    then
      stack_ptr=$(( ${stack_ptr} + "${instruction:3}" ))
    fi
  done
}

num_runs=0
while [ 1 ]
do
  echo "Flipping the ${inc}th occurrence of 'nop' or 'jmp'"
  flip_one
  echo "Evaluating the ${inc}th set of one-flip instructions"
  evaluate_instructions
  num_runs=$(( ${num_runs} + 1 ))
  if [ ${#values[@]} -lt ${num_runs} ]
  then
    echo "You've evaluated more sets of instructions (${num_runs}) than there are instructions that could be flipped (${#values[@]}). ERROR."
    exit 1
  fi
done
