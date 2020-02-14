 confd --onetime --log-level debug --confdir . --backend etcdv3 --node http://127.0.0.1:2379 --watch
 sudo cp tmp/services.conf /etc/nginx/conf.d/
 service nginx reload