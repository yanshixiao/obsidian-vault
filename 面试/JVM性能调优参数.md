---

UID: 20241224013516 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2024-12-24
---

简单点讲如下：

- 设定堆内存大小

-Xmx：堆内存最大限制。

- 设定新生代大小。 新生代不宜太小，否则会有大量对象涌入老年代

-XX:NewSize：新生代大小

-XX:NewRatio 新生代和老生代占比

-XX:SurvivorRatio：伊甸园空间和幸存者空间的占比

- 设定垃圾回收器 年轻代用 -XX:+UseParNewGC 年老代用-XX:+UseConcMarkSweepGC




详细解析：参考[传送门](https://blog.csdn.net/m0_46316970/article/details/123585951)