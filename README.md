# skyvis

天宇威视-司马大大对接

## 架构

```mermaid
graph TD
A[nginx] -->|1| B1(网关)
A[nginx] -->|2| B2(网关)
A -->|1| D[HLS]
A -->|2| E[HLS]
A -->|3| F[HLS]
B1 --> |1| E[etcd]
```
