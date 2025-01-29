---

UID: 20241221234126 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-21
---

- Java 集合框架中的一种存放相同类型的元素数据，是一种变长的集合类，基于定长数组实现，当加
入数据达到一定程度后，会实行自动扩容，即扩大数组大小。

- 底层是使用数组实现，添加元素。

	- 如果 add(o)，添加到的是数组的尾部，如果要增加的数据量很大，应该使用 ensureCapacity()
	方法，该方法的作用是预先设置 ArrayList 的大小，这样可以大大提高初始化速度。
	
	- 如果使用 add(int,o)，添加到某个位置，那么可能会挪动大量的数组元素，并且可能会触发扩
	容机制。

- 高并发的情况下，线程不安全。多个线程同时操作 ArrayList，会引发不可预知的异常或错误。

- ArrayList 实现了 Cloneable 接口，标识着它可以被复制。注意：ArrayList 里面的 clone() 复制其实
是浅复制。


> [!question] 
> 为什么有了数组还需要ArrayList ?


通常我们在使用的时候，如果在不明确要插入多少数据的情况下，普通数组就很尴尬了，因为你不知道需要初始化数组大小为多少，而 ArrayList 可以使用默认的大小，当元素个数到达一定程度后，会自动扩容。

可以这么来理解：我们常说的数组是定死的数组，ArrayList 却是动态数组


