#!/bin/bash
# Karol Melanczuk
# Pracownia Jezykow Skrptyowych 2025/2026

#while getopts "abcdefghijklmnopqrstuvwxyz" next_arg 
#do
#    if [[ "$next_arg" == "q" ]]; then
#        echo "$next_arg"
#        echo "error"
#    fi
#done
getopts "q:abcdefghijklmnoprstuvwxyz" next_arg
echo "$next_arg"
#getopts "qabcdefghijklmnoprstuvwxyz" next_arg 
#echo "$next_arg"