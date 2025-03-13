---

UID: 20250314005437 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-14
---
#### **错误代码示例**
```java
class Buffer {
    private Queue<Integer> queue = new LinkedList<>();
    private int capacity = 1;

    public synchronized void produce(int value) {
        if (queue.size() >= capacity) { // 错误：用 if 判断
            wait(); // 生产者等待
        }
        queue.add(value);
        notify(); // 唤醒一个线程（可能唤醒生产者！）
    }

    public synchronized void consume() {
        if (queue.isEmpty()) { // 错误：用 if 判断
            wait(); // 消费者等待
        }
        queue.poll();
        notify(); // 唤醒一个线程（可能唤醒消费者！）
    }
}
```


#### **死锁触发流程**

| **步骤** | **线程** | **操作**                                                      | **队列状态** |
| ------ | ------ | ----------------------------------------------------------- | -------- |
| 1      | 生产者 P1 | 插入数据，队列满，调用 `notify()`（无等待线程）                               | 队列满      |
| 2      | 生产者 P2 | 队列满，进入 `wait()`                                             | 队列满      |
| 3      | 消费者 C1 | 消费数据，队列空，调用 `notify()`（唤醒生产者 P2）                            | 队列空      |
| 4      | 生产者 P2 | 被唤醒，检查 `if (queue.size() >= capacity)`，发现队列空，直接插入数据，队列满     | 队列满      |
| 5      | 消费者 C2 | 尝试消费，检查 `if (queue.isEmpty())`，发现队列满，消费数据，队列空，调用 `notify()` | 队列空      |
| 6      | 生产者 P3 | 队列满，进入 `wait()`                                             | 队列满      |
| 7      | 消费者 C3 | 队列空，进入 `wait()`                                             | 队列空      |

**死锁条件**：  
- 所有生产者线程（P2、P3）等待队列有空位。
- 所有消费者线程（C2、C3）等待队列有数据。
- 每次 `notify()` 可能唤醒同类线程，导致没有线程能改变队列状态。


**最终状态**：
- 队列空，所有消费者等待。
- 队列满，所有生产者等待。
- 系统死锁。


### **三、总结**

| **问题**             | **核心原因**                                          | **解决方案**                           |
| ------------------ | ------------------------------------------------- | ---------------------------------- |
| 生产者-消费者死锁          | `notify()` 误唤醒同类线程，且 `if` 条件跳转导致无效操作，最终队列状态无法改变。  | 使用 `notifyAll()` + `while` 循环检查条件。 |
