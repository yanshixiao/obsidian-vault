---

UID: 20250322225333 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---


Spring 事务的实现方式基于 **AOP（面向切面编程）** 和 **代理模式**，通过拦截目标方法，动态管理事务的开启、提交、回滚等操作。其核心机制如下：

---

### **1. 核心实现机制**
#### **(1) AOP 与动态代理**
- **动态代理**：  
  Spring 通过 JDK 动态代理（针对接口）或 CGLIB 代理（针对类）创建目标对象的代理。
  - **拦截方法调用**：代理对象会拦截带有 `@Transactional` 注解的方法。
  - **事务增强逻辑**：在方法执行前后，插入事务管理代码（如开启事务、提交或回滚）。

#### **(2) 事务属性（TransactionAttribute）**
- 每个事务方法的事务属性（如传播行为、隔离级别、超时时间）通过 `@Transactional` 注解定义。
- 这些属性会被解析为 `TransactionAttribute` 对象，供事务管理器使用。

---

### **2. 关键组件**
#### **(1) `PlatformTransactionManager`**
- **作用**：Spring 事务管理的核心接口，定义了事务的创建、提交、回滚等操作。
- **常见实现类**：
  - `DataSourceTransactionManager`：用于 JDBC 或 MyBatis（基于数据源管理事务）。
  - `JpaTransactionManager`：用于 JPA/Hibernate。
  - `JtaTransactionManager`：用于分布式事务（JTA）。

#### **(2) 事务拦截器（`TransactionInterceptor`）**
- **职责**：拦截目标方法，调用 `PlatformTransactionManager` 管理事务。
- **工作流程**：
  1. **开启事务**：根据传播行为决定是否新建事务或加入现有事务。
  2. **执行业务方法**：调用目标方法。
  3. **提交或回滚**：根据执行结果（是否抛出异常）决定事务状态。

#### **(3) 事务同步管理器（`TransactionSynchronizationManager`）**
- **作用**：将事务资源（如数据库连接）绑定到当前线程，确保同一事务中的多个操作共享同一资源。
- **关键方法**：
  - `bindResource()`：绑定资源（如 `Connection`）。
  - `getResource()`：获取当前线程绑定的资源。

---

### **3. 事务管理流程**
以下以声明式事务（`@Transactional`）为例，说明事务执行步骤：

#### **步骤 1：创建代理对象**
- Spring 容器在初始化 Bean 时，检测到 `@Transactional` 注解，为其生成代理对象。

#### **步骤 2：方法拦截**
- 代理对象拦截目标方法的调用，触发 `TransactionInterceptor`。

#### **步骤 3：事务准备**
- 根据传播行为（如 `REQUIRED`）决定是否创建新事务。
- 获取数据库连接，设置隔离级别、只读模式等属性。
- 绑定连接资源到当前线程（通过 `TransactionSynchronizationManager`）。

#### **步骤 4：执行业务逻辑**
- 调用原始目标方法，执行业务代码。

#### **步骤 5：提交或回滚**
- **成功执行**：提交事务，释放连接。
- **抛出异常**：回滚事务（默认仅回滚 `RuntimeException` 和 `Error`）。
  ```java
  @Transactional(rollbackFor = Exception.class) // 自定义回滚异常类型
  ```

---

### **4. 事务传播行为的实现**
- **`REQUIRED`**：  
  若当前无事务，则新建事务；若已有事务，则加入。
  ```java
  // 伪代码逻辑
  if (当前无事务) {
      开启新事务;
  } else {
      使用现有事务;
  }
  ```
- **`REQUIRES_NEW`**：  
  无论当前是否存在事务，均挂起当前事务并创建新事务。
  ```java
  // 伪代码逻辑
  if (当前有事务) {
      挂起当前事务;
  }
  开启新事务;
  ```

---

### **5. 事务同步与资源绑定**
- **数据库连接的绑定**：  
  事务管理器通过 `DataSourceUtils.getConnection()` 获取连接，并将其绑定到当前线程。
- **资源释放**：  
  事务提交或回滚后，通过 `TransactionSynchronizationManager.unbindResource()` 释放资源。

---

### **6. 事务失效的常见场景**
#### **(1) 自调用问题**
- **问题**：类内部方法调用（如 `this.methodB()`）不会经过代理对象，导致事务失效。
- **解决**：通过 AOP 代理调用（如注入自身 Bean 或使用 `AopContext.currentProxy()`）。

#### **(2) 异常未被抛出**
- **问题**：捕获异常未重新抛出，事务拦截器无法触发回滚。
  ```java
  @Transactional
  public void method() {
      try {
          // 可能抛出异常的操作
      } catch (Exception e) {
          // 未抛出异常，事务不会回滚！
      }
  }
  ```
- **解决**：在 `catch` 块中手动回滚或抛出异常。

#### **(3) 非 public 方法**
- **问题**：`@Transactional` 注解在非 public 方法上不生效（动态代理限制）。
- **解决**：确保事务方法为 `public`。

---

### **7. 代码示例**
#### **(1) 声明式事务**
```java
@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public void createUser(User user) {
        userRepository.save(user);
        // 其他操作（如日志记录）
    }
}
```

#### **(2) 编程式事务**
```java
@Service
public class OrderService {

    @Autowired
    private PlatformTransactionManager transactionManager;

    public void placeOrder(Order order) {
        TransactionDefinition def = new DefaultTransactionDefinition();
        TransactionStatus status = transactionManager.getTransaction(def);
        try {
            // 业务逻辑
            transactionManager.commit(status);
        } catch (Exception e) {
            transactionManager.rollback(status);
            throw e;
        }
    }
}
```

---

### **总结**
Spring 事务通过 **AOP 动态代理** 和 **事务拦截器** 实现，核心依赖 `PlatformTransactionManager` 管理事务生命周期，结合传播行为、隔离级别等属性控制事务边界。理解其实现机制，可有效避免事务失效问题，并优化高并发场景下的数据一致性。


