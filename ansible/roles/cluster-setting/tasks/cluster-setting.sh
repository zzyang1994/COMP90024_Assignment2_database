#!/usr/bin/env bash
declare -a nodes=(115.146.95.1 115.146.95.136 115.146.94.2 115.146.92.127)
export masternode=`echo ${nodes} | cut -f1 -d' '`
declare -a othernodes=`echo ${nodes[@]} | sed s/${masternode}//`
export size=${#nodes[@]}
export user='admin'
export pass='password'
export cookie='a192aeb9904e6590849337933b000c99'

echo "Master node is ${masternode}!"
echo "Current node: $1!"

if [ "$1" == "${masternode}" ]
  then
    curl -XPOST "http://${user}:${pass}@localhost:5984/_cluster_setup"\
      --header "Content-Type: application/json"\
      --data "{\"action\": \"enable_cluster\", \"bind_address\": \"0.0.0.0\",\
             \"username\": \"${user}\", \"password\": \"${pass}\", \"node_count\": \"$(echo ${nodes[@]} | wc -w)\"}"
fi

if [ "$1" != "${masternode}" ]
  then
    curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
      --header "Content-Type: application/json"\
      --data "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\",\
             \"username\": \"${user}\", \"password\":\"${pass}\", \"port\": \"5984\",\
             \"remote_node\": \"$1\", \"node_count\": \"$(echo ${nodes[@]} | wc -w)\",\
             \"remote_current_user\":\"${user}\", \"remote_current_password\":\"${pass}\"}"
fi

if [ "$1" != "${masternode}" ]
  then
    curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
      --header "Content-Type: application/json"\
      --data "{\"action\": \"add_node\", \"host\":\"$1\",\
             \"port\": \"5984\", \"username\": \"${user}\", \"password\":\"${pass}\"}"
fi

curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
    --header "Content-Type: application/json" --data "{\"action\": \"finish_cluster\"}"

curl -X GET "http://${user}:${pass}@$1:5984/_membership"
curl -XPUT "http://${user}:${pass}@${masternode}:5984/twitter"
curl -X GET "http://${user}:${pass}@$1:5984/_all_dbs"

echo "==Setting CORS=="
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/_local/_config/chttpd/enable_cors" --data '"true"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/_local/_config/cors/origins" --data '"*"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/_local/_config/cors/credentials" --data '"true"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/_local/_config/cors/methods" --data '"GET, PUT, POST, HEAD, DELETE"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/_local/_config/cors/headers" --data '"accept, authorization, content-type, origin, referer, x-csrf-token"'

curl -XPUT "http://${user}:${pass}@localhost:5984/_node/couchdb@$1/_config/chttpd/enable_cors" --data '"true"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/couchdb@$1/_config/cors/origins" --data '"*"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/couchdb@$1/_config/cors/credentials" --data '"true"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/couchdb@$1/_config/cors/methods" --data '"GET, PUT, POST, HEAD, DELETE"'
curl -XPUT "http://${user}:${pass}@localhost:5984/_node/couchdb@$1/_config/cors/headers" --data '"accept, authorization, content-type, origin, referer, x-csrf-token"'
