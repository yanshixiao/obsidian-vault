---

UID: 20241223011203 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-23
---


触发 **Full GC（全量垃圾回收）** 的条件主要与内存分配、垃圾收集器策略及 JVM 配置相关。以下是常见的触发场景：

---

### **1. 显式调用 `System.gc()`**
- **原因**：代码中调用 `System.gc()` 或 `Runtime.getRuntime().gc()`，会建议 JVM 执行 Full GC。
- **注意**：可通过 `-XX:+DisableExplicitGC` 禁用显式触发，避免不必要的性能损耗。

---

### **2. 老年代空间不足**
- **晋升失败**：年轻代对象在 Minor GC 后需晋升到老年代，但老年代剩余空间不足。
  - **常见场景**：短生命周期对象意外进入老年代（如大对象、长期存活的缓存对象）。
- **内存泄漏**：老年代中对象无法回收，逐渐耗尽空间。

---

### **3. 空间分配担保失败**
- **Minor GC 前的检查**：若老年代连续空间 < **年轻代存活对象总大小**（或历次晋升平均大小），触发 Full GC。
- **目的**：确保 Minor GC 后存活对象能安全晋升到老年代。

---

### **4. 元空间（Metaspace）或永久代（PermGen）不足**
- **JDK 8+ 元空间不足**：加载的类过多或存在类加载器泄漏时，元空间触发 Full GC。
- **JDK 7 及之前**：永久代（PermGen）空间不足（如动态生成大量类，如反射、CGLib）。

---

### **5. 大对象分配失败**
- **直接进入老年代**：大对象（通过 `-XX:PretenureSizeThreshold` 指定）需老年代连续空间，不足时触发 Full GC。
- **示例**：超大数组或未合理分页的数据结构。

---

### **6. CMS/G1 的并发模式失败（Concurrent Mode Failure）**
- **CMS 回收器**：并发清理阶段用户线程同时运行，若新对象分配速度过快，老年代空间不足，退化为 Serial Old 触发 Full GC。
- **G1 回收器**：若回收速度跟不上分配速度，触发 Full GC（Serial Old）。

---

### **7. 其他特殊场景**
- **堆内存快照（Heap Dump）**：生成堆转储文件时可能触发 Full GC。
- **RMI 等机制**：分布式垃圾回收（如 RMI 的定时触发）。

---

### **排查与优化建议**
1. **监控工具**：使用 `jstat`、`jconsole` 或 `VisualVM` 观察内存使用和 GC 日志（`-XX:+PrintGCDetails`）。
2. **参数调优**：
   - 调整堆大小（`-Xms`, `-Xmx`）。
   - 优化年轻代与老年代比例（`-XX:NewRatio`）。
   - 调整元空间上限（`-XX:MaxMetaspaceSize`）。
3. **代码优化**：
   - 避免内存泄漏（如未关闭的资源、静态集合滥用）。
   - 减少大对象分配，优化数据结构。

---

通过分析触发原因并针对性优化，可减少 Full GC 频率，提升应用性能。




