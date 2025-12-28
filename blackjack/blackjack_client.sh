server_host="localhost"
server_port=$1
me=$$
generate_surrender_message() {
    msg="[SURRENDER][AUTHOR:|$$|]"
    echo $msg
}
generate_hit_message() {
    msg="[HIT][AUTHOR:|$$|]"
    echo $msg
}
generate_split_message() {
    msg="[SPLIT][AUTHOR::|$$|]"
    echo $msg
}
generate_stand_message() {
    msg="[STAND][AUTHOR:|$$|]"
    echo $msg
}
generate_doubledown_message() {
    msg="[DOUBLEDOWN][AUTHOR:|$$|]"
    echo $msg
}
generate_join_message() {
    msg="[JOIN][AUTHOR:|$$|]"
    echo $msg
}
generate_turn_message() {
    msg="[TURN][AUTHOR:|$$|]"
    echo "$msg"
}
cleanup() {
    pass_msg=$(generate_surrender_message)
    echo "$pass_msg" | nc "$server_host" "$server_port"
    exit 0
}
print_moves() {
    echo "Select a command:
        HIT        - draw another card
        STAND      - stop and keep your current hand
        SPLIT      - if you have a pair, split into two hands
        DOUBLE DOWN- double your bet and receive one card
        SURRENDER  - give up and forfeit half your bet"
}
move_cursor_to_bottom() {
    printf "\033[4;1H"
}
move_cursor_to_user_input() {
    printf "\033[10;1H\033[2K"
}

clear_all_below() {
    printf "\033[10;1H\033[J"
}
print_my_cards() {
    printf "\033[3;1H\033[2K%s" "$1"

}
print_cropier_cards() {
    printf "\033[2;1H\033[2K%s" "$1"
}
print_tag() {
    printf "\033[1;1H\033[2K%b" "$1"
}
get_card() {
    msg=$1
    if [[ $msg =~ \|(.*)\| ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}
parse_command() {
    input=$1
    if [[ $input == *"HIT"* ]]; then
        echo $(generate_hit_message)
    elif [[ $input == *"STAND"* ]]; then
        echo $(generate_stand_message)
    elif [[ $input == *"SPLIT"* ]]; then
        echo $(generate_split_message)
    elif [[ $input == *"DOUBLEDOWN"* ]]; then
        echo $(generate_doubledown_message)
    elif [[ $input == *"SURRENDER"* ]]; then
        echo $(generate_surrender_message)
    else
        echo "error"
    fi
}
wait_for_commit() {
    echo "press any key to continue."
    read -t 0.5 tmp
    clear_all_below
    printf "\033[11;1H\033[2K"
    printf "\033[12;1H\033[2K"
    printf "\033[10;1H\033[2K"
}
cmd=$(generate_join_message)
response=$(echo "$cmd" | nc "$server_host" "$server_port")
if [[ $response == "[DECLINED]" ]]; then
    echo "Sorry, you can not join table right now. Try later."
    exit 0
fi
hand="Youre hand is currently unknown."
croupier_hand="Croupier hand currently unknown."
tag="\033[33mLoading data...\033[0m"
trap cleanup EXIT INT TERM
print_tag "$tag"
print_cropier_cards "$croupier_hand"
print_my_cards "$hand"
move_cursor_to_bottom
print_moves
while [[ true ]]; do
    print_tag "$tag"
    print_cropier_cards "$croupier_hand"
    print_my_cards "$hand"
    move_cursor_to_user_input
    if read -t 2 key; then
        cmd=$(parse_command "$key")
        if [[ $cmd == "error" ]]; then
            echo "you entered unavalible message. Try again."
            wait_for_commit
            continue
        elif [[ $cmd == *"SURRENDER"* ]]; then
            break
        else
            response=$(echo "$cmd" | nc "$server_host" "$server_port")
            if [[ $response == "[DECLINED]" ]]; then
                echo -e "\e[31mNot your turn.\e[0m"
                wait_for_commit
            elif [[ $response == *"LOSE"* ]]; then
                echo "$response"
                exit
            elif [[  $response == *"CARD"* ]]; then
                and="$hand|$(get_card $response)|"
            elif [[ $response == "[STAND_ACCEPTED]" ]]; then
                continue
            elif [[ "$response" == *"HIT_ACCEPT"* ]]; then
                newhand=$(echo "$turn" | cut -d':' -f2-)
                hand="Your hand: $newhand"
            elif [[ $response == *"WAITING"* ]]; then 
                echo -e "\033[33mWaiting for players...\033[0m"
                wait_for_commit
            fi
        fi
    else 
        msg=$(generate_turn_message)
        turn=$(echo "$msg" | nc  "$server_host" "$server_port")
        if [[ $turn == "[NOTYOURS]" ]];then
            tag="\e[31mNot your turn.\e[0m"
        elif [[  $turn == *"[WAITING]"* ]]; then
            tag="\033[33mWaiting for players to join the game...\033[0m"
        else 
            if [[  $turn == *"WON"* ]]; then
                echo $turn
                exit
            elif [[ $turn == *"LOST"* ]]; then
                echo $turn
                exit
            fi
            tag="\e[32mYour turn!\e[0m"
            new_croupier_hand=$(echo "$turn" | cut -d':' -f2)
            new_player_hand=$(echo "$turn" | cut -d':' -f3)

            croupier_hand="Current croupier hand: $new_croupier_hand"
            hand="Your hand: $new_player_hand"
        fi
    fi
done

