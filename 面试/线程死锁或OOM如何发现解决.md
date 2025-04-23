---

UID: 20250402173623 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-02
---



---

处理线程死锁和内存溢出（OOM）是 JVM 调优中的常见问题。以下是详细的 **诊断工具** 和 **解决步骤**，分为 **线程死锁** 和 **OOM** 两部分：

---

### **一、线程死锁的发现与解决**
#### **1. 如何发现线程死锁？**
**现象**：  
• 应用线程数暴增，但 CPU 使用率低（线程阻塞）。  
• 日志中出现 `java.lang.Thread.State: BLOCKED` 或 `Deadlock` 关键字。  
• 接口响应时间变长或无响应。

---

#### **2. 诊断工具与步骤**
**（1）使用 `jstack` 生成线程快照**  

```bash
jstack <pid> > thread_dump.txt  # 输出线程转储到文件
```
• **分析线程状态**：搜索 `BLOCKED` 或 `deadlock` 关键字。  
• **查找死锁链**：线程转储末尾会直接提示死锁的线程和锁信息。  

> [!question] 
> 如何定位pid
> [[如何定位进程 PID]]

**示例输出**：
```
Found one Java-level deadlock:
=============================
"Thread-1":
  waiting to lock monitor 0x00007f13d4001f58 (object 0x000000076ab76b58, a java.lang.Object),
  which is held by "Thread-0"
"Thread-0":
  waiting to lock monitor 0x00007f13d40034a8 (object 0x000000076ab76b68, a java.lang.Object),
  which is held by "Thread-1"
```


> [!question] stack文件如何解读？
> [[jstack生成快照之后呢，文件怎么解读]]


**（2）使用 `jcmd` 快速检测死锁**  
```bash
jcmd <pid> Thread.print  # 直接打印线程堆栈（包含死锁信息）
```

**（3）图形化工具**  
• **JConsole**：连接进程后，进入“线程”标签，点击“检测死锁”按钮。  
• **VisualVM**：安装 **Thread Dump Analyzer** 插件，自动分析死锁。  
• **Arthas**：实时监控线程状态，使用 `thread -b` 直接查找阻塞线程。  
  ```bash
  thread -b  # 显示当前阻塞其他线程的线程
  ```

---

#### **3. 解决死锁的步骤**
1. **定位代码**：根据线程转储中的类名和方法名，找到死锁代码位置。  
2. **分析锁顺序**：检查多个线程获取锁的顺序是否一致（避免交叉锁）。  
3. **修改代码**：  
   • 使用 `ReentrantLock` 替代 `synchronized`，并设置超时（`tryLock(timeout)`）。  
   • 统一锁的获取顺序，避免循环等待。  
4. **测试验证**：通过压力测试复现问题，确保死锁消失。

---

### **二、内存溢出（OOM）的发现与解决**
#### **1. 如何发现 OOM？**
**现象**：  
• 应用日志中出现 `java.lang.OutOfMemoryError` 异常（需注意不同子类型）。  
• 频繁 Full GC 但无法回收内存，最终进程崩溃。  
• 监控工具（如 Prometheus + Grafana）显示堆内存持续增长。

**OOM 类型**：  
• `java.lang.OutOfMemoryError: Java heap space`：堆内存不足。  
• `java.lang.OutOfMemoryError: Metaspace`：元空间（类元数据）不足。  
• `java.lang.OutOfMemoryError: Direct buffer memory`：直接内存溢出（NIO 使用不当）。  
• `java.lang.OutOfMemoryError: Unable to create new native thread`：线程数超过系统限制。

---

#### **2. 诊断工具与步骤（以堆内存 OOM 为例）**
**（1）配置 JVM 参数自动生成堆转储**  
在启动脚本中添加以下参数：  
```bash
-XX:+HeapDumpOnOutOfMemoryError  # OOM时自动生成堆转储
-XX:HeapDumpPath=/path/to/dump.hprof  # 指定转储文件路径
```

**（2）使用 `jmap` 手动生成堆转储**  
```bash
jmap -dump:format=b,file=heap.hprof <pid>  # 手动导出堆转储
```

