FROM dockerhub.bmi:5000/node:10.15.3-alpine-cst
ENV TZ=Asia/Shanghai
WORKDIR /usr/src/app
EXPOSE 3000
COPY . .
RUN npm --registry https://registry.npm.taobao.org install \
    && npm run compile \
    && rm -rf ./src \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD [ "start" ]