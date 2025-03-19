---

UID: 20250319221414 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-19
---




（由于技术原因，联网搜索暂不可用）

Thread类中的`yield()`方法用于提示当前线程愿意让出CPU资源，以便其他线程有机会执行。以下是其核心作用和使用注意事项：

### 主要作用
1. **协作式调度**：调用`yield()`的线程会从**运行状态**转为**就绪状态**，让线程调度器重新选择要执行的线程（可能包括当前线程自身）。
2. **提高线程公平性**：在长时间运行的循环中调用`yield()`，可避免当前线程独占CPU，给其他线程（尤其是相同优先级的线程）运行机会。
3. **非强制性**：`yield()`仅是向调度器的**建议**，实际是否让出CPU取决于系统实现，可能被忽略。

### 与`sleep()`的区别
| 特性               | `yield()`                          | `sleep()`                          |
|--------------------|------------------------------------|------------------------------------|
| 状态转换           | 运行 → 就绪                       | 运行 → 阻塞（指定时间）           |
| 恢复条件           | 可能立即重新被调度                | 等待时间结束后进入就绪状态        |
| 参数依赖           | 无参数                            | 需指定休眠时间                    |

### 使用场景示例
```java
public class YieldExample implements Runnable {
    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println(Thread.currentThread().getName() + ": " + i);
            Thread.yield(); // 提示让出CPU
        }
    }

    public static void main(String[] args) {
        Thread t1 = new Thread(new YieldExample(), "Thread-1");
        Thread t2 = new Thread(new YieldExample(), "Thread-2");
        t1.start();
        t2.start();
    }
}
```
**可能输出**：两个线程交替执行，但实际结果因系统调度而异。

### 注意事项
- **优先级影响**：理论上，`yield()`会优先让相同或更高优先级线程运行，但线程优先级在不同系统上的实现不一致。
- **不可靠性**：依赖`yield()`控制线程顺序可能导致不可预测的结果，应结合锁、`wait()/notify()`等同步机制。
- **性能测试**：在单核和多核环境下，`yield()`的表现可能差异显著。

### 总结
`yield()`适用于优化线程协作，但因其不确定性，在需要精确控制线程行为的场景中，建议使用更可靠的同步工具（如`Lock`、`Condition`或并发框架）。
