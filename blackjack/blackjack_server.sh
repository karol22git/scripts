#!/bin/bash
pid_file="game_metadata"
game_status="game_status"
players="players"
max_players=3
game_metadata="game_metadata"
start_game="start_game"
croupier_hand="croupier_hand"
handler_name="communication_handler.sh"
setup_server() {
    server_port=$1
    echo $$ > "$pid_file"
    socat TCP-LISTEN:"$server_port",reuseaddr,fork SYSTEM:"bash $handler_name $server_port" &
    socat_pid=$!
}

cleanup() {
    kill $socat_pid 2>/dev/null
    pkill -f "$handler_name" 2>/dev/null
    rm -f "$pid_file"
    while read -r f; do rm -f "$f"; done < "$players"
    rm -f "$players"
    rm -f "$game_status"
    rm -f "$start_game"
    rm -f "$croupier_hand"
    exit 0
}
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <port>"
    exit 1
fi

setup_server "$1"
trap cleanup EXIT INT TERM
wait $socat_pid