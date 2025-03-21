---

UID: 20250321141631 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-21
---


**AQS（AbstractQueuedSynchronizer）** 是 Java 并发包（`java.util.concurrent.locks`）的核心框架，用于**构建锁和同步器**（如 `ReentrantLock`、`Semaphore`、`CountDownLatch` 等）。它通过 **CLH 队列**（一种双向链表结构的线程等待队列）和 **CAS 操作**（Compare and Swap，保证原子性）实现线程的**高效阻塞与唤醒**。

---

### **AQS 的核心机制**
#### 1. **共享状态（State）**
   • 通过一个 `volatile int state` 变量表示同步状态（如锁的持有次数、信号量剩余资源数）。
   • 通过 `getState()`、`setState()`、`compareAndSetState()` 方法操作状态，依赖 CAS 保证原子性。

#### 2. **线程队列（CLH 队列）**
   • **双向链表**结构，存储等待获取资源的线程。
   • 每个线程封装为 `Node` 节点，包含前驱（`prev`）、后继（`next`）、等待状态（`waitStatus`）等信息。

#### 3. **两种模式**
   • **独占模式（Exclusive）**：同一时刻仅允许一个线程获取资源（如 `ReentrantLock`）。
   • **共享模式（Shared）**：允许多个线程同时获取资源（如 `Semaphore`）。

---

### **AQS 的工作原理**
1. **获取资源**：
   • 线程调用 `acquire()` 方法尝试获取资源：
     ```java
     public final void acquire(int arg) {
         if (!tryAcquire(arg) && 
             acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
             selfInterrupt();
     }
     ```
   • `tryAcquire(arg)`：子类实现的具体获取逻辑（如检查 `state` 是否可用）。
   • 若获取失败，线程被封装为 `Node` 加入队列尾部，并进入阻塞状态。

2. **释放资源**：
   • 线程调用 `release()` 方法释放资源：
     ```java
     public final boolean release(int arg) {
         if (tryRelease(arg)) {
             Node h = head;
             if (h != null && h.waitStatus != 0)
                 unparkSuccessor(h);
             return true;
         }
         return false;
     }
     ```
   • `tryRelease(arg)`：子类实现的具体释放逻辑（如减少 `state`）。
   • 唤醒队列中的下一个线程（通过 `LockSupport.unpark()`）。

---

### **AQS 的应用场景**
几乎所有的 Java 同步工具都基于 AQS 实现：
1. **ReentrantLock**：
   • 通过 `state` 记录锁的持有次数（可重入）。
   • 通过队列实现公平锁（先到先得）或非公平锁（允许插队）。

2. **Semaphore**：
   • `state` 表示可用信号量数量。
   • 线程获取信号量时 `state--`，释放时 `state++`。

3. **CountDownLatch**：
   • `state` 初始化为计数器的值。
   • 调用 `countDown()` 时 `state--`，当 `state=0` 时唤醒所有等待线程。

4. **ReentrantReadWriteLock**：
   • 将 `state` 高 16 位用于读锁，低 16 位用于写锁。

---

### **AQS 与 synchronized 的对比**
| **特性**            | **AQS**                          | **synchronized**               |
|----------------------|----------------------------------|---------------------------------|
| 实现方式             | 基于 Java 代码（队列 + CAS）     | 基于 JVM 指令（Monitor 机制）  |
| 灵活性               | 高（支持自定义锁策略）          | 低（语法级固定实现）           |
| 可中断性             | 支持（`lockInterruptibly()`）   | 不支持                         |
| 超时机制             | 支持（`tryAcquireNanos()`）      | 不支持                         |
| 公平性               | 支持公平/非公平锁               | 仅非公平锁                     |

---

### **如何自定义一个锁（基于 AQS）**
```java
public class SimpleLock extends AbstractQueuedSynchronizer {

    // 尝试获取锁（独占模式）
    @Override
    protected boolean tryAcquire(int arg) {
        if (compareAndSetState(0, 1)) {  // CAS 操作修改 state
            setExclusiveOwnerThread(Thread.currentThread());  // 设置当前持有线程
            return true;
        }
        return false;
    }

    // 释放锁
    @Override
    protected boolean tryRelease(int arg) {
        if (getState() == 0) throw new IllegalMonitorStateException();
        setExclusiveOwnerThread(null);
        setState(0);  // 不需要 CAS，因为只有持有线程能释放
        return true;
    }

    // 使用示例
    public void lock() {
        acquire(1);
    }

    public void unlock() {
        release(1);
    }
}
```

---

### **总结**
• **AQS 是 Java 并发编程的基石**，通过队列和 CAS 实现了高效的线程同步。
• **核心思想**：通过 `state` 管理资源状态，线程竞争失败时进入队列等待，资源释放时按规则唤醒后续线程。
• **适用场景**：需要自定义锁、信号量、计数器等同步工具时，优先基于 AQS 实现，避免重复造轮子。

