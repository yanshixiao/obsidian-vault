---

UID: 20250315004827 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-15
---
在 Java 中，`synchronized` 和 `ReentrantLock` 都是用于实现线程同步的机制，但它们在功能、灵活性和使用方式上有显著区别。以下是两者的详细对比：

---

### **1. 核心区别总结**
| **特性**                | **`synchronized`**                               | **`ReentrantLock`**                              |
|-------------------------|-------------------------------------------------|-------------------------------------------------|
| **实现机制**            | 基于 JVM 内置锁（监视器锁）                        | 基于 JDK 实现的显式锁（`java.util.concurrent` 包） |
| **锁的获取与释放**      | 自动获取和释放（隐式管理）                        | 手动获取和释放（需在 `finally` 中调用 `unlock()`） |
| **可中断性**            | 不支持中断等待锁的线程                           | 支持通过 `lockInterruptibly()` 中断等待            |
| **公平性**              | 默认非公平锁，不可配置                           | 支持公平锁和非公平锁（构造参数指定）                |
| **条件变量**            | 通过 `wait()`/`notify()` 实现单一条件等待          | 支持多个条件变量（`Condition` 对象）               |
| **尝试获取锁**          | 不支持                                           | 支持 `tryLock()`（尝试获取或超时等待）              |
| **性能**                | Java 6 后优化较好（偏向锁、轻量级锁等）            | 高竞争场景下性能更优（如复杂同步逻辑）               |
| **代码复杂度**          | 简单易用，代码简洁                                | 更灵活但需手动管理，易遗漏释放锁                    |

---

### **2. 详细对比**
#### **(1) 实现机制**
- **`synchronized`**  
  - 是 Java 关键字，基于 JVM 的监视器锁（Monitor）实现。
  - 锁与对象关联，每个对象有一个内置锁。
  - 通过字节码指令 `monitorenter` 和 `monitorexit` 实现。

- **`ReentrantLock`**  
  - 是 JDK 提供的显式锁类，基于 `AbstractQueuedSynchronizer`（AQS）实现。
  - 需要手动调用 `lock()` 和 `unlock()` 管理锁的生命周期。

#### **(2) 锁的获取与释放**
- **`synchronized`**  
  ```java
  synchronized (lock) {
      // 同步代码块（自动加锁和解锁）
  }
  ```
  - **无需手动释放**，代码块执行完毕或发生异常时自动释放锁。

- **`ReentrantLock`**  
  ```java
  ReentrantLock lock = new ReentrantLock();
  lock.lock();
  try {
      // 同步代码块
  } finally {
      lock.unlock(); // 必须手动释放，否则可能死锁
  }
  ```
  - **必须显式释放锁**，通常在 `finally` 块中调用 `unlock()`。

#### **(3) 可中断性**
- **`synchronized`**  
  - 线程在等待锁时不可中断，只能一直阻塞。

- **`ReentrantLock`**  
  - 支持通过 `lockInterruptibly()` 方法中断等待锁的线程：
    ```java
    try {
        lock.lockInterruptibly(); // 可中断的锁获取
        // 同步代码
    } catch (InterruptedException e) {
        // 处理中断
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
    ```

#### **(4) 公平性**
- **`synchronized`**  
  - **默认非公平锁**，不保证等待时间最长的线程优先获取锁。

- **`ReentrantLock`**  
  - 可通过构造函数选择公平锁或非公平锁：
    ```java
    ReentrantLock fairLock = new ReentrantLock(true); // 公平锁
    ReentrantLock unfairLock = new ReentrantLock();    // 非公平锁（默认）
    ```
  - **公平锁**：按请求锁的顺序分配，避免线程饥饿。
  - **非公平锁**：允许插队，吞吐量更高。

#### **(5) 条件变量**
- **`synchronized`**  
  - 只能通过 `wait()`、`notify()` 和 `notifyAll()` 实现单一条件的等待/通知。
    ```java
    synchronized (lock) {
        while (conditionNotMet) {
            lock.wait();
        }
        // 执行业务逻辑
        lock.notifyAll();
    }
    ```

- **`ReentrantLock`**  
  - 支持多个条件变量（`Condition`），允许更精细的线程控制：
    ```java
    ReentrantLock lock = new ReentrantLock();
    Condition condition1 = lock.newCondition();
    Condition condition2 = lock.newCondition();

    lock.lock();
    try {
        while (condition1NotMet) {
            condition1.await(); // 等待条件1
        }
        // 执行业务逻辑
        condition2.signal();    // 唤醒等待条件2的线程
    } finally {
        lock.unlock();
    }
    ```

#### **(6) 尝试获取锁**
- **`synchronized`**  
  - 无法尝试获取锁，若锁被占用，线程会直接阻塞。

- **`ReentrantLock`**  
  - 支持通过 `tryLock()` 尝试获取锁，避免无限等待：
    ```java
    if (lock.tryLock(3, TimeUnit.SECONDS)) { // 最多等待3秒
        try {
            // 获取锁成功
        } finally {
            lock.unlock();
        }
    } else {
        // 超时未获取锁
    }
    ```

#### **(7) 性能**
- **低竞争场景**：  
  - `synchronized` 经过 JVM 优化（偏向锁、轻量级锁），性能与 `ReentrantLock` 接近。
- **高竞争场景**：  
  - `ReentrantLock` 的吞吐量更高，尤其是在需要复杂锁策略时（如公平锁、条件变量）。

---

### **3. 使用场景建议**
| **场景**                  | **推荐选择**       | **理由**                                              |
|--------------------------|-------------------|-----------------------------------------------------|
| **简单同步需求**          | `synchronized`    | 代码简洁，无需手动管理锁，避免遗漏释放锁的风险。             |
| **需要可中断锁或超时控制** | `ReentrantLock`   | 支持 `lockInterruptibly()` 和 `tryLock()`，灵活性更高。 |
| **公平锁需求**            | `ReentrantLock`   | 可配置公平锁，避免线程饥饿。                              |
| **复杂条件同步**          | `ReentrantLock`   | 支持多个 `Condition`，实现精细的线程等待/通知机制。          |
| **高并发优化场景**        | `ReentrantLock`   | 在高竞争环境下性能更优，尤其是结合 `tryLock()` 使用。        |

---

### **4. 总结**
- **`synchronized`**：  
  **优点**：简单易用，自动管理锁，适合大多数基础同步场景。  
  **缺点**：功能有限，无法中断或超时控制，不支持公平锁。

- **`ReentrantLock`**：  
  **优点**：功能丰富（可中断、公平锁、条件变量），适合复杂同步需求。  
  **缺点**：需手动管理锁，代码复杂度高，易出错。

**核心原则**：  
- 优先使用 `synchronized`，除非需要 `ReentrantLock` 的高级功能。
- 在需要精细控制锁行为时，选择 `ReentrantLock`。




