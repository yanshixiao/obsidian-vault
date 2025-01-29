---
author: yuanshuai
created: 2022-06-16 14:20:18
aliases: 
description:
tags: [IT/java/Spring]
---

对获取到的 beanFactory 做预处理设置

上一步获取到的beanFactory是一个创建出来什么都没有的空工厂,此处进行设置

```java
protected void prepareBeanFactory(ConfigurableListableBeanFactory beanFactory) {
		//设置类加载器
        beanFactory.setBeanClassLoader(this.getClassLoader());
        //设置表达式语言解析器....
        beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
        beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, this.getEnvironment()));
        //设置添加一个 tApplicationContextAwareProcessor 后置处理器
        beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
        
        //设置忽略的自动装配的接口,就是设置这些接口的实现类不能通过这些接口实现自动注入
        beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
        beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
        beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
        beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);
		
		//注册可以解析的自动装配,假设想要使用@Autowired 注解将Spring提供的 BeanFactory 
		//装配到自己,创建的某个类的属性上,就要在此处设置
        beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
        beanFactory.registerResolvableDependency(ResourceLoader.class, this);
        beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
        beanFactory.registerResolvableDependency(ApplicationContext.class, this);

		//设置添加一个ApplicationListenerDetector后置处理器
        beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(this));
		
		//添加编译时支持AspectJ
        if (beanFactory.containsBean("loadTimeWeaver")) {
            beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
            beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
        }

		//向beanFactory中注册组件
        if (!beanFactory.containsLocalBean("environment")) {
        	//注册了一个 Environment,该对象中存了一下我们默认的属性
            beanFactory.registerSingleton("environment", this.getEnvironment());
        }

        if (!beanFactory.containsLocalBean("systemProperties")) {
        	//向beanFactory中注册了系统属性属性(一个Map集合)
            beanFactory.registerSingleton("systemProperties", this.getEnvironment().getSystemProperties());
        }

        if (!beanFactory.containsLocalBean("systemEnvironment")) {
        	//向beanFactory中注册环境变量等相关信息(一个Map集合)
            beanFactory.registerSingleton("systemEnvironment", this.getEnvironment().getSystemEnvironment());
        }
    }

```

[[ignoreDependencyInterface(X.class)方法]]

[[registerResolvableDependency(BeanFactory.class, beanFactory)方法]]


