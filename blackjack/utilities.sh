real_game_metadata="REAL_GAME_METADATA"
croupier_id="stachu"
set_croupier() {
    croupier_id=$1
}
generate_deck() {
    > deck.txt
    bj_values="2 3 4 5 6 7 8 9 10 10 10 10 11"
    face_values="2 3 4 5 6 7 8 9 10 J Q K A"
    colors="♥ ♦ ♣ ♠"
    i=1
    for color in $colors; do
        idx=1
        for bj in $bj_values; do
            fv=$(echo $face_values | cut -d " " -f $idx)
            echo "${color}${fv}(${bj})" >> deck.txt
            idx=$((idx + 1))
        done
    done
}

sum_hand() {
    local hand="$1"
    local sum=0

    for card in $hand; do
        value=$(echo "$card" | sed -n 's/.*(\([0-9]\+\)).*/\1/p')
        sum=$((sum + value))
    done

    echo "$sum"
}
draw_card() {
    deck=($(cat deck.txt))
    rand_index=$((RANDOM % ${#deck[@]}))
    card=${deck[$rand_index]}
    unset 'deck[rand_index]'
    deck=("${deck[@]}")
    printf "%s\n" "${deck[@]}" > deck.txt
    echo "$card"
}
block_to_array() {
    label=$1
    mapfile -t result < <(
        sed -n "/^$label: {/,/^}/p" "$real_game_metadata" | sed '1d;$d'
    )
}
add_block() {
    label=$1
    shift
    {
        echo "$label: {"
        if [ $# -gt 0 ]; then
            for line in "$@"; do
                echo "$line"
            done
        fi
        echo "}"
    } >> "$real_game_metadata"
}
get_block() {
    local label="$1"
    sed -n "/^$label: {/,/^}/p" "$real_game_metadata"
}
delete_block() {
    local label="$1"
    sed -i "/^$label: {/,/^}/d" "$real_game_metadata"
}
set_block() {
    local label="$1"
    shift
    local content="$*"
    delete_block "$label"
    add_block "$label" "$content"
}
append_to_block() {
    label=$1
    shift
    sed -i "/^$label: {/,/^}/ {/^}/ i\\
$*
}" "$real_game_metadata"
}

get_first_record_from_block() {
    label=$1
    sed -n "/^$label: {/,/^}/p" "$real_game_metadata" | sed '1d;$d' | head -n1
}
rotate_block() {
    label=$1
    block=$(sed -n "/^$label: {/,/^}/p" "$real_game_metadata" | sed '1d;$d')

    [ -z "$block" ] && return
    first=$(echo "$block" | head -n1)
    rest=$(echo "$block" | tail -n +2)

    sed -i "/^$label: {/,/^}/d" "$real_game_metadata"

    {
        echo "$label: {"
        [ -n "$rest" ] && echo "$rest"
        echo "$first"
        echo "}"
    } >> "$real_game_metadata"
}

remove_record_from_block() {
    label=$1
    record=$2

    sed -i "/^$label: {/,/^}/ { /^$record$/d }" "$real_game_metadata"
}

get_record_from_block() {
    label=$1
    pattern=$2

    sed -n "/^$label: {/,/^}/ { /$pattern/p }" "$real_game_metadata"
}

get_value_from_block() {
    local label="$1"
    sed -n "/^$label: {/,/^}/ {
        s/[[:space:]]*//g  # usuń białe znaki
        /^[0-9][0-9]*$/p  # szukaj tylko liczb
    }" "$real_game_metadata"
}
get_number_of_players() {
    echo $(get_value_from_block "number_of_players")
}
get_maximum_number_of_players() {
    echo $(get_value_from_block "ma")
}
get_players_limit() {
    echo $(get_value_from_block "maximum_players")
}
get_players_cards() {
    local player_id="$1"
    local players_cards_unformatted=$(get_record_from_block "players_cards" "^$player_id:")
    
    if [ -n "$players_cards_unformatted" ]; then
        echo "${players_cards_unformatted#*: }"
    else
        echo ""
    fi
}

add_new_player() {
    append_to_block "players" "$1"
    old_num_of_players=$(get_number_of_players)
    new_num_of_players=$(($old_num_of_players + 1))
    set_block "number_of_players" "$new_num_of_players"
}

delete_player() {
    remove_record_from_block "players" "$1"
    old_num_of_players=$(get_number_of_players)
    new_num_of_players=$(($old_num_of_players -1))
    set_block "number_of_players" "$new_num_of_players"
}
set_game_pid() {
    set_block "game_pid" "$1"
}

run_game() {
    set_block "is_game_running" "1"
    set_block "game_status" "1"
    next_turn
}
init_game() {
    add_block "game_pid"
    add_block "players"
    add_block "players_cards"
    add_block "game_status"
    add_block "number_of_players"
    add_block "maximum_players"
    add_block "is_game_running"
    add_block "current_stake"
    add_block "players_wallets"
}
init_hands() {
    block_to_array "players"
    for item in "${result[@]}"; do 
        card2=$(draw_card)
        card1=$(draw_card)
        append_to_block "players_cards" "$item: $card1 $card2"
    done
}

draw_one_card_for_player() {
    id=$1
    last_hand=$(get_record_from_block "players_cards" "$id")
    new_card=$(draw_card)
    new_hand="$last_hand $new_card" 
    remove_record_from_block "players_cards" "$last_hand"
    append_to_block "players_cards" "$new_hand"
}
next_turn() {
    rotate_block "players"
}
set_game_pid () {
    set_block "game_pid" "$1"
}
get_current_player() {
    echo $(get_first_record_from_block "players")
}
is_game_on() {
    r=$(get_value_from_block "is_game_running")
    echo "$r"
}
set_game_status_zero() {
    set_block "game_status" "0"
    set_block "is_game_running" "0"
}

get_game_status() {
    local r=$(get_value_from_block "is_game_running")
    echo "$r"
}

set_maximum_players() {
    set_block "maximum_players" "$1"
}

set_current_players() {
    set_block "number_of_players" "$1"
}

get_game_pid() {
    r=$(get_value_from_block "game_pid")
    echo "$r"
}

get_croupier_id() {
    echo $(get_game_pid)
}
get_croupier_visible_cards() {
    local croupier_id=$(get_value_from_block "game_pid")
    local all_cards=$(get_players_cards "$croupier_id")
    
    if [ -n "$all_cards" ]; then
        cards_array=($all_cards)
        if [ ${#cards_array[@]} -gt 1 ]; then
            visible="${cards_array[@]:1}"
            echo "$visible"
        else
            echo ""
        fi
    else
        echo ""
    fi
}