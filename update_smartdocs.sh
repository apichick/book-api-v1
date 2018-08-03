#!/bin/bash

if [ $# -eq 4 ]; then
    USERNAME=$1
    PASSWORD=$2
    PORTAL_URL=$3
    CRON_KEY=$4
    RESULT=$(curl -s -o /dev/null -w "%{http_code}" -u ${USERNAME}:${PASSWORD} -H "Accept: application/json" "${PORTAL_URL}/smartdocs/apis/models/book-api-v1")
    if [ $RESULT -eq 404 ]; then
        curl -v -X POST -u ${USERNAME}:${PASSWORD} -H "Content-Type: multipart/form-data;" -F "description=Book API v1" -F "name=book-api-v1" -F "display_name=Book API v1" "${PORTAL_URL}/smartdocs/apis/models"
    fi
    curl -v -u ${USERNAME}:${PASSWORD} -H "Content-Type: multipart/form-data;" -F "api_definition=@book-api-v1-spec.json" "${PORTAL_URL}/smartdocs/apis/models/book-api-v1/import"
    curl -X POST -u ${USERNAME}:${PASSWORD} "${PORTAL_URL}/smartdocs/apis/models/book-api-v1/render"
    curl -v "${PORTAL_URL}/cron.php?cron_key=${CRON_KEY}"
fi