#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 USERNAME PASSWORD" 
fi

USERNAME=$1
PASSWORD=$2

RESULT=$(curl -s -o /dev/null -I -w "%{http_code}" -u ${USERNAME}:${PASSWORD} -H "Accept: application/json" http://dev-ylesyuk.devportal.apigee.io/smartdocs/apis/models/book-api-v1

if [ $RESULT -eq 404 ]; then
    curl -v -X POST -u ${USERNAME}:${PASSWORD} -H "Content-Type: multipart/form-data;" -F "description=Book API v1" -F "name=book-api-v1" -F "display_name=Book API v1" "http://dev-ylesyuk.devportal.apigee.io/smartdocs/apis/models"
fi

curl -v -X POST -u ${USERNAME}:${PASSWORD} -H "Content-Type: multipart/form-data;" -F "api_definition=@book-api-v1-spec.json" "http://dev-ylesyuk.devportal.apigee.io/smartdocs/apis/models/book-api-v1/import"

curl -v "http://dev-ylesyuk.devportal.apigee.io/cron.php?cron_key=Yg9UaqudC8-DS0yuCUR0PTU70zKDE--mIC3E8Ft_lDQ"
