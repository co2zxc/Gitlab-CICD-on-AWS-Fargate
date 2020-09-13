#!/bin/bash

response=$(
    curl -s -o /dev/null -I -w "%{http_code}" docker:80
)

echo $response 
if test "$response" -ge 200 && test "$response" -le 299 
then 
echo 'check point pass'
else 
echo 'check point fail'
exit 1
fi
