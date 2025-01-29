1. 官网下载 rpm包,包括4个：common、lib、client、server并依次安装，顺序不对有依赖关系的提示

> rpm -ivh mysql-community-common-version-distribution-arch.rpm

> rpm -ivh mysql-community-lib-version-distribution-arch.rpm

> rpm -ivh mysql-community-client-version-distribution-arch.rpm

> rpm -ivh mysql-community-server-version-distribution-arch.rpm

==note== 查看某个rpm包下有哪些文件
> rpm -qpl mysql-community-server-version-distribution-arch.rpm

2.修改/etc/my.cnf文件添加如下内容：
<pre>
[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
[mysqld]
character_set_server=utf8
</pre>

3.生成随机密码并登录修改
> grep 'temporary password' /var/log/mysqld.log

> mysql -u root -p

> alter user 'root'@'localhost' identified by 'newpassword';

启动不了的话，ps -A|grep mysql
查看进程，kill掉，/etc/init.d/mysqld restart 即可

