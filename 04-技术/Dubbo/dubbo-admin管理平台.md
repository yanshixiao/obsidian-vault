---

UID: 20250405015900 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-05
---


![[dubbo-admin管理平台.png]]
### dubbo-admin安装
前后端分离项目，前端vue，需要先安装NodeJS

github下载dubbo-admin解压之后得到文件夹
![[dubbo-admin管理平台-1.png]]
由于dubbo-admin从注册中心获取信息，首先要修改dubbo-admin-server中的配置文件
![[dubbo-admin管理平台-2.png]]
![[dubbo-admin管理平台-3.png]]
执行`mvn clean package`进行打包
![[dubbo-admin管理平台-4.png]]
打包完成后，启动服务
![[dubbo-admin管理平台-5.png]]
npm run dev运行ui项目
![[dubbo-admin管理平台-6.png]]
### dubbo-admin使用
服务默认端口是20880，可以更改
![[dubbo-admin管理平台-7.png]]
页面上元数据默认看不到，需要在服务生产者中添加配置
![[dubbo-admin管理平台-8.png]]
还可以测试，不需要消费者，只要有服务提供者直接测试
