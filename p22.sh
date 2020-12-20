#!/usr/bin/env bash

DEBUG=
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

y_length="${#values[@]}"
x_length="${#values[0]}"

function debug () {
  if [ -n "${DEBUG}" ]
  then
    echo "$1"
  fi
}

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
  local x_pos x_offset y_pos y_offset
  y_pos=$1
  x_pos=$2
  y_offset=${3:-0}
  x_offset=${4:-0}
  x_pos=$(( $x_pos + $x_offset ))
  y_pos=$(( $y_pos + $y_offset ))
  if [ ${y_pos} -lt 0 ] || [ ${y_pos} -ge ${y_length} ] || [ ${x_pos} -lt 0 ] || [ ${x_pos} -ge ${x_length} ]
  then
    # checking a space off the grid
    return 1
  fi
  row="${values[${y_pos}]}"
  char="${row:${x_pos}:1}"
  if [ "${char}" == 'L' ]
  then
    # not occupado
    debug "Cell at  ${y_pos},${x_pos} looking in ${y_offset},${x_offset} direction is NOT OCCUPIED (${char})."
    return 1
  elif [ "${char}" == '#' ]
  then
    # occupadaddo
    debug "Cell at  ${y_pos},${x_pos} looking in ${y_offset},${x_offset} direction is OCCUPIED (${char})."
    return 0
  elif [ "${char}" == '.' ]
  then
    if [[ ${y_offset: -1:1} -eq 0 ]] && [[ ${x_offset: -1:1} -eq 0 ]]
    then
      # don't recurse infinitely when directly checking occupation of a floor space
      debug "Position ${y_pos},${x_pos} is a floor space but we're looking in ${y_offset},${x_offset} direction. Do not recurse"
      return 1
    fi
    debug "Cell at  ${y_pos},${x_pos} looking in ${y_offset},${x_offset} direction is a floor space. Recurse."
    occupied_at $y_pos $x_pos $y_offset $x_offset
  fi
}

function check_grid () {
  local x_pos y_pos
  y_pos=$1
  x_pos=$2
  num_neighbors=0
  # up left
  debug "Check up and left (-1,-1) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "-1" "-1"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # up
  debug "Check up from (-1,0) ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "-1" "0"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # up right
  debug "Check up and right (-1,+1) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "-1" "+1"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # left
  debug "Check left (0,-1) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "0" "-1"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # right
  debug "Check right (0, +1) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "0" "+1"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # down left
  debug "Check down and left (+1, -1) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "+1" "-1"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # down 
  debug "Check down (+1,0) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "+1" "0"
  then
    num_neighbors=$(( ${num_neighbors} + 1 ))
  fi
  # down right 
  debug "Check down and right (+1,+1) from ${y_pos},${x_pos}"
  if occupied_at ${y_pos} ${x_pos} "+1" "+1"
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
      debug "Check position ${i},${j}..."
      check_grid ${i} ${j}
      if [ "$( char_at ${i} ${j} )" == '.' ]
      then
        debug "Position ${i},${j} ( $(char_at ${i} ${j}) ) is floor"
        line="${line}."
      elif ! occupied_at ${i} ${j} && [ ${num_neighbors} -eq 0 ]
      then
        debug "Position ${i},${j} ( $(char_at ${i} ${j}) ) not occupied and 0 neighbors"
        line="${line}#"
      elif ! occupied_at ${i} ${j}
      then
        debug "Position ${i},${j} ( $(char_at ${i} ${j}) ) not occupied but 1 or more neighbors"
        line="${line}L"
      elif occupied_at ${i} ${j} && [ ${num_neighbors} -ge 5 ]
      then
        debug "Position ${i},${j} ( $(char_at ${i} ${j}) ) is occupied and has 5 or more neighbors"
        line="${line}L"
      elif occupied_at ${i} ${j}
      then
        debug "Position ${i},${j} ( $(char_at ${i} ${j}) ) is occupied with fewer than 5 neighbors"
        line="${line}#"
      fi
      debug "After checking position ${i},${j} line is now: ${line}"
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
  # if [ ${steps} -ge 8 ] # DEBUG INPUT ONLY
  # then
  #   echo "You fucked up"
  #   exit 1
  # fi
  debug "Grid BEFORE update #${steps}"
  for i in "${values[@]}"
  do
    debug "${i}"
  done
  update
  debug "Grid AFTER update #${steps}"
  for i in "${grid[@]}"
  do
    debug "${i}"
  done
  debug "==========================="
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
