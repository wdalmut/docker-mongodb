#!/bin/bash

set -e

if sudo docker ps | grep "wdalmut/mongodb" >/dev/null; then
    echo ""
    echo "It looks like you already have some containers running."
    echo "Please take them down before attempting to bring up another"
    echo "cluster with the following command:"
    echo ""
    echo "  make stop-cluster"
    echo ""

    exit 1
fi

SHARD0_ID=$(sudo docker run -d -t wdalmut/mongodb mongod -f /etc/mongodb.conf  --logpath /dev/stdout --bind_ip 0.0.0.0 --port 10010)
SHARD0_IP=$(sudo docker inspect ${SHARD0_ID} | grep "IPAddress" | cut -d':' -f2 | cut -d'"' -f2)
echo "Your shard container ${SHARD0_ID} listen on ip: ${SHARD0_IP} (waiting that becomes ready)"

until sudo docker logs ${SHARD0_ID} | grep "[initandlisten] waiting for connections on port" >/dev/null;
do
    sleep 2
done

echo "The shard is available now..."

CONFIG0_ID=$(sudo docker run -d -t wdalmut/mongodb mongod -f /etc/mongodb.conf --configsvr --logpath /dev/stdout --bind_ip 0.0.0.0 --port 10000)
CONFIG0_IP=$(sudo docker inspect ${CONFIG0_ID} | grep "IPAddress" | cut -d':' -f2 | cut -d'"' -f2)
echo "Your config container ${CONFIG0_ID} listen on ip: ${CONFIG0_IP} (waiting that becomes ready)"

until sudo docker logs ${CONFIG0_ID} | grep "[initandlisten] waiting for connections on port" >/dev/null;
do
    sleep 2
done

echo "The config is available now..."

MONGOS0_ID=$(sudo docker run -d -t wdalmut/mongodb mongos --configdb ${CONFIG0_IP}:10000 --logpath /dev/stdout --bind_ip 0.0.0.0 --port 9999)
MONGOS0_IP=$(sudo docker inspect ${MONGOS0_ID} | grep "IPAddress" | cut -d':' -f2 | cut -d'"' -f2)
echo "Contacting shard and mongod containers"

until sudo docker logs ${MONGOS0_ID} | grep "config servers and shards contacted successfully" >/dev/null;
do
    sleep 2
done


# Add the shard
mongo ${MONGOS0_IP}:9999 --eval 'sh.addShard("'${SHARD0_IP}':10010")'

echo "OK, you can connect to mongos using: "
echo "mongo ${MONGOS0_IP}:9999"



