---

UID: 20241222001909 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-22
---

为了能让 HashMap 存数据和取数据的效率高，尽可能地减少 hash 值的碰撞，也就是说尽量把数
据能均匀的分配，每个链表或者红黑树长度尽量相等。

我们首先可能会想到 **% 取模**的操作来实现。

下面是回答的重点哟：

取余（%）操作中如果除数是 2 的幂次，则等价于与其除数减一的与（&）操作（也就是说
`hash % length == hash &(length - 1)` 的前提是 length 是 2 的 n 次方）。并且，采用二进
制位操作 & ，相对于 % 能够提高运算效率。



