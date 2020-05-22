# skyvis

天宇威视-司马大大对接

## build

cd 到`deploy`路径下,执行命令:

```bash
NGINX_IMAGE_TAG=v0.0.6 GATEWAY_IMAGE_TAG=v0.0.3 HOSTNAME=192.168.1.42 docker-compose build
```

## deploy

### 开启命令

将`deploy/docker-compose.yml`文件拷贝到工作目录并运行下面命令:

```bash
WAN_ENDPOINT=http://1.119.145.114:10808 NOTIFY_PREFIX=http://119.4.227.238:18084/skyvis NGINX_IMAGE_TAG=v0.0.6 GATEWAY_IMAGE_TAG=dev HOSTNAME=192.168.1.12 docker-compose up -d
```
