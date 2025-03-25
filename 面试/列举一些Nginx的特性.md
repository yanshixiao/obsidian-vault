---

UID: 20250326000913 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-26
---




---

### **Nginx 的核心特性**

#### **1. 高性能与高并发**
- **事件驱动架构**：基于异步非阻塞 I/O 模型，单机可轻松支持数万并发连接。
- **低资源消耗**：内存占用低（每个连接约 2.5KB），CPU 利用率高效。
- **多进程模型**：Master 进程管理多个 Worker 进程，充分利用多核 CPU。

#### **2. 反向代理与负载均衡**
- **反向代理**：隐藏后端服务器细节，转发请求至应用服务器（如 Tomcat、Node.js）。
- **负载均衡算法**：
  - 轮询（Round Robin）
  - 加权轮询（Weighted Round Robin）
  - IP 哈希（IP Hash）
  - 最少连接（Least Connections）
- **示例配置**：
  ```nginx
  upstream backend {
      server 10.0.0.1:8080 weight=3;
      server 10.0.0.2:8080;
  }
  ```

#### **3. 静态资源服务**
- **高效传输**：通过 `sendfile` 零拷贝技术直接发送文件，减少磁盘 I/O。
- **缓存优化**：设置 `expires` 头控制浏览器缓存，降低重复请求。
- **Gzip 压缩**：压缩响应内容，减少传输体积。

#### **4. SSL/TLS 与 HTTP/2 支持**
- **HTTPS 终止**：处理 SSL 握手、证书管理，支持 TLS 1.3。
- **HTTP/2**：多路复用、头部压缩，提升页面加载速度。
- **配置示例**：
  ```nginx
  server {
      listen 443 ssl;
      ssl_certificate     /etc/nginx/ssl/server.crt;
      ssl_certificate_key /etc/nginx/ssl/server.key;
  }
  ```

#### **5. 缓存加速**
- **代理缓存**：缓存后端响应，降低后端负载。
- **配置示例**：
  ```nginx
  proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m;
  location / {
      proxy_cache my_cache;
      proxy_pass http://backend;
  }
  ```

#### **6. 安全防护**
- **访问控制**：限制 IP 访问、请求频率。
  ```nginx
  location /admin/ {
      allow 192.168.1.0/24;
      deny all;
  }
  ```
- **DDoS 防护**：限制并发连接数。
  ```nginx
  limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
  limit_conn conn_limit 100;
  ```

#### **7. 动态内容处理**
- **FastCGI 支持**：代理 PHP、Python 等动态请求至后端处理器（如 PHP-FPM）。
  ```nginx
  location ~ \.php$ {
      fastcgi_pass unix:/var/run/php-fpm.sock;
      include fastcgi_params;
  }
  ```

#### **8. 热部署与配置管理**
- **无缝重载配置**：执行 `nginx -s reload` 不中断服务更新配置。
- **版本热升级**：替换二进制文件后，通过信号通知 Worker 进程逐步重启。

#### **9. 模块化扩展**
- **官方模块**：如 `ngx_http_rewrite_module`（重写 URL）、`ngx_http_gzip_module`（压缩）。
- **第三方模块**：如 OpenResty（Lua 脚本支持）、Nginx Plus（商业版功能扩展）。

#### **10. 日志与监控**
- **访问日志**：记录请求详情（客户端 IP、响应状态、耗时等）。
  ```nginx
  access_log /var/log/nginx/access.log combined;
  ```
- **实时状态监控**：通过 `ngx_http_stub_status_module` 查看连接数、请求数。
  ```nginx
  location /nginx_status {
      stub_status;
      allow 127.0.0.1;
      deny all;
  }
  ```

#### **11. 高级路由与重写**
- **URL 重写**：灵活修改请求路径。
  ```nginx
  rewrite ^/old-path/(.*)$ /new-path/$1 permanent;
  ```
- **条件逻辑**：基于变量（如 `$request_method`）控制流量。

#### **12. 支持 WebSocket 与 gRPC**
- **WebSocket 代理**：
  ```nginx
  location /ws/ {
      proxy_pass http://backend;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
  }
  ```
- **gRPC 代理**：
  ```nginx
  location / {
      grpc_pass grpc://backend;
  }
  ```

---

### **总结**
Nginx 凭借其 **高性能、灵活性、可扩展性**，成为现代 Web 架构的核心组件，适用于：
- **静态资源托管**  
- **反向代理与负载均衡**  
- **API 网关与微服务路由**  
- **安全防护与流量控制**  
- **实时通信（WebSocket/gRPC）**  

其模块化设计和丰富的生态系统，使其在云原生、边缘计算等场景中持续发挥关键作用。
