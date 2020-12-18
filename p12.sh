#!/usr/bin/env bash
set -e

# Figure out what file to read
INPUT=${0%sh}input
echo "Input file: ${INPUT}"


# This file is fucked, so don't just read lines
# Read into REPLY
# if it's a newline, close out the current section and
#     append it to the sections
# otherwise check if a section is in progress
#     if not, start one, otherwise append after a space
sections=( )
current_section=
while REPLY=; read -r || [[ ${REPLY} ]]; do
  if [[ ${REPLY} ]];
  then
    if [[ ${current_section} ]];
    then
      current_section+=" ${REPLY}"
    else
      current_section+="${REPLY}"
    fi
  else
    sections+=( "${current_section}" )
    current_section=
  fi
done <"${INPUT}"
if [[ ${current_section} ]]
then
  # we reached the end of the file without appending and clearing
  sections+=( "${current_section}" ) 
fi
num_entries="${#sections[@]}"
echo "Read ${num_entries} groups' answers."

count=0
total=0
for group in "${sections[@]}"
do
  array_group=(${group})
  people_in_group="${#array_group[@]}"
  declare -A answers
  for i in $(seq 0 $(( ${#group} - 1)))
  do
    if [ "${group:${i}:1}" == ' ' ]
    then
      continue
    fi
    answers["${group:${i}:1}"]=$(( 1 + answers["${group:${i}:1}"] ))
  done
  for key in "${!answers[@]}"
  do
    if [ "${answers[${key}]}" -eq ${people_in_group} ]
    then
      total=$(( ${total} + 1 ))
    fi
  done
  unset answers
done

echo "Total number of questions to which everyone answered 'yes' in their group: ${total}"
