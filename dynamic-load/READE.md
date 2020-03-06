# dynamic-load

## confd

启动默认读取`etc/confd/conf.d`中`TOML`格式的`template resource`配置文件，根据配置文件的中指定的`backend`中指定的`keys`的**值**去渲染`src`指定的templates文件。然后将渲染后的模板和`dest`文件进行`md5`摘要进行比较，如果摘要不一致说明`dest`文件需要更新。
不过在更新之前需要调用`check_cmd`命令(如果配置了)对渲染后的模板进行合法性检测，检测合法之后才会覆盖掉`dest`文件。然后调用`reload_cmd`命令(如果配置了)使服务加载新的配置文件。
这里有个特例，如果命令启动时使用了`--only-sync`则不会执行`check_cmd`和`reload_cmd`命令，只更新文件。

### json

[读取 json](https://github.com/kelseyhightower/confd/blob/master/docs/templates.md#complex-example)

### Template Resources

template resources 是 `TOML`格式的配置文件,一个文件定义了一个 template resource.这些文件默认存放在`etc/confd/conf.d`

#### 必须参数

- dest 目标文件
- keys 键的列表
- src  template 文件的相对路径(相对于`/etc/confd/conf.d`)

### Templates

templates 定义了一个应用配置文件的模板，默认在`/etc/confd/templates`路径，使用`Golang`的`text/templates`语法。
Template Resources 中的`src`项就是指定该文件的路径。

#### 可选参数

- check_cmd:该命令用于检测配置的合法性。该命令是在渲染模板之后、覆盖配置文件之前调用的。所以正常使用方式是用来检测渲染之后的模板是否合法的。使用`{{.src}}`来表示渲染后的模板。
  - 注意事项：
    - `dest`文件应该是根配置文件，不应该被父配置所引用
    - 比如根配置文件 nginx.conf 包含`dest`指向的`default.conf`配置文件

- reload_cmd:在更新完配置文件之后，重新加载配置

## nginx

- start: nginx -g 'daemon on;'
  - `-g`全局
  - 'daemon on/off;' 控制是否使用 daemon

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

#### echo_location

syntax: `echo_location <location> [<url_args>]`

location 参数 可以随便设置`location`,不一定与其他 location 字段完全相同

#### rewrite

synctax: rewrite regex replacement [flag];

使用正则表达式重写 URI

flag 可以是 last,break,redirect,permanent

#### locatin

synctax: location [ = | ~ | ~* | ^~ ] uri { ... }

参考[nginx的location配置详解](https://blog.csdn.net/tjcyjd/article/details/50897959)

#### upstream

##### load balancing

参考：

- [load_balancing](http://nginx.org/en/docs/http/load_balancing.html)
- [upstream.server](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server)

### openresty

openresty 是基于 nginx 和 lua 的高性能 web 平台，它内部集成了大量的 lua 库，第三方模块和大多数依赖。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关.

#### lua 的作用

收到对某个分片的请求之后，nginx 调用 lua 脚本先从网关服务中读取分片文件存储的 s3 的账号密码，然后将账号密码拼接到请求后面转发给 hls 后台服务。

#### 参考

- [使用 lua 扩展你的 nginx](https://blog.csdn.net/jiao_fuyou/article/details/36010691#)
- [nginx的location配置详解](https://blog.csdn.net/tjcyjd/article/details/50897959)

#### 用到的

- access_by_lua_block
- echo_location
- request_uri
- uri
- args
- arg_`name` argument `name` in the request line
- 字符串格式化:$a =1;  print("a = $a"); output: a = 1;

##### lua 导入模块

例如解析 json

```lua
local cjson = require "cjson.safe"
cjson.encode(body)
```

##### lua 条件语句

```lua
if true then
    xxxxxx
else
    oooooo
    end
```

## docker

Dockerfile:

[docker-openresty](https://github.com/openresty/docker-openresty)
[docker-nginx](https://github.com/nginxinc/docker-nginx)

## 踩坑

### 服务陷入死的循环

#### 原因

```bash
# Try to make initial configuration every 5 seconds until successful
# Try to make initial configuration every 5 seconds until successful
until confd --onetime --log-level debug  --backend etcdv3 --node http://$ETCD ; do
    echo "[nginx] waiting for confd to create initial nginx configuration."
    sleep 5
done

# Put a continual polling `confd` process into the background to watch
# for changes every 10 seconds
confd --log-level debug  --backend etcdv3 --node http://$ETCD --watch  &

echo "[nginx] confd is now monitoring etcd for changes..."

# Start the Nginx service using the generated config
echo "[nginx] starting nginx service..."
openresty -g 'daemon on;'
tail -f /var/log/nginx/*.log
```

| 命令       | 调用内容                                                   |
| ---------- | ---------------------------------------------------------- |
| check_cmd  | openresty -t -c /usr/local/openresty/nginx/conf/nginx.conf |
| reload_cmd | openresty-s reload                                         |

1. 容器启动
2. 进入`until`循环
3. confd读取`backend`中预制的keys所对应的值
4. 对模板文件进行渲染
5. 比较渲染后的模板文件和原始的文件中的内容是否相等相同则返回 0，否则接着往下执行
6. 运行`check_cmd`中的命令
   1. 此时该文件引用的`default.conf`文件是原始的`default.conf`文件(官方openresty 镜像中默认带的)，所以配置合法
7. `check_cmd`合法之后会将`default.conf`文件覆盖掉,而`新非法default.conf`因为其中`gateway/svvod`的`upstream`中 server 个数为0，所以变为非法的配置.
8. 运行`reload_cmd`,这时候会报错`host not found in upstream \"gateway\" in /etc/nginx/conf.d/default.conf` 退出码为非零。
9. 因为`until`中运行结果非零所以回到步骤 3
10. 步骤 4
11. 步骤 5 此时因为渲染后的文件跟`新非法default.conf`内容一样，所以执行完成 退出码为 0
12. 退出`until`循环，在后台执行`confd`
13. 执行 `openresty -g 'daemon on;'`命令，因为`新非法default.conf`所以启动失败
14. 容器进程退出
15. 因为`restart always`所以容器`restart`，注意：这是同一个容器，所以`新非法default.conf`文件仍然存在
16. 如果缺失的`gateway/svvod`服务仍然没有开启
    1. 进入`until`循环
    2. 文件内容一样，confd 退出码为0，并退出`until`
    3. 在`openresty -g 'daemon on;'`步骤执行失败，容器进程退出
    4. 进入**容器退出-重启无限循环**
17. 如果缺失的`gateway/svvod`服务开启了
    1. 进入`until`循环,执行`confd`
    2. 因为监听的`key-value`有变化，所以文件内容发生变化
    3. `check_cmd`因为`新非法default.conf`而失败，confd 退出码为非 0
    4. 因为`until`再次执行`confd`
    5. `confd`不断报错的**无限循环**

#### 解决方法

- 使用`check_cmd`检测**渲染后的模板**而不是目标文件
- 将 openresty 配置文件合并成一个文件，并作为`template`文件进行渲染和读取