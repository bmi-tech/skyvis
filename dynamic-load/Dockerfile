FROM openresty/openresty
WORKDIR /app
COPY ./confd-0.16.0-linux-amd64 /usr/local/bin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
ADD ./docker-entrypoint.sh ./docker-entrypoint.sh
ADD ./conf.d/nginx.toml /etc/confd/conf.d/nginx.toml
ADD ./templates/services.conf.tmpl /etc/confd/templates/services.conf.tmpl
ADD ./nginx.conf /etc/nginx/nginx.conf
ENTRYPOINT [ "./docker-entrypoint.sh" ]