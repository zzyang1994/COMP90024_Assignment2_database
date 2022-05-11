#!/usr/bin/env bash
declare -a nodes=(115.146.95.1 115.146.95.136 115.146.94.2 115.146.92.127)
export masternode=`echo ${nodes} | cut -f1 -d' '`
declare -a othernodes=`echo ${nodes[@]} | sed s/${masternode}//`
export size=${#nodes[@]}
export user='admin'
export pass='password'
export VERSION='3.2.1'
export cookie='a192aeb9904e6590849337933b000c99'

for node in ${othernodes} 
do
    curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup" \
      --header "Content-Type: application/json"\
      --data "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\",\
             \"username\": \"${user}\", \"password\":\"${pass}\", \"port\": \"5984\",\
             \"remote_node\": \"${node}\", \"node_count\": \"$(echo ${nodes[@]} | wc -w)\",\
             \"remote_current_user\":\"${user}\", \"remote_current_password\":\"${pass}\"}"
done

for node in ${othernodes}
do
    curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
      --header "Content-Type: application/json"\
      --data "{\"action\": \"add_node\", \"host\":\"${node}\",\
             \"port\": \"5984\", \"username\": \"${user}\", \"password\":\"${pass}\"}"
done

curl -XPOST "http://${user}:${pass}@${masternode}:5984/_cluster_setup"\
    --header "Content-Type: application/json" --data "{\"action\": \"finish_cluster\"}"

curl -X GET "http://${user}:${pass}@${node}:5984/_membership"
curl -XPUT "http://${user}:${pass}@${masternode}:5984/twitter"
curl -X GET "http://${user}:${pass}@${node}:5984/_all_dbs"