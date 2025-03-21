---

UID: 20250321133153 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-21
---




CyclicBarrier 和 CountDownLatch 是 Java 并发包中两个常用的同步工具类，虽然都能协调多线程，但设计目标和应用场景有显著差异。以下是它们的核心区别：

---

### **1. 设计目标**
| **特性**               | **CyclicBarrier**                            | **CountDownLatch**                     |
|-------------------------|---------------------------------------------|----------------------------------------|
| **核心用途**           | 多个线程相互等待，到达屏障后继续执行         | 一个或多个线程等待其他线程完成操作      |
| **重用性**             | 支持重复使用（自动或手动重置）               | 一次性使用，计数器归零后不可重置        |
| **触发机制**           | 由线程自身调用 `await()` 触发等待             | 由外部线程调用 `countDown()` 减少计数器 |

---

### **2. 使用场景**
#### **CyclicBarrier**
- **场景**：多线程分阶段任务，需在所有线程完成某阶段后，再一起进入下一阶段。
  - 例如：并行计算中，多个线程处理数据分片，需全部完成分片计算后再汇总结果。
- **代码示例**：
  ```java
  CyclicBarrier barrier = new CyclicBarrier(3, () -> 
      System.out.println("所有线程到达屏障，开始下一阶段"));
  
  Runnable task = () -> {
      System.out.println(Thread.currentThread().getName() + " 到达屏障");
      try {
          barrier.await();
      } catch (Exception e) {
          e.printStackTrace();
      }
      System.out.println(Thread.currentThread().getName() + " 继续执行");
  };
  
  new Thread(task).start();
  new Thread(task).start();
  new Thread(task).start();
  ```
  **输出**：
  ```
  Thread-0 到达屏障
  Thread-1 到达屏障
  Thread-2 到达屏障
  所有线程到达屏障，开始下一阶段
  Thread-0 继续执行
  Thread-1 继续执行
  Thread-2 继续执行
  ```

#### **CountDownLatch**
- **场景**：主线程等待多个子线程完成初始化，或一个线程等待多个依赖条件就绪。
  - 例如：启动服务时，主线程需等待所有组件初始化完成后再启动。
- **代码示例**：
  ```java
  CountDownLatch latch = new CountDownLatch(3);
  
  Runnable task = () -> {
      System.out.println(Thread.currentThread().getName() + " 完成任务");
      latch.countDown();
  };
  
  new Thread(task).start();
  new Thread(task).start();
  new Thread(task).start();
  
  latch.await();
  System.out.println("所有任务完成，主线程继续");
  ```
  **输出**：
  ```
  Thread-0 完成任务
  Thread-1 完成任务
  Thread-2 完成任务
  所有任务完成，主线程继续
  ```

---

### **3. 关键区别**
| **维度**               | **CyclicBarrier**                            | **CountDownLatch**                     |
|------------------------|----------------------------------------------|----------------------------------------|
| **参与者角色**         | 所有线程平等，互相等待                       | 分离“等待线程”和“完成任务线程”         |
| **计数器重置**         | 自动重置（`reset()` 可手动重置）              | 计数器归零后不可重置                   |
| **回调支持**           | 支持（通过构造函数传入 `Runnable`）           | 不支持                                 |
| **异常处理**           | 线程中断会破坏屏障，触发 `BrokenBarrierException` | 计数器减少不受线程中断影响             |

---

### **4. 典型应用对比**
#### **CyclicBarrier 的复用性**
```java
CyclicBarrier barrier = new CyclicBarrier(2);

// 第一次使用
new Thread(() -> { barrier.await(); }).start();
new Thread(() -> { barrier.await(); }).start();

// 第二次复用（CountDownLatch 无法做到）
new Thread(() -> { barrier.await(); }).start();
new Thread(() -> { barrier.await(); }).start();
```

#### **CountDownLatch 的一性次**
```java
CountDownLatch latch = new CountDownLatch(2);

// 第一次使用
new Thread(() -> { latch.countDown(); }).start();
new Thread(() -> { latch.countDown(); }).start();
latch.await();

// 无法重复使用，必须新建实例
CountDownLatch newLatch = new CountDownLatch(2);
```

---

### **5. 总结**
- **CyclicBarrier**：  
  适合多线程协同工作，需要重复同步的场景（如分阶段计算），支持自动重置和回调。
  
- **CountDownLatch**：  
  适合一次性任务等待（如启动检查、资源初始化），强调外部线程对任务完成的监控。

选择时需根据 **线程协作模式**（互相等待 vs 单向等待）和 **重用需求** 决定使用哪个工具。
