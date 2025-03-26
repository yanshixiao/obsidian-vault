---

UID: 20250326162309 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-26
---

Redis 内部使用文件事件处理器 file event handler ，这个文件事件处理器是单线程的，所以

Redis 才叫做单线程的模型。它采用 IO 多路复用机制同时监听多个 socket ，根据 socket 上的事

件来选择对应的事件处理器进行处理。

文件事件处理器的结构包含 4 个部分：

1. 多个 socket 。

2. IO 多路复用程序。

3. 文件事件分派器。

4. 事件处理器（连接应答处理器、命令请求处理器、命令回复处理器）。

多个 socket 可能会并发产生不同的操作，每个操作对应不同的文件事件，但是 IO 多路复用程序会

监听多个 socket，会将 socket 产生的事件放入队列中排队，事件分派器每次从队列中取出一个事

件，把该事件交给对应的事件处理器进行处理。

来看客户端与 Redis 的一次通信过程：
![[说说Redis的线程模型.png]]

下面来大致说一下这个图：

1. 客户端 Socket01 向 Redis 的 Server Socket 请求建立连接，此时 Server Socket 会产生一个

AE_READABLE 事件，IO 多路复用程序监听到 server socket 产生的事件后，将该事件压入队列

中。文件事件分派器从队列中获取该事件，交给连接应答处理器。连接应答处理器会创建一个

能与客户端通信的 Socket01，并将该 Socket01 的 AE_READABLE 事件与命令请求处理器关

联。

2. 假设此时客户端发送了一个 set key value 请求，此时 Redis 中的 Socket01 会产生

AE_READABLE 事件，IO 多路复用程序将事件压入队列，此时事件分派器从队列中获取到该事

件，由于前面 Socket01 的 AE_READABLE 事件已经与命令请求处理器关联，因此事件分派器

将事件交给命令请求处理器来处理。命令请求处理器读取 Socket01 的 set key value 并在自己

内存中完成 set key value 的设置。操作完成后，它会将 Socket01 的 AE_WRITABLE 事件与令

回复处理器关联。

3. 如果此时客户端准备好接收返回结果了，那么 Redis 中的 Socket01 会产生一个

AE_WRITABLE 事件，同样压入队列中，事件分派器找到相关联的命令回复处理器，由命令回复处理器对 Socket01 输入本次操作的一个结果，比如 ok ，之后解除 Socket01 的

AE_WRITABLE 事件与命令回复处理器的关联。



[[Redis 单线程模型核心流程解析（基于文件事件处理器）]]