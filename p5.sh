#!/usr/bin/env bash
set -e

# standard read the file
INPUT=${0%sh}input
echo "Input file: ${INPUT}"

set +e
OLDIFS=$IFS; IFS=$'\n' read -d '' -r -a values<${INPUT}; IFS=$OLDIFS
set -e
length_y="${#values[@]}"
length_x="${#values[0]}"
echo "Read ${length_y} lines of input of width ${length_x}."

# Start problem work here


count=0
y_pos=0
x_pos=0
while [ 1 ]
do
  x_pos=$((${x_pos} + 3))
  echo "Advancing right 3 spaces: x=${x_pos}"
  if [ ${x_pos} -ge ${length_x} ];
  then
    echo "Advanced off the grid (width ${length_x})"
    x_pos=$((${x_pos} % ${length_x}))
    echo "Modulo back to the left: x=${x_pos}"
  fi
  y_pos=$((${y_pos} + 1))
  if [ ${y_pos} -ge ${length_y} ];
  then
    break
  fi
  echo "Evaluate spot at (${x_pos}, ${y_pos}) for tree (#)"
  if [ "${values[${y_pos}]:${x_pos}:1}" == "#" ];
  then
    echo "Found a tree at position x("${x_pos}"), y("${y_pos}")"
    count=$(($count + 1))
  fi
done
echo "Total trees encountered: ${count}"
