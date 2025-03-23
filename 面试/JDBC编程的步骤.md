---

UID: 20250323143618 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---




JDBC（Java Database Connectivity）是 Java 用于操作关系型数据库的标准 API。其编程步骤通常分为以下 **6 个核心阶段**，以 MySQL 为例：

---

### **1. 加载数据库驱动**
**目的**：注册数据库驱动，使 JDBC 能识别并连接特定数据库。  
**代码示例**：
```java
// JDBC 4.0+ 后无需显式加载驱动（通过 SPI 自动发现），但部分场景仍需显式声明
Class.forName("com.mysql.cj.jdbc.Driver"); 
```

**说明**：
- **驱动类名**：不同数据库驱动类不同（如 MySQL 是 `com.mysql.cj.jdbc.Driver`，Oracle 是 `oracle.jdbc.driver.OracleDriver`）。
- **自动加载**：JDBC 4.0 后支持 SPI（Service Provider Interface），只需将驱动 JAR 放入类路径，无需手动加载。

---

### **2. 建立数据库连接**
**目的**：获取与数据库的物理连接（TCP/IP 连接）。  
**代码示例**：
```java
// 数据库 URL 格式：jdbc:mysql://主机:端口/数据库名?参数
String url = "jdbc:mysql://localhost:3306/mydb?useSSL=false&serverTimezone=UTC";
String user = "root";
String password = "123456";

// 通过 DriverManager 获取连接
Connection conn = DriverManager.getConnection(url, user, password);
```

**关键参数**：
- **useSSL=false**：禁用 SSL（测试环境使用，生产建议启用）。  
- **serverTimezone=UTC**：统一时区，避免时间转换错误。  
- **其他参数**：`characterEncoding=utf8`、`autoReconnect=true` 等。

---

### **3. 创建 Statement 或 PreparedStatement**
**目的**：定义 SQL 语句并发送到数据库执行。

#### **方式 1：Statement（普通语句）**
```java
Statement stmt = conn.createStatement();
String sql = "SELECT * FROM users WHERE id = 1";
ResultSet rs = stmt.executeQuery(sql);
```
**缺点**：存在 SQL 注入风险，且需手动拼接参数。

#### **方式 2：PreparedStatement（预编译语句，推荐）**
```java
String sql = "SELECT * FROM users WHERE id = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setInt(1, 1);  // 参数索引从 1 开始
ResultSet rs = pstmt.executeQuery();
```
**优点**：
- **防 SQL 注入**：参数通过占位符（`?`）绑定，避免恶意拼接。  
- **性能优化**：预编译 SQL，重复执行效率高。

---

### **4. 执行 SQL 并处理结果集**
**目的**：执行 SQL 并处理返回的数据（如查询结果）。

#### **执行 SQL 的方法**：
- **查询（SELECT）**：  
  ```java
  ResultSet rs = pstmt.executeQuery();
  ```
- **更新（INSERT/UPDATE/DELETE）**：  
  ```java
  int affectedRows = pstmt.executeUpdate();
  ```

#### **处理 ResultSet**：
```java
while (rs.next()) {  // 遍历结果集
    int id = rs.getInt("id");        // 按列名获取
    String name = rs.getString(2);   // 按列索引（从 1 开始）
    Date createTime = rs.getDate("create_time");
    // 将数据封装到对象或处理
}
```

---

### **5. 关闭资源（关键！）**
**目的**：释放数据库连接、语句和结果集资源，避免内存泄漏和连接耗尽。

#### **传统方式（finally 块）**：
```java
try {
    // JDBC 操作...
} catch (SQLException e) {
    e.printStackTrace();
} finally {
    // 关闭顺序：ResultSet → Statement → Connection
    try {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
```

#### **现代方式（try-with-resources，推荐）**：
```java
// Java 7+ 支持，资源自动关闭（需实现 AutoCloseable 接口）
try (Connection conn = DriverManager.getConnection(url, user, password);
     PreparedStatement pstmt = conn.prepareStatement(sql);
     ResultSet rs = pstmt.executeQuery()) {
    
    // 处理结果集...
} catch (SQLException e) {
    e.printStackTrace();
}
```

---

### **6. 异常处理**
**目的**：捕获并处理数据库操作中的异常（如连接失败、SQL 语法错误）。

#### **基础异常处理**：
```java
try {
    // JDBC 操作...
} catch (SQLException e) {
    // 记录日志或抛出业务异常
    System.err.println("SQL错误代码：" + e.getErrorCode());
    System.err.println("错误信息：" + e.getMessage());
}
```

---

### **完整代码示例（查询用户）**
```java
public class JdbcDemo {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/mydb?useSSL=false&serverTimezone=UTC";
        String user = "root";
        String password = "123456";
        String sql = "SELECT id, name, email FROM users WHERE id = ?";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, 1);  // 设置参数
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    System.out.println(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

---

### **JDBC 编程最佳实践**
1. **使用连接池**（如 HikariCP、Druid）：  
   - 避免频繁创建/销毁连接，提升性能。  
   - 示例配置（HikariCP）：
     ```java
     HikariConfig config = new HikariConfig();
     config.setJdbcUrl(url);
     config.setUsername(user);
     config.setPassword(password);
     HikariDataSource dataSource = new HikariDataSource(config);
     Connection conn = dataSource.getConnection();
     ```

2. **始终使用 PreparedStatement**：  
   - 防止 SQL 注入，提升安全性和性能。

3. **合理管理事务**：  
   - 手动控制事务提交和回滚：
     ```java
     conn.setAutoCommit(false);  // 关闭自动提交
     try {
         // 执行多个操作...
         conn.commit();          // 提交事务
     } catch (SQLException e) {
         conn.rollback();        // 回滚事务
     }
     ```

4. **处理大数据量**：  
   - 使用 `setFetchSize()` 优化结果集读取性能。  
   - 分页查询避免内存溢出。

---

### **常见问题与解决**
- **驱动类未找到**：确保驱动 JAR 已添加到类路径。  
- **连接超时**：检查数据库服务是否启动，网络是否通畅，连接参数是否正确。  
- **时区错误**：在 URL 中添加 `serverTimezone=UTC`。  
- **SSL 警告**：测试环境可添加 `useSSL=false`，生产环境应配置有效证书。

---

通过以上步骤和最佳实践，可以编写高效、安全的 JDBC 代码，满足大多数数据库操作需求。
