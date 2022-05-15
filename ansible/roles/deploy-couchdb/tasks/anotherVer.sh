#!/usr/bin/env bash
declare -a nodes=(115.146.95.1 115.146.95.136 115.146.94.2 115.146.92.127)
export masternode=`echo ${nodes} | cut -f1 -d' '`
declare -a othernodes=`echo ${nodes[@]} | sed s/${masternode}//`
export size=${#nodes[@]}
export user='admin'
export pass='password'
export VERSION='3.2.1'
export cookie='a192aeb9904e6590849337933b000c99'

echo "Current node: $1!"

if [ ! -z $(docker ps --all --filter "name=couchdb*" --quiet) ] 
  then
    docker stop $(docker ps --all --filter "name=couchdb*" --quiet) 
    docker rm $(docker ps --all --filter "name=couchdb*" --quiet)
fi 


docker pull ibmcom/couchdb3:${VERSION}

mkdir -p /usr/local/couchdb/data

docker create\
  --name couchdb$1\
  --env COUCHDB_USER=${user}\
  --env COUCHDB_PASSWORD=${pass}\
  --env COUCHDB_SECRET=${cookie}\
  --env ERL_FLAGS="-setcookie \"${cookie}\" -name \"couchdb@$1\""\
  --publish 5984:5984\
  --publish 5986:5986\
  --publish 4369:4369\
  --publish 9100-9200:9100-9200\
  --volume /usr/local/couchdb/data:/opt/couchdb/data\
  ibmcom/couchdb3:${VERSION}

declare -a cont=(`docker ps --all | grep couchdb | cut -f1 -d' ' | xargs -n${size} -d'\n'`)

docker start couchdb$1 
