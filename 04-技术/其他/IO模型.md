---
author: yuanshuai
created: 2022-01-11 11:55:54
aliases: 
description:
tags: [其他]
---

## IO模式

对于一次IO访问（以read举例），数据会先被拷贝到操作系统内核的缓冲区中，然后才会从操作系统内核的缓冲区拷贝到应用程序的地址空间。所以说，当一个read操作发生时，它会经历两个阶段：  
1. 等待数据准备 (Waiting for the data to be ready)  
2. 将数据从内核拷贝到进程中 (Copying the data from the kernel to the process)

正式因为这两个阶段，linux系统产生了下面五种网络模式的方案。  
- 阻塞 I/O（blocking IO）  
- 非阻塞 I/O（nonblocking IO）  
- I/O 多路复用（ IO multiplexing）  
- 信号驱动 I/O（ signal driven IO）  
- 异步 I/O（asynchronous IO）

注：由于signal driven IO在实际中并不常用，所以我这只提及剩下的四种IO Model。

![阻塞IO（blocking IO）](阻塞IO（blocking%20IO）.md)
![非阻塞IO （nonblocking IO）](非阻塞IO%20（nonblocking%20IO）.md)

[IO多路复用（IO multiplexing）](IO多路复用（IO%20multiplexing）.md)

[异步IO（asynchronous IO）](异步IO（asynchronous%20IO）.md)

## 总结
### blocking和non-blocking的区别

调用blocking IO会一直block住对应的进程直到操作完成，而non-blocking IO在kernel还准备数据的情况下会立刻返回。

### synchronous IO和asynchronous IO的区别

在说明synchronous IO和asynchronous IO的区别之前，需要先给出两者的定义。POSIX的定义是这样子的：  
- A synchronous I/O operation causes the requesting process to be blocked until that I/O operation completes;  
- An asynchronous I/O operation does not cause the requesting process to be blocked;

两者的区别就在于synchronous IO做”IO operation”的时候会将process阻塞。按照这个定义，之前所述的blocking IO，non-blocking IO，IO multiplexing都属于synchronous IO。

有人会说，non-blocking IO并没有被block啊。这里有个非常“狡猾”的地方，定义中所指的”IO operation”是指真实的IO操作，就是例子中的recvfrom这个system call。non-blocking IO在执行recvfrom这个system call的时候，如果kernel的数据没有准备好，这时候不会block进程。但是，当kernel中数据准备好的时候，recvfrom会将数据从kernel拷贝到用户内存中，这个时候进程是被block了，在这段时间内，进程是被block的。

而asynchronous IO则不一样，当进程发起IO 操作之后，就直接返回再也不理睬了，直到kernel发送一个信号，告诉进程说IO完成。在这整个过程中，进程完全没有被block。

**各个IO Model的比较如图所示：**  
![](Pasted%20image%2020220111115758.png)

通过上面的图片，可以发现non-blocking IO和asynchronous IO的区别还是很明显的。在non-blocking IO中，虽然进程大部分时间都不会被block，但是它仍然要求进程去主动的check，并且当数据准备完成以后，也需要进程主动的再次调用recvfrom来将数据拷贝到用户内存。而asynchronous IO则完全不同。它就像是用户进程将整个IO操作交给了他人（kernel）完成，然后他人做完后发信号通知。在此期间，用户进程不需要去检查IO操作的状态，也不需要主动的去拷贝数据。


[传送门](https://segmentfault.com/a/1190000003063859)