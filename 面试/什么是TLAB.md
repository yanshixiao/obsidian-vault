---

UID: 20250312232830 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-12
---


可以把内存分配的动作按照线程划分在不同的空间之中进行，每个线程在Java堆中预先分配一小块内存,这就是TLAB（Thread Local Allocation Buffer，本地线程分配缓存） 。虚拟机通过 -XX:UseTLAB 设定它的。



