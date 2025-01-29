---
author: yuanshuai
created: 2022-02-24 11:43:11
aliases: 
description:
tags: [java, http]
---
联调时遇到了http返回400的问题。
![](Pasted%20image%2020220224114353.png)
> JSON parse error: Cannot deserialize instance of java.lang.String` out of START_ARRAY token

原因是前端json格式有问题，后端接受字符串，但前端传了数组过来。