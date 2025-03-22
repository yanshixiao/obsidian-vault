---

UID: 20250322120656 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---





Spring 框架广泛运用了多种设计模式，以实现模块化、灵活性及扩展性。以下是 Spring 中关键设计模式及其应用场景的详细解析：

---

### **1. 单例模式（Singleton Pattern）**
- **应用场景**：管理 Bean 的实例化，确保每个 Bean 在容器中唯一。
- **实现方式**：
  - Spring 默认将 Bean 的作用域设为 `singleton`，由容器维护单例实例。
  - **示例**：所有通过 `@Component` 或 XML 定义的 Bean，默认均为单例。
- **优势**：减少对象创建开销，共享无状态服务。

---

### **2. 工厂模式（Factory Pattern）**
- **应用场景**：解耦对象的创建与使用，统一管理 Bean 实例化。
- **实现方式**：
  - **核心接口**：`BeanFactory` 和 `ApplicationContext` 作为工厂，负责创建和提供 Bean。
  - **扩展工厂**：`FactoryBean` 接口允许自定义复杂对象的创建逻辑（如 MyBatis 的 `SqlSessionFactoryBean`）。
- **示例**：
  ```java
  public class MyFactoryBean implements FactoryBean<MyObject> {
      @Override
      public MyObject getObject() {
          return new MyObject(); // 自定义创建逻辑
      }
  }
  ```

---

### **3. 代理模式（Proxy Pattern）**
- **应用场景**：实现 AOP 功能，增强目标对象行为（如事务管理、日志）。
- **实现方式**：
  - **JDK 动态代理**：基于接口代理，生成实现相同接口的代理类。
  - **CGLIB 代理**：通过继承生成子类代理，适用于无接口的类。
- **示例**：Spring 事务管理通过代理拦截方法调用，自动提交或回滚事务。

---

### **4. 模板方法模式（Template Method Pattern）**
- **应用场景**：定义算法骨架，子类实现具体步骤。
- **实现方式**：
  - **模板类**：如 `JdbcTemplate`、`RestTemplate`，封装通用流程（资源获取、异常处理）。
  - **钩子方法**：子类通过回调方法（如 `RowMapper`）定制数据处理。
- **示例**：
  ```java
  jdbcTemplate.query("SELECT * FROM users", (rs, rowNum) -> {
      return new User(rs.getString("name"));
  });
  ```

---

### **5. 观察者模式（Observer Pattern）**
- **应用场景**：实现事件驱动编程，解耦事件发布与监听。
- **实现方式**：
  - **事件类**：继承 `ApplicationEvent`（如 `ContextRefreshedEvent`）。
  - **发布者**：`ApplicationEventPublisher` 发布事件。
  - **监听者**：实现 `ApplicationListener` 或使用 `@EventListener` 注解。
- **示例**：容器启动后触发事件，执行初始化逻辑。

---

### **6. 适配器模式（Adapter Pattern）**
- **应用场景**：兼容不同接口的组件，统一调用方式。
- **实现方式**：
  - **HandlerAdapter**：在 Spring MVC 中适配不同类型的 Controller（如 Servlet、注解式 Controller）。
  - **AdvisorAdapter**：将 AOP 通知（Advice）适配为标准的拦截器链。
- **示例**：`RequestMappingHandlerAdapter` 处理 `@RequestMapping` 注解的方法。

---

### **7. 装饰者模式（Decorator Pattern）**
- **应用场景**：动态增强对象功能，避免继承膨胀。
- **实现方式**：
  - **包装类**：如 `TransactionAwareCacheDecorator` 为缓存添加事务支持。
  - **AOP 代理**：通过代理包装目标对象，添加额外行为。
- **示例**：缓存装饰器在事务提交后同步更新缓存。

---

### **8. 策略模式（Strategy Pattern）**
- **应用场景**：动态选择算法或策略实现。
- **实现方式**：
  - **资源加载**：`Resource` 接口的不同实现（`ClassPathResource`、`UrlResource`）。
  - **事务管理**：`PlatformTransactionManager` 的不同策略（JDBC、JTA）。
- **示例**：根据环境切换数据源策略（开发、测试、生产）。

---

### **9. 责任链模式（Chain of Responsibility Pattern）**
- **应用场景**：将请求沿处理链传递，由多个对象依次处理。
- **实现方式**：
  - **过滤器链**：Spring Security 的 `FilterChainProxy` 按顺序执行安全过滤器。
  - **拦截器链**：Spring MVC 的 `HandlerInterceptor` 链处理请求前后逻辑。
- **示例**：用户认证过滤器 → 权限检查过滤器 → 请求处理。

---

### **10. 原型模式（Prototype Pattern）**
- **应用场景**：每次获取 Bean 时创建新实例。
- **实现方式**：
  - 将 Bean 的作用域设为 `prototype`。
  - **示例**：多线程环境下，为每个线程创建独立的状态对象。
  ```xml
  <bean id="prototypeBean" class="com.example.PrototypeBean" scope="prototype"/>
  ```

---

### **11. 建造者模式（Builder Pattern）**
- **应用场景**：分步构建复杂对象，增强可读性。
- **实现方式**：
  - **Spring Security 配置**：`HttpSecurity` 的链式方法配置安全规则。
  - **Spring Boot 配置**：`SpringApplicationBuilder` 构建应用上下文。
- **示例**：
  ```java
  new HttpSecurity()
      .authorizeRequests().antMatchers("/admin").hasRole("ADMIN")
      .and().formLogin();
  ```

---

### **12. 组合模式（Composite Pattern）**
- **应用场景**：以树形结构处理对象集合，统一整体与部分的接口。
- **实现方式**：
  - **表达式解析**：Spring EL 中的复合表达式（如 `a > 0 && b < 10`）。
  - **组件集合**：如多个 `ViewResolver` 组合成链式解析逻辑。
- **示例**：多个 `ViewResolver` 按顺序尝试解析视图。

---

### **总结**
| **设计模式**        | **Spring 应用场景**                          | **核心价值**                     |
|---------------------|---------------------------------------------|---------------------------------|
| 单例模式             | Bean 作用域管理                              | 资源复用，减少开销               |
| 工厂模式             | BeanFactory 创建对象                         | 解耦对象创建与使用               |
| 代理模式             | AOP 动态代理                                 | 非侵入式功能增强                 |
| 模板方法模式         | JdbcTemplate、RestTemplate                   | 封装通用流程，扩展具体步骤       |
| 观察者模式           | ApplicationEvent 事件机制                    | 解耦事件发布与监听               |
| 适配器模式           | HandlerAdapter 适配不同 Controller           | 统一接口调用方式                 |
| 策略模式             | Resource 加载策略、事务管理器                | 动态切换算法实现                 |
| 责任链模式           | 过滤器链、拦截器链                          | 分步处理请求，增强扩展性         |

Spring 通过巧妙组合这些设计模式，实现了高度模块化、可扩展的架构，成为企业级开发的标杆框架。理解这些模式的应用，有助于深入掌握 Spring 的设计哲学，并提升代码设计能力。