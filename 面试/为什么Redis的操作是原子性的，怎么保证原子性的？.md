---

UID: 20250328014248 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-28
---


Redis 的原子性由其 **单线程模型** 和 **原子操作命令** 共同保障，具体机制如下：

---

### **一、Redis 原子性的核心原理**
#### **1. 单线程架构**
• **事件循环模型**：Redis 使用单线程处理所有客户端请求，同一时刻仅执行一个命令。  
• **天然原子性**：由于命令按顺序串行执行，无需考虑多线程的竞态条件（Race Condition）。

#### **2. 原子操作命令**
• **内置原子命令**：Redis 提供 `INCR`、`SETNX`、`HSET` 等命令，这些命令在服务器内部以不可中断的方式执行。  
  **示例**：  
  ```bash
  INCR counter  # 计数器原子递增
  SETNX lock:order 1  # 原子性获取锁
  ```

#### **3. 事务（MULTI/EXEC）**
• **批量原子执行**：将多个命令打包为事务，保证其按顺序执行且不被其他命令打断。  
  **示例**：  
  ```bash
  MULTI
  SET balance 100
  INCRBY balance 50
  EXEC  # 原子性执行
  ```

#### **4. Lua 脚本**
• **脚本级原子性**：Lua 脚本在 Redis 中作为一个整体执行，执行期间不会被其他命令中断。  
  **示例**：  
  ```lua
  -- 原子性扣减库存
  local stock = redis.call('GET', KEYS[1])
  if tonumber(stock) > 0 then
      redis.call('DECR', KEYS[1])
      return 1
  else
      return 0
  end
  ```

---

### **二、不同场景下的原子性保障**
#### **1. 单命令原子性**
• **所有内置命令**：如 `SET`、`HSET`、`ZADD` 等均为原子操作。  
• **优势**：无需额外控制，天然支持并发安全。

#### **2. 多命令原子性**
• **事务（MULTI/EXEC）**：  
  • **执行流程**：  
    1. `MULTI` 开启事务。  
    2. 命令入队（不立即执行）。  
    3. `EXEC` 时批量执行队列中的命令。  
  • **注意**：事务中某条命令失败（如类型错误）时，**不会回滚已执行的命令**（Redis 事务不支持 ACID 中的原子性）。  

• **Lua 脚本**：  
  • **严格原子性**：脚本执行期间，其他命令必须等待。  
  • **适用场景**：复杂业务逻辑（如库存扣减、订单状态流转）。  

#### **3. 分布式锁**
• **原子性加锁**：通过 `SET key value NX EX` 实现互斥锁。  
  ```bash
  SET lock:order_1234 "1" NX EX 30  # 原子性获取锁
  ```
• **解锁校验**：使用 Lua 脚本确保解锁操作的原子性。  
  ```lua
  -- 检查锁持有者是否匹配
  if redis.call("GET", KEYS[1]) == ARGV[1] then
      return redis.call("DEL", KEYS[1])
  else
      return 0
  end
  ```

---

### **三、原子性边界与注意事项**
#### **1. 不支持的原子性场景**
• **跨键操作**：涉及多个 Key 的复合操作（如 `GET` + `SET`）默认非原子，需通过 Lua 脚本或事务实现原子性。  
  **示例**：  
  ```lua
  -- 原子性转账（从A扣款，向B加款）
  local a = redis.call('GET', 'account:A')
  local b = redis.call('GET', 'account:B')
  if tonumber(a) >= 100 then
      redis.call('DECRBY', 'account:A', 100)
      redis.call('INCRBY', 'account:B', 100)
      return "OK"
  else
      return "FAIL"
  end
  ```

#### **2. 集群环境下的限制**
• **跨节点操作**：Redis Cluster 中，跨 Slot 的多键操作无法保证原子性（需确保所有 Key 在同一 Slot）。  
  **解决方案**：  
  • 使用 Hash Tag 强制 Key 分配到同一节点：  
    ```bash
    # 强制 user:123 和 order:123 分配到同一 Slot
    SET {user:123}:name "Alice"
    SET {user:123}:order "1001"
    ```

---

### **四、总结**
| **机制**          | **原子性级别**       | **适用场景**                     | **注意事项**                     |
|-------------------|---------------------|---------------------------------|---------------------------------|
| **单命令**         | 单个操作             | 简单计数、分布式锁                | 无                              |
| **事务（MULTI）**  | 批量命令连续执行      | 多个命令顺序执行                  | 不支持回滚，需业务层处理错误       |
| **Lua 脚本**       | 脚本内所有操作        | 复杂逻辑（如库存扣减、转账）        | 避免长时间阻塞（超过 `lua-time-limit`） |
| **WATCH 乐观锁**   | CAS（比较并交换）     | 竞态条件控制（如余额修改）          | 需重试逻辑                       |

**最佳实践**：  
• 简单操作直接使用原子命令（如 `INCR`）。  
• 复杂逻辑优先选择 Lua 脚本。  
• 分布式环境使用 Hash Tag 或 Redlock 算法保证跨节点原子性。
