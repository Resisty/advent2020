#!/usr/bin/env bash

INPUT=${0%sh}input

IFS=$'\n' read -d'' -r -a values<${INPUT}
swb='shiny gold bag'
count=0
length_input="${#values[@]}"

search_list=( "${swb}" )
declare -A found_list
while [ 1 ]
do
  for search in "${!search_list[@]}"
  do
    search_pattern="${search_list[${search}]}"
    for value in "${values[@]}"
    do
      bag_type="${value%%' contain'*}"
      bag_type="${bag_type:: -1}" # drop the plural
      contained_bags="${value#*'contain '*}"
      echo "Checking if '${bag_type}' which contains '${contained_bags}' could contain '${search_pattern}'"
      if [[ "${contained_bags}" =~ "${search_pattern}" ]]
      then
        echo "Yes, '${bag_type}' which contains '${contained_bags}' DOES contain '${search_pattern}'"
        found_list[${bag_type}]=1
        search_list+=( "${bag_type}" )
      fi
    done
    unset 'search_list[search]'
  done
  if [[ ! "${search_list[@]}" ]]
  then
    break
  fi
done
echo "Counted "${#found_list[@]}" different bag colors would be valid for outermost bag"
