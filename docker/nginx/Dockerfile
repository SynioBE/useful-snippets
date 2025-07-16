FROM nginx:alpine
ARG DOMAIN=wp.local
ENV DOMAIN=$DOMAIN
WORKDIR /app
RUN apk add --no-cache openssl
RUN openssl genrsa 8192 > /etc/ssl/certs/nginx-root-ca.key
RUN openssl req -x509 -new -nodes -key /etc/ssl/certs/nginx-root-ca.key -days 3650 -subj "/C=BE/ST=Limburg/O=Synio/CN=$DOMAIN" -out /etc/ssl/certs/nginx-root-ca.pem
RUN openssl genrsa 4096 > /etc/ssl/private/nginx-selfsigned.key
RUN openssl req -new -key /etc/ssl/private/nginx-selfsigned.key -subj "/C=BE/ST=Limburg/O=Synio/CN=$DOMAIN" -out /etc/ssl/certs/nginx-selfsigned.csr
COPY domains.extensions /etc/ssl/certs/domains.extensions
RUN sed -i -E "s/%DOMAIN%/$DOMAIN/g" /etc/ssl/certs/domains.extensions
RUN openssl x509 -req -days 3650 -CA /etc/ssl/certs/nginx-root-ca.pem -CAkey /etc/ssl/certs/nginx-root-ca.key -CAcreateserial -in /etc/ssl/certs/nginx-selfsigned.csr -extfile /etc/ssl/certs/domains.extensions -extensions domains -out /etc/ssl/certs/nginx-selfsigned.crt
