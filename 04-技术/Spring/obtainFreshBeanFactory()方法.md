---
author: yuanshuai
created: 2022-06-16 14:13:14
aliases: 
description:
tags: [IT/java/Spring]
---

获取bean工厂

```java
protected ConfigurableListableBeanFactory obtainFreshBeanFactory() {
		//刷新bean工厂,创建一个 DefaultListableBeanFactory类型的 bean工厂
		//赋值给 beanFactory 属性,对创建的这个 beanFactory 设置一个序列号
        this.refreshBeanFactory();
        //获取beanFactory,就上将上一步设置好序列号的的beanFactory返回回来
        ConfigurableListableBeanFactory beanFactory = this.getBeanFactory();
        //打印日志
        if (this.logger.isDebugEnabled()) {
            this.logger.debug("Bean factory for " + this.getDisplayName() + ": " + beanFactory);
        }
		//将创建好的 beanFactory 返回
        return beanFactory;
    }

```


