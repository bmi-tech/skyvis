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

templates 定义了一个应用配置文件的模板，默认在`/etc/confd/templates`路径，使用`GOlang`的`text/templates`语法。
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

### openresty

#### lua

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

##### echo_location

syntax: `echo_location <location> [<url_args>]`

location 参数 可以随便设置`location`,不一定与其他 location 字段完全相同

##### rewrite

synctax: rewrite regex replacement [flag];

使用正则表达式重写 URI

flag 可以是 last,break,redirect,permanent

##### locatin

synctax: location [ = | ~ | ~* | ^~ ] uri { ... }

参考[nginx的location配置详解](https://blog.csdn.net/tjcyjd/article/details/50897959)

## docker

Dockerfile:

[docker-openresty](https://github.com/openresty/docker-openresty)
[docker-nginx](https://github.com/nginxinc/docker-nginx)
