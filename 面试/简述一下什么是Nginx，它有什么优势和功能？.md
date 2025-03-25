---

UID: 20250325235248 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-25
---


---

### **Nginx 简介**
**Nginx**（发音为“engine X”）是一款高性能的 **开源 Web 服务器**，同时支持反向代理、负载均衡、缓存等多种功能。由俄罗斯工程师 Igor Sysoev 于 2004 年发布，现已成为全球最流行的 Web 服务器之一，尤其擅长处理高并发场景。

---

### **Nginx 的核心优势**

| **优势**                | **说明**                                                                 |
|-------------------------|-------------------------------------------------------------------------|
| **高并发处理能力**       | 基于事件驱动的异步非阻塞架构，单机可轻松支持数万并发连接，资源消耗极低。   |
| **低内存占用**           | 每个连接仅需约 2.5KB 内存，显著优于传统多线程服务器（如 Apache）。        |
| **高可靠性**             | 支持热部署（配置更新/版本升级无需停机）、多进程容错机制。                  |
| **模块化设计**           | 核心功能简洁，通过模块扩展功能（如 HTTP/2、Lua 脚本、缓存等）。           |
| **灵活配置**             | 基于文本的配置文件，语法清晰，支持动态重载配置。                          |
| **跨平台支持**           | 支持 Linux、Windows、macOS 等主流操作系统。                              |

---

### **Nginx 的核心功能**

#### **1. 静态资源服务**
- **高效处理静态文件**（HTML、CSS、JS、图片等），直接内存映射（`sendfile` 系统调用），减少磁盘 I/O。
- **示例配置**：
  ```nginx
  server {
      listen 80;
      location /static/ {
          root /var/www/html;
          expires 30d;  # 客户端缓存30天
      }
  }
  ```

#### **2. 反向代理与负载均衡**
- **反向代理**：将客户端请求转发至后端应用服务器（如 Tomcat、Node.js），隐藏真实服务端信息。
- **负载均衡策略**：
  - **轮询（Round Robin）**：默认策略，依次分配请求。
  - **加权轮询**：根据服务器性能分配权重。
  - **IP 哈希（IP Hash）**：同一客户端 IP 固定访问某台服务器，解决会话保持问题。
  - **最少连接（Least Connections）**：优先选择当前连接数最少的服务器。
- **示例配置**：
  ```nginx
  upstream backend {
      server 10.0.0.1:8080 weight=3;  # 权重3
      server 10.0.0.2:8080;
      server 10.0.0.3:8080 backup;     # 备用服务器
      least_conn;  # 最少连接策略
  }

  server {
      location / {
          proxy_pass http://backend;
          proxy_set_header Host $host;
      }
  }
  ```

#### **3. 缓存加速**
- **代理缓存**：缓存后端响应结果，减少重复请求对后端服务器的压力。
- **配置示例**：
  ```nginx
  proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g;

  server {
      location / {
          proxy_cache my_cache;
          proxy_pass http://backend;
          proxy_cache_valid 200 304 12h;  # 缓存200/304状态码响应12小时
      }
  }
  ```

#### **4. SSL/TLS 终止**
- **HTTPS 支持**：处理 SSL 握手、证书管理，减轻后端服务器加密计算负担。
- **示例配置**：
  ```nginx
  server {
      listen 443 ssl;
      ssl_certificate /etc/nginx/ssl/server.crt;
      ssl_certificate_key /etc/nginx/ssl/server.key;
      ssl_protocols TLSv1.2 TLSv1.3;
  }
  ```

#### **5. 安全防护**
- **访问控制**：限制 IP 访问、请求频率、连接速率。
- **DDoS 防护**：限制并发连接数和请求速率。
- **示例配置**：
  ```nginx
  location /admin/ {
      deny 192.168.1.100;  # 禁止特定IP
      allow 10.0.0.0/8;     # 允许内网IP
      limit_req zone=req_limit burst=10;  # 限制请求速率
  }
  ```

#### **6. 动态内容处理**
- **FastCGI 代理**：将 PHP、Python 等动态请求转发至后端处理器（如 PHP-FPM）。
- **示例配置**：
  ```nginx
  location ~ \.php$ {
      fastcgi_pass unix:/var/run/php-fpm.sock;
      include fastcgi_params;
  }
  ```

#### **7. 日志与监控**
- **访问日志**：记录请求详情（如客户端 IP、响应状态、耗时）。
- **错误日志**：诊断服务异常。
- **实时状态监控**：通过 `ngx_http_stub_status_module` 查看连接数、请求数等指标。
  ```nginx
  location /nginx_status {
      stub_status;
      allow 127.0.0.1;  # 仅允许本机访问
      deny all;
  }
  ```

---

### **Nginx vs Apache**
| **特性**       | **Nginx**                              | **Apache**                       |
|----------------|----------------------------------------|----------------------------------|
| **架构**       | 事件驱动、异步非阻塞                   | 多线程/多进程，阻塞式 I/O        |
| **并发能力**   | 高并发（数万连接）                     | 低至中并发（数千连接）           |
| **内存占用**   | 低                                     | 高                               |
| **动态内容**   | 需反向代理至后端处理器（如 PHP-FPM）    | 内置模块（如 mod_php）           |
| **配置语法**   | 简洁，基于块的声明式配置               | XML 风格，较复杂                 |
| **热部署**     | 支持                                   | 不支持（需重启）                 |

---

### **总结**
Nginx 凭借其 **高性能、低消耗、高扩展性** 成为现代 Web 架构的核心组件，适用于：
- **静态资源托管**  
- **反向代理与负载均衡**  
- **SSL 终止与安全防护**  
- **高并发 Web 服务**  

结合其丰富的模块生态系统（如 OpenResty 支持 Lua 脚本），Nginx 可灵活适配从个人博客到大型分布式系统的多样化场景。


