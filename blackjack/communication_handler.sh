game_status="game_status"
players="players"
max_players=3
game_metadata="game_metadata"
start_game="start_game"
croupier_hand="croupier_hand"
log() {
    echo "[LOG]: $1" >&2
}
get_id() {
    msg=$1
    if [[ $msg =~ \|(.*)\| ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}
generate_deck() {
    > deck.txt
    values="2 3 4 5 6 7 8 9 10 10 10 10 11"
    for i in {1..4}; do
        for v in $values; do
            echo "$v" >> deck.txt
        done
    done
}
sum_hand() {
    total=0
    while read -r line; do
        (( total += line ))
    done < "$1"
    echo "$total"
}

draw_card() {
    deck=($(cat deck.txt))
    rand_index=$((RANDOM % ${#deck[@]}))
    card=${deck[$rand_index]}
    #echo "Wylosowana karta: $card"
    unset 'deck[rand_index]'
    deck=("${deck[@]}")
    printf "%s\n" "${deck[@]}" > deck.txt
    echo "$card"
}
add_player() {
    player=$1
    echo "$player" >> $players
}
remove_player() {
    player=$1
    grep -v "^$player$" $players > tmp.txt
    mv tmp.txt $players
}

croupier_move() {
    croupier=$(cat $game_metadata)
    hand=$(sum_hand $croupier)
    if [[ $hand -lt 17 ]]; then
        card=$(draw_card)
        echo "|$card|" >> $croupier_hand
        echo "$card" >> $croupier
    fi
    next_turn
}
current_player() {
    head -n 1 $players
}
next_turn() {
    first=$(head -n 1 $players)
    tail -n +2 $players > tmp.txt
    echo "$first" >> tmp.txt
    mv tmp.txt $players
    croupier=$(cat $game_metadata)
    cp=$(current_player)
    if [[ $cp -eq $croupier ]]; then
        croupier_move
    fi
}

get_status() {
    cat $game_status
}
inc_status() {
    count=$(cat $game_status)
    echo $((count + 1)) > $game_status
}


proceed_new_player() {
    if [[ ! -e "$game_status" ]]; then
        echo 1 > $game_status
        croupier=$(cat $game_metadata)
        add_player "$croupier"
        echo "0" > $start_game
        generate_deck
        card1=$(draw_card)
        card2=$(draw_card)
        echo $card1 >> "$croupier"
        echo "$card2" >> "$croupier"
        echo "|$card1|" >> "$croupier_hand"
        echo "1"
    else
        num_of_players=$(get_status)
        if [[ num_of_players -le $max_players ]]; then
            inc_status 
            echo "1"
        else 
            echo "0"
        fi
    fi
}
get_status() {
    cat $game_status
}

end_game() {
    rm -f "$game_status"
}
proceed_turn_query() {
    id=$(get_id "$1")
    cp=$(current_player)
    status=$(get_status)
    isOn=$(cat $start_game)
    if [[ $isOn -eq 0 ]]; then
    #if [[ $status -lt $max_players ]]; then
        echo "2"
    elif [[ $id -ne $cp ]]; then
        echo "0"
    else 
        content=$(tr -d '\n' < $croupier_hand)
        cHand=$(sum_hand $(cat $game_metadata))
        echo >2 $cHand
        if [[ $cHand -ge 21 ]]; then
            echo "[WON] Croupier draw another card, and got hand equal $cHand. You won"
            remove_player "$id"
            next_turn
        else 
            echo "$content"
        fi
          #  echo "1"
    fi
}
dec_status() {
    count=$(cat "$game_status")
    if (( count > 0 )); then
        echo $((count - 1)) > "$game_status"
    else
        rm -f "$game_status"
        rm -f "$players"
    fi
}

proceed_surrender() {
    id=$(get_id "$1")
    remove_player "$id"
    dec_status
}

is_his_tourn() {
    he=$1
    cp=$(current_player)
    if [[ $he -eq $cp ]]; then
        echo "1"
    else
        echo "0"
    fi
}
proceed_stand() {
    key=$1
    id=$(get_id "$key")
    r=$(is_his_tourn "$id")
    if [[ $r -eq 1 ]]; then
        next_turn
        echo "1"
    else 
        echo "0"
    fi
}
start_game() {
    echo "1" > "$start_game"
    croupier_move
}
look_for_start() {
    num_of_players=$(get_status)
    if [[ $num_of_players -eq $max_players ]]; then
        start_game
    fi
}
proceed_join() {
    key=$1
    r=$(proceed_new_player)
    if [[ $r -eq "1" ]]; then
        id=$(get_id "$key")
        add_player "$id"
        card1=$(draw_card)
        card2=$(draw_card)
        echo "$card1" >> "$id"
        echo "$card2" >> "$id"
        look_for_start
        echo "|$card1||$card2|"
    else 
        echo "0"
    fi 
}
proceed_hit() {
    key=$1
    id=$(get_id "$key")
    r=$(is_his_tourn "$id")
    if [[ $r -eq 1 ]]; then
        card=$(draw_card)
        echo "$card" >> "$id"
        hand=$(sum_hand "$id")
        if [[ $hand -gt 21 ]]; then
            echo "[LOSE] You draw $card, and now Your hand is $hand. You lose."
            remove_player "$id"
        else
            echo "[CARD] You draw $card. Now Yoyr hand is $hand."
        fi
        next_turn
    else 
        echo "0"
    fi
}
parse_command() {
    key=$1
    if [[ $key == *"HIT"* ]]; then
        proceed_hit "$key"
    elif [[ $key == *"JOIN"* ]]; then
        proceed_join "$key"
    elif [[ $key == *"STAND"* ]]; then
        proceed_stand "$key"
    elif [[ $key == *"SPLIT"* ]]; then
        echo "error"
        #echo $(generate_split_message)
    elif [[ $key == *"DOUBLEDOWN"* ]]; then
        proceed_hit "$key"
    elif [[ $key == *"SURRENDER"* ]]; then
        proceed_surrender "$key"
    elif [[ $key == *"TURN"* ]]; then
        proceed_turn_query "$key"
    else
        echo "error"
    fi
}
read -r key
log "$key"
parse_command "$key"