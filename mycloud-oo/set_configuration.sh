#!/bin/bash

set -x

docker exec -u www-data mycloudapp-server php occ --no-warnings config:system:get trusted_domains >> trusted_domain.tmp

if ! grep -q "mycloudapp-nginx-server" trusted_domain.tmp; then
    TRUSTED_INDEX=$(cat trusted_domain.tmp | wc -l);
    docker exec -u www-data mycloudapp-server php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="mycloudapp-nginx-server"
fi

rm trusted_domain.tmp

docker exec -u www-data mycloudapp-server php occ --no-warnings app:install onlyoffice

docker exec -u www-data mycloudapp-server php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"
docker exec -u www-data mycloudapp-server php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://mycloudapp-onlyoffice-document-server/"
docker exec -u www-data mycloudapp-server php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://mycloudapp-nginx-server/"
docker exec -u www-data mycloudapp-server php occ --no-warnings config:system:set onlyoffice jwt_secret --value="secret"