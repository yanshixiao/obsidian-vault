---

UID: 20250327123032 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-27
---
- Master 最好不要做任何持久化工作，如 RDB 内存快照和 AOF 日志文件；

- 如果数据比较重要，某个 Slave 开启 AOF 备份数据，策略设置为每秒同步一次；

- 为了主从复制的速度和连接的稳定性，Master 和 Slave 最好在同一个局域网内；

- 尽量避免在压力很大的主库上增加从库；

- 主从复制不要用图状结构，用单向链表结构更为稳定，即：Master <- Slave1 <- Slave2 <-Slave3….；这样的结构方便解决单点故障问题，实现 Slave 对 Master 的替换。如果 Master 挂了，可以立刻启用 Slave1 做 Master，其他不变。

[[为啥说不要用master去执行rdb和aof备份]]

### Redis 常见性能问题及解决方案

#### **1. 大 Key（Big Key）**
• **问题**：单个 Key 的 Value 过大（如 Hash/List 元素过多、String 值过大），导致操作阻塞、内存不均、网络延迟。
• **解决方案**：
  • **拆分大 Key**：将大 Hash 拆分为多个小 Hash，按业务前缀分片。
  • **异步删除**：使用 `UNLINK` 替代 `DEL`，非阻塞删除。
  • **监控识别**：通过 `redis-cli --bigkeys` 或自定义脚本扫描大 Key。

#### **2. 热 Key（Hot Key）**
• **问题**：某个 Key 被高频访问，导致单节点 CPU/网络过载。
• **解决方案**：
  • **本地缓存**：在应用层缓存热 Key（如 Guava Cache）。
  • **分片打散**：通过 Hash Tag 将热 Key 分布到多节点。
  • **读写分离**：利用从节点分担读压力（需注意数据一致性）。

#### **3. 内存不足**
• **问题**：数据量超过物理内存，触发频繁淘汰（OOM）。
• **解决方案**：
  • **内存优化**：使用更紧凑的数据结构（如 ziplist、intset）。
  • **淘汰策略**：设置 `maxmemory-policy` 为 `allkeys-lru` 或 `volatile-lru`。
  • **分片扩容**：通过 Redis Cluster 横向扩展内存容量。

#### **4. 持久化性能瓶颈**
• **问题**：RDB/AOF 持久化导致主线程阻塞或磁盘 I/O 压力。
• **解决方案**：
  • **RDB 调优**：减少 `save` 配置项频率，或在低峰期手动执行 `BGSAVE`。
  • **AOF 调优**：使用 `appendfsync everysec` 替代 `always`，平衡性能与安全。
  • **混合持久化**：Redis 4.0+ 开启 `aof-use-rdb-preamble`，结合 RDB 快照与 AOF 增量。

#### **5. 主从同步延迟**
• **问题**：从节点复制延迟高，读取过期数据。
• **解决方案**：
  • **监控同步偏移量**：通过 `INFO replication` 检查 `slave_repl_offset` 与 `master_repl_offset`。
  • **优化网络**：确保主从节点间网络带宽充足。
  • **限流保护**：主节点开启 `client-output-buffer-limit` 避免复制缓冲区溢出。

#### **6. 慢查询阻塞**
• **问题**：复杂命令（如 `KEYS`、`HGETALL`）或 Lua 脚本执行时间过长。
• **解决方案**：
  • **避免慢命令**：用 `SCAN` 替代 `KEYS`，分批次获取数据。
  • **超时控制**：设置 `lua-time-limit`，监控 `SLOWLOG`。
  • **索引优化**：对高频查询字段建立二级索引（如使用 Sorted Set）。

#### **7. 高连接数消耗**
• **问题**：客户端连接数过多，导致资源耗尽。
• **解决方案**：
  • **连接池**：客户端使用连接池复用连接（如 Jedis Pool）。
  • **限制配置**：设置 `maxclients` 并监控连接数，通过 `CLIENT LIST` 分析空闲连接。
  • **短连接优化**：HTTP 服务中避免频繁创建 Redis 连接。

#### **8. 集群分片不均**
• **问题**：数据分布不均导致部分节点负载过高。
• **解决方案**：
  • **槽位平衡**：使用 `redis-cli --cluster rebalance` 重新分配槽位。
  • **Hash Tag**：对关联 Key 使用 `{}` 强制分片到同一槽位（如 `user:{1001}:profile`）。
  • **监控工具**：通过 `redis-cli --cluster check` 定期检查集群状态。

#### **9. 网络瓶颈**
• **问题**：跨机房部署或带宽不足导致延迟升高。
• **解决方案**：
  • **就近部署**：确保 Redis 节点与客户端同机房或同可用区。
  • **Pipeline 批处理**：合并多个命令减少网络往返次数。
  • **流量压缩**：启用 `client-output-buffer-limit` 或使用外部压缩工具。

#### **10. CPU 竞争**
• **问题**：单线程模型下 CPU 核数未充分利用。
• **解决方案**：
  • **多实例部署**：在同一机器部署多个 Redis 实例，绑定不同 CPU 核。
  • **集群分片**：通过 Redis Cluster 分散负载到多节点。
  • **读写分离**：将读请求分流到从节点。

### **总结**
| **问题类型**       | **关键解决策略**                              | **工具/命令**                          |
|--------------------|---------------------------------------------|---------------------------------------|
| 大 Key             | 拆分、异步删除、监控                         | `UNLINK`, `redis-cli --bigkeys`       |
| 热 Key             | 本地缓存、分片、读写分离                     | 本地缓存库（Caffeine）                |
| 内存不足           | 数据结构优化、淘汰策略、分片                 | `maxmemory-policy`, ziplist           |
| 持久化瓶颈         | 调整 RDB/AOF 策略、混合持久化                | `BGSAVE`, `appendfsync`               |
| 主从延迟           | 网络优化、监控偏移量                         | `INFO replication`                    |
| 慢查询             | 替代命令、Lua 超时、索引优化                 | `SLOWLOG`, `SCAN`                     |
| 高连接数           | 连接池、限制配置                             | `maxclients`, Jedis Pool              |
| 分片不均           | 槽位再平衡、Hash Tag                        | `redis-cli --cluster rebalance`       |
| 网络瓶颈           | 就近部署、Pipeline、压缩                    | Pipeline, 跨机房专线                  |
| CPU 竞争           | 多实例、集群分片、读写分离                   | 多实例绑定 CPU, Redis Cluster         |

### **最佳实践建议**
1. **监控先行**：使用 `INFO`、`MONITOR`、Prometheus + Grafana 实时监控关键指标。
2. **压测验证**：通过 `redis-benchmark` 模拟高负载场景，提前识别瓶颈。
3. **版本升级**：定期评估 Redis 新版本（如 Redis 7 的多线程 I/O），获取性能优化。
4. **容灾设计**：部署哨兵（Sentinel）或集群（Cluster），避免单点故障。


