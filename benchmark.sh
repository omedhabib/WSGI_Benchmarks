#!/bin/bash

CONTAINER=
STATS_PID=
IP=
PORT=9808
CONNECTIONS=(100 200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000)
BASE=$1

ulimit -n 10240

function start() {
    local id=$1
    shift
    echo "Starting $id ($*)"
    CONTAINER=$(docker run --detach --memory 512MB --cpuset-cpus 0,1 --workdir /home/www/wsgi_benchmark -p $PORT:$PORT wsgi_benchmark "$@")

    while true; do
        echo "    Waiting for container ..."
        IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$CONTAINER")
        result=$(curl --silent "http://$IP:$PORT")
        if [[ "$result" == "OK" ]]; then
            break
        fi
        sleep 1
    done
}

function stop() {
    echo "    Shutting down $1 ..."
    docker kill "$CONTAINER"
}

function perf() {
    docker stats > "$BASE/$1.$2.stats" &
    STATS_PID=$!

    echo "    Testing $1 with $2 connections ..."
    taskset -c 2,3 wrk --duration 30s --threads 4 --connections "$2" "http://$IP:$PORT" > "$BASE/$1.$2.log"

    sleep 1
    kill $STATS_PID
}

# Install docker image (if needed)
docker inspect wsgi_benchmark > /dev/null 2>&1
[ $? -gt 0 ] && docker build -t wsgi_benchmark:latest .

for connections in "${CONNECTIONS[@]}"; do
    for server in $(find src/* | shuf); do
        filename=$(basename "$server")
        base="${filename%.*}"
        ext="${filename##*.}"
        
        case "$ext" in
            py|pyc)
                # ignore, this is the base application that the WSGI servers wrap around
                continue
                ;;
            wsgi)
                start "$base" python "$filename"
                ;;
            sh)
                start "$base" bash "$filename"
                ;;
            *)
                echo "!! Unknown file type: $filename !!"
                continue
                ;;
        esac

        perf "$base" "$connections"
        stop "$base"
        sleep 1

    done
done
