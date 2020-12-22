#!/usr/bin/env bash

DEBUG=
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

y_pos=0
x_pos=0
compass='ENWS'
heading=0 # 'E'



function debug () {
  if [ -n "${DEBUG}" ]
  then
    echo "$1"
  fi
}

function manhattan_dist () {
  if [ 0 -gt ${y_pos} ]
  then
    y_pos=$(( 0 - ${y_pos} ))
  fi
  if [ 0 -gt ${x_pos} ]
  then
    x_pos=$(( 0 - ${x_pos} ))
  fi
  echo "$(( ${y_pos} +  ${x_pos} ))"
}

function resolve_heading () {
  local unit magnitude
  unit=$1
  if [ "${unit}" == 'L' ]
  then
    # angles go up
    op='+'
  else
    op='-'
  fi
  magnitude=$2
  relative=$(( ( ${heading} "${op}" ( ( ${magnitude} / 90 ) % ( 360 / 90 ) ) ) % 4 ))
  if [ 0 -gt "${relative}" ]
  then
    heading=$(( 4 + ${relative} ))
  else
    heading="${relative}"
  fi
}


function move () {
  local unit magnitude
  unit="$1"
  magnitude="$2"
  if [ "${unit}" == 'E' ]
  then
    x_pos=$(( ${x_pos} + ${magnitude} ))
  fi
  if [ "${unit}" == 'W' ]
  then
    x_pos=$(( ${x_pos} - ${magnitude} ))
  fi
  if [ "${unit}" == 'N' ]
  then
    y_pos=$(( ${y_pos} + ${magnitude} ))
  fi
  if [ "${unit}" == 'S' ]
  then
    y_pos=$(( ${y_pos} - ${magnitude} ))
  fi
  if [ "${unit}" == 'L' ] || [ "${unit}" == 'R' ]
  then
    resolve_heading "${unit}" "${magnitude}"
  fi
  if [ "${unit}" == 'F' ]
  then
    move "${compass:${heading}:1}" "${magnitude}"
  fi
}

for value in "${values[@]}"
do
  move "${value:0:1}" "${value:1}"
done
manhattan_dist
