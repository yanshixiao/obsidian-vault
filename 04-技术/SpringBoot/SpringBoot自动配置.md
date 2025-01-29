## SpringBoot自动配置

### Condition

![image-20210709145400316](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709145400316.png)

#### 需求1

![image-20210709145424710](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709145424710.png)

ClassCondition.java

```java
package com.yanshixiao.springbootcondition.condition;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.type.AnnotatedTypeMetadata;

/**
 * @author yanshixiao
 * @date Created in 3:12 下午 2021/7/9
 */
public class ClassCondition implements Condition {
    @Override
    public boolean matches(ConditionContext conditionContext, AnnotatedTypeMetadata annotatedTypeMetadata) {
        //1.需求：导入jedis坐标后创建bean
        //思路：判断redis.clients.jedis.Jedis是否存在
        boolean flag = true;
        try {
            Class<?> cls = Class.forName("redis.clients.jedis.Jedis");
        } catch (ClassNotFoundException e) {
            flag = false;
            e.printStackTrace();
        }
        return flag;
    }
}

```

UserConfig.java

```java
package com.yanshixiao.springbootcondition.config;

import com.yanshixiao.springbootcondition.condition.ClassCondition;
import com.yanshixiao.springbootcondition.domain.User;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

/**
 * @author yanshixiao
 * @date Created in 3:03 下午 2021/7/9
 */
@Configuration
public class UserConfig {
    @Bean
    @Conditional(ClassCondition.class)
    public User user() {
        return new User();
    }
}
```

#### 需求2

![image-20210709152626586](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709152626586.png)

可以自定义一个注解@ConditionOnClass

```java
package com.yanshixiao.springbootcondition.condition;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.type.AnnotatedTypeMetadata;

import java.util.Map;

/**
 * @author yanshixiao
 * @date Created in 3:12 下午 2021/7/9
 */
public class ClassCondition implements Condition {
    /**
     *
     * @param conditionContext 上下文对象，可以获取环境，IOC，ClassLoader对象
     * @param annotatedTypeMetadata 注解的元对象，可以用于获取注解定义的属性值
     * @return
     */
    @Override
    public boolean matches(ConditionContext conditionContext, AnnotatedTypeMetadata annotatedTypeMetadata) {
//        //1.需求：导入jedis坐标后创建bean
//        //思路：判断redis.clients.jedis.Jedis是否存在
//        boolean flag = true;
//        try {
//            Class<?> cls = Class.forName("redis.clients.jedis.Jedis");
//        } catch (ClassNotFoundException e) {
//            flag = false;
//            e.printStackTrace();
//        }
//        return flag;
        //2.需求：导入通过注解属性值value指定坐标后创建bean
        //获取注解属性值 value
        Map<String, Object> annotationAttributes = annotatedTypeMetadata.getAnnotationAttributes(ConditionOnClass.class.getName());
//        System.out.println(annotationAttributes);
        String[] value = (String[]) annotationAttributes.get("value");
        boolean flag = true;
        try {
            for (String className : value) {
                Class<?> cls = Class.forName(className);
            }
        } catch (ClassNotFoundException e) {
            flag = false;
            e.printStackTrace();
        }
        return flag;
    }
}
```

ConditionOnClass.java

```java
package com.yanshixiao.springbootcondition.condition;

import org.springframework.context.annotation.Conditional;

import java.lang.annotation.*;

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Conditional(ClassCondition.class)
public @interface ConditionOnClass {
    String[] value();
}
```

springboot中有大量类似的注解，如图

![image-20210709155601283](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709155601283.png)

其中redis下有一个RedisAutoConfiguration.java

![image-20210709160140403](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709160140403.png)

#### 总结

![image-20210709164303346](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709164303346.png)

### 切换内置web服务器

![image-20210709182415634](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709182415634.png)

仍旧是在autoconfiguration包中查看

![image-20210709182720299](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210709182720299.png)



EmbeddedWebServerFactoryCustomizerAutoConfiguration.java

