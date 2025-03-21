---

UID: 20250321143156 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-21
---





---

**Semaphore（信号量）** 是 Java 并发包中的一种同步工具，用于**控制同时访问共享资源的线程数量**（限流）。其核心思想是通过“许可证”（Permits）机制，限制并发操作的线程数。Semaphore 基于 **AQS（AbstractQueuedSynchronizer）** 实现，支持公平与非公平两种模式。

---

### **核心机制**
1. **许可证（Permits）**  
   • 通过一个整数 `state` 表示可用许可证数量。
   • 线程调用 `acquire()` 获取许可证（`state--`），若 `state=0` 则线程阻塞。
   • 线程调用 `release()` 释放许可证（`state++`），唤醒等待线程。

2. **两种模式**  
   • **公平模式**：按线程请求顺序分配许可证（类似公平锁）。
   • **非公平模式**（默认）：允许新线程插队直接尝试获取许可证，提高吞吐量。

---

### **核心方法**
| 方法                          | 作用                                                                 |
|------------------------------|----------------------------------------------------------------------|
| `Semaphore(int permits)`     | 创建非公平信号量，指定许可证数量                                      |
| `Semaphore(int permits, boolean fair)` | 指定许可证数量和公平性                                                |
| `acquire()`                   | 获取一个许可证（阻塞直到成功或中断）                                  |
| `acquire(int permits)`        | 获取多个许可证                                                        |
| `tryAcquire()`                | 尝试获取许可证（非阻塞，立即返回是否成功）                            |
| `release()`                   | 释放一个许可证                                                        |
| `release(int permits)`        | 释放多个许可证                                                        |
| `availablePermits()`          | 返回当前可用许可证数量                                                |

---

### **使用场景**
#### 1. **资源池限流（如数据库连接池）**
```java
public class ConnectionPool {
    private final Semaphore semaphore;
    private final List<Connection> pool = new ArrayList<>();

    public ConnectionPool(int maxSize) {
        semaphore = new Semaphore(maxSize); // 控制最大并发数
        // 初始化连接池
        for (int i = 0; i < maxSize; i++) {
            pool.add(createConnection());
        }
    }

    public Connection getConnection() throws InterruptedException {
        semaphore.acquire(); // 获取许可证（阻塞）
        return pool.remove(0);
    }

    public void releaseConnection(Connection conn) {
        pool.add(conn);
        semaphore.release(); // 释放许可证（必须在 finally 中调用）
    }

    private Connection createConnection() { /* 创建连接 */ }
}
```

#### 2. **接口限流（防止高并发击穿系统）**
```java
public class RateLimiter {
    private final Semaphore semaphore = new Semaphore(100); // 每秒最多 100 个请求

    public void handleRequest() {
        try {
            semaphore.acquire();
            // 处理请求...
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            semaphore.release();
        }
    }
}
```

#### 3. **并行任务分片控制**
```java
// 限制同时处理文件的线程数为 4
Semaphore semaphore = new Semaphore(4);
List<File> files = getFilesToProcess();

files.parallelStream().forEach(file -> {
    try {
        semaphore.acquire();
        processFile(file); // 高 CPU/IO 消耗操作
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    } finally {
        semaphore.release();
    }
});
```

---

### **与其他工具对比**
| **工具**           | **核心目的**                     | **关键区别**                                      |
|--------------------|----------------------------------|-------------------------------------------------|
| `Semaphore`        | 控制并发线程数量                 | 通过许可证动态调整，支持增/减资源                |
| `CountDownLatch`   | 等待一组任务完成                 | 一次性使用，计数器不可重置                       |
| `CyclicBarrier`    | 多线程协同到达屏障               | 可重复使用，所有线程互相等待                     |
| `ReentrantLock`    | 互斥访问共享资源                 | 仅允许单个线程访问                               |

---

### **注意事项**
1. **避免死锁**：`release()` 必须在 `finally` 块中调用，确保许可证释放。
2. **异常处理**：若线程在 `acquire()` 时被中断，需正确处理 `InterruptedException`。
3. **许可证数量**：初始许可证数量建议根据实际资源容量设置（如 CPU 核心数、连接池大小）。
4. **动态调整**：通过 `reducePermits()` 或 `increasePermits()`（需子类化）可动态调整许可证数量。

---

### **底层实现（基于 AQS）**
• **共享模式**：Semaphore 使用 AQS 的共享模式（`tryAcquireShared`、`tryReleaseShared`）。
• **非公平获取**（默认）：
  ```java
  final int nonfairTryAcquireShared(int acquires) {
      for (;;) {
          int available = getState();
          int remaining = available - acquires;
          if (remaining < 0 || compareAndSetState(available, remaining)) {
              return remaining;
          }
      }
  }
  ```

---

### **总结**
• **Semaphore 的核心价值**：通过许可证机制灵活控制并发度，适用于资源池、限流、任务分片等场景。
• **与锁的区别**：锁是“独占”资源，Semaphore 是“定量共享”资源。
• **性能优势**：非公平模式在高并发场景下可减少线程切换，提升吞吐量。

