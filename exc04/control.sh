directory="$HOME/.config/server.conf"
pid_file="pid.txt"
command="$1"
port=-1
if [[ "$command" == "start" ]]; then
    if pgrep -f "server.sh" > /dev/null; then
        echo "na razie server dziala"
        exit 0
    fi
    if [[ -n "$2" ]]; then
        #echo "$2"
        port="$2"
    #else
    #    port=$(< "$directory")
    #    if [[ "$port"=="" ]]; then
    #        port=6789
    #    fi
    fi

    #condition=$(lsof -i :"$port")
    #if [[ "$condition" != "" ]]; then
    #    echo "Port $port is unavailable"
    #    exit 0
    #fi
    ./server.sh -p "$port" &
elif [[ "$command" == "stop" ]]; then
    #pid=$(pgrep -f "socat TCP-LISTEN")
    if [[ -f "$pid_file" ]]; then
        pid=$(< "$pid_file")
        if [[ "$pid" != "" ]]; then
            kill "$pid"
        fi
    fi
elif [[ "$command" == "status" ]]; then
    pid=$(pgrep -f "socat TCP-LISTEN")
    if [[ "$pid" != "" ]]; then
        echo "$pid"
    fi
    #echo "$pid"
elif [[ "$command" == "restart" ]]; then
    #port=$(lsof -i -P -n | grep "socat.*LISTEN" | awk '{print $9}' | cut -d: -f2)
    pid=$(pgrep -f "socat TCP-LISTEN")
    if [[ "$pid" != "" ]]; then
        kill "$pid"
    fi
    #echo "$port"
    ./server.sh &
fi
