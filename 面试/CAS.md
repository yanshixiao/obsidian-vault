---

UID: 20250311232535 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-11
---
### 乐观锁与 CAS 的核心概念

1. **乐观锁**  
   是一种无锁并发控制策略，**假设操作数据时不会发生冲突**，只在提交修改时检查是否有其他线程修改过数据。若冲突发生，则通过重试或回滚解决。  
   核心思想：**先操作，冲突再处理**（类似“编辑文档时不锁定，保存时检查冲突”）。

2. **CAS（Compare and Swap）**  
   是乐观锁的核心实现技术，通过一条**原子CPU指令**实现。它的操作逻辑是：  
   ```c
   CAS(address, expectedValue, newValue) {
     if (*address == expectedValue) {
       *address = newValue;
       return true;
     }
     return false;
   }
   ```

---

### Java 中的经典示例：AtomicInteger
```java
import java.util.concurrent.atomic.AtomicInteger;

public class CASExample {
    private static AtomicInteger counter = new AtomicInteger(0);

    public static void main(String[] args) {
        // 模拟 10 个线程并发自增
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                // 自旋重试直到成功
                while (true) {
                    int current = counter.get();
                    int next = current + 1;
                    if (counter.compareAndSet(current, next)) {
                        break;
                    }
                }
            }).start();
        }
        System.out.println("最终结果: " + counter.get()); // 正确输出 10
    }
}
```

#### 代码解析
- **`compareAndSet(current, next)`**  
  底层调用 `Unsafe` 类的 CAS 指令，比较当前值是否为 `current`：
  - 是 → 更新为 `next`，返回 `true`
  - 否 → 放弃更新，返回 `false`

- **自旋循环**  
  通过 `while(true)` 在冲突时自动重试，无需阻塞线程。

---

### 对比悲观锁（如 `synchronized`）
```java
private static int counter = 0;

public synchronized static void increment() {
    counter++; // 直接加锁保证原子性，但线程会阻塞
}
```

**CAS 的优势**  
- **无阻塞**：线程失败时通过自旋重试，避免上下文切换开销
- **高并发场景更高效**：尤其在低冲突情况下性能显著优于悲观锁

---

### 典型应用场景
1. **原子类**（`AtomicInteger`、`AtomicReference`）
2. **并发容器**（`ConcurrentHashMap` 的节点操作）
3. **自旋锁**（通过 CAS 实现轻量级锁）

---

### CAS 的局限性
1. **ABA 问题**  
   其他线程可能将值从 A → B → A，CAS 无法感知中间变化。解决方案：使用带版本号的原子类（如 `AtomicStampedReference`）。
2. **自旋开销**  
   高冲突场景下可能导致长时间重试，此时悲观锁更合适。




