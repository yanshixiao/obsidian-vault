---
author: yuanshuai
created: 2022-01-11 11:51:12
aliases: 
description:
tags: [其他]
---




## 阻塞I/O（blocking IO）  
在linux中，默认情况下所有的socket都是blocking，一个典型的读操作流程大概是这样：  
![](Pasted%20image%2020220111114951.png)

当用户进程调用了recvfrom这个系统调用，kernel就开始了IO的第一个阶段：准备数据（对于网络IO来说，很多时候数据在一开始还没有到达。比如，还没有收到一个完整的UDP包。这个时候kernel就要等待足够的数据到来）。这个过程需要等待，也就是说数据被拷贝到操作系统内核的缓冲区中是需要一个过程的。而在用户进程这边，整个进程会被阻塞（当然，是进程自己选择的阻塞）。当kernel一直等到数据准备好了，它就会将数据从kernel中拷贝到用户内存，然后kernel返回结果，用户进程才解除block的状态，重新运行起来。

**所以，blocking IO的特点就是在IO执行的两个阶段都被block了。**