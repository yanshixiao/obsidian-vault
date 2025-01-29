---
author: yuanshuai
created: 2022-06-07 15:37:15
aliases: 
description:
tags: [IT/java/Spring]
---

Servlet的注解，在方法上加该注解会在项目启动的时候执行该方法，也可以理解为在spring容器初始化的时候执行该方法。并且只会被服务器执行一次。

依赖注入中，要将对象p注入到对象a，那么首先就必须得生成对象a和对象p，才能执行注入。所以，如果一个类A中有个成员变量p被@Autowired注解，那么@Autowired注入是发生在A的构造方法执行完之后的。

如果想在生成对象时完成某些初始化操作，而偏偏这些初始化操作又依赖于依赖注入，那么就无法在构造函数中实现。为此，可以使用@PostConstruct注解一个方法来完成初始化，@PostConstruct注解的方法将会在依赖注入完成后被自动调用。

经常用在spring中，在spring bean的生命周期执行顺序为

Constructor(构造方法) -> @Autowired(依赖注入) -> @PostConstruct(注释的方法)

![[46de5d47-f5c8-486c-a0b7-0d48b1c717dc.svg]]

主要的应用：在静态方法中调用依赖注入的Bean中的方法。

  

MyUtil

```java
package com.rimag.collect.component;

import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;

@Component
public class MyUtil {
    private final static MyUtil staticInstance = new MyUtil();

    @Resource
    MyService myService;


    @PostConstruct
    public void init() {
        System.out.println("postConstruct");
        staticInstance.myService = myService;
    }

    public static Integer invoke() {
        return staticInstance.myService.add(10, 20);
    }
}
```

  

MyService

```java
package com.rimag.collect.component;

import org.springframework.stereotype.Component;

@Component
public class MyService {
    public Integer add(int a, int b) {
        return a+b;
    }
}
```

