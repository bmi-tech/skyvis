etcdctl put /myapp/subdomain myapp
etcdctl put /myapp/upstream/app2 "10.0.1.100:80"
etcdctl put /myapp/upstream/app1 "10.0.1.101:80"
etcdctl put /yourapp/subdomain yourapp
etcdctl put /yourapp/upstream/app2 "10.0.1.102:80"
etcdctl put /yourapp/upstream/app1 "10.0.1.103:80"