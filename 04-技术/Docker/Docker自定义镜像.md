---

UID: 20241114134043 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-11-14
---


![[Pasted image 20241114144048.png]]


docker在上述1234步每一步都会打成一个包，最后几个包合并成一个镜像


![[Pasted image 20241114145720.png]]

分层的好处可以共用某些层，就像下面redis 日志第一行显示already exists
![[Pasted image 20241114145625.png]]

我们只需要描述镜像结构，每一层是什么，docker自动制作。如何告诉？就要用到[DockerFile](DockerFile文件)

![[Pasted image 20241114152034.png]]

有了dockerfile文件后，就要根据文件**构建镜像**
![[Pasted image 20241114152653.png]]
名字默认用Dockfile， 如果想要自定义，使用-f参数


![[Pasted image 20241114155510.png]]