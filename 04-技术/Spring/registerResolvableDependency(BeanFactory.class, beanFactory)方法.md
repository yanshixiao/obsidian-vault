---
author: yuanshuai
created: 2022-06-16 14:34:38
aliases: 
description:
tags: [IT/java/Spring]
---

指定@Autowired时，相应接口注入哪个实例，一般用在一个接口有多个实现。

```java
@Component
public class CustomBeanFactoryPostProcessor implements BeanFactoryPostProcessor {
	@Override
	public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
		beanFactory.registerResolvableDependency(ITestBean.class,new ITestBeanB());
		beanFactory.registerResolvableDependency(ITestBeanFather.class,new ITestBeanA());
	}
}

```

```java
public interface ITestBean {
	void iTest();
}

public class ITestBeanFather {
}

@Component
public class ITestBeanA extends ITestBeanFather implements ITestBean{
	@Override
	public void iTest() {
		System.out.println("ITestBeanA");
	}
}

@Component
public class ITestBeanB extends ITestBeanFather implements ITestBean{
	@Override
	public void iTest() {
		System.out.println("ITestBeanB");
	}
}

@Component
public class AutowiredBean implements InitializingBean {
	@Autowired
	private ITestBean iTestBean;
	@Autowired
	private ITestBeanFather iTestBeanFather;

	@Override
	public void afterPropertiesSet() throws Exception {
		iTestBean.iTest();
		ITestBean bean = (ITestBean) this.iTestBeanFather;
		bean.iTest();
	}
}

```

