---

UID: 20250314232014 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-14
---



在 Java 多线程编程中，`sleep()` 和 `wait()` 都是用于暂停线程执行的方法，但它们的核心行为、使用场景和底层机制有显著区别。以下是详细的对比：

---

### **1. 核心区别总结**
| **特性**               | **`Thread.sleep()`**                            | **`Object.wait()`**                          |
|-----------------------|------------------------------------------------|---------------------------------------------|
| **所属类**             | `Thread` 类的静态方法                            | `Object` 类的实例方法                        |
| **锁的释放**           | **不释放锁**（线程继续持有所有已获取的锁）          | **释放锁**（线程进入等待队列，释放对象锁）       |
| **唤醒机制**           | 时间到期自动恢复                                 | 必须通过 `notify()`/`notifyAll()` 或超时唤醒  |
| **调用位置**           | 任意位置（不需要在同步代码块中）                  | 必须在同步代码块（`synchronized` 块）内调用    |
| **用途**               | 单纯让线程暂停指定时间                            | 线程间协作（如等待某个条件满足）               |

---

### **2. 详细对比**
#### **(1) 锁的行为**
- **`sleep()`**  
  线程调用 `sleep()` 后，**不会释放已持有的锁**。其他线程无法进入该对象的同步代码块。  
  **示例**：
  ```java
  synchronized (lock) {
      Thread.sleep(1000); // 线程休眠，但 lock 锁未释放
  }
  ```
  - 其他线程需等待锁释放才能执行同步代码。

- **`wait()`**  
  线程调用 `wait()` 后，**立即释放锁**，进入等待队列。其他线程可以获取锁并执行同步代码。  
  **示例**：
  ```java
  synchronized (lock) {
      lock.wait(); // 释放 lock 锁，线程进入等待状态
  }
  ```
  - 其他线程可以获取 `lock` 并调用 `lock.notify()` 唤醒等待线程。

---

#### **(2) 使用场景**
- **`sleep()`**  
  适用于 **单纯让线程暂停一段时间**，不涉及线程间协作。  
  **典型场景**：  
  - 定时任务（如每隔 1 秒执行一次操作）。  
  - 模拟耗时操作（如网络请求延迟）。

- **`wait()`**  
  用于 **线程间协作**，等待某个条件满足（如生产者-消费者模型）。  
  **典型场景**：  
  - 生产者等待队列有空位时再生产。  
  - 消费者等待队列有数据时再消费。

---

#### **(3) 唤醒机制**
- **`sleep()`**  
  线程在指定时间（毫秒/纳秒）结束后自动恢复运行，**无需外部唤醒**。  
  **示例**：
  ```java
  Thread.sleep(2000); // 休眠 2 秒后自动恢复
  ```

- **`wait()`**  
  必须通过以下方式唤醒：  
  1. 其他线程调用 `notify()` 或 `notifyAll()`。  
  2. 超时（若调用带超时参数的 `wait(long timeout)`）。  
  **示例**：
  ```java
  synchronized (lock) {
      lock.wait(5000); // 最多等待 5 秒，超时后自动恢复
  }
  ```

---

#### **(4) 异常处理**
- **共同点**：  
  两者都会抛出 `InterruptedException`，需捕获或声明抛出。  
  **示例**：
  ```java
  try {
      Thread.sleep(1000);
  } catch (InterruptedException e) {
      // 处理中断
  }

  synchronized (lock) {
      try {
          lock.wait();
      } catch (InterruptedException e) {
          // 处理中断
      }
  }
  ```

---

### **3. 错误使用示例**
#### **(1) 在同步块中使用 `sleep()` 导致性能问题**
```java
synchronized (lock) {
    Thread.sleep(5000); // 线程休眠 5 秒，但锁未释放
}
```
- **问题**：其他线程需等待 5 秒才能获取锁，系统吞吐量下降。

#### **(2) 未在同步块中调用 `wait()`**
```java
lock.wait(); // 抛出 IllegalMonitorStateException
```
- **问题**：`wait()` 必须在同步代码块中调用。

---

### **4. 代码示例：生产者-消费者模型**
```java
class Buffer {
    private Queue<Integer> queue = new LinkedList<>();
    private int capacity = 1;

    public synchronized void produce(int value) throws InterruptedException {
        while (queue.size() >= capacity) {
            wait(); // 释放锁，等待消费者消费
        }
        queue.add(value);
        notifyAll(); // 唤醒所有等待线程
    }

    public synchronized void consume() throws InterruptedException {
        while (queue.isEmpty()) {
            wait(); // 释放锁，等待生产者生产
        }
        queue.poll();
        notifyAll(); // 唤醒所有等待线程
    }
}
```
- **关键点**：  
  - `wait()` 释放锁，允许其他线程进入同步方法。  
  - `notifyAll()` 确保所有等待线程有机会重新检查条件。

---

### **5. 总结**
| **选择依据**           | **`sleep()`**                          | **`wait()`**                          |
|-----------------------|---------------------------------------|---------------------------------------|
| **是否需要释放锁**      | 否（保持锁）                           | 是（释放锁）                           |
| **是否需要同步块**      | 否                                    | 是                                    |
| **适用场景**           | 定时暂停、模拟延迟                     | 线程间协作（如等待条件满足）            |
| **唤醒方式**           | 自动恢复                              | 需外部唤醒或超时                       |

**核心原则**：
- 若要让线程暂停且不涉及资源协作，用 `sleep()`。
- 若需线程间协作（如等待条件），用 `wait()`，并配合 `notify()`/`notifyAll()`。

