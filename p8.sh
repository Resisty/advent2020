#!/usr/bin/env bash

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

total=0
for entry in "${sections[@]}"
do
  OLDIFS=$IFS; IFS=' '; read -ra fields <<< "${entry}"; IFS=$OLDIFS
  required_fields=0
  for field in "${fields[@]}"
  do
    present=0
    failed=
    OLDIFS=$IFS; IFS=':'; read -ra tokens <<< "${field}"; IFS=$OLDIFS
    case "${tokens[0]}" in
      byr)
        if [ "${tokens[1]}" -lt 1920 ] || [ "${tokens[1]}" -gt 2002 ]
        then
          echo "Invalid birth year: ${field} ([1920-2002])"
          continue 2
        fi
        ;;
      iyr)
        if [ "${tokens[1]}" -lt 2010 ] || [ "${tokens[1]}" -gt 2020 ]
        then
          echo "Invalid issue year: ${field} ([2010-2020])"
          continue 2
        fi
        ;;
      eyr)
        if [ "${tokens[1]}" -lt 2020 ] || [ "${tokens[1]}" -gt 2030 ]
        then
          echo "Invalid expiration year: ${field} ([2020-2030])"
          continue 2
        fi
        ;;
      hgt)
        magnitude="${tokens[1]%??}"
        unit="${tokens[1]: -2}"
        if [ "${unit}" == "cm" ]
        then
          if [ "${magnitude}" -lt 150 ] || [  "${magnitude}" -gt 193 ]
          then
            echo "Invalid height: ${field} ([150-193]cm)"
            continue 2
          fi
        elif [ "${unit}" == "in" ]
        then
          if [ "${magnitude}" -lt 59 ] || [ "${magnitude}" -gt 76 ]
          then
            echo "Invalid height: ${field} ([59-76])in"
            continue 2
          fi
        else 
          echo "Invalid height: ${field} (invalid unit)"
          continue 2
        fi
        ;;
      hcl)
        if [[ ! "${tokens[1]}" =~ [#][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9] ]] || [ "${#tokens[1]}" -gt 7 ]
        then
          echo "Invalid hair color: ${field} (#[a-f0-9]{6})"
          continue 2
        fi
        ;;
      ecl)
        valid_colors=(amb blu brn gry grn hzl oth)
        if [[ ! "${valid_colors[@]}" =~ "${tokens[1]}" ]]
        then
          echo "Invalid eye color: ${field} (${valid_colors[*]})"
          continue 2
        fi
        ;;
      pid)
        if [[ ! "${tokens[1]}" =~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] || [ "${#tokens[1]}" -gt 9 ]
        then
          echo "Invalid passport id: "${field}" (9-digit number)"
          continue 2
        fi
        ;;
      cid)
        continue
        ;;
    esac
    required_fields=$((${required_fields} + 1))
  done
  if [ ${required_fields} -lt 7 ]
  then
    echo "Entry '${entry}' is missing fields!"
  else
    echo "Entry '${entry}' appears valid!"
    total=$((${total} + 1))
  fi
done

echo "Total passports analyzed: ${num_entries}."
echo "Total VALID passports encountered: ${total}"