```java
/*
 * Copyright 2012-2019 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.boot.autoconfigure.web.embedded;

import io.undertow.Undertow;
import org.apache.catalina.startup.Tomcat;
import org.apache.coyote.UpgradeProtocol;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.Loader;
import org.eclipse.jetty.webapp.WebAppContext;
import org.xnio.SslClientAuthMode;
import reactor.netty.http.server.HttpServer;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.boot.autoconfigure.web.ServerProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

/**
 * {@link EnableAutoConfiguration Auto-configuration} for embedded servlet and reactive
 * web servers customizations.
 *
 * @author Phillip Webb
 * @since 2.0.0
 */
@Configuration(proxyBeanMethods = false)
@ConditionalOnWebApplication
@EnableConfigurationProperties(ServerProperties.class)
public class EmbeddedWebServerFactoryCustomizerAutoConfiguration {

   /**
    * Nested configuration if Tomcat is being used.
    */
   @Configuration(proxyBeanMethods = false)
   @ConditionalOnClass({ Tomcat.class, UpgradeProtocol.class })
   public static class TomcatWebServerFactoryCustomizerConfiguration {

      @Bean
      public TomcatWebServerFactoryCustomizer tomcatWebServerFactoryCustomizer(Environment environment,
            ServerProperties serverProperties) {
         return new TomcatWebServerFactoryCustomizer(environment, serverProperties);
      }

   }

   /**
    * Nested configuration if Jetty is being used.
    */
   @Configuration(proxyBeanMethods = false)
   @ConditionalOnClass({ Server.class, Loader.class, WebAppContext.class })
   public static class JettyWebServerFactoryCustomizerConfiguration {

      @Bean
      public JettyWebServerFactoryCustomizer jettyWebServerFactoryCustomizer(Environment environment,
            ServerProperties serverProperties) {
         return new JettyWebServerFactoryCustomizer(environment, serverProperties);
      }

   }

   /**
    * Nested configuration if Undertow is being used.
    */
   @Configuration(proxyBeanMethods = false)
   @ConditionalOnClass({ Undertow.class, SslClientAuthMode.class })
   public static class UndertowWebServerFactoryCustomizerConfiguration {

      @Bean
      public UndertowWebServerFactoryCustomizer undertowWebServerFactoryCustomizer(Environment environment,
            ServerProperties serverProperties) {
         return new UndertowWebServerFactoryCustomizer(environment, serverProperties);
      }

   }

   /**
    * Nested configuration if Netty is being used.
    */
   @Configuration(proxyBeanMethods = false)
   @ConditionalOnClass(HttpServer.class)
   public static class NettyWebServerFactoryCustomizerConfiguration {

      @Bean
      public NettyWebServerFactoryCustomizer nettyWebServerFactoryCustomizer(Environment environment,
            ServerProperties serverProperties) {
         return new NettyWebServerFactoryCustomizer(environment, serverProperties);
      }

   }

}
```



分析源码可知，只要分别导入不同web服务器的坐标依赖，就可以实现服务器的切换

具体做法：先排除掉starter-web中的tomcat

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <artifactId>spring-boot-starter-tomcat</artifactId>
            <groupId>org.springframework.boot</groupId>
        </exclusion>
    </exclusions>
</dependency>
```

再引入jetty的坐标依赖

```xml
<!--引入jetty依赖-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>
```



### @Enable*注解

![image-20210712144000156](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210712144000156.png)



```java
/**
 * @ComponentScan:扫描范围：当前引导类所在包及其子包
 * com.yanshixiao.springbootenable
 * com.yanshixiao.config
 * 方法1：
 * 使用@ComponentScan扫描com.yanshixiao.config包
 * 方法2：
 * 使用@Import注解，加载类。这些类都会被spring创建并放入IOC容器
 * 方法3：
 * 可以对@Import注解进行封装，
 */
```

这里重点是方法三

![image-20210712151025278](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210712151025278.png)

![image-20210712151045396](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210712151045396.png)

### @Import注解

![image-20210712151408347](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210712151408347.png)

MyImportSelector.java

```java
package com.yanshixiao.config;

