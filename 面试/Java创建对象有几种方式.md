---

UID: 20241221232916 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-21
---


# new关键字

```java
User user = new User
```


# 反射

```java
User user=User.class.newInstance();

Object object=(Object)Class.forName("java.lang.Object").newInstance()
```

# clone
clone 是 Object 的方法，所以所有对象都有这个方法

# 反序列化
我们反序列化一个对象，JVM 会给我们创建一个单独的对象。JVM 创建对象并不会调用任何构造函数。一个对象实现了 Serializable 接口，就可以把对象写入到文件中，并通过读取文件来创建对象。
