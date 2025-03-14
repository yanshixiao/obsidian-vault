---

UID: 20250315003829 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-15
---

> [!note]
> 和interrupt()方法不是一回事


在Java中，`interrupted()` 和 `isInterrupted()` 方法都与线程的中断状态相关，但它们在作用对象、行为和使用场景上有显著区别。以下是两者的详细对比：

---

### **1. 核心区别总结**
| **特性**               | **`Thread.interrupted()`**               | **`thread.isInterrupted()`**             |
|------------------------|------------------------------------------|------------------------------------------|
| **方法类型**           | 静态方法（通过 `Thread` 类调用）           | 实例方法（通过线程对象调用）                |
| **作用对象**           | 检查并清除 **当前线程** 的中断状态          | 检查 **指定线程** 的中断状态               |
| **是否清除中断状态**    | **是**（调用后中断状态会被重置为 `false`） | **否**（仅检查，不修改中断状态）           |
| **使用场景**           | 响应当前线程的中断并清理状态                | 检查其他线程是否被中断（不影响其状态）       |

---

### **2. 方法定义与行为**
#### **(1) `Thread.interrupted()`**
- **定义**：
  ```java
  public static boolean interrupted() {
      return currentThread().isInterrupted(true); // 清除中断状态
  }
  ```
- **行为**：
  - 检查 **当前正在执行的线程** 是否被中断。
  - **清除中断状态**：若当前线程已被中断，调用后会将中断状态重置为 `false`。

#### **(2) `thread.isInterrupted()`**
- **定义**：
  ```java
  public boolean isInterrupted() {
      return isInterrupted(false); // 不清除中断状态
  }
  ```
- **行为**：
  - 检查 **调用该方法的线程对象** 是否被中断。
  - **不修改中断状态**：无论结果如何，线程的中断状态保持不变。

---

### **3. 示例代码验证**
```java
public class InterruptExample {
    public static void main(String[] args) {
        Thread worker = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                // 模拟工作
            }
            System.out.println("Worker线程被中断，退出循环。");
        });

        worker.start();

        // 中断worker线程
        worker.interrupt();

        // 检查worker线程的中断状态（不修改状态）
        System.out.println("worker.isInterrupted(): " + worker.isInterrupted()); // true
        System.out.println("worker.isInterrupted(): " + worker.isInterrupted()); // true

        // 中断主线程
        Thread.currentThread().interrupt();

        // 检查主线程的中断状态（会清除状态）
        System.out.println("Thread.interrupted(): " + Thread.interrupted());     // true
        System.out.println("Thread.interrupted(): " + Thread.interrupted());     // false
    }
}
```

#### **输出结果**：
```
worker.isInterrupted(): true
worker.isInterrupted(): true
Worker线程被中断，退出循环。
Thread.interrupted(): true
Thread.interrupted(): false
```

---

### **4. 使用场景分析**
#### **(1) `Thread.interrupted()`**
- **适用场景**：  
  在需要 **响应当前线程中断并清理状态** 时使用。例如，在捕获 `InterruptedException` 后，重新检查中断状态并清理：
  ```java
  public void run() {
      while (!Thread.interrupted()) { // 检查并清除中断状态
          try {
              Thread.sleep(1000);
          } catch (InterruptedException e) {
              Thread.currentThread().interrupt(); // 重新设置中断状态
          }
      }
  }
  ```

#### **(2) `thread.isInterrupted()`**
- **适用场景**：  
  需要 **监控其他线程的中断状态**（如父线程监控子线程）而不影响其状态时使用：
  ```java
  Thread worker = new Thread(() -> {
      // 长时间任务...
  });
  worker.start();

  // 外部检查worker是否被中断
  if (worker.isInterrupted()) {
      System.out.println("Worker线程已被中断。");
  }
  ```

---

### **5. 常见误区**
#### **(1) 错误调用静态方法**
```java
Thread thread = new Thread(() -> {});
thread.interrupt();

// 错误：实际调用的是 Thread.interrupted()，检查的是主线程的中断状态！
System.out.println(thread.interrupted()); // 输出 false（除非主线程被中断）
```
- **正确做法**：使用 `thread.isInterrupted()` 检查指定线程的中断状态。

#### **(2) 忽略中断状态清除**
```java
if (Thread.interrupted()) {
    // 处理中断...
    // 中断状态已被清除，后续代码无法感知中断！
}
```
- **正确做法**：若需保留中断状态，应在处理前调用 `isInterrupted()`，或处理后重新设置中断标志。

---

### **6. 总结**
| **操作目的**             | **选择的方法**               |
|-------------------------|-----------------------------|
| 检查并清除当前线程中断状态 | `Thread.interrupted()`      |
| 检查其他线程的中断状态     | `thread.isInterrupted()`    |
| 需要保留中断状态         | `thread.isInterrupted()`    |

**核心原则**：  
- 明确要操作的是当前线程还是其他线程。
- 根据是否需要清除中断状态选择方法。

