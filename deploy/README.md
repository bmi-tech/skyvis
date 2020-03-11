# docker-compose 部署

## 环境变量

以下环境变量可以在部署服务中使用：
| 环境变量          | 变量意义                                        | 默认值                |
| ----------------- | ----------------------------------------------- | --------------------- |
| NGINX_IMAGE_TAG   | nginx 镜像的 tag                                | 无                    |
| NGINX_PORT        | nginx 映射到宿主机上的端口                      | 8080                  |
| GATEWAY_IMAGE_TAG | gateway 镜像的 tag                              | 无                    |
| WAN_ENDPOINT      | 暴露在公网上的 endpoint，需要按照路由器端口映射 | http://localhost:8080 |
| NOTIFY_PREFIX     | 天宇接受通知的接口                              | http://localhost:1008 |

例如传入 nginx,gateway 镜像 tag:

```bash
NGINX_IMAGE_TAG=v0.0.1 GATEWAY_IMAGE_TAG=v0.0.1 docker-compose up -d
```
