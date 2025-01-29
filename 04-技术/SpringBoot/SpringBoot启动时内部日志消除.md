SpringBoot启动时，发现很多类似
```
Generating unique operation named: listUsingGET_17
```
这样的打印输出。

这和==swagger2==有些关联，是因为spring 在加载controller 的时候，发现这些类里面的方法名称有重复的，所以给你自动生成了一些名称，用以区分这些方法

如何处理这些信息呢？

1. 如果不在意此类信息，则可以通过配置日志，将其关闭，方法中的日志级别是INFO，可以调整到WARN或更高，就不会再打印，如下是logback配置文件的一部分

```xml
<logger name="org.springframework" level="ERROR"></logger>  
<logger name="org.springframework.data.rest" level="INFO"></logger>  
<logger name="org.springframework.web" level="INFO"></logger>  
<!--去除swagger使用中类似“Generating unique operation named: listUsingGET_17”的日志打印-->  
<logger name="springfox.documentation.spring.web.readers.operation" level="WARN"></logger>  
<logger name="com.rimag.manage.mapper" level="DEBUG"></logger>  
<root level="INFO">  
 <appender-ref ref="STDOUT" />  
 <appender-ref ref="LOGFILE" />  
</root>
```



2. 通过aop切面切入改方法，不进行日志打印，或者以警告的方式进行日志打印，看到警告则进行规避，代码如下

```java
package com.rimag.manage.config;  
  
import org.aspectj.lang.ProceedingJoinPoint;  
import org.aspectj.lang.annotation.Around;  
import org.aspectj.lang.annotation.Aspect;  
import org.aspectj.lang.annotation.Pointcut;  
import org.slf4j.Logger;  
import org.slf4j.LoggerFactory;  
import org.springframework.stereotype.Component;  
  
import java.util.Map;  
  
import static com.google.common.collect.Maps.newHashMap;  
  
/**  
 * */@Component  
@Aspect  
public class UserCachingOperationNameGenerator {  
    Logger log = LoggerFactory.getLogger(UserCachingOperationNameGenerator.class);  
  
  
 private Map<String, Integer> generated = newHashMap();  
  
  
 @Pointcut("execution(* springfox.documentation.spring.web.readers.operation.CachingOperationNameGenerator.startingWith(String))")  
    public void c() {  
    }  
  
  
    @Around("c()")  
    public Object a(ProceedingJoinPoint point) {  
        Object[] args = point.getArgs();  
 return startingWith(String.valueOf(args[0]));  
 }  
  
    private String startingWith(String prefix) {  
        if (generated.containsKey(prefix)) {  
            generated.put(prefix, generated.get(prefix) + 1);  
 String nextUniqueOperationName = String.format("%s_%s", prefix, generated.get(prefix));  
 log.info("组件中存在相同的方法名称，自动生成组件方法唯一名称进行替换: {}", nextUniqueOperationName);  
 return nextUniqueOperationName;  
 } else {  
            generated.put(prefix, 0);  
 return prefix;  
 }  
    }  
}
```

此处不执行joinPoint的process方法，相当于截胡了（不走被代理方法）。可以自定义打印的格式等