FROM openresty/openresty
WORKDIR /app
COPY ./confd /usr/local/bin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
ADD ./docker-entrypoint.sh ./docker-entrypoint.sh
ADD ./conf.d/nginx.toml /etc/confd/conf.d/nginx.toml
ADD ./templates/services.conf.tmpl /etc/confd/templates/services.conf.tmpl
ADD ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
RUN mkdir -p /var/log/nginx/ && touch /var/log/nginx/error.log
ENTRYPOINT [ "./docker-entrypoint.sh" ]