---
author: yuanshuai
created: 2022-06-07 14:21:43
aliases: 
description:
tags: [IT/java/Spring]
---

```java
private void invokeAwareMethods(String beanName, Object bean) {  
   if (bean instanceof Aware) {  
      if (bean instanceof BeanNameAware) {  
         ((BeanNameAware) bean).setBeanName(beanName);  
      }  
      if (bean instanceof BeanClassLoaderAware) {  
         ClassLoader bcl = getBeanClassLoader();  
         if (bcl != null) {  
            ((BeanClassLoaderAware) bean).setBeanClassLoader(bcl);  
         }  
      }  
      if (bean instanceof BeanFactoryAware) {  
         ((BeanFactoryAware) bean).setBeanFactory(AbstractAutowireCapableBeanFactory.this);  
      }  
   }  
}
```

Aware翻译过来是感知的意思

从源码可以看出，这个方法的功能如下：

- 如果 `bean` 实现了 `BeanNameAware` 接口，则将 `beanName` 设置进去
- 如果 `bean` 实现了 `BeanClassLoaderAware` 接口，则将 `ClassLoader` 设置进去
- 如果 `bean` 实现了 `BeanFactoryAware` 接口，则将 `beanFactory`设置进去




