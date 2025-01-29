---
author: yuanshuai
created: 2021-12-28 15:47:54
aliases: 
description:
tags: [MySQL]
---


## 一, 创建用户:

 命令:CREATE USER ['username'@'host](mailto:%20username%20@%20host)' IDENTIFIED BY 'password';

 说明:username - 你将创建的用户名, host - 指定该用户在哪个主机上可以登陆,如果是本地用户可用localhost, 如果想让该用户可以从任意远程主机登陆,可以使用通配符%. password - 该用户的登陆密码,密码可以为空,如果为空则该用户可以不需要密码登陆服务器.

 例子: CREATE USER ['dog'@'localhost](mailto:%20dog%20@%20localhost)' IDENTIFIED BY '123456';

 CREATE USER ['](mailto:%20pig%20@%20192.168.1.101_)[pig'@'192.168.1.101](mailto:%20pig%20@%20192.168.1.101)_' IDENDIFIED BY '123456';

 CREATE USER 'pig'@'%' IDENTIFIED BY '123456';

 CREATE USER 'pig'@'%' IDENTIFIED BY '';

 CREATE USER 'pig'@'%';

## 二,授权:

 命令:GRANT privileges ON databasename.tablename TO ['username'@'host'](mailto:%20username%20@%20host)

 说明: privileges - 用户的操作权限,如SELECT , INSERT , UPDATE 等(详细列表见该文最后面).如果要授予所的权限则使用ALL.;databasename - 数据库名,tablename-表名,如果要授予该用户对所有数据库和表的相应操作权限则可用*表示, 如*.*.

 例子: GRANT SELECT, INSERT ON test.user TO 'pig'@'%';

 GRANT ALL ON *.* TO 'pig'@'%';

 注意:用以上命令授权的用户不能给其它用户授权,如果想让该用户可以授权,用以下命令:

 GRANT privileges ON databasename.tablename TO ['username'@'host'](mailto:%20username%20@%20host) WITH GRANT OPTION;

## 三.设置与更改用户密码

 命令:SET PASSWORD FOR ['username'@'host'](mailto:%20username%20@%20host) = PASSWORD('newpassword');如果是当前登陆用户用SET PASSWORD = PASSWORD("newpassword");

 例子: SET PASSWORD FOR 'pig'@'%' = PASSWORD("123456");

## 四.撤销用户权限

 命令: REVOKE privilege ON databasename.tablename FROM ['username'@'host'](mailto:%20username%20@%20host);

 说明: privilege, databasename, tablename - 同授权部分.

 例子: REVOKE SELECT ON *.* FROM 'pig'@'%';

 注意: 假如你在给用户'pig'@'%'授权的时候是这样的(或类似的):GRANT SELECT ON test.user TO 'pig'@'%', 则在使用REVOKE SELECT ON *.* FROM 'pig'@'%';命令并不能撤销该用户对test数据库中user表的SELECT 操作.相反,如果授权使用的是GRANT SELECT ON *.* TO 'pig'@'%';则REVOKE SELECT ON test.user FROM 'pig'@'%';命令也不能撤销该用户对test数据库中user表的Select 权限.

 具体信息可以用命令SHOW GRANTS FOR 'pig'@'%'; 查看.

## 五.删除用户

 命令: 
 ```sql
 DROP USER 'username'@'host';
 ```