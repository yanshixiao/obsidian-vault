---

UID: 20250325003117 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-25
---

---

### MySQL 索引类型详解

MySQL 支持多种索引类型，每种索引适用于不同的场景和查询需求。以下是常见的索引类型及其核心特性、使用场景和示例：

---

#### **1. B-Tree 索引（默认索引类型）**
- **存储引擎支持**：InnoDB、MyISAM、Memory 等。
- **数据结构**：B+ 树（平衡多路搜索树）。
- **适用场景**：
  - 等值查询（`=`）。
  - 范围查询（`>`, `<`, `BETWEEN`）。
  - 排序（`ORDER BY`）和分组（`GROUP BY`）。
- **优点**：
  - 支持最左前缀匹配。
  - 适合高基数（唯一值多）的列。
- **缺点**：
  - 对模糊查询（如 `LIKE '%abc'`）支持有限。
- **示例**：
  ```sql
  -- 创建普通B-Tree索引
  CREATE INDEX idx_age ON users(age);

  -- 创建复合索引
  CREATE INDEX idx_age_name ON users(age, name);
  ```

---

#### **2. 哈希索引（Hash Index）**
- **存储引擎支持**：Memory、InnoDB（自适应哈希索引，内部自动管理）。
- **数据结构**：哈希表。
- **适用场景**：
  - 精确等值查询（`=`、`IN`）。
  - 内存表（Memory 引擎）的快速查询。
- **优点**：
  - 查询速度极快（接近 O(1)）。
- **缺点**：
  - 不支持范围查询和排序。
  - 哈希冲突可能影响性能。
- **示例**：
  ```sql
  -- 仅Memory引擎支持显式创建哈希索引
  CREATE TABLE memory_table (
      id INT PRIMARY KEY,
      data VARCHAR(20)
  ) ENGINE=MEMORY;
  CREATE INDEX idx_hash_data USING HASH ON memory_table(data);
  ```

---

#### **3. 全文索引（Full-Text Index）**
- **存储引擎支持**：InnoDB（5.6+）、MyISAM。
- **数据结构**：倒排索引（Inverted Index）。
- **适用场景**：
  - 文本内容的模糊搜索（如 `MATCH ... AGAINST`）。
  - 支持自然语言搜索和布尔搜索。
- **优点**：
  - 高效处理大文本字段的搜索。
- **缺点**：
  - 仅适用于 `CHAR`、`VARCHAR`、`TEXT` 类型。
  - 需要手动维护停用词和分词规则。
- **示例**：
  ```sql
  -- 创建全文索引
  CREATE FULLTEXT INDEX idx_content ON articles(content);

  -- 使用全文搜索
  SELECT * FROM articles 
  WHERE MATCH(content) AGAINST('database optimization' IN NATURAL LANGUAGE MODE);
  ```

---

#### **4. 空间索引（Spatial Index）**
- **存储引擎支持**：MyISAM、InnoDB（5.7+）。
- **数据结构**：R-Tree。
- **适用场景**：
  - 地理空间数据查询（如 `GIS` 坐标范围查询）。
  - 支持几何数据类型（`POINT`、`LINESTRING`、`POLYGON`）。
- **优点**：
  - 高效处理空间范围查询（如 `ST_Contains`、`ST_Distance`）。
- **缺点**：
  - 仅适用于空间数据类型。
- **示例**：
  ```sql
  -- 创建空间索引
  CREATE TABLE locations (
      id INT PRIMARY KEY,
      position POINT NOT NULL,
      SPATIAL INDEX idx_position (position)
  ) ENGINE=InnoDB;

  -- 查询某区域内的点
  SELECT * FROM locations 
  WHERE ST_Contains(ST_GeomFromText('POLYGON(...)'), position);
  ```

---

#### **5. 前缀索引（Prefix Index）**
- **适用场景**：
  - 文本列较长时，仅对前 N 个字符创建索引以节省空间。
- **优点**：
  - 减少索引存储空间。
- **缺点**：
  - 可能降低查询准确性（需平衡前缀长度和区分度）。
- **示例**：
  ```sql
  -- 对email列的前10个字符创建索引
  CREATE INDEX idx_email_prefix ON users(email(10));
  ```

---

#### **6. 唯一索引（Unique Index）**
- **特点**：
  - 索引列的值必须唯一（允许 NULL 值，但只能有一个 NULL）。
- **适用场景**：
  - 强制数据唯一性约束（如用户手机号、邮箱）。
- **示例**：
  ```sql
  CREATE UNIQUE INDEX idx_unique_phone ON users(phone);
  ```

---

#### **7. 覆盖索引（Covering Index）**
- **特点**：
  - 索引包含查询所需的所有字段，无需回表查询数据行。
- **适用场景**：
  - 高频查询仅需索引列数据。
- **示例**：
  ```sql
  -- 创建覆盖索引（包含age和name）
  CREATE INDEX idx_cover_age_name ON users(age, name);

  -- 查询仅需索引列时，直接使用覆盖索引
  SELECT age, name FROM users WHERE age > 20;
  ```

---

#### **8. 复合索引（Composite Index）**
- **特点**：
  - 基于多个列的联合索引。
  - 遵循最左前缀原则（查询条件需包含最左侧列）。
- **适用场景**：
  - 多条件组合查询。
- **示例**：
  ```sql
  -- 复合索引（city + age）
  CREATE INDEX idx_city_age ON employees(city, age);

  -- 有效使用索引的查询
  SELECT * FROM employees WHERE city = 'Shanghai' AND age > 30;
  -- 仅使用city列的索引
  SELECT * FROM employees WHERE city = 'Shanghai';
  -- 无法使用索引（未包含city列）
  SELECT * FROM employees WHERE age > 30;
  ```

---

### **索引选择建议**
1. **高频查询字段优先**：对 `WHERE`、`JOIN`、`ORDER BY` 涉及的列建索引。  
2. **避免过度索引**：索引会增加写操作开销，删除未使用的冗余索引。  
3. **区分度高的列**：选择唯一值多的列（如用户ID）作为索引。  
4. **小数据类型**：使用更小的数据类型（如 `INT` 代替 `BIGINT`）减少索引大小。  

---

### **总结**
- **B-Tree 索引**是 MySQL 的默认选择，适用于大多数场景。  
- **哈希索引**适合内存表的精确查询，**全文索引**用于文本搜索。  
- **唯一索引**和**复合索引**需结合业务需求设计，遵循最左前缀原则。  
- 合理选择索引类型和设计索引策略，是优化 MySQL 查询性能的关键！



