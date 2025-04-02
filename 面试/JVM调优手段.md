---

UID: 20250402173415 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-02
---



JVM 调优的核心在于监控和分析 JVM 的运行状态（如内存、GC、线程等），再通过调整 JVM 参数优化性能。以下是常用的 **命令行工具** 和 **关键参数**，涵盖监控、诊断和调优三部分：

---

### **一、监控类命令**
#### **1. `jps` - 查看 Java 进程**
列出当前用户的所有 Java 进程 ID 和主类名。  
```bash
jps -l  # 显示完整主类名
jps -v  # 显示 JVM 启动参数
```

#### **2. `jstat` - 监控 JVM 统计信息**
实时查看堆内存、GC 活动、类加载情况等。  
```bash
jstat -gc <pid> 1000 10  # 每1秒打印一次GC情况，共10次
jstat -gcutil <pid>       # 显示堆内存各区域使用比例
jstat -class <pid>        # 类加载/卸载统计
```
**关键指标**：  
• `YGC/YGCT`：Young GC 次数/耗时  
• `FGC/FGCT`：Full GC 次数/耗时  
• `OGC/OU`：Old区容量/使用量  

---

#### **3. `jmap` - 生成堆内存快照**
导出堆内存详细信息或生成 Heap Dump 文件。  
```bash
jmap -heap <pid>          # 显示堆内存配置和使用情况
jmap -histo <pid>         # 统计对象内存占用（直方图）
jmap -dump:format=b,file=heap.hprof <pid>  # 导出堆转储文件
```


---

#### **4. `jstack` - 生成线程快照**
查看 Java 进程的线程堆栈信息，用于分析死锁、线程阻塞等问题。  
```bash
jstack <pid> > thread.txt  # 输出线程快照到文件
jstack -l <pid>           # 显示锁信息（排查死锁）
```

---

#### **5. `jinfo` - 查看/修改 JVM 参数**
实时查看或动态修改 JVM 参数（仅支持部分参数）。  
```bash
jinfo <pid>               # 显示所有参数
jinfo -flag +PrintGCDetails <pid>  # 动态开启GC日志
```

---

### **二、诊断类工具**
#### **1. `jcmd` - 多功能诊断命令**
集成多种功能，生成堆转储、线程快照、JFR 记录等。  
```bash
jcmd <pid> help                   # 查看支持的命令
jcmd <pid> GC.heap_info           # 显示堆信息
jcmd <pid> Thread.print           # 打印线程堆栈（类似jstack）
jcmd <pid> GC.run                 # 触发Full GC
jcmd <pid> JFR.start duration=60s filename=recording.jfr  # 开启JFR记录
```

#### **2. `jconsole` / `jvisualvm` - 图形化监控**
图形化工具，提供内存、线程、类的实时监控和分析。  
```bash
jconsole   # 启动JConsole
jvisualvm  # 启动VisualVM（支持插件扩展）
```

---

### **三、调优核心参数**
根据监控结果调整以下参数优化性能：

#### **1. 内存分配**
```bash
-Xms512m        # 初始堆大小（建议与-Xmx相同，避免动态扩容）
-Xmx2048m       # 最大堆大小
-Xmn512m        # 新生代大小（Young区）
-XX:MetaspaceSize=256m   # 元空间初始大小
-XX:MaxMetaspaceSize=512m  # 元空间最大大小
```

#### **2. 垃圾回收器选择**
```bash
-XX:+UseG1GC           # 启用G1回收器（默认JDK9+）
-XX:+UseConcMarkSweepGC  # CMS回收器（JDK8）
-XX:+UseParallelGC     # Parallel Scavenge（吞吐量优先）
-XX:+UseZGC            # 低延迟ZGC（JDK11+）
```

#### **3. GC 日志配置**
```bash
-XX:+PrintGCDetails          # 打印GC详细信息
-XX:+PrintGCDateStamps       # 显示GC发生时间
-Xloggc:/path/to/gc.log      # 输出GC日志到文件
-XX:+UseGCLogFileRotation    # 开启GC日志滚动
-XX:NumberOfGCLogFiles=5     # 保留5个历史文件
-XX:GCLogFileSize=10M       # 每个日志文件最大10M
```

#### **4. 其他优化参数**
```bash
-XX:MaxTenuringThreshold=15  # 对象晋升老年代的年龄阈值
-XX:SurvivorRatio=8          # Eden区与Survivor区的比例（8:1:1）
-XX:+HeapDumpOnOutOfMemoryError  # OOM时自动生成堆转储
-XX:HeapDumpPath=/path/to/dump.hprof  # 堆转储文件路径
```

---

### **四、调优实战步骤**
1. **监控发现问题**：  
   • 使用 `jstat` 观察 GC 频率和耗时。  
   • 用 `jmap` 分析堆内存对象分布。  
   • 用 `jstack` 排查线程死锁或阻塞。

2. **调整参数优化**：  
   • 根据对象生命周期调整堆大小（如增大新生代减少 Full GC）。  
   • 选择合适的垃圾回收器（如 G1 或 ZGC 降低延迟）。  
   • 优化元空间大小避免频繁 Full GC。

3. **验证效果**：  
   • 对比优化前后的 GC 日志（关注 Full GC 次数和暂停时间）。  
   • 使用 `jcmd` 或 VisualVM 验证内存泄漏是否缓解。

---

### **五、高级工具**
• **Arthas**：阿里开源的 Java 诊断工具，支持实时热修复、方法监控等。  
  ```bash
  arthas-boot.jar  # 启动后选择目标进程
  ```
• **JFR（Java Flight Recorder）**：内置性能分析工具，记录详细运行时事件。  
  ```bash
  -XX:StartFlightRecording=delay=5s,duration=60s,name=test,filename=recording.jfr
  ```

---

### **六、调优注意事项**
1. **避免过度优化**：优先解决频繁 Full GC、OOM、线程死锁等关键问题。  
2. **分代优化**：关注对象在 Young/Old 区的分布，调整分代比例。  
3. **结合业务场景**：高吞吐量优先选择 Parallel，低延迟选择 G1/ZGC。  
4. **测试环境验证**：生产环境调优前务必在测试环境充分验证。

---

通过以上命令和参数，结合监控数据，可以系统化优化 JVM 性能。如果需要更深入分析，可结合 **MAT（Memory Analyzer Tool）** 分析堆转储文件，或使用 **Async Profiler** 进行火焰图分析。

