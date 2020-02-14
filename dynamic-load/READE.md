# dynamic-load

## confd+nginx

### nginx configuration

nginx 配置文件默认以 nginx.conf 为根文件，根文件中根配置项目根据网络层级、通讯协议和应用层协议不同因而字段名有所不同(可能为 tcp,udp,http,rtmp)等等。
一般情况下我们使用 nginx 是用来提供 http 服务的，在 http 层里面就是相关 http 相关配置，例如：日志格式、转发头部设置、日志文件、保活时间、proxy cache 等等。
在最后一行会有`include /etc/nginx/conf.d/*.conf;`用于导入子配置项目文件。
server 和 upstream 同属于 http 的下一级，其中 upstream 用于设置上游服务访问的相关参数，例如：ip,port,weight等等。一个 server 块就定义了一个 nginx server 实例，一个 http 块可以包含多个 server 和多个 uptream，而且他们是多对多的关系.location 块包含在 server 块里面，可以包含多个 location 块以针对不同的`URL`做不同的处理，一般都是使用`proxy_pass http://uptream_name`转发给 uptream 块所定义的某个 upstream。
当然 location 也也支持代理指定文件夹下的静态文件，例如下面配置就代理`/usr/share/nginx/html`文件夹内的静态文件：

```conf
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
```

### confd

[读取 json](https://github.com/kelseyhightower/confd/blob/master/docs/templates.md#complex-example)

### docker process manager
