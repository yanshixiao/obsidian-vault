---

UID: 20241115132022 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-11-15
---

# 网关路由

## 快速入门
![[18569917316320302.png]]


![[37304917316321552.png]]

![[99169017316325452.png]]

##路由属性
![[13972217316327212.png]]

![[21390017316327702.png]]

![[37714017316328532.png]]

![[92031417316331602.png]]


# 网关登录校验
![[17453917316335942.png]]
## 思路分析
![[44977517316337912.png]]
![[63276217316339152.png]]
## 自定义GlobalFilter
![[30570317316347002.png]]
![[71607817316349882.png]]
还可以实现Ordered接口指定顺序
![[Pasted image 20241115133821.png]]
## 自定义GatewayFilter
todo
## 实现登录校验

![[Pasted image 20241115135930.png]]
## 网关传递用户到微服务
![[Pasted image 20241115140552.png]]
![[Pasted image 20241115141020.png]]
![[Pasted image 20241115140810.png]]

![[Pasted image 20241115141053.png]]

编写拦截器
![[Pasted image 20241115142206.png]]
把拦截器添加到mvc
![[Screenshot_20241115_142013.jpg]]
common包下的配置无法被别的微服务识别，还需要配置一下
![[Pasted image 20241115142425.png]]
还要加上条件，在网关模块里不生效
![[Pasted image 20241115142711.png]]
## OpenFeign传递用户信息
![[Pasted image 20241115144344.png]]

![[Pasted image 20241115145048.png]]

![[Pasted image 20241115145537.png]]


![[Pasted image 20241115145843.png]]