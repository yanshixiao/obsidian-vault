---
author: yuanshuai
created: 2022-05-31 10:06:57
aliases: 
description:
tags: [技术/java]
---

先贴一下源码，可以发现，代码实现是一样的
![[Pasted image 20220531100727.png]]
不过方法注释中有提到，这个方法主要是为了lambda处理使用的, `filter(Objects::isNull)`要比`filter(x->x==null)`更直观一些。




