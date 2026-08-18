#!/bin/bash

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=orson.kvm"

openssl x509 -req -in server.csr \
  -CA root_mitm_headroom.crt \
  -CAkey root_mitm_headroom.key \
  -CAcreateserial -out server.crt -days 825 -sha256 \
  -extfile cert.ext
