---
author: yuanshuai
created: 2021-10-15 11:16:31
aliases: 
description:
tags: [Spring]
---




### 异常

#### 分类

##### checked异常：
不可预测，无效的用户输入，文件不存在，网络或数据库连接错误等。代码中必须try-catch处理或者throw抛出。继承自Exception。

##### unchecked异常：
可以预测，是RuntimeException的子类，常见的有NullPointerException。不是必须代码显示处理。

#### 实现

自定义异常处理类继承 HandlerExceptionResolvers 。 实现resolveException方法，进行个性化的处理。注入到bean中后，Spring中的doDispatch方法中：

```java
catch (Exception ex) {  
    Object handler = (mappedHandler != null ? mappedHandler.getHandler() : null);  
    mv = processHandlerException(processedRequest, response, handler, ex);  
    errorView = (mv != null);  
}  
```
processHandlerException方法就是捕获异常处理的。继续看这个方法


```
protected ModelAndView processHandlerException(HttpServletRequest request, HttpServletResponse response,  
        Object handler, Exception ex) throws Exception {  
  
    // Check registered HandlerExceptionResolvers...  
    ModelAndView exMv = null;  
    for (HandlerExceptionResolver handlerExceptionResolver : this.handlerExceptionResolvers) {  
        exMv = handlerExceptionResolver.resolveException(request, response, handler, ex);  
        if (exMv != null) {  
            break;  
        }  
    }  
    if (exMv != null) {  
        if (exMv.isEmpty()) {  
            return null;  
        }  
        // We might still need view name translation for a plain error model...  
        if (!exMv.hasView()) {  
            exMv.setViewName(getDefaultViewName(request));  
        }  
        if (logger.isDebugEnabled()) {  
            logger.debug("Handler execution resulted in exception - forwarding to resolved error view: " + exMv, ex);  
        }  
        WebUtils.exposeErrorRequestAttributes(request, ex, getServletName());  
        return exMv;  
    }  
  
    throw ex;  
}  
```
这个方法中handlerExceptionResolver.resolveException()就是实际处理异常的。
其中this.handlerExceptionResolvers肯定是个列表，不用说，反射balabalba。继续跟踪。
```
private void initHandlerExceptionResolvers(ApplicationContext context) {  
        this.handlerExceptionResolvers = null;  
  
        if (this.detectAllHandlerExceptionResolvers) {  
            // Find all HandlerExceptionResolvers in the ApplicationContext, including ancestor contexts.  
            Map<String, HandlerExceptionResolver> matchingBeans = BeanFactoryUtils  
                    .beansOfTypeIncludingAncestors(context, HandlerExceptionResolver.class, true, false);  
            if (!matchingBeans.isEmpty()) {  
                this.handlerExceptionResolvers = new ArrayList<HandlerExceptionResolver>(matchingBeans.values());  
                // We keep HandlerExceptionResolvers in sorted order.  
                OrderComparator.sort(this.handlerExceptionResolvers);  
            }  
        }  
        else {  
            try {  
                HandlerExceptionResolver her =  
                        context.getBean(HANDLER_EXCEPTION_RESOLVER_BEAN_NAME, HandlerExceptionResolver.class);  
                this.handlerExceptionResolvers = Collections.singletonList(her);  
            }  
            catch (NoSuchBeanDefinitionException ex) {  
                // Ignore, no HandlerExceptionResolver is fine too.  
            }  
        }  
  
        // Ensure we have at least some HandlerExceptionResolvers, by registering  
        // default HandlerExceptionResolvers if no other resolvers are found.  
        if (this.handlerExceptionResolvers == null) {  
            this.handlerExceptionResolvers = getDefaultStrategies(context, HandlerExceptionResolver.class);  
            if (logger.isDebugEnabled()) {  
                logger.debug("No HandlerExceptionResolvers found in servlet '" + getServletName() + "': using default");  
            }  
        }  
    }  
```

可以清洗看到这个方法是将handlerExceptionResolvers进行了初始化，并将自定义的异常处理类（可以多个）写入this.handlerExceptionResolvers
