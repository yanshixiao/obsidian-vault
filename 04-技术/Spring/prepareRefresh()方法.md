---
author: yuanshuai
created: 2022-06-16 14:10:05
aliases: 
description:
tags: [IT/java/Spring]
---

激活开启容器

```java
	protected void prepareRefresh() {
		//记录时间
        this.startupDate = System.currentTimeMillis();
        //设置当前容器未关闭
        this.closed.set(false);
        //设置当前容器已激活
        this.active.set(true);
        if (this.logger.isInfoEnabled()) {
        	//打印容器刷新日志
            this.logger.info("Refreshing " + this);
        }
		//初始化一下属性(该方法默认是空的,是提供给子类来实现的,
		//假设我们有些工作需要在初始化bean以前就要加载设置等,可以通过重写这个方法来完成)
        this.initPropertySources();
        //校验设置的属性是否合法
        this.getEnvironment().validateRequiredProperties();
        //初始化一个集合属性,提供用来保存后面创建的事件,如果有事件发生会放入这个集合中
        this.earlyApplicationEvents = new LinkedHashSet();
    }

```