---

UID: 20250319223351 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-19
---
在Java中，`synchronized`关键字是实现线程同步的核心机制，用于解决多线程环境下的**线程安全问题**（如数据竞争、原子性破坏）。以下是关于`synchronized`的全面解析：

---

### 一、`synchronized`的核心作用
1. **原子性保证**  
   确保被修饰的代码块或方法在同一时间只能被一个线程执行（互斥访问）。
2. **内存可见性**  
   通过锁的获取与释放，强制线程从主内存中读取共享变量的最新值（遵循`JMM`的`happens-before`规则）。
3. **可重入性**  
   同一个线程可以重复获取同一把锁，避免自身死锁（如递归调用）。

---

### 二、`synchronized`的三种使用方式
#### 1. 修饰实例方法
- **锁对象**：当前实例对象（`this`）
- **示例**：
  ```java
  public class Counter {
      private int count = 0;

      public synchronized void increment() {
          count++; // 线程安全的操作
      }
  }
  ```

#### 2. 修饰静态方法
- **锁对象**：类的`Class`对象（如`Counter.class`）
- **示例**：
  ```java
  public class Logger {
      public static synchronized void log(String message) {
          // 线程安全的静态方法
      }
  }
  ```

#### 3. 修饰代码块
- **锁对象**：显式指定任意对象（推荐使用与共享资源相关的对象）
- **示例**：
  ```java
  public class OrderService {
      private final Object lock = new Object();

      public void processOrder() {
          synchronized(lock) { // 使用专用锁对象
              // 线程安全的代码块
          }
      }
  }
  ```

---

### 三、底层实现原理
#### 1. Monitor机制
- 每个Java对象都有一个关联的**Monitor（监视器锁）**。
- 当线程进入`synchronized`代码块时，会尝试通过`monitorenter`指令获取对象的Monitor所有权。
- 退出时通过`monitorexit`指令释放锁。

#### 2. 字节码层面
编译后的字节码中会插入`monitorenter`和`monitorexit`指令：
```java
public void syncMethod();
  Code:
     0: aload_0
     1: dup
     2: astore_1
     3: monitorenter     // 获取锁
     4: aload_1
     5: monitorexit      // 正常退出释放锁
     6: goto          14
     9: astore_2
    10: aload_1
    11: monitorexit      // 异常退出释放锁
    12: aload_2
    13: athrow
    14: return
```

#### 3. 锁升级优化（JDK 1.6+）
- **偏向锁**：无竞争时，标记线程ID避免CAS操作。
- **轻量级锁**：通过CAS自旋尝试获取锁。
- **重量级锁**：竞争激烈时，升级为操作系统级别的互斥锁。

---

### 四、关键特性与注意事项
#### 1. 锁的范围控制
- **尽量缩小同步范围**：仅同步必要的代码块，减少锁竞争。
  ```java
  // 不推荐：同步整个方法
  public synchronized void process() { /* 大量非同步逻辑 */ }

  // 推荐：仅同步关键部分
  public void process() {
      // 非同步逻辑
      synchronized(this) {
          // 关键操作
      }
  }
  ```

#### 2. 锁对象选择
- **避免使用字符串常量或基础类型**：
  ```java
  // 风险：字符串字面量驻留可能导致意外锁竞争
  synchronized("LOCK") { ... }

  // 推荐：使用专用对象
  private final Object lock = new Object();
  ```

#### 3. 死锁风险
- 避免嵌套获取多个锁，或使用**固定顺序获取锁**：
  ```java
  // 错误示例：嵌套锁可能死锁
  synchronized(lockA) {
      synchronized(lockB) { ... }
  }

  // 正确示例：固定获取顺序
  if (lockA.hashCode() < lockB.hashCode()) {
      synchronized(lockA) { synchronized(lockB) { ... } }
  } else {
      synchronized(lockB) { synchronized(lockA) { ... } }
  }
  ```

---

### 五、`synchronized` vs `Lock`
| 特性               | `synchronized`                          | `Lock`（如`ReentrantLock`）           |
|--------------------|-----------------------------------------|---------------------------------------|
| **获取方式**       | 自动获取与释放                          | 需手动调用`lock()`和`unlock()`        |
| **灵活性**         | 仅支持非公平锁                          | 支持公平锁与非公平锁                  |
| **条件变量**       | 通过`wait()/notify()`实现               | 通过`Condition`提供更细粒度的等待通知 |
| **超时获取锁**     | 不支持                                  | 支持`tryLock(timeout)`                |
| **可中断性**       | 等待锁时不可中断                        | 支持中断等待                          |

---

### 六、实际应用场景
#### 1. 线程安全计数器
```java
public class SafeCounter {
    private int count = 0;
    
    public synchronized void add() {
        count++;
    }
}
```

#### 2. 单例模式（双重检查锁定）
```java
public class Singleton {
    private static volatile Singleton instance;

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized(Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

#### 3. 资源池管理
```java
public class ConnectionPool {
    private final List<Connection> pool = new ArrayList<>();
    private final Object lock = new Object();

    public Connection getConnection() {
        synchronized(lock) {
            if (!pool.isEmpty()) {
                return pool.remove(0);
            }
            return createNewConnection();
        }
    }
}
```

---

### 七、常见误区
1. **错误认为`synchronized`方法锁的是代码**  
   实际锁的是调用该方法的**对象实例**或**类的Class对象**。
2. **过度同步**  
   将整个方法标记为`synchronized`可能导致性能下降。
3. **忽略可见性问题**  
   即使使用`synchronized`，仍需注意共享变量的正确声明（如使用`volatile`）。

---

### 总结
`synchronized`是Java中最基础的线程同步工具，适用于大多数简单并发场景。但在高并发或需要更灵活控制的场景中，建议结合`java.util.concurrent`包中的高级锁（如`ReentrantLock`、`StampedLock`）或其他并发工具使用。理解其底层原理和最佳实践，能有效避免线程安全问题并优化性能。




