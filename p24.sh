#!/usr/bin/env bash

DEBUG=
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

y_pos=0
x_pos=0
wpt_x=10
wpt_y=1
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
  local unit magnitude tmp
  unit=$1
  magnitude=$2
  if [ "${unit}" == 'L' ]
  then
    echo "Rotating left by ${magnitude} is the same as rotating right by 360 - ${magnitude} -> $(( 360 - ${magnitude}))"
    resolve_heading 'R' "$(( 360 - ${magnitude} ))"
    return 0
  fi
  rotated_quadrants=$(( ( ${magnitude} / 90  ) % 4 ))
  echo "Rotating through ${rotated_quadrants} quadrants"
  case "${rotated_quadrants}" in
    1)
      tmp="${wpt_x}"
      wpt_x="${wpt_y}"
      wpt_y="$(( 0 - ${tmp} ))"
      return 0
      ;;
    2)
      tmp="${wpt_x}"
      wpt_x="$(( 0 - ${wpt_x} ))"
      wpt_y="$(( 0 - ${wpt_y} ))"
      return 0
      ;;
    3)
      # x,y -> y,-x -> -x,-y -> -y,x
      tmp="${wpt_x}"
      wpt_x="$(( 0 - ${wpt_y} ))"
      wpt_y="${tmp}"
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}


function move () {
  local unit magnitude
  unit="$1"
  magnitude="$2"
  if [ "${unit}" == 'E' ]
  then
    wpt_x=$(( ${wpt_x} + ${magnitude} ))
  fi
  if [ "${unit}" == 'W' ]
  then
    wpt_x=$(( ${wpt_x} - ${magnitude} ))
  fi
  if [ "${unit}" == 'N' ]
  then
    wpt_y=$(( ${wpt_y} + ${magnitude} ))
  fi
  if [ "${unit}" == 'S' ]
  then
    wpt_y=$(( ${wpt_y} - ${magnitude} ))
  fi
  if [ "${unit}" == 'L' ] || [ "${unit}" == 'R' ]
  then
    resolve_heading "${unit}" "${magnitude}"
  fi
  if [ "${unit}" == 'F' ]
  then
    x_pos=$(( ${x_pos} + ( ${magnitude} * ${wpt_x} ) ))
    y_pos=$(( ${y_pos} + ( ${magnitude} * ${wpt_y} ) ))
  fi
}

for value in "${values[@]}"
do
  move "${value:0:1}" "${value:1}"
  echo "Updated via instruction ${value}. Ship now at ${x_pos}, ${y_pos}. Waypoint now at ${wpt_x}, ${wpt_y}."
done
manhattan_dist
