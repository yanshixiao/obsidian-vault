---

UID: 20250328005837 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-28
---







在 Redis 中，**哈希表（Hash Table）** 是其核心数据结构之一，用于高效存储和快速访问键值对（Key-Value）。以下是哈希表在 Redis 中的作用、实现原理及实际应用的详细说明：

---

### 一、哈希表的定义
**哈希表** 是一种通过 **哈希函数（Hash Function）** 将键（Key）映射到内存地址的数据结构，支持近似 O(1) 时间复杂度的数据插入、删除和查找。  
Redis 使用哈希表实现以下功能：
1. **全局键值对存储**：所有 Redis 键（如 `SET name "Alice"`）存储在 **全局哈希表** 中。
2. **Hash 数据类型**：当用户使用 `HSET user:1001 name "Alice"` 命令时，`user:1001` 对应的 Value 内部也是一个哈希表。

---

### 二、哈希表的实现原理
#### 1. 数据结构
Redis 的哈希表由以下结构组成：
• **哈希表节点（dictEntry）**：存储键值对，并指向下一个节点（用于解决哈希冲突）。  
  ```c
  typedef struct dictEntry {
      void *key;          // 键（如 "name"）
      void *val;          // 值（如 "Alice"）
      struct dictEntry *next;  // 指向下一个节点（链表）
  } dictEntry;
  ```
• **哈希表（dictht）**：包含多个哈希桶（Bucket），每个桶是链表头节点。  
  ```c
  typedef struct dictht {
      dictEntry **table;      // 哈希桶数组
      unsigned long size;     // 哈希表大小（桶的数量）
      unsigned long sizemask; // 哈希掩码（用于计算索引，等于 size-1）
      unsigned long used;     // 已使用的节点数
  } dictht;
  ```
• **字典（dict）**：管理两个哈希表（用于渐进式 Rehash）。  
  ```c
  typedef struct dict {
      dictht ht[2];      // 两个哈希表（ht[0] 主表，ht[1] Rehash 临时表）
      long rehashidx;     // Rehash 进度（-1 表示未进行）
  } dict;
  ```

#### 2. 哈希函数
Redis 默认使用 **SipHash 算法** 计算键的哈希值，该算法在安全性和性能之间取得平衡，可有效防止哈希碰撞攻击。

#### 3. 哈希冲突解决
当多个键的哈希值映射到同一桶时，Redis 使用 **链地址法（Separate Chaining）**：  
• 将冲突的键值对以链表形式存储在同一个桶中。  
• 查找时遍历链表，通过键的完整比对（`key->val`）确认目标节点。

---

### 三、哈希表的动态扩容（Rehash）
当哈希表负载因子（`used / size`）过高时，Redis 自动触发扩容操作，以降低哈希冲突概率。

#### 1. 扩容条件
• **扩容触发**：满足以下任一条件时触发：  
  • 负载因子 ≥ 1 且允许扩容（`dict_can_resize` 为真）。  
  • 负载因子 ≥ 5（强制扩容）。  
• **缩容触发**：当负载因子 < 0.1 时，Redis 会缩容以减少内存占用。

#### 2. 渐进式 Rehash
扩容过程中，Redis 使用 **渐进式 Rehash** 策略，避免一次性迁移数据导致主线程阻塞：  
1. 分配新哈希表（`ht[1]`），大小为第一个大于 `ht[0].used * 2` 的 2^n。  
2. 将 `rehashidx` 置为 0，表示开始迁移。  
3. 每次处理客户端请求时，迁移 `ht[0]` 中 `rehashidx` 对应桶的所有节点到 `ht[1]`，并递增 `rehashidx`。  
4. 迁移完成后，释放 `ht[0]`，将 `ht[1]` 设置为 `ht[0]`，重置 `rehashidx = -1`。

---

### 四、哈希表的实际应用
#### 1. 全局键值对存储
所有 Redis 键（如 `SET`、`GET` 操作的 Key）存储在全局哈希表中。  
• **示例**：执行 `SET user:1001 "Alice"` 时，Redis 将 `user:1001` 作为键，计算哈希值后插入全局哈希表。

#### 2. Hash 数据类型
当用户使用 `HSET` 命令时，Redis 内部使用哈希表存储字段-值对。  
• **示例**：  
  ```bash
  HSET user:1001 name "Alice" age 30
  ```
  • `user:1001` 对应的 Value 是一个哈希表，包含 `name` 和 `age` 两个字段。  
  • 查找 `HGET user:1001 name` 时，先定位 `user:1001` 的全局键，再从其内部的哈希表中找到 `name` 字段。

#### 3. 哈希表与其他数据结构的结合
• **Set 类型**：当元素数量较少时，Redis 使用哈希表存储 Set（`SADD` 命令）。  
• **ZSet 类型**：ZSet 的跳跃表（SkipList）中，元素的分值（Score）通过哈希表辅助查找。

---

### 五、哈希表的性能优化
#### 1. 避免大 Key
• **问题**：单个哈希表存储过多字段（如 `HSET` 存储 10 万字段），导致链表过长。  
• **优化**：拆分为多个 Key（如 `user:1001:info`、`user:1001:orders`）。

#### 2. 监控负载因子
通过 `INFO memory` 命令监控哈希表状态：  
```bash
# 查看哈希表负载因子
used_memory_human: 1.5G
mem_fragmentation_ratio: 1.2
```

#### 3. 配置调优
• **强制扩容阈值**：修改 `redis.conf` 中的 `hash-max-ziplist-entries` 和 `hash-max-ziplist-value`，控制哈希表与压缩列表的转换条件。

---

### 六、哈希表 vs. 其他数据结构
| **数据结构** | 优点                          | 缺点                     | 适用场景                 |
|--------------|-------------------------------|-------------------------|--------------------------|
| **哈希表**    | O(1) 时间复杂度的读写          | 内存占用较高             | 键值对存储、频繁查找      |
| **压缩列表**  | 内存紧凑，适合小数据           | 读写效率随数据量增长下降 | 小规模 Hash/List/ZSet   |
| **跳跃表**    | 支持范围查询，有序性           | 实现复杂，内存开销较大   | ZSet（有序集合）         |

---

### 总结
• **哈希表是 Redis 高效运行的核心**，支撑全局键值对存储和 Hash 数据类型。  
• 通过 **链地址法** 解决哈希冲突，通过 **渐进式 Rehash** 动态扩容，平衡性能与内存占用。  
• 合理设计 Key 和字段规模，监控负载因子，可最大化哈希表的性能优势。

