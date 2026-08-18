Depends:
    nginx squid-openssl
    TCP PORTS: 80,443,9000,9999

1. Generate root
```
$ cd ssl
$ ./root.sh
```

2. Add custom root CA (debian):
```
# cp root_mitm_headroom.crt /usr/local/share/ca-certificates/
# update-ca-certificates --fresh
```

3. Generate certificate for nginx (my hostname was `orson.kvm`):
```
$ ./nginx.sh
# mkdir /etc/nginx/cert
# cp server.crt server.key /etc/nginx/cert/
```

4. Prepare PEM for squid SSL bump:
```
$ cat root_mitm_headroom.crt root_mitm_headroom.key > root_mitm_headroom.pem
# mv root_mitm_headroom.pem /etc/squid/
```

5. Prepare squid and start it
```
# /usr/lib/squid/security_file_certgen -c -s /var/spool/squid/ssldb -M 4MB
# chown -R proxy:proxy /var/spool/squid/ssldb
# cp ../conf/squid.conf /etc/squid/
```

6. Apply iptables rule (and make it permanent I guess):
Local ip address of VM where I run headroom, opencode/copilot, nginx and squid is 10.10.60.60

```
# iptables -t nat -A OUTPUT -o eth1 -p tcp --dport 443 -m owner ! --uid-owner 0 -j DNAT --to-destination 10.10.60.60:443
```

7. Add to /etc/environment:
```
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
```
