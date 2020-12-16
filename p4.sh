#!/usr/bin/env bash
set -e

# standard read the file
INPUT=${0%sh}input
echo "Input file: ${INPUT}"

set +e
OLDIFS=$IFS; IFS=$'\n' read -d '' -r -a values<${INPUT}; IFS=$OLDIFS
set -e
length_input="${#values[@]}"
echo "Read ${length_input} lines of input."

# Start problem work here

# make a function to split up the input line
function tokenize () {
  echo "Got line: ${1}"
  OLDIFS=$IFS; IFS=' '; read -ra TOKS <<< "${1}"; IFS=$OLDIFS
  echo "Tokenized line: '${TOKS[*]}'"
  OLDIFS=$IFS; IFS='-'; read -ra RANGE <<< "${TOKS[0]}"; IFS=$OLDIFS
  echo "Established range: '${RANGE[*]}'"
  first=$(( ${RANGE[0]} - 1 ))
  second=$(( ${RANGE[1]} - 1 ))
  char=${TOKS[1]::-1}
  pass=${TOKS[2]}
}

count=0
for (( i=0; i<${length_input}; i++))
do
  tokenize "${values[${i}]}"
  echo "Tokenized string '${values[${i}]}' to '${first}', '${second}', '${char}', '${pass}'"
  if [[ "${pass:${first}:1}" == "${char}" ]] && [[ "${pass:${second}:1}" != "${char}" ]];
  then
    echo "${pass} is VALID: it has char ${char} at pos ${first} and not pos ${second}"
    count=$(( 1 + ${count} ))
  elif [[ "${pass:${first}:1}" != "${char}" ]] && [[ "${pass:${second}:1}" == "${char}" ]];
  then
    echo "${pass} is VALID: does not have char ${char} at pos ${first} but does at pos ${second}"
    count=$(( 1 + ${count} ))
  else
    echo "${pass} is INVALID: it does not have char ${char} at pos ${first} or at pos ${second} OR"
    echo "${pass} does have char ${char} at pos ${first} AND at pos ${second}"
  fi
done
echo "Total good passwords: ${count}"
