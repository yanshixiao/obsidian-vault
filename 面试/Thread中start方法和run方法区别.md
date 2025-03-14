---

UID: 20250315001624 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-15
---


Thread 类中的 `start()` 和 `run()` 方法的区别主要体现在 **线程的启动方式** 和 **代码执行机制** 上。以下是详细对比：

---

### **1. `start()` 方法**
#### **作用**  
- **启动新线程**：调用 `start()` 会创建一个新的线程，并在新线程中异步执行 `run()` 方法中的代码。
- **线程生命周期管理**：线程会经历 `NEW`（新建）→ `RUNNABLE`（就绪/运行）的状态变化。

#### **特点**  
- **只能调用一次**：重复调用 `start()` 会抛出 `IllegalThreadStateException`（因为线程启动后不可重启）。
- **异步执行**：新线程独立于当前线程运行，代码并发执行。

#### **示例**  
```java
public class MyThread extends Thread {
    @Override
    public void run() {
        System.out.println("线程执行: " + Thread.currentThread().getName());
    }
}

public static void main(String[] args) {
    MyThread thread = new MyThread();
    thread.start(); // 启动新线程，输出如：线程执行: Thread-0
}
```

---

### **2. `run()` 方法**
#### **作用**  
- **普通方法调用**：直接调用 `run()` 不会创建新线程，而是将 `run()` 中的代码在当前线程中同步执行。
- **无线程管理**：不会触发线程状态的变化，代码按顺序执行。

#### **特点**  
- **可多次调用**：`run()` 是一个普通方法，可以被重复调用。
- **同步执行**：代码在当前线程中运行，没有并发效果。

#### **示例**  
```java
public static void main(String[] args) {
    MyThread thread = new MyThread();
    thread.run(); // 直接调用，输出如：线程执行: main（主线程）
}
```

---

### **3. 核心区别总结**
| **特性**              | **`start()`**                          | **`run()`**                          |
|-----------------------|---------------------------------------|--------------------------------------|
| **线程创建**          | 创建新线程，异步执行代码                  | 不创建新线程，代码在当前线程同步执行        |
| **调用次数**          | 只能调用一次                            | 可重复调用                            |
| **执行机制**          | 多线程并发                              | 单线程顺序执行                        |
| **线程状态管理**      | 触发线程生命周期变化（NEW → RUNNABLE）   | 不涉及线程状态变化                     |
| **典型用途**          | 启动多线程任务                          | 普通方法调用，无需多线程时使用            |

---

### **4. 常见误区**
#### **直接调用 `run()` 的陷阱**  
```java
Thread thread = new Thread(() -> {
    System.out.println("当前线程: " + Thread.currentThread().getName());
});
thread.run(); // 输出：当前线程: main（没有启动新线程！）
```
- 期望多线程执行时，必须调用 `start()`，而非 `run()`。

#### **重复调用 `start()` 的异常**  
```java
Thread thread = new Thread(() -> {});
thread.start();
thread.start(); // 抛出 IllegalThreadStateException
```

---

### **5. 底层机制**
- **`start()` 的底层实现**  
  `start()` 方法会调用 JVM 的本地方法 `start0()`，由操作系统分配资源并创建新线程。  
  新线程创建后，会自动调用 `run()` 方法。

- **`run()` 的默认实现**  
  ```java
  public void run() {
      if (target != null) {
          target.run(); // 实际执行的是传入 Runnable 的 run() 方法
      }
  }
  ```

---

### **6. 总结**
- **使用 `start()`**：需要多线程并发执行任务时调用，正确启动线程。
- **直接调用 `run()`**：仅在单线程中同步执行代码时使用，无并发效果。

**核心原则**：  
要实现多线程并发，必须通过 `start()` 启动线程，而非直接调用 `run()`！



