---

UID: 20250323142514 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---





MyBatis 提供了一套缓存机制，用于提升数据库查询性能，减少重复查询的开销。其缓存分为**一级缓存**和**二级缓存**，两者的作用范围、生命周期和配置方式不同。以下是详细解析：

---

### **一、一级缓存（Local Cache）**
#### **1. 作用范围**
- **SqlSession 级别**：一级缓存默认开启，仅在同一个 `SqlSession` 生命周期内有效。
- **自动失效**：当执行 **更新操作（INSERT/UPDATE/DELETE）** 或调用 `sqlSession.clearCache()` 时，缓存会被清空。

#### **2. 工作原理**
- **缓存存储结构**：基于 `PerpetualCache`（一个简单的 HashMap 实现）。
- **执行流程**：
  1. 执行查询时，MyBatis 根据 `statementId`（Mapper 方法全限定名）、参数、分页条件等生成缓存键（CacheKey）。
  2. 若缓存中存在该键对应的结果，直接返回缓存数据。
  3. 若不存在，查询数据库并将结果存入缓存。

#### **3. 代码示例**
```java
try (SqlSession sqlSession = sqlSessionFactory.openSession()) {
    UserMapper mapper = sqlSession.getMapper(UserMapper.class);
    
    // 第一次查询（查数据库）
    User user1 = mapper.findUserById(1L);
    
    // 第二次查询（命中缓存）
    User user2 = mapper.findUserById(1L); 
    
    // 执行更新操作（清空缓存）
    mapper.updateUser(user1);
    
    // 第三次查询（重新查数据库）
    User user3 = mapper.findUserById(1L);
}
```

#### **4. 注意事项**
- **事务隔离性**：一级缓存可能导致“脏读”，若其他 `SqlSession` 修改了数据，当前会话的缓存不会自动更新。
- **作用域限制**：不同 `SqlSession` 的缓存相互隔离。

---

### **二、二级缓存（Global Cache）**
#### **1. 作用范围**
- **Mapper 级别**：二级缓存需要显式开启，同一 `Mapper` 的多个 `SqlSession` 共享缓存。
- **生命周期**：缓存数据在 `SqlSession` 关闭或提交时才会被存入二级缓存，且后续会话可共享。

#### **2. 工作原理**
- **存储结构**：默认基于 `PerpetualCache`，但可通过配置集成第三方缓存（如 EhCache、Redis）。
- **执行流程**：
  1. 查询时，优先从二级缓存获取数据。
  2. 若未命中，继续查询一级缓存。
  3. 若仍未命中，查询数据库，并将结果存入一级和二级缓存（事务提交后）。

#### **3. 配置方式**
##### **步骤 1：全局开启二级缓存（可选）**
在 `mybatis-config.xml` 中配置：
```xml
<settings>
    <!-- 默认值为 true，通常无需显式配置，但需映射文件显式启用-->
    <setting name="cacheEnabled" value="true"/>
</settings>
```

##### **步骤 2：在 Mapper 中启用缓存**
在 `Mapper.xml` 中添加 `<cache/>` 标签：
```xml
<!-- UserMapper.xml -->
<mapper namespace="com.example.mapper.UserMapper">
    <!-- 启用二级缓存 -->
    <cache 
        eviction="LRU"              <!-- 缓存淘汰策略（默认 LRU） -->
        flushInterval="60000"       <!-- 自动刷新间隔（毫秒） -->
        size="1024"                 <!-- 最大缓存对象数 -->
        readOnly="true"             <!-- 是否只读（默认 false） -->
    />
    
    <select id="findUserById" resultType="User" useCache="true">
        SELECT * FROM users WHERE id = #{id}
    </select>
</mapper>
```

##### **步骤 3：实体类实现序列化**
若使用默认缓存（或部分第三方缓存），实体类需实现 `Serializable` 接口：
```java
public class User implements Serializable {
    // ...
}
```

