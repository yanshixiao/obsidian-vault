---
author: yuanshuai
created: 2022-06-07 14:13:27
aliases: 
description:
tags: [IT/java/Spring]
---

`bean` 的初始化方式除了可以使用 `init-method` 属性或 `@Bean(initMethod=''”)`，还可以通过实现 `InitializingBean` 接口，并且在 `afterPropertiesSet()` 方法中实现自己初始化的业务逻辑

调用的顺序为先调用`afterPropertiesSet()`，然后调用`init-method`指定的方法

```java
protected void invokeInitMethods(String beanName, final Object bean, @Nullable RootBeanDefinition mbd)
			throws Throwable {
			
	// 首先检查是否是InitializingBean，如果是的话则需要调用 afterPropertiesSet 方法
	boolean isInitializingBean = (bean instanceof InitializingBean);
	if (isInitializingBean && (mbd == null || !mbd.isExternallyManagedInitMethod("afterPropertiesSet"))) {
		if (logger.isDebugEnabled()) {
			logger.debug("Invoking afterPropertiesSet() on bean with name '" + beanName + "'");
		}
		// 调用 afterPropertiesSet  方法
		if (System.getSecurityManager() != null) {
			try {
				AccessController.doPrivileged((PrivilegedExceptionAction<Object>) () -> {
					((InitializingBean) bean).afterPropertiesSet();
					return null;
				}, getAccessControlContext());
			}
			catch (PrivilegedActionException pae) {
					throw pae.getException();
			}
		}
		else {
			((InitializingBean) bean).afterPropertiesSet();
		}
	}
	
	if (mbd != null && bean.getClass() != NullBean.class) {
		// 从RootBeanDefinition 中获取initMethod 方法名称
		String initMethodName = mbd.getInitMethodName();
		// 调用initMethod 方法
		if (StringUtils.hasLength(initMethodName) &&
			!(isInitializingBean && "afterPropertiesSet".equals(initMethodName)) &&
				!mbd.isExternallyManagedInitMethod(initMethodName)) {
			invokeCustomInitMethod(beanName, bean, mbd);
		}
	}
}
```
