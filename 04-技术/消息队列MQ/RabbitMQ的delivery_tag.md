---

UID: 20250415232922 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-15
---




在 RabbitMQ 中，`delivery_tag` 是消息确认机制的核心标识符，结合 Spring Boot 项目使用 MySQL 或 Redis 存储消费进度，可以有效管理消息的可靠消费。以下是详细解析及实现方案：

---

### **一、delivery_tag 的作用与特性**
#### 1. **基本概念**
• **定义**：`delivery_tag` 是 RabbitMQ 在每个 **Channel** 内为消息分配的 **唯一递增整数**，用于标识消息的唯一性。
• **作用域**：仅在当前 Channel 内有效，不同 Channel 的 `delivery_tag` 独立计数。
• **手动确认**：需通过 `basicAck(deliveryTag, multiple)` 显式确认消息，确保消息不丢失。

#### 2. **与自动确认的区别**
| **特性**         | **自动确认（autoAck=true）**       | **手动确认（autoAck=false）**       |
|-------------------|-----------------------------------|-----------------------------------|
| **确认时机**       | 消息发送后立即确认               | 需显式调用 `ack` 或 `nack`         |
| **可靠性**         | 可能丢失消息（消费者崩溃时）       | 高可靠（消息处理完成才确认）        |
| **适用场景**       | 低吞吐、可容忍重复消息的简单场景   | 高可靠场景（如订单支付、事务操作）  |

---

### **二、Spring Boot 中结合 MySQL/Redis 存储消费进度**
#### 1. **为什么需要外部存储？**
• **跨实例协调**：在集群环境下，多个消费者实例需共享消费进度，避免重复消费。
• **精确控制**：需暂停/恢复消费时，可基于存储的进度动态调整。
• **故障恢复**：服务重启后，从存储中恢复消费位置，避免消息丢失。

#### 2. **存储方案对比**
| **存储介质** | **优点**                     | **缺点**                     | **适用场景**               |
|-------------|-----------------------------|-----------------------------|---------------------------|
| **MySQL**   | 强一致性、事务支持            | 性能较低（高并发时可能成为瓶颈） | 需强一致性的金融交易场景     |
| **Redis**   | 高性能、支持原子操作           | 数据持久化需配置（可能丢失内存数据） | 高吞吐、允许最终一致性的场景 |

---

### **三、实现步骤（以 Spring Boot + Redis 为例）**
#### 1. **依赖配置**
```xml
<!-- Spring Boot Starter AMQP -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>

<!-- Redis -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

#### 2. **配置 RabbitMQ 手动确认**
```yaml
spring:
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
    listener:
      simple:
        acknowledge-mode: manual  # 手动确认
        prefetch: 1               # 每次只处理一条消息（避免并发问题）
```

#### 3. **Redis 存储消费进度**
```java
@Component
public class RedisProgressStore {
    @Autowired
    private StringRedisTemplate redisTemplate;

    // 记录已确认的最大 deliveryTag
    public void updateProgress(String queueName, long deliveryTag) {
        String key = "rabbitmq:progress:" + queueName;
        redisTemplate.opsForValue().set(key, String.valueOf(deliveryTag));
    }

    // 获取已确认的最大 deliveryTag
    public long getLastAckedTag(String queueName) {
        String key = "rabbitmq:progress:" + queueName;
        String value = redisTemplate.opsForValue().get(key);
        return value == null ? 0 : Long.parseLong(value);
    }
}
```

#### 4. **消费者逻辑实现**
```java
@RabbitListener(queues = "your_queue")
public void handleMessage(Message message, Channel channel) throws IOException {
    long deliveryTag = message.getMessageProperties().getDeliveryTag();
    String queueName = message.getMessageProperties().getConsumerQueue();

// 1. 检查是否已处理过该消息
	String progressKey = "rabbitmq:progress:" + queueName;
	String lastProcessedTagStr = redisTemplate.opsForValue().get(progressKey);
	long lastProcessedTag = lastProcessedTagStr == null ? 0 : Long.parseLong(lastProcessedTagStr);

	if (deliveryTag <= lastProcessedTag) {
		// 已处理过，直接ACK（避免重复消费）
		channel.basicAck(deliveryTag, false);
		return;
	}

    try {
        // 1. 处理消息（需实现幂等性）
        processMessage(message.getBody());

        // 2. 更新 Redis 中的消费进度
        redisProgressStore.updateProgress(queueName, deliveryTag);

        // 3. 手动确认消息（multiple=false 表示仅确认当前消息）
        channel.basicAck(deliveryTag, false);
    } catch (Exception e) {
        // 处理失败：拒绝消息并重新入队（或进入死信队列）
        //第二个参数false是不批量否定，第三个参数true是重新入队，如果是false就丢弃或进死信队列
        channel.basicNack(deliveryTag, false, true);
    }
}
```

#### 5. **启动时恢复消费进度**
在消费者启动时，从 Redis 加载已确认的最大 `deliveryTag`，并跳过已处理的消息：
```java
@PostConstruct
public void recoverProgress() {
    String queueName = "your_queue";
    long lastAckedTag = redisProgressStore.getLastAckedTag(queueName);

    // 设置消费者的起始位置（需配合 RabbitMQ 的 `basic.qos`）
    // 注意：RabbitMQ 不支持直接跳过消息，需通过业务逻辑过滤
    // 示例：记录已处理的消息 ID，在消费者中跳过
}
```

---

### **四、常用场景与最佳实践**
#### 1. **场景示例**
• **订单支付超时处理**  
  用户下单后未支付，需定时关闭订单。通过 RabbitMQ 延迟队列触发处理，消费进度存储确保任务不重复执行。
• **日志采集与分析**  
  高吞吐日志写入 Redis，消费端按序处理并记录进度，避免日志丢失或重复。
• **分布式锁竞争**  
  通过 RabbitMQ 分配任务，消费进度存储避免多个实例重复执行同一任务。

#### 2. **关键注意事项**
• **幂等性设计**：业务逻辑需支持重复消费（如通过唯一 ID 去重）。
• **性能优化**：  
  • Redis 批量更新（如 Pipeline）减少 IO。  
  • MySQL 使用批量插入或异步写入。  
• **错误处理**：  
  • 死信队列（DLX）兜底处理失败消息。  
  • 监控 `nack` 和 `reject` 计数，及时告警。

---

### **五、总结**
• **delivery_tag** 是 RabbitMQ 消息确认的核心标识，需结合手动确认机制使用。
• **外部存储（MySQL/Redis）** 用于在集群环境中可靠记录消费进度，确保消息不丢失、不重复。
• **场景选择**：  
  • 高吞吐、允许最终一致 → **Redis**。  
  • 强一致性、事务需求 → **MySQL**。  
• **核心代码逻辑**：消费处理 → 更新进度 → 手动确认。


