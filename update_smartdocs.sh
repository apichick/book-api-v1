#!/bin/bash

if [ $# -lt 4 ]; then
    echo "Usage: $0 USERNAME PASSWORD PORTAL_URL CRON_URL" 
fi

USERNAME=$1
PASSWORD=$2
PORTAL_URL=$3
CRON_KEY=$4

RESULT=$(curl -s -o /dev/null -I -w "%{http_code}" -u ${USERNAME}:${PASSWORD} -H "Accept: application/json" ${PORTAL_URL}/smartdocs/apis/models/book-api-v1)

if [ $RESULT -eq 404 ]; then
    curl -X POST -u ${USERNAME}:${PASSWORD} -H "Content-Type: multipart/form-data;" -F "description=First 5 characters of the alphabet" -F "name=book-api-v1" -F "display_name=Book API v1" "${PORTAL_URL}/smartdocs/apis/models"
fi

curl -X POST -u ${USERNAME}:${PASSWORD} -H "Content-Type: multipart/form-data;" -F "api_definition=@book-api-v1-spec.json" "${PORTAL_URL}/smartdocs/apis/models/book-api-v1/import"

curl -v "${PORTAL_URL}/cron.php?cron_key=Yg9UaqudC8-DS0yuCUR0PTU70zKDE--"
