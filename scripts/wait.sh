#!/usr/bin/env bash

if [ -n "$DOCKER_SERVICES" ]; then
  for service in $(echo "$DOCKER_SERVICES" | sed 's/,/\n/g'); do
    echo "$service"
    HOST="$(echo "$service" | sed 's/:/ /g' | awk '{ print $1 }')"
    PORT="$(echo "$service" | sed 's/:/ /g' | awk '{ print $2 }')"
    echo "Waiting for $HOST to resolve"
    until getent hosts "$HOST"; do
      sleep 3
    done
    IP="$(getent hosts "$HOST" | awk '{ print $1 }')"
    echo "Resolved $HOST to $IP!"
    echo "Waiting for $PORT on $IP"
    until exec 6<>"/dev/tcp/$IP/$PORT"; do
      6<&-
      sleep 3
    done
    6<&-
    echo "$IP:$PORT is up!"
  done
fi

exec "$@"
