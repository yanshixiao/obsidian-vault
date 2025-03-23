---

UID: 20250323141159 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---



---

**是的，MyBatis 支持延迟加载（Lazy Loading）**。其核心目的是优化数据库查询性能，**仅在真正需要关联数据时执行查询**，避免一次性加载冗余数据。以下是 MyBatis 延迟加载的实现原理、配置方式和注意事项：

---

### **一、延迟加载的实现原理**
MyBatis 的延迟加载通过 **动态代理** 和 **拦截器机制** 实现，具体步骤如下：

#### 1. **生成代理对象**  
   - 当查询主对象（如 `User`）时，MyBatis 不会立即加载关联对象（如 `Order`）。  
   - 关联属性（如 `user.getOrders()`）会被替换为 **动态代理对象**（如 `JavassistProxy` 或 `CglibProxy`）。

#### 2. **拦截方法调用**  
   - 代理对象会拦截所有方法调用（如 `getOrders()`、`size()` 等）。  
   - 当首次访问关联属性时，触发关联数据的查询。

#### 3. **执行延迟查询**  
   - 代理对象通过 `SqlSession` 执行预先定义的关联查询 SQL（如 `findOrdersByUserId`）。  
   - 查询结果被注入到主对象的关联属性中，后续访问不再触发查询。

---

### **二、延迟加载的配置方式**
#### 1. **全局配置（mybatis-config.xml）**  
   在全局配置文件中开启延迟加载和代理模式：
   ```xml
   <settings>
       <!-- 开启延迟加载 -->
       <setting name="lazyLoadingEnabled" value="true"/>
       <!-- 按需加载（仅触发实际访问的关联属性） -->
       <setting name="aggressiveLazyLoading" value="false"/>
       <!-- 选择代理实现（默认 JAVASSIST） -->
       <setting name="proxyMethod" value="CGLIB"/>
   </settings>
   ```

#### 2. **局部配置（Mapper XML）**  
   在 `<association>` 或 `<collection>` 中指定 `fetchType="lazy"`：
   ```xml
   <resultMap id="userResultMap" type="User">
       <collection 
           property="orders" 
           column="id" 
           select="findOrdersByUserId"
           fetchType="lazy"  <!-- 显式指定延迟加载 -->
       />
   </resultMap>
   ```

---

### **三、延迟加载的触发条件**
- **访问关联属性**：调用 `getXXX()` 方法（如 `user.getOrders()`）。  
- **操作关联属性**：直接操作关联对象的方法或属性（如 `user.getOrders().size()`）。  
- **序列化触发**：某些序列化工具（如 Jackson）会自动调用 `getter` 方法，可能意外触发查询。

---

### **四、延迟加载的代码示例**
#### 1. **实体类定义**
```java
public class User {
    private Long id;
    private String name;
    private List<Order> orders;  // 延迟加载的关联对象
    // getter/setter
}

public class Order {
    private Long id;
    private String product;
    // getter/setter
}
```

#### 2. **Mapper XML 配置**
```xml
<resultMap id="userResultMap" type="User">
    <id property="id" column="id"/>
    <result property="name" column="name"/>
    <collection 
        property="orders" 
        column="id" 
        select="com.example.mapper.OrderMapper.findOrdersByUserId"
        fetchType="lazy"
    />
</resultMap>

<select id="findUserById" resultMap="userResultMap">
    SELECT id, name FROM users WHERE id = #{id}
</select>
```

#### 3. **业务层调用**
```java
// 查询用户（此时 orders 未被加载）
User user = userMapper.findUserById(1L);

// 触发延迟加载（执行关联查询）
List<Order> orders = user.getOrders(); 
```

---

### **五、延迟加载的注意事项**
1. **会话生命周期**  
   - 延迟加载依赖 `SqlSession` 的存在。**若会话已关闭**（如 Service 方法结束后自动提交事务），访问延迟属性会抛出 `LazyInitializationException`。  
   - **解决方案**：确保在事务范围内操作（如使用 Spring `@Transactional`）。

2. **性能陷阱**  
   - **循环触发 N+1 问题**：遍历主对象列表并访问关联属性时，可能触发多次查询。  
     **优化方案**：改用 JOIN 查询或批量加载。

3. **代理对象限制**  
   - 代理对象无法直接序列化（如 JSON 转换），需先触发加载。  
   - 避免调用代理对象的 `equals()`、`hashCode()` 等方法，可能导致意外查询。

---

### **六、与其他框架的对比**
| **特性**         | **MyBatis**                            | **Hibernate**                       |
|------------------|----------------------------------------|-------------------------------------|
| **实现方式**     | 动态代理拦截 `getter` 方法              | 字节码增强或代理对象                 |
| **配置灵活性**   | 需显式配置关联查询和延迟加载             | 默认延迟加载，注解配置更简洁          |
| **事务管理**     | 依赖外部事务（如 Spring）               | 集成 Session 生命周期管理            |
| **性能控制**     | 手动优化 SQL，灵活性高                  | 自动生成 SQL，优化难度较大            |

---

### **七、适用场景**
- **大数据量主对象**：主表数据量大，关联数据不总是需要。  
- **动态按需加载**：如用户点击“查看详情”时才加载订单。  
- **避免复杂 JOIN**：关联表结构复杂时，拆分为多次查询更高效。

---

### **总结**  
MyBatis 的延迟加载通过动态代理实现按需查询，显著减少不必要的数据库交互。其核心优势在于灵活性和对 SQL 的精细控制，但需注意会话生命周期和潜在的 N+1 问题。合理配置后，能有效提升复杂对象模型的查询性能。---

