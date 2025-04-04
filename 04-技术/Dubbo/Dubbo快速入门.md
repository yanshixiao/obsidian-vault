---

UID: 20250404022222 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-04
---
### ZooKeeper安装
![[ZooKeeper安装.png]]

---

### Dubbo快速入门
![[Dubbo快速入门.png]]

先整合spring和SpringMVC
![[Dubbo快速入门-1.png]]


这时候仍然是单体架构，因为service作为一个jar包不能单独对外提供服务
![[Dubbo快速入门-2.png]]
要改造成下图才行
![[Dubbo快速入门-3.png]]

#### 服务提供者
替换注解
![[Dubbo快速入门-4.png]]
替换之后，还不知道注册中心在哪，所以需要改下配置
![[Dubbo快速入门-5.png]]
#### 服务消费者
分体后不能本地依赖了，UserService接口在Spring中也没有bean了（不需要Spring管理了）
![[Dubbo快速入门-6.png]]
还需要加上ZooKeeper的配置
![[Dubbo快速入门-7.png]]
由于本地服务提供者和服务消费者都启动，默认qos监控会占用端口22222，两个22222就冲突了，这时候可以随便改一个配置文件（其实只有本地会出现，如果不同的机器应该就没事了）
![[Dubbo快速入门-8.png]]
还有个事，web和service都有一个UserService接口，应该提出来，搞成一个公共的服务，然后web和service都去依赖它，减少重复。
![[Dubbo快速入门-9.png]]