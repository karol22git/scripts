
if [[ "$1" == "test1" ]]; then
    server_host="localhost"
    server_port=$(lsof -i -P -n | grep "socat.*LISTEN" | awk '{print $9}' | cut -d: -f2)
    if [[ "$server_port" == "" ]]; then
        exit 0
    fi
    #socat - TCP:localhost:"$port"
    echo "?" | nc "$server_host" "$server_port"
    echo "INC" | nc "$server_host" "$server_port"
    echo "INC" | nc "$server_host" "$server_port"
    echo "?" | nc "$server_host" "$server_port"
    echo "INC"| nc "$server_host" "$server_port"
    echo "?" | nc "$server_host" "$server_port"

fi