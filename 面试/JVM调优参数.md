---

UID: 20250312005326 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-12
---


以下是 JVM 常用调优参数的分类整理及说明，帮助优化内存管理、垃圾回收（GC）性能和系统稳定性：

---

### **一、内存配置参数**
#### **1. 堆内存**
- **`-Xms`**：初始堆大小（默认物理内存的 1/64）  
  `-Xms4g`  
- **`-Xmx`**：最大堆大小（默认物理内存的 1/4）  
  `-Xmx8g`  
  **建议**：生产环境 `-Xms` 和 `-Xmx` 设为相同值，避免堆动态扩容导致性能波动。

- **`-Xmn`**：年轻代（Young Generation）大小  
  `-Xmn2g`  
  **建议**：年轻代占堆的 25%~50%（如 G1 无需手动设置）。

- **`-XX:NewRatio`**：老年代与年轻代的比例  
  `-XX:NewRatio=2`（老年代占 2/3，年轻代占 1/3）

- **`-XX:SurvivorRatio`**：Eden 区与 Survivor 区的比例  
  `-XX:SurvivorRatio=8`（Eden 占 8/10，每个 Survivor 占 1/10）

---

#### **2. 非堆内存**
- **`-XX:MetaspaceSize`**：元空间初始大小（Java 8+）  
  `-XX:MetaspaceSize=256m`  
- **`-XX:MaxMetaspaceSize`**：元空间最大大小  
  `-XX:MaxMetaspaceSize=512m`  

- **`-Xss`**：线程栈大小  
  `-Xss512k`（默认 1MB，越小可创建更多线程）

---

### **二、垃圾回收器配置**
#### **1. 通用参数**
- **`-XX:+UseSerialGC`**：启用 Serial 收集器（单线程，适合小应用）
- **`-XX:+UseParallelGC`**：启用 Parallel Scavenge（吞吐量优先）
- **`-XX:+UseConcMarkSweepGC`**：启用 CMS 收集器（低延迟，已废弃）
- **`-XX:+UseG1GC`**：启用 G1 收集器（Java 9+ 默认，推荐生产环境）

#### **2. G1 专用参数**
- **`-XX:MaxGCPauseMillis`**：目标最大 GC 停顿时间  
  `-XX:MaxGCPauseMillis=200`（单位毫秒）
- **`-XX:InitiatingHeapOccupancyPercent`**：触发并发标记的堆占用阈值  
  `-XX:InitiatingHeapOccupancyPercent=45`（默认 45%）

#### **3. CMS 专用参数（已废弃）**
- **`-XX:CMSInitiatingOccupancyFraction`**：触发 CMS 的堆占用阈值  
  `-XX:CMSInitiatingOccupancyFraction=75`

---

### **三、GC 日志与监控**
- **`-XX:+PrintGCDetails`**：打印详细 GC 日志
- **`-XX:+PrintGCDateStamps`**：记录 GC 发生的时间
- **`-Xloggc:<file>`**：指定 GC 日志文件路径  
  `-Xloggc:/logs/gc.log`
- **`-XX:+HeapDumpOnOutOfMemoryError`**：内存溢出时生成堆转储文件
- **`-XX:HeapDumpPath=<path>`**：指定堆转储文件路径  
  `-XX:HeapDumpPath=/logs/heapdump.hprof`

---

### **四、性能优化参数**
- **`-XX:+DisableExplicitGC`**：禁用 `System.gc()` 调用（避免误触发 Full GC）
- **`-XX:+ExplicitGCInvokesConcurrent`**：使用并发方式处理 `System.gc()`（如配合 CMS/G1）
- **`-XX:ParallelGCThreads`**：并行 GC 线程数  
  `-XX:ParallelGCThreads=4`（根据 CPU 核数调整）
- **`-XX:ConcGCThreads`**：并发 GC 线程数（G1/CMS）  
  `-XX:ConcGCThreads=2`

---

### **五、故障排查参数**
- **`-XX:ErrorFile=<file>`**：JVM 崩溃日志路径  
  `-XX:ErrorFile=/logs/hs_err_pid%p.log`
- **`-XX:NativeMemoryTracking=summary`**：跟踪 Native 内存使用  
  配合 `jcmd <pid> VM.native_memory summary` 使用

---

### **六、生产环境推荐配置示例**
```bash
# 基础内存配置
-Xms8g -Xmx8g  
-XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m  

# G1 垃圾回收器
-XX:+UseG1GC  
-XX:MaxGCPauseMillis=200  
-XX:InitiatingHeapOccupancyPercent=45  

# GC 日志与监控
-XX:+PrintGCDetails  
-XX:+PrintGCDateStamps  
-Xloggc:/logs/gc.log  
-XX:+HeapDumpOnOutOfMemoryError  
-XX:HeapDumpPath=/logs/heapdump.hprof  

# 其他优化
-XX:+DisableExplicitGC  
-XX:ParallelGCThreads=4  
```

---

### **调优建议**
1. **堆内存**：根据应用对象生命周期调整年轻代与老年代比例。
2. **GC 选择**：高吞吐选 Parallel，低延迟选 G1。
3. **监控工具**：结合 `jstat`、`jvisualvm`、`GCViewer` 分析日志。
4. **逐步优化**：每次只调整 1-2 个参数，通过压测验证效果。


