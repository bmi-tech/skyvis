etcdctl put /services/web/hls/1 '{"IP": "192.168.1.42","Port":8081}'
etcdctl put /services/web/hls/2 '{"IP": "192.168.1.42","Port":8082}'
etcdctl put /services/web/gateway/1 '{"IP": "192.168.1.42","Port":8091}'
etcdctl put /services/web/gateway/2 '{"IP": "192.168.1.42","Port":8092}'