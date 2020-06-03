# skyvis

天宇威视-司马大大对接

## 环境依赖

部署环境需要预先安装以下相应版本的服务

| 服务           | 版本                                 |
| -------------- | ------------------------------------ |
| Docker         | Docker version 18.09.5 或更高        |
| Docker-Compose | docker-compose version 1.21.2 或更高 |

## 组件

本工程包含天宇威视的基础服务，每个服务的名称以及作用如下:

| 服务          | 描述       | 绑定主机的端口 | 作用                                                                           |
| ------------- | ---------- | -------------- | ------------------------------------------------------------------------------ |
| rabbit        | 消息队列   | 5672,15672     | 负责异步消息的分发                                                             |
| etcd          | 分布式 k-v | 6379           | 负责服务注册与发现                                                             |
| dynamic_nginx | web 服务器 | 默认 8080      | 反向代理 gateway 和 svvod 服务，所有的`信令`和`媒体流`都会经过该服务器代理分发 |
| gateway       | 网关服务   |                | 网关服务负责任务的分发和点播密码的转发                                         |

## 编译

只有**研发**需要编译镜像

cd 到`deploy`路径下,执行命令:

```bash
NGINX_IMAGE_TAG=v0.0.6 GATEWAY_IMAGE_TAG=v0.0.3 HOSTNAME=192.168.1.42 docker-compose build
```

## 部署

### docker-compose 部署

在单台机器上部署服务的时候，使用`docker-compose`可以提高部署的效率，减少部署过程中的错误。

#### 部署命令

将[docker-compose.yml](deploy/docker-compose.yml)文件拷贝到要部署的工作目录，然后运行下面的命令:

```bash
`WAN_ENDPOINT`=http://1.119.145.114:10808 `NOTIFY_PREFIX`=http://119.4.227.238:18084/skyvis `NGINX_IMAGE_TAG`=v0.0.6 `GATEWAY_IMAGE_TAG`=dev docker-compose up -d
```

上面的环境变量的作用如下:

| ENV               | Description                                                            | Required |
| ----------------- | ---------------------------------------------------------------------- | -------- |
| NOTIFY_PREFIX     | `天宇`接受消息回调的地址                                               | yes      |
| NGINX_IMAGE_TAG   | dynamic_nginx 镜像的 tag                                               | yes      |
| GATEWAY_IMAGE_TAG | gateway 服务镜像的 tag                                                 | yes      |
| NGINX_PORT        | dynamic_nginx 绑定到主机的端口，默认是`8080`                           | no       |
| WAN_ENDPOINT      | dynamic_nginx 暴露给`天宇和用户`的`http`接口，格式为：`http://ip:port` | yes      |

注意事项：

- 环境变量`WAN_ENDPOINT`用来指定dynamic_nginx 暴露给`天宇和用户`的`http`接口，该变量的值在不同`部署场景`有不同的值:
  - 内网环境,值为:`http://<宿主机IP>:<dynamic_nginx 绑定到主机的端口,默认为8080>` 天宇威视生产环境是这种场景
  - 通过路由器映射到公网,值为：`http://<路由器公网IP>:<路由器公网映射端口>`
