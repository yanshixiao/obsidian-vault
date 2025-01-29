---
author: yuanshuai
created: 2022-10-18 14:41:27
aliases: 
description:
tags: [04-技术/基础]
---


# no instance(s) of type variable(s) R exist so that void conforms to R

在使用Stream.map()方法时，出现该错误`no instance(s) of type variable(s) R exist so that void conforms to R`

```java
List<User> users = new ArrayList<Person>(); 
users.add(new User().setAge("20").setPhoneNumber("12345678901")); 
users.add(new User().setAge("30").setPhoneNumber("10203040506"));
//这里是手机号只显示前6位
users = users.stream().map(u -> { u.setPhoneNumber(u.getPhoneNumber() != null ? u.getPhoneNumber().substring(0, 6) : null)}).collect(Collectors.toList());
```

点进map()可以看到源码：

![[Pasted image 20221018144519.png]]

由源码可知：map()是要一个返回值R的，而上面的写法是没有返回值的。

添加返回值即可

```java
users = users.stream().map(u -> { u.setPhoneNumber(u.getPhoneNumber() != null ? u.getPhoneNumber().substring(0, 6) : null); return u;}).collect(Collectors.toList());
```




