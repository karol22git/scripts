#!/bin/bash
directory="counter.txt"

if [[ ! -f "$directory" ]]; then 
    echo "0" > "$directory"
fi
read -r key
case "$key" in
    "?")
        counter=$(< "$directory")
        echo "$counter"
        ;;
    "INC")
        counter=$(< "$directory")
        ((counter++))
        echo "$counter" > "$directory"
        ;;
    *)
        ;;
esac


#directory="counter.txt"
#
#
##read key
#if [[ ! -f "$directory" ]]; then 
#    echo "0" > "counter.txt"
#fi
#while read -r key; do
#    case "$key" in
#        "?")
#            counter=$(< "$directory")
#            echo "$counter"
#            ;;
#        "INC")
#            counter=$(< "$directory")
#            ((counter++))
#            echo "$counter" > "$directory"
#            ;;
#
#        *)
#        echo "$key"
#            ;;
#    esac
#done
#-r znaki ucieczki
#if [[ "$key" == "?" ]]; then
#    counter=$(< "$directory")
#    echo "$counter"
#elif [[ "$key" == "INC" ]]; then
#    counter=$(< "$directory")
#    ((counter++))
#    echo "$counter" > "$directory"
#fi