#!/usr/bin/env bash

ip=$(echo $1 | cut -d : -f 1)
port=$(echo $1 | cut -d : -f 2)

if [[ -z $ip || -z $port ]]; then
    echo "Usage: rssh ip:port"
    exit 1
fi

docker run --rm -p$ip:$port:2222 \
    -e EXTERNAL_ADDRESS=$ip:$port \
    -e SEED_AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub)" \
    -v $(pwd)/data:/data \
    rssh:local