**（3）使用 MAT（Memory Analyzer Tool）分析堆转储**  
1. **下载 MAT**：https://www.eclipse.org/mat/  
2. **打开堆转储文件**：  
   • 分析 **Leak Suspects**（泄漏嫌疑点）。  
   • 查看 **Dominator Tree**（支配树），找到占用内存最大的对象。  
3. **定位问题对象**：  
   • 检查对象的 **GC Roots** 引用链，确认是否有非预期的强引用（如静态集合类缓存）。  
   • 对比多个堆转储文件，观察对象数量的增长趋势。

**示例分析**：  
• 发现 `com.example.User` 对象占用了 80% 的堆内存。  
• 查看引用链，发现这些对象被一个静态 `HashMap` 缓存，未及时清理。

**（4）使用 `jstat` 监控内存和 GC 情况**  
```bash
jstat -gcutil <pid> 1000  # 每秒打印一次各区域内存使用率
```
• 观察 `O`（老年代使用率）是否持续增长，且 Full GC 后无法回收。

**（5）使用 Arthas 动态监控内存**  
```bash
dashboard  # 实时监控堆内存和线程
heapdump /path/to/dump.hprof  # 动态导出堆转储（无需重启）
```

---

#### **3. 解决 OOM 的步骤**
1. **确定 OOM 类型**：根据异常信息区分堆、元空间、直接内存等问题。  
2. **堆内存 OOM**：  
   • **分析堆转储**：找到占用内存最大的对象及引用链。  
   • **修复代码**：  
     ◦ 移除无效缓存（如使用弱引用 `WeakHashMap`）。  
     ◦ 关闭未释放的资源（如数据库连接、文件流）。  
     ◦ 优化数据结构和算法（避免一次性加载全部数据）。  
   • **调整 JVM 参数**：  
     ```bash
     -Xmx4g  # 增大堆内存（需结合物理机内存）
     -XX:+UseG1GC  # 使用G1回收器优化大堆内存
     ```
3. **元空间 OOM**：  
   • **原因**：动态生成大量类（如反射、CGLIB 代理）。  
   • **解决**：  
     ```bash
     -XX:MaxMetaspaceSize=512m  # 增加元空间上限
     -XX:+MetaspaceSize=256m    # 设置初始大小
     ```
4. **直接内存 OOM**：  
   • **原因**：未正确释放 `ByteBuffer` 或 Netty 的堆外内存。  
   • **解决**：  
     ◦ 检查代码中 `DirectByteBuffer` 是否调用 `cleaner.clean()`。  
     ◦ 调整直接内存大小：  
       ```bash
       -XX:MaxDirectMemorySize=1g
       ```

---

### **三、通用预防与优化建议**
1. **代码层面**：  
   • 避免在循环中创建大对象。  
   • 使用连接池、对象池复用资源。  
   • 定期清理无用的静态集合类数据。  
2. **监控与告警**：  
   • 集成 APM 工具（如 SkyWalking、Prometheus）监控堆内存和线程数。  
   • 设置阈值告警（如堆内存使用率 > 80%）。  
3. **压测验证**：  
   • 使用 JMeter 或 Gatling 模拟高并发场景，提前暴露死锁和 OOM。  
4. **定期分析**：  
   • 在测试环境定期生成堆转储和线程转储，用 MAT 或 VisualVM 分析潜在问题。

---

### **四、高级工具补充**
1. **JFR（Java Flight Recorder）**：  
   • 记录 JVM 详细事件（如内存分配、锁竞争）。  
   ```bash
   -XX:StartFlightRecording=duration=60s,filename=recording.jfr
   ```
2. **Async Profiler**：  
   • 生成火焰图分析 CPU 和锁竞争问题。  
   ```bash
   ./profiler.sh -d 30 -f flamegraph.html <pid>
   ```
3. **Arthas 高级命令**：  
   ```bash
   monitor -c 5 com.example.Service *  # 监控方法调用耗时
   trace com.example.Service process  # 跟踪方法内部调用路径
   ```

---

通过以上工具和步骤，可以系统化诊断和解决线程死锁与 OOM 问题。**核心要点**：  
• 死锁：快速获取线程转储，分析锁竞争关系。  
• OOM：生成堆转储，定位大对象引用链，结合代码优化和参数调整。