import org.springframework.context.annotation.ImportSelector;
import org.springframework.core.type.AnnotationMetadata;

/**
 * @author yanshixiao
 * @date Created in 4:05 下午 2021/7/12
 */
public class MyImportSelector implements ImportSelector {
    @Override
    public String[] selectImports(AnnotationMetadata annotationMetadata) {
        return new String[]{"com.yanshixiao.domain.User", "com.yanshixiao.domain.Role"};
    }
}
```

MyImportBeanDefinitionRegistrar.java

```java
package com.yanshixiao.config;

import com.yanshixiao.domain.User;
import org.springframework.beans.factory.support.AbstractBeanDefinition;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.context.annotation.ImportBeanDefinitionRegistrar;
import org.springframework.core.type.AnnotationMetadata;

/**
 * @author yanshixiao
 * @date Created in 4:20 下午 2021/7/12
 */
public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
    @Override
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        AbstractBeanDefinition beanDefinition = BeanDefinitionBuilder.rootBeanDefinition(User.class).getBeanDefinition();
        registry.registerBeanDefinition("user", beanDefinition);
    }
}
```



### @EnableAutoConfiguration

![image-20210712164221370](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210712164221370.png)

首先底层使用了@Import注解，传入了ImportSelector的实现类。

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage
@Import(AutoConfigurationImportSelector.class)
public @interface EnableAutoConfiguration {
```

AutoConfigurationImportSelector类中实现的方法如下：

```java
@Override
public String[] selectImports(AnnotationMetadata annotationMetadata) {
   if (!isEnabled(annotationMetadata)) {
      return NO_IMPORTS;
   }
   AutoConfigurationEntry autoConfigurationEntry = getAutoConfigurationEntry(annotationMetadata);
   return StringUtils.toStringArray(autoConfigurationEntry.getConfigurations());
}
```

核心方法是getAutoConfigurationEntry

```java
/**
 * Return the {@link AutoConfigurationEntry} based on the {@link AnnotationMetadata}
 * of the importing {@link Configuration @Configuration} class.
 * @param annotationMetadata the annotation metadata of the configuration class
 * @return the auto-configurations that should be imported
 */
protected AutoConfigurationEntry getAutoConfigurationEntry(AnnotationMetadata annotationMetadata) {
   if (!isEnabled(annotationMetadata)) {
      return EMPTY_ENTRY;
   }
   AnnotationAttributes attributes = getAttributes(annotationMetadata);
   List<String> configurations = getCandidateConfigurations(annotationMetadata, attributes);
   configurations = removeDuplicates(configurations);
   Set<String> exclusions = getExclusions(annotationMetadata, attributes);
   checkExcludedClasses(configurations, exclusions);
   configurations.removeAll(exclusions);
   configurations = getConfigurationClassFilter().filter(configurations);
   fireAutoConfigurationImportEvents(configurations, exclusions);
   return new AutoConfigurationEntry(configurations, exclusions);
}
```

其中最重要的是getCandidateConfigurations(annotationMetadata, attributes)

```java
/**
 * Return the auto-configuration class names that should be considered. By default
 * this method will load candidates using {@link SpringFactoriesLoader} with
 * {@link #getSpringFactoriesLoaderFactoryClass()}.
 * @param metadata the source metadata
 * @param attributes the {@link #getAttributes(AnnotationMetadata) annotation
 * attributes}
 * @return a list of candidate configurations
 */
protected List<String> getCandidateConfigurations(AnnotationMetadata metadata, AnnotationAttributes attributes) {
   List<String> configurations = SpringFactoriesLoader.loadFactoryNames(getSpringFactoriesLoaderFactoryClass(),
         getBeanClassLoader());
   Assert.notEmpty(configurations, "No auto configuration classes found in META-INF/spring.factories. If you "
         + "are using a custom packaging, make sure that file is correct.");
   return configurations;
}
```



## SpringBoot事件监听

