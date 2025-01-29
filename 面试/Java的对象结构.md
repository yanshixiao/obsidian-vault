---
UID: 20241224005823
aliases: 
tags: 
source: 
cssclasses: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2024-12-24
---

Java对象由三个部分组成：**对象头**、**实例数据**、**对齐填充**。

<font color="#9bbb59">对象头</font>由两部分组成，第一部分存储对象自身的运行时数据：哈希码、GC分代年龄、锁标识状态、线程持有的锁、偏向线程ID（一般占32/64 bit）。第二部分是指针类型，指向对象的类元数据类型（即对象代表哪个类）。如果是数组对象，则对象头中还有一部分用来记录数组长度。

<font color="#9bbb59">实例数据</font>用来存储对象真正的有效信息（包括父类继承下来的和自己定义的）

<font color="#9bbb59">对齐填充</font>：JVM要求对象起始地址必须是8字节的整数倍（8字节对齐）



