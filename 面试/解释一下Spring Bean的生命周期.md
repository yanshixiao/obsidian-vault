---

UID: 20250322113435 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---



Spring Bean的生命周期指的是Bean从被创建到被销毁的整个过程，由Spring容器管理。以下是详细的阶段和扩展点：

---

### **1. Bean的实例化（Instantiation）**
- **方式**：通过构造函数或工厂方法创建Bean实例。
- **触发条件**：容器启动时（单例）或每次请求时（原型作用域）。

---

### **2. 属性注入（Populate Properties）**
- **过程**：设置Bean的依赖属性，通过Setter方法、字段注入或构造器注入完成。
- **示例**：
  ```xml
  <bean id="userService" class="com.example.UserService">
      <property name="userDao" ref="userDao"/>
  </bean>
  ```

---

### **3. Aware接口回调（Aware Interfaces）**
- **作用**：让Bean获取容器的底层信息（如BeanName、BeanFactory等）。
- **常见接口**：
  - `BeanNameAware`：注入Bean的ID。
  - `BeanFactoryAware`：注入BeanFactory实例。
  - `ApplicationContextAware`：注入ApplicationContext（更强大，但耦合性更高）。

---

### **4. BeanPostProcessor的前置处理（PostProcessBeforeInitialization）**
- **执行时机**：属性注入完成后，初始化方法调用前。
- **用途**：修改Bean属性或生成代理对象（如AOP的动态代理）。
- **示例**：
  ```java
  public class CustomBeanPostProcessor implements BeanPostProcessor {
      @Override
      public Object postProcessBeforeInitialization(Object bean, String beanName) {
          // 修改或增强Bean
          return bean;
      }
  }
  ```

---

### **5. 初始化方法（Initialization）**
- **执行顺序**：
  1. `@PostConstruct`注解标记的方法。
  2. `InitializingBean`接口的`afterPropertiesSet()`方法。
  3. XML配置的`init-method`或`@Bean(initMethod = "...")`。
- **示例**：
  ```java
  @Component
  public class MyBean {
      @PostConstruct
      public void init() {
          System.out.println("@PostConstruct初始化");
      }
  }
  ```

---

### **6. BeanPostProcessor的后置处理（PostProcessAfterInitialization）**
- **执行时机**：初始化方法调用后。
- **用途**：进一步处理Bean（如生成最终代理对象）。
- **示例**：
  ```java
  public class CustomBeanPostProcessor implements BeanPostProcessor {
      @Override
      public Object postProcessAfterInitialization(Object bean, String beanName) {
          // 最终处理
          return bean;
      }
  }
  ```

---

### **7. Bean就绪（Ready）**
- **状态**：此时Bean已完全初始化，可被应用程序使用（如通过`context.getBean()`获取）。

---

### **8. 销毁阶段（Destruction）**
- **触发条件**：容器关闭时（仅单例Bean，原型Bean需手动管理）。
- **执行顺序**：
  1. `@PreDestroy`注解标记的方法。
  2. `DisposableBean`接口的`destroy()`方法。
  3. XML配置的`destroy-method`或`@Bean(destroyMethod = "...")`。
- **示例**：
  ```java
  @Component
  public class MyBean {
      @PreDestroy
      public void cleanup() {
          System.out.println("@PreDestroy清理资源");
      }
  }
  ```

---

### **完整流程图**
```plaintext
实例化 → 属性注入 → Aware接口回调 → BeanPostProcessor前置处理 → 初始化方法 → BeanPostProcessor后置处理 → Bean就绪 → 销毁方法
```

---

### **关键扩展点总结**
| 扩展点                  | 说明                                                                 |
|-------------------------|----------------------------------------------------------------------|
| `BeanPostProcessor`     | 全局干预Bean的创建过程（前后置处理）。                               |
| `Aware接口`             | 获取容器信息（如BeanName、ApplicationContext）。                     |
| `@PostConstruct/@PreDestroy` | 注解驱动的初始化和销毁方法（推荐使用，解耦Spring接口）。             |
| `InitializingBean/DisposableBean` | 接口定义的初始化和销毁方法（与Spring耦合）。              |
| `init-method/destroy-method` | XML或Java配置中指定的自定义方法（灵活性高）。                 |

---

### **作用域对生命周期的影响**
- **单例Bean（Singleton）**：容器启动时创建，关闭时销毁。
- **原型Bean（Prototype）**：每次请求时创建，容器不管理销毁（需手动清理）。
- **其他作用域**（如Request、Session）：生命周期与会话或请求绑定。

---

### **实际应用场景**
- **数据库连接池**：在初始化时建立连接，销毁时关闭连接。
- **缓存管理**：在初始化时加载数据，销毁时持久化数据。
- **AOP代理**：通过`BeanPostProcessor`生成代理对象。

---

通过理解Bean的生命周期，开发者可以精准控制资源管理、扩展框架功能，并避免因生命周期混乱导致的资源泄漏或状态不一致问题。

