#!/bin/sh

echo 'cecos-caas-demo'

cd $(dirname $0)

exec_in() { docker-compose exec -T $@; }

# Fresh start
docker-compose down

# Up all dinds nodes
docker-compose up -d manager1 manager2 worker1 worker2

# Manager1 init
exec_in manager1 docker swarm init
TOKEN_WORKER="$(exec_in manager1 docker swarm join-token -q worker)"
TOKEN_MANAGER="$(exec_in manager1 docker swarm join-token -q manager)"

# Manager2 join
exec_in manager2 docker swarm join --token $TOKEN_MANAGER manager1:2377

# Worker1 join
exec_in worker1 docker swarm join --token $TOKEN_WORKER manager1:2377

# Worker2 join
exec_in worker2 docker swarm join --token $TOKEN_WORKER manager1:2377

# Up app
docker-compose up -d proxy caas
