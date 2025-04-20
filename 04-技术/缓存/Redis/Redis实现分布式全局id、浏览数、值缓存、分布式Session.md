---

UID: 20250420003209 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-20
---

Redis实现分布式全局id、浏览数、值缓存、分布式Session主要是对String的应用。


### 值缓存
把查询结果缓存到Redis，不要给MySQL太大压力，比如把列表数据序列化为json，放到redis中。

### 浏览数
点击率可以用string来存储，每当访问一次，就incr一次。

### 分布式系统的全局id
比如创建订单时候，去redis的key incr一下，得到新的最大的数。

但是超高并发情况下，和redis交互过于频繁了，有没有优化办法？

可以使用incrby orderId 1000，每次取1000个，服务内部使用每次加1，用完之后再去redis取。

### 分布式session
传统session在集群服务情况下会出问题。
![[Redis实现分布式全局id、浏览数、值缓存、分布式Session.png]]
可以把session存到Redis里。下次查询如果命中，说明已经登录了。
![[Redis实现分布式全局id、浏览数、值缓存、分布式Session-1.png]]
