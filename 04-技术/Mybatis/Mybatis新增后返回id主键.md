---
author: yuanshuai
created: 2021-10-28 15:25:01
aliases: 
description:
tags: [Mybatis]
---


只需要在mapper.xml文件中新增selectKey，如下图

![](Pasted%20image%2020211028152622.png)


```xml
<insert id="insertSelective" parameterType="com.rimag.manage.model.Task">  
 <selectKey keyProperty="id" order="AFTER" resultType="java.lang.Long">  
 SELECT LAST_INSERT_ID() as id  
 </selectKey>  
 insert into task
```

有一点需要注意，这样操作以后，并不是通过返回值方式获取id，而是从对象中获取。
![](Pasted%20image%2020211028152712.png)