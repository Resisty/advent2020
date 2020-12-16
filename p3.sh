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
  min=${RANGE[0]}
  max=${RANGE[1]}
  char=${TOKS[1]::-1}
  pass=${TOKS[2]}
}
count=0
for (( i=0; i<${length_input}; i++))
do
  tokenize "${values[${i}]}"
  echo "Tokenized string '${values[${i}]}' to '${min}', '${max}', '${char}', '${pass}'"
  mod_pass="${pass//[!${char}]/}"
  if [[ ${#mod_pass} -ge ${min} ]] && [[ ${#mod_pass} -le ${max} ]];
  then
    echo "${pass} has between ${min} and ${max} of character ${char}: ${#mod_pass} (counted from ${mod_pass})"
    count=$(expr 1 + ${count})
  else
    echo "${pass} does NOT HAVE between ${min} and ${max} of character ${char}"
  fi
done
echo "Total good passwords: ${count}"
