---
author: yuanshuai
created: 2021-10-20 17:15:39
aliases: 
description:
tags: [SpringBoot]
---



```java
@Target(ElementType.TYPE)  
@Retention(RetentionPolicy.RUNTIME)  
@Documented  
@Component  
public @interface ControllerAdvice {
```

可以看出来实际上是个Component，可以被ComponentScan扫描到。
顾名思义，这是一个增强的 Controller。使用这个 Controller ，可以实现三个方面的功能：

1.  全局异常处理
2.  全局数据绑定
3.  全局数据预处理

项目中一般使用的是第一种，配合@ExceptionHandler注解实现全局异常处理。如下图所示

![图1](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/mmexport1629446054247.png)


参考
1. https://www.cnblogs.com/lenve/p/10748453.html
2. https://blog.csdn.net/w372426096/article/details/78429141