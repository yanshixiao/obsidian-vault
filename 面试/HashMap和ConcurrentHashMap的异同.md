---

UID: 20241222002146 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-22
---


1. 都是 key-value 形式的存储数据；

2. HashMap 是线程不安全的，ConcurrentHashMap 是 JUC 下的线程安全的；3. HashMap 底层数据结构是数组 + 链表（JDK 1.8 之前）。JDK 1.8 之后是数组 + 链表 + [[红黑树]]。当链表中元素个数达到 8 的时候，链表的查询速度不如红黑树快，链表会转为红黑树，红

黑树查询速度快；

4. HashMap 初始数组大小为 16（默认），当出现扩容的时候，2倍数组大小的方式进行扩

容；（0.75是扩容因子，数组容量使用75%之后就开始扩容，减少碰撞，空间换时间）

5. ConcurrentHashMap 在 JDK 1.8 之前是采用分段锁来现实的 Segment + HashEntry，

Segment 数组大小默认是 16，2 的 n 次方；JDK 1.8 之后，采用 Node + CAS + Synchronized

来保证并发安全进行实现。


