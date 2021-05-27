#!/bin/bash

PAYLOAD=""

if [ -z "$1" ]
  then
    PAYLOAD="{\"aps\":{\"content-available\" : 1, \"foo\":\"bar\"}}"
  else 
    PAYLOAD=$(<$1)
fi

TEAMID="GRQYGPJ394"
KEYID="B6S5PJ76G6"
SECRET="/home/pushtest/pu.sh/key.p8"
BUNDLEID="com.tecnichedivendita.tevecomobile"
DEVICETOKEN="8344833942a0d96af1883ef049cafbb7706a21bf1d5f43f6725de4296e4eae5e"

function base64URLSafe {
  openssl base64 -e -A | tr -- '+/' '-_' | tr -d =
}

function sign {
  printf "$1"| openssl dgst -binary -sha256 -sign "$SECRET" | base64URLSafe
}

time=$(date +%s)
header=$(printf '{ "alg": "ES256", "kid": "%s" }' "$KEYID" | base64URLSafe)
claims=$(printf '{ "iss": "%s", "iat": %d }' "$TEAMID" "$time" | base64URLSafe)
jwt="$header.$claims.$(sign $header.$claims)"

# Development server: api.sandbox.push.apple.com:443
#ENDPOINT=https://api.sandbox.push.apple.com:443
# 
# Production server: api.push.apple.com:443
# Uncomment URL below to send pushes to production server
ENDPOINT=https://api.push.apple.com:443
# 
URLPATH=/3/device/

URL=$ENDPOINT$URLPATH$DEVICETOKEN

curl -v \
   --http2 \
   --header "authorization: bearer $jwt" \
   --header "apns-topic: ${BUNDLEID}" \
   --data "${PAYLOAD}" \
   "${URL}"
