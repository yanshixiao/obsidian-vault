---

UID: 20250415220429 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-15
---



### RabbitMQ中的basic.qos


在RabbitMQ中，_basic.qos_方法用于限制信道（或连接）上未确认消息的数量，这个数量也被称为“**预取计数**”（prefetch count）。这种机制可以防止消费者在高并发情况下被大量未处理的消息淹没，从而导致系统崩溃

#### 使用示例

##### 单个消费者

以下是一个基本的Java示例，它将一次接收最多10个未确认的消息：
```java
Channel channel = ...;
Consumer consumer = ...;
channel.basicQos(10); // 每个消费者的限制
channel.basicConsume("my-queue", false, consumer);
```


在这个示例中，_basicQos(10)_表示每个消费者最多可以接收10个未确认的消息

##### 独立消费者

如果在同一个信道上启动两个消费者，每个消费者将独立接收最多10个未确认的消息：

```java
Channel channel = ...;
Consumer consumer1 = ...;
Consumer consumer2 = ...;
channel.basicQos(10); // 每个消费者的限制
channel.basicConsume("my-queue1", false, consumer1);
channel.basicConsume("my-queue2", false, consumer2);
```

在这个示例中，每个消费者独立处理消息，不会互相影响

##### 多个消费者共享限制

如果使用不同的全局值多次调用_basic.qos_，RabbitMQ将其解释为这两个预取限制应相互独立地执行。消费者只有在未达到对未确认消息的限制时，才会收到新消息：

```java
Channel channel = ...;
Consumer consumer1 = ...;
Consumer consumer2 = ...;
channel.basicQos(10, false); // 每个消费者的限制
channel.basicQos(15, true); // 每个信道的限制
channel.basicConsume("my-queue1", false, consumer1);
channel.basicConsume("my-queue2", false, consumer2);
```


在这个示例中，这两个消费者之间只有15个未确认的消息，每个消费者最多有10条消息

##### 重要考虑事项

- **全局标识**：在RabbitMQ中，_basic.qos_方法的全局标识默认是_false_。当设置为_true_时，限制将应用于信道上的所有消费者，而不是单个消费者
    
- **性能影响**：在集群环境中，信道和队列之间的协调会增加额外的开销，从而影响性能
    

通过合理设置_basic.qos_，可以有效控制消费者的负载，防止系统在高并发情况下崩溃。

