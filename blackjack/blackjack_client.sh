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
    read tmp
}
cmd=$(generate_join_message)
response=$(echo "$cmd" | nc "$server_host" "$server_port")
if [[ $response == "0" ]]; then
    #echo "tt $response"
    echo "Sorry, you can not join table right now. Try later."
    exit 0
fi
hand="$response"
croupier_hand="Croupier hand currently unknown."
tag="\033[33mLoading data...\033[0m"
trap cleanup EXIT INT TERM
while [[ true ]]; do
    echo -e "$tag"
    if [[ $hand != "" ]]; then
        echo "Your hand: $hand"
    fi
    echo $croupier_hand
    print_moves
    if read -t 5 key; then
        cmd=$(parse_command "$key")
        if [[ $cmd == "error" ]]; then
            echo "you entered unavalible message. Try again."
            wait_for_commit
            continue
        elif [[ $cmd == *"SURRENDER"* ]]; then
            break
        else
            response=$(echo "$cmd" | nc "$server_host" "$server_port")
            if [[ $response == "0" ]]; then
                echo -e "\e[31mNot your turn.\e[0m"
            elif [[ $response == *"LOSE"* ]]; then
                echo "$response"
                exit
            elif [[  $response == *"CARD"* ]]; then
                hand="$hand+|$(get_card $response)|"
            fi
        fi
    else 
        clear
        msg=$(generate_turn_message)
        turn=$(echo "$msg" | nc  "$server_host" "$server_port")
        if [[ $turn == "0" ]];then
            tag="\e[31mNot your turn.\e[0m"
        elif [[  $turn == "2" ]]; then
            tag="\033[33mWaiting for players to join the game...\033[0m"
        else 
            if [[  $turn == *"WON"* ]]; then
                echo $turn
                exit
            fi
            tag="\e[32mYour turn!\e[0m"
            croupier_hand="Current croupier hand: $turn"
        fi
    fi
done

