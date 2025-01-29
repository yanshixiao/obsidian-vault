### MySQL数据库（zip）安装  

1.解压  

2.配置环境变量  

3.新建data目录，用作存放数据，也可不新建，不用配置文件初始化。 

4.新建my.ini文件，文件内容如下  
```
[mysqld]
#设置mysql的安装目录
basedir=D:\\software\\mysql-5.7.18-winx64
#设置mysql数据库的数据的存放目录
datadir=D:\\software\\mysql-5.7.18-winx64\\data
```
注意，my.ini必须为ANSI编码，不能为utf-8，否则后续命令报错。  
注意，windows环境下\的转义。 

5.在bin目录下（配置过环境变量后不需要特定路径）执行：  

`mysqld --defaults-file=D:\software\mysql-5.7.18-winx64\my.ini --initialize-insecure`  
其中--defaults-file选项必须在第一个。 initialize-insecure表示不生成随机密码，initialize表示生成随机密码。

6.注册服务，执行`mysqld --install MySQL`  

7.启动服务， `net start mysql`  

8.第一次登录无需密码，进入mysql命令行后执行：  
`alter user 'root'@'localhost' identified by '123456';`

[https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization-mysqld.html ](https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization-mysqld.html  "官网文档链接")
