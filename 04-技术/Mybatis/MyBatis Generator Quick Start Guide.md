---
author: yuanshuai
created: 2021-11-16 17:11:23
aliases: 
description:
tags: [Mybatis]
---


MyBatis-Generator

1.创建完成配置文件

1.指定如何连接目标数据库

2.指定生成Model对象文件的路径

3.指定生成Mapper映射文件（.xml）的路径

4.指定生成Mapper接口文件的路径（如果不需要可以删除）

5.指定数据库的表

2.将文件保存在合适的位置

[3.](http://www.mybatis.org/generator/quickstart.html)运行如下命令：

java -jar mybatis-generator-core-x.x.x.jar -configfile \temp\generatorConfig.xml -overwrite

[http://www.mybatis.org/generator/quickstart.html](http://www.mybatis.org/generator/quickstart.html)