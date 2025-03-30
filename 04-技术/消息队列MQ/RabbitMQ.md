---
UID: 20241115170904
aliases: 
tags: 
source: 
cssclasses: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-11-15
---


# 安装部署
![[Pasted image 20241115171137.png]]
![[Pasted image 20241115232043.png]]
# 快速入门
![[Pasted image 20241115232843.png]]
在控制台页面操作发消息，交换机需要和queue绑定，否则交换机没有存储消息的功能，直接就丢了
![[Pasted image 20241115232959.png]]

# 数据隔离
![[Pasted image 20241115235406.png]]

# Java客户端
## 快速入门
![[Pasted image 20241116001113.png]]
![[Pasted image 20241116001355.png]]
![[Pasted image 20241116001444.png]]
![[Pasted image 20241116001454.png]]
![[Pasted image 20241116001602.png]]
![[Pasted image 20241116004621.png]]
![[Pasted image 20241116005834.png]]


## WorkQueue
![[Pasted image 20241116191820.png]]
两个消费者平均消费，类似于轮询，也就是说队列中的一条消息只能被一个消费者消费
![[Pasted image 20241116192901.png]]
即便加上线程休眠，模拟消费者有快有慢，结果还是平均分配

![[Pasted image 20241116193317.png]]
设置成这样之后，就能实现能者多劳
![[Pasted image 20241116193611.png]]

##  Fanout交换机
![[Pasted image 20241118001044.png]]
![[Pasted image 20241118001240.png]]
![[Pasted image 20241118001321.png]]
![[Pasted image 20241118001900.png]]


## Direct交换机
![[Pasted image 20241118002148.png]]
也可以所有的binding key设置成一样的，实现fanout的效果
![[Pasted image 20241118002354.png]]
可以绑定多个bindingkey
![[Pasted image 20241118002619.png]]
![[Pasted image 20241118002824.png]]


## Topic交换机
![[Pasted image 20241118003123.png]]
![[Pasted image 20241118003229.png]]
![[Pasted image 20241118003653.png]]

## 声明队列交换机
一般通过代码来定义交换机、队列等
### 基于Bean实现
![[Pasted image 20241118003931.png]]
![[Pasted image 20241118004312.png]]

### 基于注解实现
在进行directExchange绑定的时候，由于可以绑定多个bindingkey，代码就变得非常麻烦
![[Pasted image 20241118005607.png]]
可以使用注解方式
![[Pasted image 20241118005817.png]]


## 消息转换器
![[12389417318911022.png]]

默认方式用的jdk的序列化，占用字节多，可读性差
![[29205717318912352.png]]


![[71162417318915732.png]]
用json序列化替换
![[75394817318916062.png]]

![[93453517318917512.png]]
![[4896017318919292.png]]
![[29789317318921432.png]]

![[55916417318925072.png]]
![[56557217318925142.png]]



# 发送者可靠性
## 发送者重连
![[Pasted image 20241118162056.png]]
![[Pasted image 20241118163321.png]]
持久化队列，消息没有持久化到磁盘，也是返回NACK，但是路由key写错，相当于程序员问题，MQ没问题，所以还是ack
![[Pasted image 20241118164102.png]]

## 发送者确认机制
![[Pasted image 20241118164548.png]]

### 开启确认机制
![[Pasted image 20241118170021.png]]
return callback每个template只能添加一次
![[Pasted image 20241118170119.png]]
confirm callback在每条消息发送时都要指定
![[Pasted image 20241118170153.png]]
### 代码实现
![[Pasted image 20241118170548.png]]
![[Pasted image 20241118170600.png]]
![[Pasted image 20241118170644.png]]
![[Pasted image 20241118170939.png]]
![[Pasted image 20241118171516.png]]
![[Pasted image 20241118172053.png]]
其实正常情况不需要开启确认，因为对性能影响较大，如果实在有必要，要注意重试次数别太多

# MQ可靠性
![[Pasted image 20241118174741.png]]
## 数据持久化
交换机持久化、队列持久化、消息持久化
![[Pasted image 20241118175230.png]]
![[Pasted image 20241118175247.png]]
![[Pasted image 20241118175309.png]]

开启持久化后对性能是否有影响？

先不持久化尝试发送一百万条
![[69121217319270552 1.png]]
![[Pasted image 20241118175940.png]]
pageOut就是写入磁盘了，发送条数峰值就下降了，也就是阻塞了，不持久化，每过一段时间都会写入磁盘，影像吞吐

持久化发送
![[83409617319272072.png]]
![[90445517319272292.png]]
可以看到峰值更高，而且没有中断过，rabbitMQ对写磁盘做了优化

## Lazy Queue
![[22802017319278842.png]]
![[24727217319279032.png]]
![[31879117319279752.png]]
开启lazy queue之后队列是否持久化影响不大
![[40021617319281462.png]]
![[41847117319281572.png]]
直接pageOut写磁盘，没有In Memory

![[46872117319282142.png]]

![[53179517319282802.png]]


# 消费者的可靠性
## 消费者确认机制
![[27754917319286092.png]]
![[63574417319289062.png]]
![[79521817319295292.png]]
![[98530017319296742.png]]
## 失败重试策略
![[17629317319776512.png]]
![[37219217319778072.png]]
![[43254817319778562.png]]
![[65587017319780422.png]]
![[70503817319780932.png]]
![[100087217319784042.png]]
![[107255417319784822.png]]
## 业务幂等性
![[20141817319793432.png]]
![[41229017319794702.png]]
![[66686017319796472.png]]
![[106081617320642742.png]]
![[146120017320643912.png]]

# 延迟消息
![[RabbitMQ-3.png]]
延迟消息实现延迟任务，可以对服务一致性进行兜底（超时未支付取消）
# 死信交换机
![[RabbitMQ-5.png]]
![[RabbitMQ-6.png]]
MessagePostProcessor是消息后置处理器，在消息转换成Message后进行进一步操作

# 延迟消息插件
![[RabbitMQ-7.png]]
![[RabbitMQ-8.png]]
![[RabbitMQ-9.png]]
![[RabbitMQ-10.png]]

![[RabbitMQ-11.png]]
![[RabbitMQ-12.png]]
计时利用时钟，时钟依赖CPU，CPU密集型任务，使用延迟消息时，要尽量避免同一时刻存在大量延迟消息（时间设置短一点，同时存在的就少了）

# 业务改造
![[26154517321513002.png]]

