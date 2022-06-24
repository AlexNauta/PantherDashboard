#!/bin/bash
name="miner-install-presearch"
service=$(cat /var/dashboard/services/$name | tr -d '\n')
registrationcode=$(cat /var/dashboard/statuses/$name | tr -d '\n')
pantherx_ver=$(cat /var/dashboard/statuses/pantherx_ver)

# Fix invalid status when boot finish
if [[ $service == 'running' ]]; then
  if [[ ! -f /tmp/dashboard-$name-flag ]]; then
    echo 'stopped' > /var/dashboard/services/$name
  fi
fi

if [[ $service == 'start' ]]; then
  touch /tmp/dashboard-$name-flag
  echo 'running' > /var/dashboard/services/$name
  echo 'Stopping currently running docker...' > /var/dashboard/logs/$name.log
  docker stop presearch-node >> /var/dashboard/logs/$name.log
  echo 'Removing currently running docker...' >> /var/dashboard/logs/$name.log
  docker rm presearch-node >> /var/dashboard/logs/$name.log
  echo 'Stopping currently running docker auto updater...' > /var/dashboard/logs/$name.log
  docker stop presearch-auto-updater >> /var/dashboard/logs/$name.log
  echo 'Removing currently running docker auto updater...' >> /var/dashboard/logs/$name.log
  docker rm presearch-auto-updater >> /var/dashboard/logs/$name.log
  echo 'Acquiring and starting latest docker auto updater version...' >> /var/dashboard/logs/$name.log
  docker run -d --name presearch-auto-updater --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock presearch/auto-updater --cleanup --interval 900 presearch-auto-updater presearch-node >> /var/dashboard/logs/$name.log
  echo 'Acquiring and starting latest docker version...' >> /var/dashboard/logs/$name.log
  docker pull presearch/node >> /var/dashboard/logs/$name.log
  docker run -dt --name presearch-node --restart=unless-stopped -v presearch-node-storage:/app/node -e REGISTRATION_CODE=$registrationcode presearch/node >> /var/dashboard/logs/$name.log
  echo 'stopped' > /var/dashboard/services/$name
  echo 'Update complete.' >> /var/dashboard/logs/$name.log
fi
