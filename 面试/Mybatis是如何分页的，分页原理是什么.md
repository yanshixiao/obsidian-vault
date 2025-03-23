---

UID: 20250323120700 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---





在 MyBatis 中，分页功能并不是框架原生支持的，但可以通过以下方式实现分页。以下是 MyBatis 分页的常见方法及其原理分析：

---

### **一、MyBatis 分页的常见实现方式**

#### 1. **手动 SQL 分页**（物理分页）
直接在 SQL 中编写分页语法（如 MySQL 的 `LIMIT`、Oracle 的 `ROWNUM`），通过参数传递分页偏移量和每页大小。  
**示例**：
```xml
<select id="getUsersByPage" resultType="User">
  SELECT * FROM users
  LIMIT #{offset}, #{pageSize}
</select>
```
**特点**：  
- 简单直接，性能高（数据库层面分页）。  
- 需手动处理分页参数，不同数据库语法不同，代码侵入性强。

---

#### 2. **`RowBounds` 分页**（逻辑分页）
通过 MyBatis 的 `RowBounds` 参数在内存中分页，本质是查询全部数据后截取指定区间的结果。  
**示例**：
```java
List<User> users = sqlSession.selectList("getAllUsers", null, new RowBounds(offset, pageSize));
```
**特点**：  
- 代码简单，但性能极差（数据量大时可能导致内存溢出）。  
- 仅适用于小数据量场景。

---

#### 3. **分页插件**（推荐）
通过第三方插件（如 **PageHelper**）实现自动化分页，无需手动编写分页 SQL。  
**示例**：
```java
// 启动分页（PageHelper 会自动拦截后续的第一个 SQL）
PageHelper.startPage(pageNum, pageSize);
List<User> users = userMapper.selectUsers();
PageInfo<User> pageInfo = new PageInfo<>(users);
```
**特点**：  
- 自动生成分页 SQL，支持多数据库方言。  
- 提供分页结果包装（总记录数、页码等）。

---

### **二、分页插件的核心原理**
以 **PageHelper** 为例，其核心是通过 MyBatis 的 **插件机制（Interceptor）** 动态修改 SQL 语句，实现分页逻辑。

---

#### **1. 插件拦截点**
分页插件通过实现 MyBatis 的 `Interceptor` 接口，拦截以下两个关键节点：
- **`Executor`**：拦截 `query` 方法，处理分页逻辑。  
- **`StatementHandler``**：拦截 SQL 解析，修改原始 SQL 为分页语句。

---

#### **2. 分页流程**
1. **触发分页**  
   调用 `PageHelper.startPage(pageNum, pageSize)`，将分页参数存入 `ThreadLocal`。

2. **拦截 SQL 执行**  
   插件拦截 MyBatis 的 `Executor.query()` 方法，检测当前线程是否存在分页参数。

3. **生成分页 SQL**  
   根据数据库类型（如 MySQL、Oracle），使用对应的 `Dialect` 类将原始 SQL 改写为分页 SQL：  
   - **MySQL**：`SELECT * FROM table LIMIT offset, pageSize`  
   - **Oracle**：嵌套 `ROWNUM` 查询。

4. **查询总记录数**  
   自动生成 `COUNT(*)` SQL 查询总记录数，用于计算总页数。

5. **封装分页结果**  
   将分页后的数据列表和分页信息（总记录数、页码等）包装到 `PageInfo` 对象中。

---

#### **3. 关键代码示例（简化版）**
```java
@Intercepts({
    @Signature(type = Executor.class, method = "query", args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class})
})
public class PageInterceptor implements Interceptor {
    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        // 1. 从 ThreadLocal 获取分页参数
        Page page = PageHelper.getPage();
        
        // 2. 生成分页 SQL 和 COUNT SQL
        String originalSql = getOriginalSql(invocation);
        String pageSql = Dialect.generatePageSql(originalSql, page);
        
        // 3. 执行分页查询和总数查询
        List<?> data = executePageQuery(pageSql);
        long total = executeCountQuery();
        
        // 4. 封装结果到 PageInfo
        return new PageInfo(data, total);
    }
}
```

---

### **三、分页插件的核心优势**
1. **自动化**  
   - 无需手动编写分页 SQL 或处理分页参数。  
2. **多数据库支持**  
   - 通过 `Dialect` 抽象层适配不同数据库的分页语法。  
3. **性能优化**  
   - 物理分页（数据库层面分页），避免内存溢出风险。  
4. **功能丰富**  
   - 支持排序、总数统计、页码计算等扩展功能。

---

### **四、分页插件的局限性**
1. **复杂 SQL 兼容性**  
   - 嵌套子查询或复杂 SQL 可能导致分页 SQL 生成错误。  
2. **性能损耗**  
   - 自动生成 `COUNT(*)` 查询可能较慢，需优化或手动指定统计方式。  
3. **依赖插件版本**  
   - 需与 MyBatis 版本兼容（如 PageHelper 需匹配 MyBatis 3.3+）。

---

### **五、最佳实践**
1. **优先使用分页插件**  
   - 如 PageHelper，减少重复代码，提升开发效率。  
2. **优化 COUNT 查询**  
   - 复杂查询时手动编写 `COUNT` SQL 避免性能问题。  
3. **分页参数校验**  
   - 限制每页最大数据量，防止恶意请求导致内存耗尽。  

---

### **总结**  
MyBatis 分页的核心是通过插件动态拦截并修改 SQL，结合数据库方言实现物理分页。分页插件（如 PageHelper）解决了手动分页的繁琐问题，但在复杂场景下需注意 SQL 兼容性和性能优化。