# lua

收到对某个分片的请求之后，nginx 调用 lua 脚本先从网关服务中读取分片文件存储的 s3 的账号密码，然后将账号密码拼接到请求后面转发给 hls 后台服务。

## 参考

- [使用 lua 扩展你的 nginx](https://blog.csdn.net/jiao_fuyou/article/details/36010691#)
- [nginx的location配置详解](https://blog.csdn.net/tjcyjd/article/details/50897959)
