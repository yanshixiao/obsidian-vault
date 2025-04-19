---
UID: 20250419235317
aliases: 
tags:
  - 事务
  - Spring
source: 
cssclasses: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-19
---


Spring中声明式事务传播级别，默认是REQUIRED，即外层有则加入，外层没有就新建。

spring生成动态代理对象，开始事务，即connection.setAutoCommit(false)。

然后把数据库连接放到ThreadLocal中，其实是一个map，key是dataSource，value是connection（其实是ConnectionHolder）。

这下明朗了，只要想办法把外层事务线程的connection放到内部事务线程中，就OK了，

看源码TransactionSynchronizationManager类，有bindResource和getResource方法。


然后，两个方法，搞定


```java
//获取连接
ConnectionHolder connectionHolder = (ConnectionHolder) TransactionSynchronizationManager.getResource(dataSource);
//。。。外部业务代码

//绑定连接
Thread thread = new Thread(()->{
	//绑定主线程的connection到子线程
	TransactionSynchronizationManager.bindResource(dataSource, connectionHolder);
	//....内部业务代码
});
thread.start();
thread.join();
```


[[事务注解的本质是什么]]？

#todo 这种方式可能会有线程安全问题，以后再了解
