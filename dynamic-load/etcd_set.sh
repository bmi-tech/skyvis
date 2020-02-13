etcdctl put /services/web/cust1/2 '{"IP": "localhost","Port":8080}'
etcdctl put /services/web/cust2/2 '{"IP": "localhost","Port":8080}'
etcdctl put /services/web/cust2/1 '{"IP": "localhost","Port":8080}'
etcdctl put /services/web/cust1/1 '{"IP": "localhost","Port":8080}'