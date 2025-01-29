---
author: yuanshuai
created: 2022-06-07 14:38:36
aliases: 
description:
tags: [IT/java/Spring]
---

Spring初始化bean的方式有

-   `xml` 配置文件中指定 `init-method` 标签
-   使用 `@PostConstruct` 注解
-   实现 `InitializingBean` 接口，重写`afterPropertiesSet()`方法
-   使用 `@Bean` 注解，指定属性`init-method`

执行顺序为

@PostConstruct > InitializingBean(`afterPropertiesSet()`) > init-method

[[@PostConstruct]]




