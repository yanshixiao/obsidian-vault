---
author: yuanshuai
created: 2022-09-27 10:38:17
aliases: 
description:
tags: [04-技术/MySQL]
---


# int(1)不代表存不了大数


一般情况下，创建表字段时，感觉使用了int(1)就限制了大小。真实情况肯定不是这样。

我们知道在 mysql 中 int 占 4 个字节，那么对于无符号的 int，最大值是 2^32-1 = 4294967295，将近 40 亿，难道用了 int(1)，就不能达到这个最大值吗？

```sql
CREATE TABLE `user` (
  `id` int(1) unsigned NOT NULL AUTO_INCREMENT,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
```


id 字段为无符号的 int(1)，我来插入一个最大值看看。

```
mysql> INSERT INTO `user` (`id`) VALUES (4294967295);
Query OK, 1 row affected (0.00 sec)
```


可以看到成功了，说明 int 后面的数字，不影响 int 本身支持的大小，int(1)、int(2)...int(10) 没什么区别。

**零填充**

一般 int 后面的数字，配合 zerofill 一起使用才有效。先看个例子：

```sql
CREATE TABLE `user` (
  `id` int(4) unsigned zerofill NOT NULL AUTO_INCREMENT,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
```

注意 int(4) 后面加了个 zerofill，我们先来插入 4 条数据。

```
mysql> INSERT INTO `user` (`id`) VALUES (1),(10),(100),(1000);
Query OK, 4 rows affected (0.00 sec)
Records: 4  Duplicates: 0  Warnings: 0
```

分别插入 1、10、100、1000 4 条数据，然后我们来查询下：

```
mysql> select * from user;
+------+
| id   |
+------+
| 0001 |
| 0010 |
| 0100 |
| 1000 |
+------+
4 rows in set (0.00 sec)
```


通过数据可以发现 int(4) + zerofill 实现了不足 4 位补 0 的现象，单单 int(4) 是没有用的。而且对于 0001 这种，底层存储的还是 1，只是在展示的会补 0。


## 总结

int 后面的数字不能表示字段的长度，int(num) 一般加上 zerofill，才有效果。




题外话：至于mybatis能否读取到，如何读取没有验证。
