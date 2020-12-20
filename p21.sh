#!/usr/bin/env bash

INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

y_length="${#values[@]}"
x_length="${#values[0]}"

function char_at () {
  local x_pos y_pos
  y_pos=$1
  x_pos=$2
  if [ ${y_pos} -lt 0 ] || [ ${y_pos} -ge ${y_length} ] || [ ${x_pos} -lt 0 ] || [ ${x_pos} -ge ${x_length} ]
  then
    # checking a space off the grid
    return 1
  fi
  row="${values[${y_pos}]}"
  char="${row:${x_pos}:1}"
  echo "${char}"
}

function occupied_at () {
  local x_pos y_pos
  y_pos=$1
  x_pos=$2
  if [ ${y_pos} -lt 0 ] || [ ${y_pos} -ge ${y_length} ] || [ ${x_pos} -lt 0 ] || [ ${x_pos} -ge ${x_length} ]
  then
    # checking a space off the grid
    return 1
  fi
  row="${values[${y_pos}]}"
  char="${row:${x_pos}:1}"
  if [ "${char}" == 'L' ] || [ "${char}" == '.' ]
  then
    # not occupado
    return 1
  elif [ "${char}" == '#' ]
  then
    # occupadaddo
    return 0
  fi
}

function check_grid () {
  local x_pos y_pos
  y_pos=$1
  x_pos=$2
  num_neighbors=0
  # up left
  if occupied_at $(( ${y_pos} - 1 )) $(( ${x_pos} - 1 ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # up
  if occupied_at $(( ${y_pos} - 1 )) $(( ${x_pos} ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # up right
  if occupied_at $(( ${y_pos} - 1 )) $(( ${x_pos} + 1 ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # left
  if occupied_at $(( ${y_pos} )) $(( ${x_pos} - 1 ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # right
  if occupied_at $(( ${y_pos} )) $(( ${x_pos} + 1 ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # down left
  if occupied_at $(( ${y_pos} + 1 )) $(( ${x_pos} - 1 ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # down 
  if occupied_at $(( ${y_pos} + 1 )) $(( ${x_pos} ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # down right 
  if occupied_at $(( ${y_pos} + 1 )) $(( ${x_pos} + 1 ))
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
}

function update () {
  grid=()
  for i in $(seq 0 $(( ${y_length} - 1 )) )
  do
    line=""
    for j in $(seq 0 $(( ${x_length} - 1 )) )
    do
      #echo "Check position ${i},${j}..."
      check_grid ${i} ${j}
      if [ "$( char_at ${i} ${j} )" == '.' ]
      then
        #echo "Position ${i},${j} ( $(char_at ${i} ${j}) ) is floor"
        line="${line}."
      elif ! occupied_at ${i} ${j} && [ ${num_neighbors} -eq 0 ]
      then
        #echo "Position ${i},${j} ( $(char_at ${i} ${j}) ) not occupied and 0 neighbors"
        line="${line}#"
      elif ! occupied_at ${i} ${j}
      then
        #echo "Position ${i},${j} ( $(char_at ${i} ${j}) ) not occupied but 1 or more neighbors"
        line="${line}L"
      elif occupied_at ${i} ${j} && [ ${num_neighbors} -ge 4 ]
      then
        #echo "Position ${i},${j} ( $(char_at ${i} ${j}) ) is occupied and has 4 or more neighbors"
        line="${line}L"
      elif occupied_at ${i} ${j}
      then
        #echo "Position ${i},${j} ( $(char_at ${i} ${j}) ) is occupied with fewer than 4 neighbors"
        line="${line}#"
      fi
      #echo "After checking position ${i},${j} line is now: ${line}"
    done
    if [ "${#line}" -ne "${x_length}" ]
    then
      echo "Line ( ${line} ) is incorrect length! Is ${#line} but should be ${x_length}"
      exit 1
    fi
    grid+=( "${line}" )
  done
}

function is_contained_by () {
  local element match="${1}"
  shift
  for element
  do
    [[ "${element}" == "${match}" ]] && echo "${element} == ${match}" && return 0
  done
  return 1
}

previous=( "${values[*]}" )
steps=1
while [ 1 ]
do
  # if [ ${steps} -ge 7 ] # DEBUG INPUT ONLY
  # then
  #   echo "You fucked up"
  #   exit 1
  # fi
  # echo "Grid BEFORE update #${steps}"
  # for i in "${values[@]}"
  # do
  #   echo "${i}"
  # done
  update
  #echo "Grid AFTER update #${steps}"
  #for i in "${grid[@]}"
  #do
  #  echo "${i}"
  #done
  #echo "==========================="
  if [ "${values[*]}" == "${grid[*]}" ]
  then
    only_octothorpes="${values[*]//[!#]/}"
    num_octothorpes=$(( ${#only_octothorpes} - ( ${#values[@]} - 1 ) )) # sets of # separated by ' ', so subtract number of lines minus 1
    echo "No change after step ${steps}. Number of occupied seats: ${num_octothorpes}"
    break
  fi
  values=( "${grid[@]}" )
  steps=$(( ${steps} + 1 ))
  if is_contained_by "${grid[*]}" "${previous[@]}"
  then
    echo "You've looped."
    exit 1
  fi
  previous+=( "${grid[*]}" )
done