**是的，MyBatis 支持延迟加载（Lazy Loading）**。其核心目的是优化数据库查询性能，**仅在真正需要关联数据时执行查询**，避免一次性加载冗余数据。以下是 MyBatis 延迟加载的实现原理、配置方式和注意事项：

---

### **一、延迟加载的实现原理**
MyBatis 的延迟加载通过 **动态代理** 和 **拦截器机制** 实现，具体步骤如下：

#### 1. **生成代理对象**  
   - 当查询主对象（如 `User`）时，MyBatis 不会立即加载关联对象（如 `Order`）。  
   - 关联属性（如 `user.getOrders()`）会被替换为 **动态代理对象**（如 `JavassistProxy` 或 `CglibProxy`）。

#### 2. **拦截方法调用**  
   - 代理对象会拦截所有方法调用（如 `getOrders()`、`size()` 等）。  
   - 当首次访问关联属性时，触发关联数据的查询。

#### 3. **执行延迟查询**  
   - 代理对象通过 `SqlSession` 执行预先定义的关联查询 SQL（如 `findOrdersByUserId`）。  
   - 查询结果被注入到主对象的关联属性中，后续访问不再触发查询。

---

### **二、延迟加载的配置方式**
#### 1. **全局配置（mybatis-config.xml）**  
   在全局配置文件中开启延迟加载和代理模式：
   ```xml
   <settings>
       <!-- 开启延迟加载 -->
       <setting name="lazyLoadingEnabled" value="true"/>
       <!-- 按需加载（仅触发实际访问的关联属性） -->
       <setting name="aggressiveLazyLoading" value="false"/>
       <!-- 选择代理实现（默认 JAVASSIST） -->
       <setting name="proxyMethod" value="CGLIB"/>
   </settings>
   ```

#### 2. **局部配置（Mapper XML）**  
   在 `<association>` 或 `<collection>` 中指定 `fetchType="lazy"`：
   ```xml
   <resultMap id="userResultMap" type="User">
       <collection 
           property="orders" 
           column="id" 
           select="findOrdersByUserId"
           fetchType="lazy"  <!-- 显式指定延迟加载 -->
       />
   </resultMap>
   ```

---

### **三、延迟加载的触发条件**
- **访问关联属性**：调用 `getXXX()` 方法（如 `user.getOrders()`）。  
- **操作关联属性**：直接操作关联对象的方法或属性（如 `user.getOrders().size()`）。  
- **序列化触发**：某些序列化工具（如 Jackson）会自动调用 `getter` 方法，可能意外触发查询。

---

### **四、延迟加载的代码示例**
#### 1. **实体类定义**
```java
public class User {
    private Long id;
    private String name;
    private List<Order> orders;  // 延迟加载的关联对象
    // getter/setter
}

public class Order {
    private Long id;
    private String product;
    // getter/setter
}
```

#### 2. **Mapper XML 配置**
```xml
<resultMap id="userResultMap" type="User">
    <id property="id" column="id"/>
    <result property="name" column="name"/>
    <collection 
        property="orders" 
        column="id" 
        select="com.example.mapper.OrderMapper.findOrdersByUserId"
        fetchType="lazy"
    />
</resultMap>

<select id="findUserById" resultMap="userResultMap">
    SELECT id, name FROM users WHERE id = #{id}
</select>
```

#### 3. **业务层调用**
```java
// 查询用户（此时 orders 未被加载）
User user = userMapper.findUserById(1L);

// 触发延迟加载（执行关联查询）
List<Order> orders = user.getOrders(); 
```

---

### **五、延迟加载的注意事项**
1. **会话生命周期**  
   - 延迟加载依赖 `SqlSession` 的存在。**若会话已关闭**（如 Service 方法结束后自动提交事务），访问延迟属性会抛出 `LazyInitializationException`。  
   - **解决方案**：确保在事务范围内操作（如使用 Spring `@Transactional`）。

2. **性能陷阱**  
   - **循环触发 N+1 问题**：遍历主对象列表并访问关联属性时，可能触发多次查询。  
     **优化方案**：改用 JOIN 查询或批量加载。

3. **代理对象限制**  
   - 代理对象无法直接序列化（如 JSON 转换），需先触发加载。  
   - 避免调用代理对象的 `equals()`、`hashCode()` 等方法，可能导致意外查询。

---

### **六、与其他框架的对比**
| **特性**         | **MyBatis**                            | **Hibernate**                       |
|------------------|----------------------------------------|-------------------------------------|
| **实现方式**     | 动态代理拦截 `getter` 方法              | 字节码增强或代理对象                 |
| **配置灵活性**   | 需显式配置关联查询和延迟加载             | 默认延迟加载，注解配置更简洁          |
| **事务管理**     | 依赖外部事务（如 Spring）               | 集成 Session 生命周期管理            |
| **性能控制**     | 手动优化 SQL，灵活性高                  | 自动生成 SQL，优化难度较大            |

---

### **七、适用场景**
- **大数据量主对象**：主表数据量大，关联数据不总是需要。  
- **动态按需加载**：如用户点击“查看详情”时才加载订单。  
- **避免复杂 JOIN**：关联表结构复杂时，拆分为多次查询更高效。

---

### **总结**  
MyBatis 的延迟加载通过动态代理实现按需查询，显著减少不必要的数据库交互。其核心优势在于灵活性和对 SQL 的精细控制，但需注意会话生命周期和潜在的 N+1 问题。合理配置后，能有效提升复杂对象模型的查询性能。

