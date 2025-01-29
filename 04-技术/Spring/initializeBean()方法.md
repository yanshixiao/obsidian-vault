---
author: yuanshuai
created: 2022-06-07 14:06:11
aliases: 
description:
tags: [IT/java/Spring]
---


到此方法时，bean已经完成了两个重要工作

- 调用createBeanInstance()方法：完成bean的实例化工作
- 调用populationBean()方法：完成bean的属性填充注入工作

```java
protected Object initializeBean(final String beanName, final Object bean, @Nullable RootBeanDefinition mbd) {
	// 对特殊的bean进行处理：实现了 Aware、BeanClassLoaderAware、BeanFactoryAware 的处理
	if (System.getSecurityManager() != null) {
		AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
			// 激活 Aware 方法
			invokeAwareMethods(beanName, bean);
			return null;
		}, getAccessControlContext());
	}
	else {
		invokeAwareMethods(beanName, bean);
	}

	Object wrappedBean = bean;
	if (mbd == null || !mbd.isSynthetic()) {
		// 调用了bean后处理器的方法
		// BeanPostProcessor 提供的方法，在bean初始化前调用，这时的 bean已完成了实例化和属性填充注入工作
		wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
	}

	try {
		// 激活自定义的init的方法
		invokeInitMethods(beanName, wrappedBean, mbd);
	}
	catch (Throwable ex) {
		throw new BeanCreationException(
				(mbd != null ? mbd.getResourceDescription() : null),
				beanName, "Invocation of init method failed", ex);
	}
	if (mbd == null || !mbd.isSynthetic()) {
		// 调用bean后处理器的方法
		// BeanPostProcessor 提供的方法，在bean初始化后调用，这时候的bean 已经创建完成了
		wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
	}
	return wrappedBean;
}
```

1. 对实现了 Aware 接口的 bean 进行相关设置
2. 调用 bean 后处理器的方法 applyBeanPostProcessorsBeforeInitialization()
3. 执行实现了 InitializingBean 或者用户自定义的 init 方法方法
4. 调用 bean 后处理器的方法applyBeanPostProcessorsAfterInitialization()：此处可以产生[[ aop]] 的代理对象

[[invokeAwareMethods()方法]]
[[invokeInitMethods()方法]]




