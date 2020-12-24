#!/usr/bin/env bash

DEBUG=
INPUT=${0%sh}input
OLDIFS=$IFS; IFS='\n' readarray -t values<${INPUT}; IFS=$OLDIFS

earliest="${values[0]}"
bus_order="${values[1]}"
OLDIFS=$IFS; IFS=',' read -ra bus_order_arr<<<${bus_order}; IFS=$OLDIFS

function debug () {
  if [ -n "${DEBUG}" ]
  then
    echo "$1"
  fi
}
# remove 'x' values and create key:value pairs of index:bus_id
bus_ids=( )
b_i=( )
big_N=1
for i in $( seq 0 $(( ${#bus_order_arr[@]} - 1 )) )
do
  if [ 'x' == "${bus_order_arr[${i}]}" ]
  then
    continue
  fi
  bus_id=${bus_order_arr[${i}]}
  bus_ids+=( ${bus_id} )
  b_i+=( $(( ( ${bus_id} - ${i} ) % ${bus_id} )) )
  big_N=$(( ${big_N} * ${bus_id} ))
done

big_N_i=( )
for i in $( seq 0 $(( ${#bus_ids[@]} - 1 )) )
do
  big_N_i+=( $(( ${big_N} / ${bus_ids[${i}]} )) )
done

x_i=( )
for i in $( seq 0 $(( ${#bus_ids[@]} - 1 )) )
do
  mod=$(( ${big_N_i[${i}]} % ${bus_ids[${i}]} ))
  if [ ${mod} -eq 1 ]
  then
    x_i+=( 1 )
  else
    mult=2
    while [ $(( ( ${mod} * ${mult} ) % ${bus_ids[${i}]} )) -ne 1 ]
    do
      mult=$(( ${mult} + 1 ))
    done
    x_i+=( ${mult} )
  fi
done

bi_ni_xi=0
for i in $( seq 0 $(( ${#bus_ids[@]} - 1 )) )
do
  bi_ni_xi=$(( ${bi_ni_xi} + ( ${b_i[${i}]} * ${big_N_i[${i}]} * ${x_i[${i}]} ) ))
done
echo "$(( ${bi_ni_xi} % ${big_N} ))"
