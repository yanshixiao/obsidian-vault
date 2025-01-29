---
author: yuanshuai
created: 2021-12-29 13:52:54
aliases: 
description:
tags: [Docker]
---

## 问题
在windows docker desktop中安装了MySQL之后，由于一些原因（见[Docker安装MySQL8.0](Docker安装MySQL8.0.md)），无法挂载本地磁盘目录。就想知道默认的volume映射在哪里。


## 分析
首先使用`docker inspect 容器名称`查看相关信息

![](Pasted%20image%2020211229135651.png)

但是在wsl中并找不到这个路径。

---


在`%LOCALAPPDATA%/Docker/wsl`路径下，能看到两个文件夹，两个文件夹下面各有一个.vhdx文件。

- **data/ext4.vhdx** which is consumed by **docker-desktop-data**
- **distro/ext4.vhdx** which is consumed by **docker-desktop**


实际上，Docker拉取的镜像和创建的容器就存放docker-desktop和docker-desktop-data。
这两个东西相信不陌生，如果不把这连个.vhdx链接到其他盘的话，恐怕系统盘容量会蹭蹭往下掉。
![](Pasted%20image%2020211229140145.png)

几乎所有内容都在这里面，数据卷Volume也不例外。

## 解决
在浏览器中输入以下地址，就可以进入vhdx中。
```text
\\wsl$\docker-desktop
\\wsl$\docker-desktop-data
```

我们想访问的数据卷的位置
```text
\\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes\

```

![](Pasted%20image%2020211229140806.png)

至于怎么修改数据卷存放位置，看这个[迁移Docker镜像和容器的存储位置](https://dev.to/kimcuonthenet/move-docker-desktop-data-distro-out-of-system-drive-4cg2)

