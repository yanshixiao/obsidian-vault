---
author: yuanshuai
created: 2022-06-16 14:08:05
aliases: 
description:
tags: [IT/java/Spring]
---


AbstractApplicationContext中的refresh()中，调用的方法如下
- [[prepareRefresh()方法|this.prepareRefresh()]]
-  [[obtainFreshBeanFactory()方法|this.obtainFreshBeanFactory()]]
- [[prepareBeanFactory(beanFactory)方法|this.prepareBeanFactory(beanFactory)]]
- [[postProcessBeanFactory(beanFactory)方法|this.postProcessBeanFactory(beanFactory)]]
