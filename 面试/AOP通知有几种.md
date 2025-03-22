---

UID: 20250322104023 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---




AOP（面向切面编程）中的 **通知（Advice）** 是切面在特定连接点（如方法调用、异常抛出等）执行的动作。常见的通知类型包括以下五种：

---

### 1. **前置通知（Before Advice）**
- **作用**：在目标方法执行**之前**触发。
- **场景**：适用于权限校验、参数验证等。
- **示例**：
  ```java
  @Before("execution(* com.example.service.*.*(..))")
  public void beforeAdvice() {
      System.out.println("方法执行前：权限检查...");
  }
  ```

---

### 2. **后置通知（After Returning Advice）**
- **作用**：在目标方法**成功执行并返回结果后**触发（仅当方法正常结束时调用）。
- **场景**：记录返回值、日志统计等。
- **示例**：
  ```java
  @AfterReturning(pointcut = "execution(* com.example.service.*.*(..))", returning = "result")
  public void afterReturningAdvice(Object result) {
      System.out.println("方法返回结果：" + result);
  }
  ```

---

### 3. **异常通知（After Throwing Advice）**
- **作用**：在目标方法**抛出异常时**触发。
- **场景**：异常处理、错误日志记录等。
- **示例**：
  ```java
  @AfterThrowing(pointcut = "execution(* com.example.service.*.*(..))", throwing = "ex")
  public void afterThrowingAdvice(Exception ex) {
      System.out.println("方法抛出异常：" + ex.getMessage());
  }
  ```

---

### 4. **最终通知（After (Finally) Advice）**
- **作用**：在目标方法**执行结束后**触发（无论成功或异常都会执行，类似 `finally` 块）。
- **场景**：资源清理（如关闭文件、释放连接）。
- **示例**：
  ```java
  @After("execution(* com.example.service.*.*(..))")
  public void afterAdvice() {
      System.out.println("方法执行结束：释放资源...");
  }
  ```

---

### 5. **环绕通知（Around Advice）**
- **作用**：**包裹**目标方法的执行，可以控制是否执行方法、修改参数或返回值。
- **场景**：性能监控、事务管理、缓存等。
- **示例**：
  ```java
  @Around("execution(* com.example.service.*.*(..))")
  public Object aroundAdvice(ProceedingJoinPoint joinPoint) throws Throwable {
      System.out.println("方法执行前：开启事务...");
      Object result = joinPoint.proceed(); // 执行目标方法
      System.out.println("方法执行后：提交事务...");
      return result;
  }
  ```

---

### 补充说明
- **执行顺序**：若同一连接点有多个通知，执行顺序通常为：  
  `Around（前半）` → `Before` → **目标方法** → `Around（后半）` → `AfterReturning/AfterThrowing` → `After`。
- **框架差异**：Spring AOP 基于代理，仅支持方法级别的连接点；AspectJ 支持更细粒度的连接点（如字段访问）。
- **引入通知（Introduction）**：严格来说属于增强类能力的特殊通知（添加接口实现），但通常不归类为基本通知类型。

通过合理使用这些通知，可以解耦横切关注点（如日志、安全），使业务代码更专注于核心逻辑。
