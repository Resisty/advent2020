#!/usr/bin/env bash
set -e

INPUT=${0%sh}input

set +e
IFS=$'\n' read -d'' -r -a values<${INPUT}
set -e
index=0
length_input="${#values[@]}"
while [ 1 ]
do
  value=${values[${index}]}
  for ((i=$(expr 1 + ${index}); i<${length_input}; i++))
  do
    second_value=${values[${i}]}
    for ((j=$(expr 1 + ${i}); j<${length_input}; j++))
    do
      third_value=${values[${j}]}
      if [[ 2020 -eq $(expr ${value} + ${second_value} + ${third_value}) ]]
      then
        echo $(expr ${value} \* ${second_value} \* ${third_value})
        break 3
      fi
    done
  done
  index=$(expr 1 + ${index})
  if [[ ${index} -gt ${length_input} ]]
  then
    echo "Ran out of input before finding the answer! Re-evaluate your solution."
    exit 1
  fi
done
