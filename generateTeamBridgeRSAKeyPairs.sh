#!/bin/bash

function generate_pair () {
  openssl genrsa -out private_key.pem 4096

  openssl pkcs8 \
    -topk8 \
    -inform PEM \
    -outform DER \
    -in private_key.pem \
    -out bridge_private_key.der \
    -nocrypt

  openssl rsa \
    -in private_key.pem \
    -pubout \
    -outform DER \
    -out bridge_public_key.der

  chmod 600 bridge_private_key.der bridge_public_key.der

  cp bridge_public_key.der "$KEY_ROOT/$2/bridge_$1_public_key.der"
  mv bridge_private_key.der bridge_public_key.der "$KEY_ROOT/$1/"
  rm private_key.pem

  return 0
}

KEY_ROOT="bridgekeys"
KEY_LOCAL="client"
KEY_REMOTE="server"
mkdir -p "$KEY_ROOT/$KEY_LOCAL" "$KEY_ROOT/$KEY_REMOTE"
generate_pair "$KEY_LOCAL" "$KEY_REMOTE"
generate_pair "$KEY_REMOTE" "$KEY_LOCAL"
