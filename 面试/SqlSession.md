---

UID: 20250323143316 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---




---

**SqlSession** 是 MyBatis 中用于执行数据库操作的**核心接口**，相当于一次数据库会话的抽象。它提供了执行 SQL、管理事务、获取 Mapper 接口代理对象等核心功能。理解其生命周期和创建时机对性能优化和避免资源泄漏至关重要。

---

### **一、SqlSession 的核心作用**
1. **执行 SQL 操作**  
   - 直接通过 `selectOne()`、`insert()` 等方法执行 SQL。  
   - 通过 `getMapper()` 获取 Mapper 接口的动态代理对象（如 `UserMapper`）。  
2. **管理事务**  
   - 手动提交（`commit()`）或回滚（`rollback()`）事务。  
3. **控制缓存**  
   - 一级缓存（`SqlSession` 级别）的生命周期由其管理。  
4. **维护数据库连接**  
   - 每个 `SqlSession` 对应一个数据库连接（除非使用连接池复用）。

---

### **二、SqlSession 的创建时机**
#### **1. 手动创建（原生 MyBatis）**
每次调用 `SqlSessionFactory.openSession()` 方法都会创建一个新的 `SqlSession`。  
**示例**：
```java
// 创建一个新的 SqlSession（默认开启事务，需手动提交）
SqlSession sqlSession = sqlSessionFactory.openSession();
try {
    UserMapper mapper = sqlSession.getMapper(UserMapper.class);
    User user = mapper.findUserById(1L);
    sqlSession.commit(); // 手动提交事务
} finally {
    sqlSession.close();  // 必须关闭释放资源
}
```

#### **2. 自动创建（集成 Spring）**
在 Spring 或 Spring Boot 中，`SqlSession` 的生命周期通常由框架管理：  
- **默认行为**：每个事务（如 `@Transactional` 方法）创建一个新的 `SqlSession`，事务结束后关闭。  
- **线程绑定**：同一线程内的事务复用同一个 `SqlSession`（通过 `TransactionSynchronizationManager`）。

---

### **三、SqlSession 的创建场景**
以下操作会触发新的 `SqlSession` 创建：

#### **1. 调用 `SqlSessionFactory.openSession()`**
- **每次调用均创建新实例**：  
  ```java
  SqlSession session1 = sqlSessionFactory.openSession();
  SqlSession session2 = sqlSessionFactory.openSession(); // 新的 SqlSession
  ```

#### **2. 不同线程访问**
- **线程不共享**：每个线程首次获取 `SqlSession` 时创建新实例（需结合连接池管理）。

#### **3. 事务边界变化**
- **Spring 事务传播行为**：  
  - `PROPAGATION_REQUIRES_NEW`：挂起当前事务，创建新事务和新 `SqlSession`。  
  - `PROPAGATION_NESTED`：嵌套事务可能复用或新建 `SqlSession`（依赖具体实现）。

#### **4. 连接池资源释放后重新获取**
- **连接池耗尽后**：当连接池中无可用连接时，新请求会等待或创建新连接（取决于配置），此时可能伴随新的 `SqlSession`。

---

### **四、SqlSession 的复用与线程安全**
| **场景**               | **是否复用** | **线程安全** | **说明**                                                                 |
|------------------------|------------|------------|-------------------------------------------------------------------------|
| **原生 MyBatis**        | 否          | 否          | 每个线程需独立创建和关闭，避免并发问题。                                       |
| **Spring 事务管理**     | 是（事务内） | 是          | 同一事务内复用，通过线程绑定保证线程安全。                                     |
| **连接池配置**         | 是（连接级别）| 否          | 连接池复用的是物理连接，但 `SqlSession` 仍可能新建（如不同事务）。             |

---

### **五、最佳实践**
1. **及时关闭 SqlSession**  
   **原生 MyBatis** 中必须手动关闭，避免数据库连接泄漏：
   ```java
   try (SqlSession session = sqlSessionFactory.openSession()) { 
       // 自动关闭（实现 AutoCloseable）
   }
   ```

2. **集成 Spring 时依赖事务管理**  
   使用 `@Transactional` 注解，由 Spring 管理 `SqlSession` 生命周期，避免手动操作。

3. **避免跨线程传递 SqlSession**  
   `SqlSession` 非线程安全，禁止在多线程间共享。

4. **合理配置连接池**  
   如使用 `HikariCP` 或 `Druid`，优化连接池参数（如 `maxPoolSize`），减少频繁创建开销。

---

### **六、常见问题**
#### **Q1：SqlSession 和数据库连接是一对一关系吗？**
- **是**：每个 `SqlSession` 对应一个数据库连接（除非开启连接池复用）。  
- **但**：连接池中物理连接可能被多个 `SqlSession` 复用（不同时活跃）。

#### **Q2：为何要避免频繁创建 SqlSession？**
- **资源开销**：频繁创建/关闭会导致连接池压力增大和性能下降。  
- **事务管理困难**：短生命周期的 `SqlSession` 需手动管理提交和回滚，易出错。

#### **Q3：Spring 中如何控制 SqlSession 创建？**
- **事务传播机制**：通过 `@Transactional(propagation = ...)` 定义事务边界，间接控制 `SqlSession` 生命周期。  
- **模板模式**：使用 `SqlSessionTemplate` 封装线程安全的 `SqlSession` 操作。

---

### **总结**
`SqlSession` 是 MyBatis 操作数据库的入口，其创建时机由调用 `openSession()` 或框架事务管理触发。**关键原则**：  
- 原生 MyBatis 中手动管理，确保及时关闭。  
- Spring 集成时依赖事务注解，避免直接操作。  
- 高并发场景优化连接池配置，平衡资源开销与性能。
