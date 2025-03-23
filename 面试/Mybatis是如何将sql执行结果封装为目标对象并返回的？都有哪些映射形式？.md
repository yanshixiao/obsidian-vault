---

UID: 20250323121015 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---




MyBatis 通过灵活的结果映射机制将 SQL 查询结果转换为 Java 对象，其核心原理是 **通过反射或动态代理将数据库字段与对象属性匹配**。以下是具体实现方式和映射形式：

---

### **一、结果映射的核心流程**
1. **执行 SQL**  
   通过 JDBC 执行 SQL，获取 `ResultSet` 结果集。
2. **创建目标对象**  
   根据映射配置（如 `resultType` 或 `resultMap`），反射实例化目标对象。
3. **填充属性值**  
   遍历 `ResultSet` 的每一行数据，根据字段名或映射规则将值注入对象属性。

---

### **二、MyBatis 支持的映射形式**

#### 1. **自动映射（Auto-Mapping）**
- **规则**：  
  数据库字段名与对象属性名 **自动匹配**（默认开启，支持驼峰转换）。
- **配置**：  
  ```xml
  <settings>
      <!-- 开启自动驼峰转换（user_name → userName） -->
      <setting name="mapUnderscoreToCamelCase" value="true"/>
  </settings>
  ```
- **示例**：  
  ```xml
  <select id="getUser" resultType="com.example.User">
      SELECT id, user_name, email FROM users
  </select>
  ```
  ```java
  public class User {
      private Long id;
      private String userName;  // 自动映射到 user_name
      private String email;
  }
  ```
- **特点**：  
  - 无需额外配置，适合字段与属性名一致的场景。  
  - 无法处理复杂映射（如嵌套对象、字段名不一致）。

---

#### 2. **`<resultMap>` 显式映射**
- **规则**：  
  在 XML 中通过 `<resultMap>` 手动定义字段与属性的映射关系。
- **示例**：  
  ```xml
  <resultMap id="userResultMap" type="User">
      <id property="id" column="user_id"/>  <!-- 主键映射 -->
      <result property="name" column="user_name"/>
      <result property="email" column="email"/>
      <!-- 嵌套对象映射（一对一） -->
      <association property="dept" javaType="Department">
          <id property="deptId" column="dept_id"/>
          <result property="deptName" column="dept_name"/>
      </association>
      <!-- 集合映射（一对多） -->
      <collection property="roles" ofType="Role">
          <id property="roleId" column="role_id"/>
          <result property="roleName" column="role_name"/>
      </collection>
  </resultMap>

  <select id="getUser" resultMap="userResultMap">
      SELECT 
          u.user_id, u.user_name, u.email,
          d.dept_id, d.dept_name,
          r.role_id, r.role_name
      FROM users u
      LEFT JOIN department d ON u.dept_id = d.dept_id
      LEFT JOIN user_role ur ON u.user_id = ur.user_id
      LEFT JOIN roles r ON ur.role_id = r.role_id
  </select>
  ```
- **特点**：  
  - 灵活性强，支持复杂对象、关联查询、集合映射。  
  - 需手动配置，适合字段与属性名不一致或存在嵌套的场景。

---

#### 3. **注解映射**
- **规则**：  
  使用 MyBatis 注解（如 `@Results`、`@Result`）直接在接口方法上定义映射关系。
- **示例**：  
  ```java
  @Select("SELECT user_id, user_name, email FROM users WHERE id = #{id}")
  @Results({
      @Result(property = "id", column = "user_id"),
      @Result(property = "name", column = "user_name"),
      @Result(property = "email", column = "email"),
      @Result(property = "dept", column = "dept_id",
              one = @One(select = "com.example.mapper.DeptMapper.getDeptById"))
  })
  User getUserById(Integer id);
  ```
- **特点**：  
  - 代码与 SQL 集中，适合简单映射。  
  - 复杂映射时代码冗长，可读性差。

---

#### 4. **构造函数映射**
- **规则**：  
  通过目标对象的构造函数直接注入字段值，需配合 `@ConstructorArgs` 注解或 `<constructor>` 标签。
- **示例**：  
  ```java
  public class User {
      private Long id;
      private String name;

      @ConstructorArgs({
          @Arg(column = "user_id", javaType = Long.class),
          @Arg(column = "user_name", javaType = String.class)
      })
      public User(Long id, String name) {
          this.id = id;
          this.name = name;
      }
  }
  ```
  ```xml
  <resultMap id="userResultMap" type="User">
      <constructor>
          <idArg column="user_id" javaType="Long"/>
          <arg column="user_name" javaType="String"/>
      </constructor>
  </resultMap>
  ```
- **特点**：  
  - 适用于依赖构造方法初始化的对象（如不可变对象）。  
  - 需严格匹配参数顺序和类型。

---

#### 5. **动态结果映射（Discriminator）**
- **规则**：  
  根据查询结果中的某个字段值，动态选择不同的映射规则。
- **示例**：  
  ```xml
  <resultMap id="vehicleResultMap" type="Vehicle">
      <id property="id" column="id"/>
      <discriminator javaType="String" column="type">
          <case value="CAR" resultMap="carResultMap"/>
          <case value="BIKE" resultMap="bikeResultMap"/>
      </discriminator>
  </resultMap>
  <resultMap id="carResultMap" type="Car" extends="vehicleResultMap">
      <result property="doorCount" column="door_count"/>
  </resultMap>
  <resultMap id="bikeResultMap" type="Bike" extends="vehicleResultMap">
      <result property="frameSize" column="frame_size"/>
  </resultMap>
  ```
- **特点**：  
  - 支持多态映射，适合继承结构的对象。  
  - 配置复杂，使用场景较少。

---

### **三、底层实现原理**
1. **`ResultSetHandler` 处理结果集**  
   MyBatis 通过 `DefaultResultSetHandler` 遍历 `ResultSet`，逐行映射数据。
2. **反射与类型处理器**  
   - 反射调用目标对象的 Setter 方法或构造函数注入值。  
   - 使用 `TypeHandler` 处理 Java 类型与 JDBC 类型的转换（如 `String ↔ VARCHAR`）。
3. **延迟加载（Lazy Loading）**  
   对关联对象（如 `<association>`、`<collection>`），通过动态代理实现按需加载。

---

### **四、最佳实践**
- **简单场景**：优先使用 **自动映射** 或 **注解映射**。  
- **复杂场景**：使用 **`<resultMap>`** 显式配置，尤其是存在嵌套对象或集合时。  
- **不可变对象**：通过 **构造函数映射** 确保对象初始化完整性。  
- **性能优化**：避免过度使用关联查询（N+1 问题），结合延迟加载或批量查询优化。

---

### **总结**  
MyBatis 通过自动映射、显式 `<resultMap>`、注解、构造函数等多种方式将 SQL 结果转换为对象。开发者应根据场景选择合适策略：简单映射用自动规则，复杂关系用显式配置，不可变对象用构造方法，多态数据用鉴别器。理解这些机制能显著提升 ORM 效率和代码可维护性。
