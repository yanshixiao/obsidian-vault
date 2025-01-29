---
author: yuanshuai
created: 2021-12-28 14:17:14
aliases: 
description:
tags: [MySQL]
---

本人只有windows系统，又不想搞虚拟机，所以以下操作都在windows环境下

## 安装DockerDesktop
没啥好说的，官网下载

## 拉取mysql镜像
```bash
docker pull mysql
```

## 启动
```bash
docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:latest --default-authentication-plugin=mysql_native_password
```

本身想挂载目录改配置文件，但是提示World-writable config file '/etc/mysql/my.cnf' is ignored. 意思是配置文件权限过宽松了，所以忽略了。而在windows环境下又没有找到好的方法修改，所以就作罢了。

后来了解到docker desktop会有一个默认的路径映射，并不会一重启数据全丢失，所以先姑息。

## 如果需要的话，修改权限
```bash
#进入容器
docker exec -it mysql bash
docker exec -it mysql /bin/bash

#容器内进入 
mysqlmysql -u root -p  
#查看用户信息  
select host,user,plugin,authentication_string from mysql.user;  
#修改用户信息  
ALTER user ‘root’@’%’ IDENTIFIED WITH mysql_native_password BY ‘123456’;  
#刷新配置  
flush privileges;  
#查看用户信息，即可看到信息被修改  
select host,user,plugin,authentication_string from mysql.user;  
# 退出 mysql  
exit;  
# 退出容器控制台  
exit
```

![](Pasted%20image%2020211228143030.png)


```ad-note
使用`docker inspect` 容器id或名称（例如docker inspect mysql）查看容器的详细配置信息，找到Mounts配置项就可以看到共享文件夹的映射配置。
```
如下图
![](Pasted%20image%2020211228143353.png)


如果想让容器随系统启动，docker run命令中加一个参数

```bash
--restart=always
```

参考：
[1](https://blog.csdn.net/yaoyuncn/article/details/103914588)
[2](https://blog.csdn.net/monkeyhi/article/details/115395752)

