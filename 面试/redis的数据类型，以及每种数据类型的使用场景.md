---

UID: 20250328012648 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-28
---



Redis支持多种数据类型，每种类型都有其独特的特点和适用场景。以下是主要数据类型及其常见使用场景的详细说明：

---

### **1. 字符串（String）**
• **特点**：最基本的数据类型，可存储文本、数字或二进制数据（最大512MB）。
• **应用场景**：
  • **缓存对象**：存储序列化的用户信息、商品详情等。
    ```bash
    SET user:1001 '{"name":"Alice","age":30}'
    GET user:1001
    ```
  • **计数器**：统计网站访问量、点赞数等。
    ```bash
    INCR page_views
    ```
  • **分布式锁**：通过 `SET key value NX` 实现互斥锁。
    ```bash
    SET lock:order_123 "1" NX EX 30
    ```

---

### **2. 列表（List）**
• **特点**：有序的字符串集合，支持双向插入（LPUSH/RPUSH）和弹出（LPOP/RPOP）。
• **应用场景**：
  • **消息队列**：实现简单的生产者-消费者模型。
    ```bash
    LPUSH tasks "send_email"
    RPOP tasks
    ```
  • **最新动态**：存储用户的最新微博或新闻列表。
    ```bash
    LPUSH user:1001:posts "New post"
    LRANGE user:1001:posts 0 9  # 获取最新10条
    ```

---

### **3. 哈希（Hash）**
• **特点**：存储字段-值（field-value）的映射表，适合表示对象。
• **应用场景**：
  • **用户信息存储**：高效管理对象的多个属性。
    ```bash
    HSET user:1001 name "Alice" age 30
    HGET user:1001 name
    ```
  • **购物车**：以用户ID为键，商品ID为字段，数量为值。
    ```bash
    HSET cart:1001 item_1 3 item_2 2
    HINCRBY cart:1001 item_1 1
    ```

---

### **4. 集合（Set）**
• **特点**：无序且元素唯一的集合，支持交（INTER）、并（UNION）、差（DIFF）操作。
• **应用场景**：
  • **标签系统**：存储用户的兴趣标签。
    ```bash
    SADD user:1001:tags "tech" "travel"
    SMEMBERS user:1001:tags
    ```
  • **共同好友**：计算多个用户的共同好友。
    ```bash
    SINTER user:1001:friends user:1002:friends
    ```

---

### **5. 有序集合（Sorted Set）**
• **特点**：元素按关联的分数（score）排序，支持范围查询。
• **应用场景**：
  • **排行榜**：根据分数实时更新排名。
    ```bash
    ZADD leaderboard 100 "player_1" 90 "player_2"
    ZREVRANGE leaderboard 0 9 WITHSCORES  # 前10名
    ```
  • **延迟队列**：用时间戳作为分数，定时处理任务。
    ```bash
    ZADD delay_queue 1630000000 "task_1"
    ZRANGEBYSCORE delay_queue 0 1630000000  # 获取到期任务
    ```

---

### **6. 位图（Bitmap）**
• **特点**：通过位操作存储布尔值（0/1），节省内存。
• **应用场景**：
  • **用户签到**：记录每日签到状态。
```bash
SETBIT sign:1001 20230101 1  # 2023年1月1日签到
BITCOUNT sign:1001            # 统计总签到天数
```
  • **活跃用户统计**：标记用户的活跃状态。


```bash
SETBIT active_users 1001 1    # 用户1001活跃
```

---

### **7. HyperLogLog**
• **特点**：用于基数统计（去重计数），误差率约0.81%，占用内存极小。
• **应用场景**：
  • **独立访客统计**：统计每日UV（Unique Visitors）。
    ```bash
    PFADD uv:20231001 "user_1" "user_2"
    PFCOUNT uv:20231001
    ```

---

### **8. 地理空间索引（Geospatial）**
• **特点**：存储地理位置（经度、纬度），支持范围查询和距离计算。
• **应用场景**：
  • **附近的人**：查询指定范围内的地点。
    ```bash
    GEOADD locations 116.405285 39.904989 "Beijing"
    GEORADIUS locations 116.40 39.90 10 km WITHCOORD
    ```

---

### **9. 流（Stream）**
• **特点**：支持多消费者组的消息流，类似消息队列（如Kafka）。
• **应用场景**：
  • **事件溯源**：记录用户操作日志流。
    ```bash
    XADD user_events * action "login" user_id 1001
    XREAD COUNT 10 STREAMS user_events 0
    ```

---

### **总结：Redis数据类型适用场景对比**
| **数据类型**       | **特点**                     | **典型场景**                               |
|---------------------|-----------------------------|------------------------------------------|
| **String**          | 简单键值存储                 | 缓存、计数器、分布式锁                     |
| **List**            | 有序列表，支持双向操作        | 消息队列、最新动态列表                     |
| **Hash**            | 字段-值映射表               | 用户对象、购物车                           |
| **Set**             | 无序唯一集合                | 标签系统、共同好友                         |
| **Sorted Set**      | 按分数排序的集合             | 排行榜、延迟队列                           |
| **Bitmap**          | 位操作存储布尔值            | 签到、活跃用户统计                         |
| **HyperLogLog**     | 近似去重计数                | 独立访客统计（UV）                        |
| **Geospatial**      | 地理位置存储与查询           | 附近地点搜索                              |
| **Stream**          | 消息流，支持多消费者组        | 事件日志、实时消息处理                     |

**选型建议**：
• **简单键值存储**：优先选择 **String**。
• **结构化对象**：使用 **Hash** 或 **String + JSON**（根据访问模式选择）。
• **需要排序或范围查询**：选择 **Sorted Set**。
• **去重统计**：大数据量用 **HyperLogLog**，精确统计用 **Set**。
• **实时消息处理**：使用 **Stream** 或外部消息队列（如 Kafka）。



