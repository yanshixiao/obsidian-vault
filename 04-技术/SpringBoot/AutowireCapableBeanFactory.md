---
author: yuanshuai
created: 2021-10-20 15:37:39
aliases: 
description:
tags: [SpringBoot]
---


`AutowireCapableBeanFactory`的作用.  
项目中,有部分实现并未与`Spring`深度集成,因此其实例并未被`Spring`容器管理.  
然而,出于需要,这些并未被`Spring`管理的`Bean`需要引入`Spring`容器中的`Bean`.  
此时,就需要通过实现`AutowireCapableBeanFactory`,从而让`Spring`实现依赖注入等功能.

参考：
1. [链接](https://www.cnblogs.com/jason1990/p/11110196.html)
2. [链接](https://www.jianshu.com/p/14dd69b5c516)

