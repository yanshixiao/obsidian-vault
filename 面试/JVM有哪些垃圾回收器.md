---

UID: 20250312233344 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-12
---

如果说垃圾收集算法是内存回收的方法论，那么垃圾收集器就是内存回收的具体实现。下图展示了7种作用于不同分代的收集器，其中用于回收新生代的收集器包括Serial、PraNew、Parallel Scavenge，回收老年代的收集器包括Serial Old、Parallel Old、CMS，还有用于回收整个Java堆的G1收集器。不同收集器之间的连线表示它们可以搭配使用。
![[JVM有哪些垃圾回收器.png]]
- Serial收集器（复制算法): 新生代单线程收集器，标记和清理都是单线程，优点是简单高效；

- ParNew收集器 (复制算法): 新生代收并行集器，实际上是Serial收集器的多线程版本，在多核CPU环境下有着比Serial更好的表现；

- Parallel Scavenge收集器 (复制算法): 新生代并行收集器，追求高吞吐量，高效利用 CPU。吞吐量 = 用户线程时间/(用户线程时间+GC线程时间)，高吞吐量可以高效率的利用CPU时间，尽快完成程序的运算任务，适合后台应用等对交互响应要求不高的场景；
> [!question] 
>高吞吐与后台应用响应要求不高的关联？
[[Parallel Scavenge收集器]]

- Serial Old收集器 (标记-整理算法): 老年代单线程收集器，Serial收集器的老年代版本；

- Parallel Old收集器 (标记-整理算法)： 老年代并行收集器，吞吐量优先，Parallel Scavenge收集器的老年代版本；

- CMS(Concurrent Mark Sweep)收集器（标记-清除算法）： 老年代并行收集器，以获取最短回收停顿时间为目标的收集器，具有高并发、低停顿的特点，追求最短GC回收停顿时间。

- G1(Garbage First)收集器 (标记-整理算法)： Java堆并行收集器，G1收集器是JDK1.7提供的一个新收集器，G1收集器基于“标记-整理”算法实现，也就是说不会产生内存碎片。此外，G1收集器不同于之前的收集器的一个重要特点是：G1回收的范围是整个Java堆(包括新生代，老年代)，而前六种收集器回收的范围仅限于新生代或老年代。

- ZGC （Z Garbage Collector）是一款由Oracle公司研发的，以低延迟为首要目标的一款垃圾收集器。它是基于动态Region内存布局，（暂时）不设年龄分代，使用了读屏障、染色指针和内存多重映射等技术来实现可并发的标记-整理算法的收集器。在 JDK 11 新加入，还在实验阶段，主要特点是：回收TB级内存（最大4T），停顿时间不超过10ms。优点：低停顿，高吞吐量， ZGC 收集过程中额外耗费的内存小。缺点：浮动垃圾。目前使用的非常少，真正普及还是需要写时间的。



新生代收集器：Serial、 ParNew 、 Parallel Scavenge

老年代收集器： CMS 、Serial Old、Parallel Old

整堆收集器： G1 ， ZGC (因为不涉年代不在图中)。




