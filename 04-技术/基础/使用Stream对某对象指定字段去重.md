---
author: yuanshuai
created: 2023-02-20 10:38:23
aliases: 
description:
tags: [04-技术/基础]
---


# 使用Stream对某对象指定字段去重

```java
receiverList = receiverList.stream().filter(distinctByKey1(s -> s.getUserPhone())).collect(Collectors.toList());
```

```java
/**  
 * 断言：利用map根据Function结果去重  
 * @param keyExtractor  
 * @return  
 * @param <T>  
 */  
static <T> Predicate<T> distinctByKey1(Function<? super T, ?> keyExtractor) {  
    Map<Object, Boolean> seen = new ConcurrentHashMap<>();  
    return t -> seen.putIfAbsent(keyExtractor.apply(t), Boolean.TRUE) == null;  
}
```








