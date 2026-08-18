#!/bin/bash

openssl genrsa -out root_mitm_headroom.key 4096

openssl req -x509 -new -nodes -key root_mitm_headroom.key -sha256 -days 3650 \
  -out root_mitm_headroom.crt \
  -subj "/CN=Headroom MITM CA/O=DevOps/C=EN" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,digitalSignature,cRLSign,keyCertSign" \
  -addext "subjectKeyIdentifier=hash"

