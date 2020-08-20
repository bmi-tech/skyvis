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

| 服务          | 描述       | 绑定主机的端口 | 作用                                   | 镜像地址                         | 镜像 tag             |
| ------------- | ---------- | -------------- | -------------------------------------- | -------------------------------- | -------------------- |
| rabbit        | 消息队列   | tcp:5672,15672 | 负责异步消息的分发                     | dockerhub.bmi:5000/rabbitmq      | 3-management         |
| etcd          | 分布式 k-v | tcp:6379       | 负责服务注册与发现                     | dockerhub.bmi:5000/etcd          | v3.4.5               |
| dynamic_nginx | web 服务器 | tcp:默认 8080  | 反向代理 gateway 和 svvod 服务         | dockerhub.bmi:5000/dynamic_nginx | 需要跟踪最新发布版本 |
| gateway       | 网关服务   |                | 网关服务负责任务的分发和点播密码的转发 | dockerhub.bmi:5000/gateway       | 需要跟踪最新发布版本 |

## 编译

只有**研发**需要编译镜像

cd 到`deploy`路径下,执行命令:

```bash
NGINX_IMAGE_TAG=v0.0.6 GATEWAY_IMAGE_TAG=v0.0.7 HOSTNAME=192.168.1.42 docker-compose build
```

## 部署

### docker-compose 部署

在单台机器上部署服务的时候，使用`docker-compose`可以提高部署的效率，减少错误。

#### 部署命令

将[docker-compose.yml](deploy/docker-compose.yml)文件拷贝到要部署的工作目录，然后运行下面的命令:

```bash
`WAN_ENDPOINT`=http://1.119.145.114:10808 `NOTIFY_PREFIX`=http://119.4.227.238:18084/skyvis `NGINX_IMAGE_TAG`=v0.0.6 `GATEWAY_IMAGE_TAG`=v0.0.7 docker-compose up -d
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

## troubleshooting

### gateway nginx etcd 容器都在运行，但向 nginx 发请求报错 Connection refused

现象：

- `docker ps`发现`gateway`、`etcd`和`nginx`的状态都是`Up`
- 向`nginx`的`8080`发送请求报错`Connection refused`
- 使用`docker logs ...`查看`nginx`的日志发现一直在报错:`host not found in upstream \"svvod\" in /usr/local/openresty/nginx/conf/.nginx.conf...省略... configuration file /usr/local/openresty/nginx/conf/.nginx.conf503058336 test failed`

原因：

- nginx 容器中使用 confd 监听etcd，从中获取注册到 etcd 中`gateway`和`svvod`的服务配置,然后使用这些配置信息来渲染配置模板供`nginx`进程使用，如果没有`svvod`注册到`etcd`,那么渲染出来的配置文件就是非法的，nginx 就无法启动，那么 nginx 就会一直循环报错。

两个解决方法，需要根据情况选择：

1. 开启**至少一个**`svvod`服务示例，并正确地注册到`etcd`中去。
2. 如果连一个`svvod`服务都没有条件部署的话，需要在`etcd`写入一个假的`svvod`服务注册信息，操作方式如下：
   1. 下载对应系统和架构的`etcdctl`[解压后有etcd,和etcdctl](https://github.com/etcd-io/etcd/releases)
   2. 运行`etcdctl put  /bmi/skyvis/services/web/svvod/fake_node '{"ip":"gateway","port":3000,"weight":1000}'  --endpoints <etcd 访问 ip>:2379`命令将伪造的信息写入`etcd`