#### **4. 缓存淘汰策略（eviction）**
| **策略**      | **说明**                                                                 |
|---------------|-------------------------------------------------------------------------|
| `LRU`         | 最近最少使用（默认策略），移除最长时间未被访问的对象。                        |
| `FIFO`        | 先进先出，按对象进入缓存的顺序移除。                                      |
| `SOFT`        | 软引用，基于垃圾回收器状态和软引用规则移除对象。                            |
| `WEAK`        | 弱引用，更积极地移除对象。                                                |

#### **5. 注意事项**
- **事务提交后缓存生效**：只有 `SqlSession` 关闭或提交时，数据才会从一级缓存刷入二级缓存。
- **更新操作清空缓存**：执行 INSERT/UPDATE/DELETE 时，相关 Mapper 的二级缓存会被清空。
- **多表关联风险**：若多个 Mapper 共享缓存，需通过 `<cache-ref>` 指定缓存引用，避免数据不一致。

---

### **三、一级缓存 vs 二级缓存**
| **特性**         | **一级缓存**                          | **二级缓存**                          |
|------------------|-------------------------------------|-------------------------------------|
| **作用范围**     | `SqlSession` 内部                   | 跨 `SqlSession`，同一 Mapper 共享     |
| **默认状态**     | 开启                                | 需显式配置                           |
| **存储位置**     | 内存（JVM 堆）                      | 内存或第三方缓存（如 Redis、EhCache） |
| **数据共享**     | 隔离，不同会话不共享                  | 共享，多个会话可访问同一缓存           |
| **适用场景**     | 高频重复查询的短会话操作              | 跨会话的只读或低频更新数据             |

---

### **四、第三方缓存集成（如 EhCache）**
#### **1. 添加依赖**
```xml
<dependency>
    <groupId>org.mybatis.caches</groupId>
    <artifactId>mybatis-ehcache</artifactId>
    <version>1.2.2</version>
</dependency>
```

#### **2. 配置 Mapper 缓存**
```xml
<mapper namespace="com.example.mapper.UserMapper">
    <cache type="org.mybatis.caches.ehcache.EhcacheCache"/>
</mapper>
```

#### **3. 添加 EhCache 配置文件**
在 `src/main/resources/ehcache.xml` 中配置：
```xml
<ehcache>
    <diskStore path="java.io.tmpdir"/>
    <defaultCache
        maxEntriesLocalHeap="1000"
        eternal="false"
        timeToIdleSeconds="300"
        timeToLiveSeconds="600"
        diskSpoolBufferSizeMB="30"
        statistics="true"/>
</ehcache>
```

---

### **五、最佳实践**
1. **合理选择缓存级别**：  
   - 高频查询且数据更新少的场景用二级缓存。  
   - 事务性强的操作避免使用缓存，或设置较短的刷新间隔。

2. **避免缓存滥用**：  
   - 频繁更新的数据不适合缓存。  
   - 大数据量对象需评估内存消耗。

3. **监控与调优**：  
   - 使用第三方缓存时（如 Redis），监控命中率和内存占用。  
   - 调整淘汰策略（如 `LRU`）和缓存大小（`size`）。

4. **处理多表关联**：  
   - 使用 `<cache-ref>` 关联多个 Mapper 的缓存，确保数据一致性：
     ```xml
     <mapper namespace="com.example.mapper.OrderMapper">
         <cache-ref namespace="com.example.mapper.UserMapper"/>
     </mapper>
     ```

---

### **六、常见问题**
#### **Q1：缓存导致脏数据？**
- **原因**：其他系统或服务直接修改数据库，绕过 MyBatis 缓存机制。  
- **解决**：  
  - 设置较短的 `flushInterval`。  
  - 手动调用 `sqlSession.clearCache()`。  
  - 禁用缓存（`useCache="false"`）。

#### **Q2：二级缓存不生效？**
- **检查点**：  
  - 实体类是否实现 `Serializable`。  
  - Mapper 是否配置 `<cache/>`。  
  - 是否在 `SqlSession` 提交或关闭后查询。

---

### **总结**
MyBatis 的缓存机制通过一级缓存（会话级）和二级缓存（全局级）优化查询性能。一级缓存自动管理，适用于短事务内的重复查询；二级缓存需显式配置，适合跨会话的共享数据。合理使用缓存能显著提升性能，但需注意数据一致性和内存管理，结合业务场景选择策略。