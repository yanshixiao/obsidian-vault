---

UID: 20241222001030 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-22
---

1. 出生的版本不一样，Hashtable 出生于 Java 发布的第一版本 JDK 1.0，HashMap 出生于 JDK

1.2。

2. 都实现了 Map、Cloneable、Serializable（当前 JDK 版本 1.8）。

3. HashMap 继承的是 AbstractMap，并且 AbstractMap 也实现了 Map 接口。Hashtable 继承

Dictionary。

4. Hashtable 中大部分 public 修饰普通方法都是 synchronized 字段修饰的，是线程安全的，

HashMap 是非线程安全的。

5. Hashtable 的 key 不能为 null，value 也不能为 null，这个可以从 Hashtable 源码中的 put 方

法看到，判断如果 value 为 null 就直接抛出空指针异常，在 put 方法中计算 key 的 hash 值之

前并没有判断 key 为 null 的情况，那说明，这时候如果 key 为空，照样会抛出空指针异常。

6. HashMap 的 key 和 value 都可以为 null。在计算 hash 值的时候，有判断，如果

key==null ，则其 hash=0 ；至于 value 是否为 null，根本没有判断过。

7. Hashtable 直接使用对象的 hash 值。hash 值是 JDK 根据对象的地址或者字符串或者数字算出

来的 int 类型的数值。然后再使用除留余数法来获得最终的位置。然而除法运算是非常耗费时

间的，效率很低。HashMap 为了提高计算效率，将哈希表的大小固定为了 2 的幂，这样在取

模预算时，不需要做除法，只需要做位运算。位运算比除法的效率要高很多。

8. Hashtable、HashMap 都使用了 Iterator。而由于历史原因，Hashtable 还使用了

Enumeration 的方式。

9. 默认情况下，初始容量不同，Hashtable 的初始长度是 11，之后每次扩充容量变为之前的

2n+1（n 为上一次的长度）而 HashMap 的初始长度为 16，之后每次扩充变为原来的两倍

另外在 Hashtable 源码注释中有这么一句话：
```
Hashtable is synchronized. If a thread-safe implementation is not needed, it is

recommended to use HashMap in place of Hashtable . If a thread-safe highly

concurrent implementation is desired, then it is recommended to use

ConcurrentHashMap in place of Hashtable.
```


大致意思：Hashtable 是线程安全，推荐使用 HashMap 代替 Hashtable；如果需要线程安全高并

发的话，推荐使用 ConcurrentHashMap 代替 Hashtable。

>[!question] 
>HashMap 是线程不安全的，那么在需要线程安全的情况下还要考虑性能，有什么解决方式？

这里最好的选择就是 [[ConcurrentHashMap]] 了，后面还要涉及到
ConcurrentHashMap的数据结构以及底层原理等。



