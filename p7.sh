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
#     if not, start one, otherwise append behind a space
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
echo "Read ${num_entries} passports and/or credentials."

required_fields=(byr iyr eyr hgt hcl ecl pid)
total=0
for entry in "${sections[@]}"
do
  failed=
  for field in "${required_fields[@]}"
  do
    if [[ ! "${entry}" =~ "${field}" ]]
    then
      # echo "Passport/credentials '${entry}' failed to match required field '${field}'"
      failed='y'
    fi
  done
  if [ -z "${failed}" ]
  then
    # echo "Passport/credentials '${entry}' appears valid!"
    total=$((${total} + 1))
  fi
done

echo "Total valid passports encountered: ${total}"
