#!/usr/bin/env bash

INPUT=${0%sh}input

OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS
length_input="${#values[@]}"
echo "Read ${length_input} boot instructions"

accumulator=0
stack_ptr=0
declare -A visited
while [ 1 ]
do
  if [ -n "${visited[${stack_ptr}]}" ]
  then
    echo "Already visited stack instruction ${stack_ptr}. Accumulator at ${accumulator}. Done!"
    break
  fi
  instruction="${values[${stack_ptr}]}"
  visited[${stack_ptr}]=1
  if [ "nop" == "${instruction::3}" ]
  then
    stack_ptr=$(( ${stack_ptr} + 1 ))
    echo "'nop' instruction; did nothing, advanced stack pointer by 1: ${stack_ptr}."
  fi
  if [ "acc" == "${instruction::3}" ]
  then
    accumulator=$(( ${accumulator} + "${instruction:3}" ))
    stack_ptr=$(( ${stack_ptr} + 1 ))
    echo "'acc' instruction; added ${instruction:3} to the accumulator (now: ${accumulator}), advanced stack pointer by 1: ${stack_ptr}."
  fi
  if [ "jmp" == "${instruction::3}" ]
  then
    stack_ptr=$(( ${stack_ptr} + "${instruction:3}" ))
    echo "'jmp' instruction; added ${instruction:3} to stack pointer: ${stack_ptr}." 
  fi
done
