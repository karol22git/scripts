#!/bin/bash
source utilities.sh
real_game_metadata="REAL_GAME_METADATA"
handler_name="communication_handler.sh"
MAX_PLAYERS=2
setup_server() {
    server_port=$1
    set_croupier "$$"
    init_game
    set_game_pid "$$"
    generate_deck
    set_game_status_zero
    set_maximum_players "$MAX_PLAYERS"
    set_current_players "1"
    append_to_block "players" "$$"
    socat TCP-LISTEN:"$server_port",reuseaddr,fork SYSTEM:"bash $handler_name $server_port" &
    socat_pid=$!
}

cleanup() {
    if [[ -f "$real_game_metadata" ]]; then
        cp "$real_game_metadata" memory_dumb
    fi
    rm -f deck.txt
    rm -f "$real_game_metadata"
    kill $socat_pid 2>/dev/null
    exit 0
}
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <port>"
    exit 1
fi

setup_server "$1"
trap cleanup EXIT INT TERM
wait $socat_pid