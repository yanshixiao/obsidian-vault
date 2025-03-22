---

UID: 20250322115711 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---
---

Spring 框架支持多种 Bean 的作用域（Scope），用于控制 Bean 的实例创建和生命周期管理。以下是 Spring 支持的几种核心作用域及其适用场景：

---

### **1. Singleton（单例作用域）**
- **默认作用域**：如果未显式指定作用域，Bean 默认为单例。
- **特点**：
  - 每个 Spring IoC 容器中，一个 Bean 定义对应**唯一实例**。
  - 所有依赖该 Bean 的组件共享同一个实例。
- **适用场景**：
  - 无状态的工具类（如日志组件、配置类）。
  - 需要频繁重用的对象（如数据库连接池）。
- **配置方式**：
  ```java
  @Bean
  @Scope("singleton")  // 可省略，默认即为单例
  public DataSource dataSource() {
      return new HikariDataSource();
  }
  ```

---

### **2. Prototype（原型作用域）**
- **特点**：
  - 每次通过容器请求 Bean 时，都会**创建一个新实例**。
  - 不管理 Bean 的生命周期（销毁需手动处理）。
- **适用场景**：
  - 有状态的 Bean（如用户请求的上下文对象）。
  - 需要隔离状态的场景（如多线程任务）。
- **配置方式**：
  ```java
  @Bean
  @Scope("prototype")
  public UserSession userSession() {
      return new UserSession();
  }
  ```

---

### **3. Request（请求作用域）**
- **特点**：
  - 每个 HTTP 请求会创建一个新实例。
  - **仅限 Web 环境**（如 Spring MVC、Spring WebFlux）。
- **适用场景**：
  - 存储请求级别的数据（如表单数据、用户认证信息）。
- **配置方式**：
  ```java
  @Bean
  @RequestScope  // 或 @Scope(value = WebApplicationContext.SCOPE_REQUEST)
  public RequestData requestData() {
      return new RequestData();
  }
  ```

---

### **4. Session（会话作用域）**
- **特点**：
  - 每个用户会话（Session）对应一个实例。
  - 实例在会话期间存活，会话结束则销毁。
  - **仅限 Web 环境**。
- **适用场景**：
  - 存储用户会话数据（如购物车、用户偏好设置）。
- **配置方式**：
  ```java
  @Bean
  @SessionScope  // 或 @Scope(value = WebApplicationContext.SCOPE_SESSION)
  public ShoppingCart shoppingCart() {
      return new ShoppingCart();
  }
  ```

---

### **5. Application（应用作用域）**
- **特点**：
  - 整个 Web 应用的生命周期内只创建一个实例。
  - 作用域为 `ServletContext` 级别，与 Spring 容器的单例不同。
- **适用场景**：
  - 全局共享的配置或资源（如应用级别的缓存）。
- **配置方式**：
  ```java
  @Bean
  @Scope(value = WebApplicationContext.SCOPE_APPLICATION)
  public GlobalCache globalCache() {
      return new GlobalCache();
  }
  ```

---

### **6. WebSocket（WebSocket 作用域）**
- **特点**：
  - 每个 WebSocket 会话的生命周期内创建一个实例。
  - 仅适用于 WebSocket 通信场景。
- **适用场景**：
  - 实时通信中维护会话状态（如聊天室消息管理）。
- **配置方式**：
  ```java
  @Bean
  @Scope(scopeName = "websocket", proxyMode = ScopedProxyMode.TARGET_CLASS)
  public ChatSession chatSession() {
      return new ChatSession();
  }
  ```

---

### **7. 自定义作用域**
- **扩展机制**：通过实现 `Scope` 接口定义自定义作用域（如基于线程、租户等）。
- **示例场景**：
  - 线程级作用域：每个线程独立实例。
  - 租户隔离作用域：多租户应用中按租户区分实例。
- **注册方式**：
  ```java
  public class ThreadScope implements Scope { /* 实现接口方法 */ }

  // 注册自定义作用域
  @Configuration
  public class AppConfig {
      @Bean
      public CustomScopeConfigurer customScope() {
          CustomScopeConfigurer configurer = new CustomScopeConfigurer();
          configurer.addScope("thread", new ThreadScope());
          return configurer;
      }
  }
  ```

---

### **作用域配置方式对比**
| **作用域**       | **注解**                          | **XML 配置**                   | **适用环境**        |
|------------------|----------------------------------|--------------------------------|--------------------|
| Singleton        | `@Scope("singleton")`            | `<bean scope="singleton">`     | 所有环境           |
| Prototype        | `@Scope("prototype")`            | `<bean scope="prototype">`     | 所有环境           |
| Request          | `@RequestScope`                  | `<bean scope="request">`       | Web 环境           |
| Session          | `@SessionScope`                  | `<bean scope="session">`       | Web 环境           |
| Application      | `@Scope("application")`          | `<bean scope="application">`   | Web 环境           |
| WebSocket        | `@Scope("websocket")`            | 需自定义配置                   | WebSocket 环境     |
| 自定义作用域      | 注册自定义 `Scope` 实现           | 注册自定义 `Scope` 实现        | 按需配置           |

---

### **注意事项**
1. **作用域代理**：
   - 在单例 Bean 中注入短作用域 Bean（如 Request）时，需使用代理：
     ```java
     @Scope(proxyMode = ScopedProxyMode.TARGET_CLASS)
     ```
   - 代理模式确保每次调用时获取最新实例。

2. **资源管理**：
   - Prototype 作用域的 Bean 需手动清理资源（如数据库连接）。
   - 可通过实现 `DisposableBean` 或定义 `@PreDestroy` 方法处理。

3. **性能影响**：
   - 高频创建 Prototype 或 Request 作用域的 Bean 可能影响性能，需权衡设计。

---

### **总结**
Spring 的作用域机制提供了灵活的实例管理策略，开发者可根据业务需求选择：
- **无状态共享** → Singleton。
- **状态隔离** → Prototype、Request、Session。
- **全局资源** → Application。
- **实时通信** → WebSocket。
- **特殊需求** → 自定义作用域。

合理使用作用域能有效管理资源生命周期，提升应用的健壮性和性能。


