---
UID: 20241221233412
aliases: 
tags: 
source: 
cssclasses: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2024-12-21
---


**ArrayList**

- <font color="#9bbb59">优点</font>：ArrayList 是实现了基于动态数组的数据结构，因为地址连续，一旦数据存储好了，查询操作效率会比较高（在内存里是连着放的）。
- <font color="#9bbb59">缺点</font>：因为地址连续，ArrayList 要移动数据，所以插入和删除操作效率比较低。

**LinkedList**
- <font color="#9bbb59"> 优点</font>：LinkedList 基于链表的数据结构，地址是任意的，所以在开辟内存空间的时候不需要等一个连续的地址。对于新增和删除操作，LinkedList 比较占优势。LinkedList 适用于要头尾操作或插入指定位置的场景。
- <font color="#9bbb59">缺点</font>：因为 LinkedList 要移动指针，所以查询操作性能比较低。
**适用场景分析**
- 当需要对数据进行对随机访问的时候，选用 ArrayList。
- 当需要对数据进行多次增加删除修改时，采用 LinkedList。
- 
如果容量固定，并且只会添加到尾部，不会引起扩容，优先采用 ArrayList。
当然，绝大数业务的场景下，使用 ArrayList 就够了，但需要注意避免 ArrayList 的扩容，以及非顺序的插入。



