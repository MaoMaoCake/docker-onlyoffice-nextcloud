#!/bin/bash

set -x

docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:get trusted_domains >> trusted_domain.tmp

if ! grep -q "nextcloud-nginx-server" trusted_domain.tmp; then
    TRUSTED_INDEX=$(cat trusted_domain.tmp | wc -l);
    docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="nextcloud-nginx-server"
fi

if ! grep -q "cloud.yourdomain.com" trusted_domain.tmp; then
    TRUSTED_INDEX=$(cat trusted_domain.tmp | wc -l);
    docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="cloud.yourdomain.com"
fi

rm trusted_domain.tmp

docker exec -u www-data nextcloud-app-server php occ --no-warnings app:install onlyoffice

docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"
docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://nextcloud-onlyoffice-document-server/"
docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nextcloud-nginx-server/"

# force the system to use https
docker exec -u www-data nextcloud-app-server php occ --no-warnings config:system:set overwriteprotocol --value=https