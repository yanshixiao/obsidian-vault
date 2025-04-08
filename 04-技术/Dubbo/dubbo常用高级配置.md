---

UID: 20250405021609 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-05
---




### 序列化
![[dubbo常用高级配置.png]]
### 地址缓存
![[dubbo常用高级配置-1.png]]
### 超时与重试
#### 超时
![[dubbo常用高级配置-2.png]]
![[dubbo常用高级配置-3.png]]
timeout可以设置在@Service注解上，也可以设置在@Reference上
![[dubbo常用高级配置-4.png]]
![[dubbo常用高级配置-5.png]]
thread只是为了方便看3秒
@Reference也设置timeout但是只设置一秒，效果是1秒就超时。
![[dubbo常用高级配置-6.png]]
超时时间建议配置在服务提供方，以为接口有多慢服务提供方知道。
#### 重试
![[dubbo常用高级配置-7.png]]
![[dubbo常用高级配置-8.png]]
### 多版本
![[dubbo常用高级配置-9.png]]
![[dubbo常用高级配置-10.png]]
![[dubbo常用高级配置-11.png]]

### 负载均衡
![[dubbo常用高级配置-13.png]]
![[dubbo常用高级配置-12.png]]
### 集群容错
![[dubbo常用高级配置-15.png]]
默认重试
![[dubbo常用高级配置-14.png]]
### 服务降级
![[dubbo常用高级配置-17.png]]
![[dubbo常用高级配置-16.png]]