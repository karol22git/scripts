#!/bin/bash
# Karol Melanczuk
# Pracownia Jezykow Skrptyowych 2025/2026
player_up="🟪🟪🟪"
player_middle="🟪🟪🟪"
player_down="🟪🟪🟪"
counter=0
SCREEN_WIDTH=50
SCREEN_HEIGHT=20
print_at() {
    local line=$1
    local column=$2
    #local char=$3
    char="$3"
    printf "\033[${line};${column}H${char}"
}
print_player() {
    a=$((SCREEN_HEIGHT-1))
    b=$((SCREEN_HEIGHT-2))
    print_at "$SCREEN_HEIGHT" "$counter" "$player_down"
    print_at "$b" "$counter" "$player_middle"
    print_at "$a" "$counter" "$player_up"
}
while [ true ]
do
read -r -s -n 3 key
#read key
clear
if [[ "$key" == " " ]]; then
    echo "mam"
elif [[ "$key" == $'\x1b[A' ]];then #gora
    echo "mam"
elif [[ "$key" == $'\x1b[B' ]]; then #dol
    echo "mam"
elif [[ "$key" == $'\x1b[D' ]];then #lewo
    if [[ "$counter" -ne 0 ]]; then
        counter=$((counter-3)) 
    fi
elif [[ "$key" == $'\x1b[C' ]]; then #prawo
    counter=$((counter+3)) 
fi
#printf "\033[${counter}G${player}"
print_player
#print_at "$SCREEN_HEIGHT" "$counter" "$player"
#echo "$counter"
done