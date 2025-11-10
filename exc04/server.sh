pid_file="pid.txt"
directory="$HOME/.config/server.conf"
result=$(getopt -o  ":p:" -- "$@")
if [ $? -ne 0 ]; then
    argument_error=1
fi
eval set -- "$result"
port=-1
while true;
do
case "$1" in
    "-p")
    port="$2"
    shift 2;;
    *)
    shift 1
    break
esac
done

if [[ "$port" == -1 ]]; then 
    if [[ -f "$directory" ]]; then
        port=$(< "$directory")
        if [[ "$port"=="" ]]; then
            port=6789
        fi
    else
        port=6789
    fi
fi
#condition="ss"
condition=$(lsof -i :"$port")
    if [[ "$condition" != "" ]]; then
        echo "Port $port is unavailable"
        exit 0 &
        exit 0
        #kill -TERM $$
    fi
echo $$ > "$pid_file"
socat TCP-LISTEN:"$port",reuseaddr,fork SYSTEM:"bash handler.sh \$port" 2>/dev/null&
socat_pid=$!
cleanup() {
    kill $socat_pid 2>/dev/null
    pkill -f "handler.sh" 2>/dev/null
    rm -f "$pid_file"
    exit 0
}
trap cleanup EXIT INT TERM
wait $socat_pid
#2>/dev/null