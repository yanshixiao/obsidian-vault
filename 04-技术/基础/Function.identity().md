---
author: yuanshuai
created: 2022-09-28 11:42:59
aliases: 
description:
tags: [04-技术/基础]
---


# Function.identity()


在阅读同事代码时，发现了如下逻辑

```java
Map<String, ChargeItem> newMap = newList.stream().collect(Collectors.toMap(ChargeItem::getItemId, e -> e, (k1, k2) -> k2));
```


由于对toMap不太熟悉，遂百度[toMap用法](https://www.jianshu.com/p/2b6927d95137)

发现两者有差异
![[Pasted image 20220928114749.png]]

看一下源码，一目了然

```java
  
/**  
 * Returns a function that always returns its input argument. * * @param <T> the type of the input and output objects to the function  
 * @return a function that always returns its input argument  
 */static <T> Function<T, T> identity() {  
    return t -> t;  
}
```
