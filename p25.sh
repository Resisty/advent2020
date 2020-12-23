#!/usr/bin/env bash

DEBUG=
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

earliest="${values[0]}"
buses="${values[1]}"
OLDIFS=$IFS; IFS=',' read -ra bus_ids<<<${buses}; IFS=$OLDIFS

function minimum() {
  min=
  local element
  for element
  do
    [[ -n "${min}" ]] || min=${element}
    (( ${element} < min )) && min=${element}
  done
}

min=
min_id=
times=( )
for bus_id in "${bus_ids[@]}"
do
  if [ "x" == "${bus_id}" ]
  then
    continue
  fi
  next=$(( ( ${bus_id} - ( ${earliest} % ${bus_id} ) ) + ${earliest} ))
  if [ -z "${min}" ] || [ ${min} -gt ${next} ]
  then
    min=${next}
    min_id=${bus_id}
  fi
done

wait_time=$(( ${min} - ${earliest} ))
product=$(( ${wait_time} * ${min_id} ))
echo "Must wait ${min} - ${earliest} = ${wait_time} for bus id ${min_id}. Wait ( ${wait_time} ) times id ( ${min_id} ) = ${product}" 
