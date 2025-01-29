---
author: yuanshuai
created: 2023-01-06 18:19:28
aliases: 
description:
tags: [04-技术/基础]
---


# Jdk8使用stream对对象某字段求和


```java
1.  //写法1
    
2.  double collectionRatio = userList.stream().collect(Collectors.summingDouble(OrderReceivablesDetail::getCollectionRatio));
    
3.  System.out.println("比例总和 ：" + collectionRatio);
    
4.  //写法2
    
5.  double collectionRatio2 = userList.stream().mapToDouble(OrderReceivablesDetail::getCollectionRatio).sum();
    
6.  System.out.println("比例总和2： " + collectionRatio2);
```






