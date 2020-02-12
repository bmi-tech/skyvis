etcdctl put /myapp/subdomain myapp
etcdctl put /myapp/upstream/app2 '{"IP": "100.0.0.2","Port":8080}'
etcdctl put /myapp/upstream/app1 '{"IP": "100.0.0.1","Port":8080}'
etcdctl put /yourapp/subdomain yourapp
etcdctl put /yourapp/upstream/app2 '{"IP": "101.0.0.2","Port":8080}'
etcdctl put /yourapp/upstream/app1 '{"IP": "101.0.0.1","Port":8080}'