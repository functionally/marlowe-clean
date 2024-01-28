#!/usr/bin/env bash

while true
do
  psql -f active.sql "$NETWORK"
  while read c
  do
    curl -sS \
      -X POST \
      -H 'Content-Type: application/json' \
      -H "X-Change-Address: $(cat payment.address)" \
      -d '{"version" : "v1", "inputs" : [], "metadata" : {}, "tags" : {}}' \
      "http://$MARLOWE_RT_HOST:$MARLOWE_RT_PORT/contracts/${c/\#/%23}/transactions" \
    | jq '.resource.txBody' \
    | marlowe-cli transaction submit \
        --tx-body-file /dev/stdin \
        --required-signer payment.skey \
        --timeout 600s \
    2> /dev/null
    if [ $? == 0 ]
    then
      sleep 3s
    fi
  done < active.list
  echo
  sleep 90m
done
