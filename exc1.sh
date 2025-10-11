#!/bin/bash
# Karol Melanczuk
# Pracownia Jezykow Skrptyowych 2025/2026
set -e
global_max=31
gloabl_min=0

format() {
    printf '%*s' $1
}

multiplication_table() {
    min=$1
    max=$2
    for ((i=min ; i<=max; i+=1))
    do
        printf "%4d" $i
    done
    printf "\n"
    for ((i=min; i<=max; i+=1))
    do
        printf "%4d" $i
        for ((j=min ; j<=max; j++))
        do
           printf "%4d" $((j * i))
        done
        printf "\n"
    done
}

if [ $# -eq 0 ] || [ $# -gt 2  ]; then
    exit 0
elif [ $# -eq 1 ]; then
    if [ $1 -gt $global_max ]; then
        exit 0
    fi
    min=1
    max=$1
else 
    if [ $1 -gt $2 ];then
        exit 0
    fi
    if [ $gloabl_min -ge $1 ] || [ $2 -gt $global_max ]; then
        exit 0
    fi
    min=$1
    max=$2
fi

format 4
multiplication_table $min $max