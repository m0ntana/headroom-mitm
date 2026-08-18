# Why
This is example of configuration to make `headroom` absolutely transparent to your agents so no additional configuration needed and you don't have
to specify model on agent's start.

# Depends
Packages: `nginx squid-openssl`  
TCP PORTS: 80,443,9000,9001,9999

# Topology
I do traffic redirection, run nginx, squid, `headroom` and agents on separate VM. Here is detailed picture of traffic flow:
<img width="983" height="730" alt="image" src="https://github.com/user-attachments/assets/1b62894a-e6b3-4323-b233-6c34558dfc92" />

# Topology roles
* `squid` generates SSL certificates dynamically (SSL bump)
* `nginx` at port `9000` rewrites incompatible URI (like copilot sometimes sends `/responses` instead of `/v1/responses`)
* `headroom` does its job and forwards queries to uplink
* `nginx` at port 9999 restores original URI, communicates with actual uplink (api.github.com) for example and sends response back to `headroom`


# How To
1. Generate root CA
```
$ cd ssl
$ ./root.sh
```

2. Add custom root CA (debian):
```
# cp root_mitm_headroom.crt /usr/local/share/ca-certificates/
# update-ca-certificates --fresh
```

3. Configure nginx (my hostname was `orson.kvm`):
```
$ ./nginx.sh
# mkdir /etc/nginx/cert
# cp server.crt server.key /etc/nginx/cert/
# cp ../conf/headroom /etc/nginx/sites-enabled/
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

6. Apply iptables rule (don't forget to replace username and make rule permanent I guess):

```
# iptables -t nat -A OUTPUT -o eth1 -p tcp --dport 443 -m owner --uid-owner m0ntana -j DNAT --to-destination 127.0.0.1:443
```

7. Add to /etc/environment (this will tell python to use common root CA instead of its own):
```
REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
```
