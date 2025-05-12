!/bin/bash

curl --location \
     -X GET 'http://a1dd2d4d1cbc845539f31a8e4446097e-87445575.us-east-2.elb.amazonaws.com:8080/api/v1/jmx' \
     -H 'X-Trino-Role: starburst_service=ROLE{sysadmin}' \
     -H 'X-Trino-User: starburst_service'  
     -u 'starburst_service: ""'
