#!/bin/bash

# https://stackoverflow.com/questions/36920558/is-there-anyway-to-specify-basicconstraints-for-openssl-cert-via-command-line

export OPENSSL_CONF=./openssl.cnf
SSL=openssl
PREFIX=mysql
CERTS="server client"

echo "Create CA certificate"
echo "---------------------"
#sudo $SSL genrsa 2048 > ${PREFIX}-ca-key.pem
#sudo $SSL req -x509 -new -subj "/CN=MySQL CA" -nodes -days 72000 -key ${PREFIX}-ca-key.pem -out ${PREFIX}-ca.pem
echo "---------------------------------------------------------"

for CERT in $CERTS; do
  echo "Create $CERT certificate, remove passphrase, and sign it"
  echo "---------------------------------------------------------"
  echo "Creating"
  $SSL req -x509 -subj "/CN=10.10.203.20" -newkey rsa:2048 -days 72000 -nodes -keyout ${PREFIX}-${CERT}-key.pem -out ${PREFIX}-${CERT}-req.pem
  echo "Removing passphrase"
  $SSL rsa -in ${PREFIX}-${CERT}-key.pem -out ${PREFIX}-${CERT}-key.pem
  echo "Signing"
  echo $SSL x509 -in ${PREFIX}-${CERT}-req.pem -days 3600 -CAcreateserial -CA ${PREFIX}-ca.pem -CAkey ${PREFIX}-ca-key.pem -out ${PREFIX}-${CERT}-cert.pem
  $SSL x509 -in ${PREFIX}-${CERT}-req.pem -days 3600 -CAcreateserial -CA ${PREFIX}-ca.pem -CAkey ${PREFIX}-ca-key.pem -out ${PREFIX}-${CERT}-cert.pem
  echo "---------------------------------------------------------"
  echo "verify $CERT cert"
  $SSL verify -CAfile ${PREFIX}-ca.pem ${PREFIX}-${CERT}-cert.pem
done

read -p "Press any key to continue..."
 