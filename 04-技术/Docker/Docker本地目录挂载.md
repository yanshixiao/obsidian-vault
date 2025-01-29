---

UID: 20241114130845 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-11-14
---

![[4135117315609612.png]]

```bash
docker inspect mysql
```


创建容器时并没有手动挂载，但是查看时依然有挂载数据卷，只不过名字是自动生成的，这种叫做匿名卷

![[Pasted image 20241114131518.png]]匿名卷的问题是版本升级时重新生成容器还需额外自己迁移数据

我们可以自定义目录，也不需要再var/lib/docker/volumns里。

命令和挂载数据卷（数据卷：容器内目录）一样
![[64048317315617802.png]]

配置文件、数据目录、初始化脚本的位置在官网都能找到[Docker mysql](https://hub.docker.com/_/mysql)

![[Pasted image 20241114133125.png]]

现在本地创建/root/mysql/data等几个目录，然后创建对应的文件。
如配置文件
![[Pasted image 20241114133538.png]]

然后执行命令
记得删除之前的mysql容器
![[Pasted image 20241114133657.png]]