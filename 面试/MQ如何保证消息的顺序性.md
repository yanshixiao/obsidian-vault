---

UID: 20250326125727 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-26
---
先看看顺序会错乱的俩场景：

- **RabbitMQ**：一个 queue，多个 consumer。比如，生产者向 RabbitMQ 里发送了三条数据，顺序依次是 data1/data2/data3，压入的是 RabbitMQ 的一个内存队列。有三个消费者分别从 MQ 中消费这三条数据中的一条，结果消费者 2 先执行完操作，把 data2 存入数据库，然后是 data1/data3。这不明显乱了。
![[MQ如何保证消息的顺序性.png]]
解决方案：
#### RabbitMQ

拆分多个 queue，每个 queue 一个 consumer，就是多一些 queue 而已，确实是麻烦点，这样也会造成吞吐量下降，可以在消费者内部采用多线程的方式取消费。

![[MQ如何保证消息的顺序性-1.png]]

通过 ​**路由分发 + 队列隔离 + 消费者内部有序处理** 实现顺序保障，具体分三步：

#### 1. ​**路由分发：按业务键分组**

- ​**目标**：将需要顺序处理的消息（如同一订单的操作）分发到同一个队列。
- ​**实现**：
    
    java
    
    复制
    
    ```java
    // 示例：根据订单ID哈希选择队列
    String queueName = "order_queue_" + (orderId.hashCode() % queueCount);
    rabbitTemplate.convertAndSend(exchange, queueName, message);
    ```
    
- ​**效果**：同一订单的消息始终进入同一队列。

#### 2. ​**队列隔离：每个队列绑定唯一消费者**

- ​**规则**：每个队列只允许一个消费者订阅。
- ​**优势**：
    - 队列的FIFO特性自然保留消息顺序。
    - 消费者独占队列，避免多个消费者竞争。

#### 3. ​**消费者内部有序处理**

- ​**多线程仍保序的机制**：
    - ​**方案1：单线程池顺序执行**
        
        java
        
        复制
        
        ```java
        // 消费者内部使用单线程池处理消息
        private ExecutorService executor = Executors.newSingleThreadExecutor();
        
        @RabbitListener(queues = "queue1")
        public void handleMessage(Message message) {
            executor.submit(() -> processMessage(message)); // 按入队顺序提交任务
        }
        ```
        
    - ​**方案2：消息键绑定线程**
        
        java
        
        复制
        
        ```java
        // 根据订单ID选择线程（同一订单由固定线程处理）
        int threadIndex = orderId.hashCode() % threadPoolSize;
        executor.getThread(threadIndex).submit(() -> processMessage(message));
        ```



或者就一个 queue 但是对应一个 consumer，然后这个 consumer 内部用内存队列做排队，然后分发给底层不同的 worker 来处理。

注意，这里消费者不直接消费消息，而是将消息根据关键值（比如：订单 id）进行哈希，哈希值相同的消息保存到相同的内存队列里。也就是说，需要保证顺序的消息存到了相同的内存队列，然后由一个唯一的 worker 去处理。

[[RabbitMQ的消息顺序性]]