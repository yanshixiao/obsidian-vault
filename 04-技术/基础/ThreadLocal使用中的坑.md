---
author: yuanshuai
created: 2021-11-16 17:15:45
aliases: 
description:
tags: [基础]
---


ThreadLocal使用常见的坑：

 ThreadLocal是与线程绑定的一个变量，假设没有将ThreadLocal内的变量删除（remove）或替换，它的生命周期将会与线程共存，假如我们使用的是线程池，会导致下一个线程获取到垃圾数据

同时没有删除的话，也会引起OOM

解决方案：从设计的角度要让ThreadLocal的set、remove有始有终，通常在外部调用的代码中使用finally来remove数据