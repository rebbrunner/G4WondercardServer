#!/bin/bash
openssl pkcs12 -in WII_NWC_1_CERT.p12 -passin pass:alpine -passout pass:alpine -out keys.txt && \
sed -n '7,29p' keys.txt > nwc.crt && \
sed -n '33,50p' keys.txt > nwc.key && \
openssl genrsa -out server.key 1024 && \
echo -e "US\nWashington\nRedmond\nNintendo of America Inc.\nNintendo Wifi Network\n*.*.*\nca@noa.nintendo.com\n\n\n" | openssl req -new -key server.key -out server.csr && \
openssl x509 -req -in server.csr -CA nwc.crt -CAkey nwc.key -CAcreateserial -out server.crt -days 3650 -sha1 -passin pass:alpine && \

mkdir /etc/apache2/certs && \
cp /dummy-certs/server.crt /etc/apache2/certs/ && \
cp /dummy-certs/server.key /etc/apache2/certs/ && \
cp /dummy-certs/nwc.crt /etc/apache2/certs/
