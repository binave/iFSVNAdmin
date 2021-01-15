#!/bin/bash

_defined() {
    while [ "$1" ]; do
        eval printf \$$1 >/dev/null 2>&1 || {
            printf "[ERROR] variable '$1' not defined\n" >&2;
            return 1
        }
        shift
    done
    return 0
}

which nc >/dev/null 2>&1 || {
    printf "'nc' command not found.\n" >&2;
    exit 1
};

cd `dirname $0`;

[ -s "stable-1.6.2.tar.gz" ] || {
    curl -LO https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.tar.gz || exit 1
};

__ran_port () {
    port=$(($RANDOM % 55535 + 10000));
}

use_ports=$(netstat -apn | awk '$4 ~ /:[1-9]/{gsub(/.*:/, "", $4); if(!m[$4]++)printf ","$4}'),;
__ran_port;
until [ "$use_ports" == "${use_ports/,${port},/}" ]; do
    __ran_port
done

assets_url=$(docker network inspect --format '{{(index .IPAM.Config 0).Subnet}}' bridge);
# sed -i "s@curl.*|@curl http://${assets_url%.*}.1:$port |@" Dockerfile;

{
    printf "HTTP/1.1 200 OK\n\n";
    cat stable-1.6.2.tar.gz
} | ncat -l -p $port &

docker build --tag binave/svnadmin:1.6.2-alpine3.6.5 \
    --build-arg ALPINE_VERSION=3.6.5 \
    --build-arg REPO_MIRRORS_HOST=mirrors.tuna.tsinghua.edu.cn \
    --build-arg NETCAT_URL=http://${assets_url%.*}.1:$port \
    .
