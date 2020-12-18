#!/usr/bin/env bash

INPUT=${0%sh}input

IFS=$'\n' read -d'' -r -a values<${INPUT}
sgb='shiny gold bag'
length_input="${#values[@]}"

function strip_bag_chars() {
  if [ ' ' == "${num_type_bags:0:1}" ]
  then
    num_type_bags="${num_type_bags:1}"
  fi
  if [ '.' == "${num_type_bags: -1}" ]
  then
    num_type_bags="${num_type_bags:: -1}"
  fi
  if [ 's' == "${num_type_bags: -1}" ]
  then
    num_type_bags="${num_type_bags:: -1}"
  fi
}

search_list=( "${sgb}" )
count=0
while [ 1 ]
do
  for search in "${!search_list[@]}"
  do
    search_pattern="${search_list[${search}]}"
    for value in "${values[@]}"
    do
      bag_type="${value%%' contain'*}"
      bag_type="${bag_type:: -1}" # drop the plural
      if [[ "${bag_type}" =~ "${search_pattern}" ]]
      then
        contained_bags="${value#*'contain '*}"
        readarray -td, contain_toks <<<"${contained_bags},"; unset 'contain_toks[-1]'
        for tok in "${!contain_toks[@]}"
        do
          num_type_bags="${contain_toks[${tok}]}"
          strip_bag_chars
          num="${num_type_bags%%' '*}"
          next_bag_type="${num_type_bags#*' '*}"
          count=$(( ${count} + "${num}" ))
          for i in $( seq 0 $(( ${num} - 1 )) )
          do
            search_list+=( "${next_bag_type}" )
          done
          # echo "Given '${value}':"
          # echo "Adding ${num} to bags total and adding ${next_bag_type} to search"
        done
      fi
    done
    unset 'search_list[search]'
  done
  if [[ ! "${search_list[@]}" ]]
  then
    break
  fi
done
echo "Counted "${count}" different bag colors would be valid for outermost bag"
