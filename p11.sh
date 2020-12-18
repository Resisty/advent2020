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
#     if not, start one, otherwise append
sections=( )
current_section=
while REPLY=; read -r || [[ ${REPLY} ]]; do
  if [[ ${REPLY} ]];
  then
    current_section+="${REPLY}"
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
  declare -A answers
  for i in $(seq 0 $(( ${#group} - 1)))
  do
    answers["${group:${i}:1}"]=1
  done
  # echo "Answers of group ${count}:"
  # declare -p answers
  total=$(( ${total} + ${#answers[@]} ))
  count=$(( ${count} + 1 ))
  unset answers
done

echo "Total 'yes' answers across groups: ${total}"
