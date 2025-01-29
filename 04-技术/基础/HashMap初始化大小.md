---
author: yuanshuai
created: 2022-02-25 14:59:09
aliases: 
description:
tags: [java, hashmap]
---




HashMap在初始化时可以指定大小，初始化大小取大于传入参数的2次幂，比如`new HashMap(7)`，则其初始化大小为8

由于0.75负载因子的存在，想创建一个能容纳7个元素的map容器，直接传参数7，其大小初始化为8，最多存放6个数据就需要扩容，为了避免这种情况，一般用公式`0.75 * 期望大小 + 1`。

或者用`Maps.newHashMapWithExpectedSize(期望大小)`