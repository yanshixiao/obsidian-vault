---

UID: 20250328005803 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-28
---


### **一、快速诊断**
#### 1. 查看内存使用情况
```bash
# 连接 Redis 执行
INFO memory
```
重点关注以下指标：
• **`used_memory`**：Redis 当前使用的内存（字节）。
• **`maxmemory`**：配置的最大内存限制（若未配置则为 0，表示无限制）。
• **`mem_fragmentation_ratio`**：内存碎片率（`used_memory_rss / used_memory`，理想值 1.0~1.5）。
• **`evicted_keys`**：因内存不足被淘汰的 Key 数量。

#### 2. 检查淘汰策略
```bash
CONFIG GET maxmemory-policy
```
默认策略为 `noeviction`（不淘汰，直接报错），需根据业务调整。

---

### **二、解决方案**
#### 1. **配置合理的内存淘汰策略**
| **策略**          | 适用场景                          | 配置示例                          |
|-------------------|----------------------------------|----------------------------------|
| **volatile-lru**  | 仅淘汰有过期时间的 Key，优先移除最近最少使用的 | `CONFIG SET maxmemory-policy volatile-lru` |
| **allkeys-lfu**   | 淘汰所有 Key，优先移除最不经常使用的       | `CONFIG SET maxmemory-policy allkeys-lfu`  |
| **volatile-ttl**  | 淘汰剩余过期时间最短的 Key              | `CONFIG SET maxmemory-policy volatile-ttl` |

**操作步骤**：
1. 修改 `redis.conf` 或动态配置：
   ```bash
   # 设置最大内存为 4GB
   CONFIG SET maxmemory 4gb
   # 启用 LFU 淘汰策略
   CONFIG SET maxmemory-policy allkeys-lfu
   ```
2. 重启 Redis 或确保配置持久化。

---

#### 2. **优化数据结构与 Key 设计**
• **避免大 Key**：  
  单个 Key 的 Value 不宜过大（如超过 10KB）。  
  ```bash
  # 查找大 Key
  redis-cli --bigkeys
  ```
  **优化方法**：
  • 拆分 Hash/List：将 `user:1001:orders` 拆分为 `user:1001:orders:shard1`、`user:1001:orders:shard2`。
  • 压缩数据：对文本型 Value 使用 Gzip 或 Snappy 压缩。

• **使用高效数据结构**：
  | **场景**          | **低效结构**      | **高效结构**              |
  |-------------------|------------------|--------------------------|
  | 计数器            | String + INCR    | String（已最优）          |
  | 标签集合          | Set              | IntSet（小规模整数集合）   |
  | 短文本存储        | String           | Hash + ziplist 编码       |

---

#### 3. **清理过期数据与冷数据**
• **手动删除无用 Key**：
  ```bash
  # 删除匹配模式的 Key（慎用）
  redis-cli --scan --pattern "temp:*" | xargs redis-cli DEL
  ```
• **设置 TTL**：
  ```bash
  # 为 Key 设置过期时间
  EXPIRE user:1001:session 3600
  ```

---

#### 4. **处理内存碎片**
• **查看碎片率**：
  ```bash
  INFO memory | grep mem_fragmentation_ratio
  ```
  • **> 1.5**：碎片较高，需处理。
  • **< 1.0**：内存被交换到磁盘（SWAP），需增加物理内存。

• **解决方案**：
  1. **重启 Redis**：强制内存重新分配（需确保有持久化或主从同步）。
  2. **开启自动碎片整理**（Redis 4.0+）：
     ```bash
     CONFIG SET activedefrag yes
     CONFIG SET active-defrag-ignore-bytes 100mb    # 碎片超过 100MB 时触发
     CONFIG SET active-defrag-threshold-lower 10    # 碎片率超过 10% 时触发
     ```

---

#### 5. **扩展硬件或集群化**
• **垂直扩展**：升级单机内存（适用于数据量可预估的场景）。
• **水平扩展**：使用 Redis Cluster 或代理分片（如 Codis、Twemproxy）。
  ```bash
  # Redis Cluster 分片示例（6节点：3主3从）
  redis-cli --cluster create 192.168.1.1:6379 192.168.1.2:6379 ... --cluster-replicas 1
  ```

---

#### 6. **监控与预防**
• **实时监控工具**：
  • `redis-cli --stat`：查看实时内存、Key 数量、QPS。
  • Prometheus + Grafana：通过 Redis Exporter 采集指标。
• **预警规则**：
  • 内存使用率 > 80%
  • 碎片率 > 1.5
  • 淘汰 Key 数量突增

---

### **三、案例场景**
#### **场景 1：电商大促期间 OOM**
• **现象**：`maxmemory` 设置为 8GB，但 `used_memory` 达到 8GB 后报错。
• **根因**：淘汰策略为 `noeviction`，未自动清理数据。
• **解决**：  
  ```bash
  # 动态修改为 LFU 淘汰策略
  CONFIG SET maxmemory-policy allkeys-lfu
  ```

#### **场景 2：长期运行后内存碎片率高**
• **现象**：`mem_fragmentation_ratio=2.1`，实际数据仅占内存 50%。
• **解决**：  
  ```bash
  # 开启自动碎片整理
  CONFIG SET activedefrag yes
  ```

---

### **总结**
| **步骤**               | **操作**                                | **关键命令/工具**                     |
|------------------------|----------------------------------------|--------------------------------------|
| 1. 配置淘汰策略         | 根据业务选择 LRU/LFU/TTL               | `CONFIG SET maxmemory-policy`        |
| 2. 优化数据结构         | 拆分大 Key、使用 ziplist/IntSet        | `redis-cli --bigkeys`                |
| 3. 清理冷数据           | 设置 TTL、手动删除无用 Key              | `EXPIRE`、`SCAN + DEL`               |
| 4. 处理内存碎片         | 重启或开启自动碎片整理                  | `activedefrag`                       |
| 5. 扩展容量             | 升级内存或集群分片                     | Redis Cluster                        |
| 6. 持续监控             | 设置告警规则，定期分析内存趋势           | Prometheus + Grafana                 |

通过合理配置、数据结构优化、定期清理与监控，可有效避免 Redis 内存不足问题。