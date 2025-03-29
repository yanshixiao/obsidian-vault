---

UID: 20250329184604 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-29
---
---

在 Elasticsearch 中，字段的 **索引（`index`）** 和 **存储（`store`）** 属性是控制数据如何被处理和存储的核心配置。它们的用途和适用场景如下：

---

### **一、索引（`index`）**
#### **1. 用途**
• **控制字段是否可被搜索/聚合**：
  • 若 `index: true`（默认值）：字段会被 **分析并存入倒排索引**，支持搜索、过滤和聚合。
  • 若 `index: false`：字段不会被索引，**无法用于搜索、过滤或聚合**。

#### **2. 适用场景**
• **无需搜索的字段**：如原始数据中的辅助字段（如日志中的调试信息）。
• **节省存储和计算资源**：减少不必要的索引开销。

#### **3. 配置示例**
```json
PUT /my_index
{
  "mappings": {
    "properties": {
      "title": { "type": "text", "index": true },  // 可搜索（默认）
      "debug_info": { "type": "text", "index": false } // 不可搜索
    }
  }
}
```

---

### **二、存储（`store`）**
#### **1. 用途**
• **控制字段值是否独立存储**：
  • 若 `store: true`：字段值会 **独立存储**，可直接从磁盘读取，无需解析 `_source`。
  • 若 `store: false`（默认值）：字段值仅存储在 `_source` 中，检索时需要从 `_source` 解析。

#### **2. 适用场景**
• **高频访问的字段**：需频繁单独获取某些字段（如商品价格、用户ID）。
• **节省解析开销**：避免从 `_source` 中提取大字段（如长文本）。
• **禁用 `_source` 时保留字段**：当 `_source: false` 时，需显式设置 `store: true` 才能保留字段值。

#### **3. 配置示例**
```json
PUT /my_index
{
  "mappings": {
    "properties": {
      "content": { "type": "text", "store": true }, // 独立存储
      "author": { "type": "keyword" } // 依赖 _source（默认）
    }
  }
}
```

---

### **三、`index` 和 `store` 的对比**
| **属性**   | **作用**                          | **默认值** | **存储开销** | **典型场景**                  |
|------------|-----------------------------------|------------|--------------|-------------------------------|
| `index`    | 决定字段是否可被搜索/聚合          | `true`     | 高（需建索引） | 需要搜索的字段（如标题、标签） |
| `store`    | 决定字段是否独立存储               | `false`    | 低（仅存值）  | 高频访问或禁用 `_source` 的字段 |

---

### **四、其他相关属性**
#### **1. `doc_values`**
• **用途**：控制字段是否启用列式存储，用于排序和聚合。  
• **默认值**：数值、`keyword`、`date` 等字段默认为 `true`。  
• **场景**：对需要聚合但无需搜索的字段，可关闭 `index` 但开启 `doc_values`。  
```json
"price": { "type": "integer", "index": false, "doc_values": true }
```

#### **2. `_source`**
• **用途**：控制是否存储原始文档内容。  
• **默认值**：`true`。  
• **场景**：若禁用 `_source`，需显式指定 `store: true` 的字段才能被检索。  
```json
PUT /my_index
{
  "mappings": {
    "_source": { "enabled": false }, // 不存储原始文档
    "properties": {
      "title": { "type": "text", "store": true } // 独立存储
    }
  }
}
```

---

### **五、最佳实践**
1. **优先使用默认配置**：  
   • 大多数场景无需修改 `store`，依赖 `_source` 即可。  
   • 默认开启 `index` 和 `doc_values` 以支持搜索和聚合。

2. **优化高频访问字段**：  
   • 若需频繁获取某字段（如商品价格），设为 `store: true` 以提升性能。  
   • 结合 `_source: false` 减少存储空间（需谨慎，会丢失原始数据）。

3. **节省资源的场景**：  
   • 对无需搜索的字段设置 `index: false`（如日志中的调试信息）。  
   • 对仅用于聚合的字段关闭 `index` 但保留 `doc_values: true`。

---

### **六、总结**
• **`index`**：决定字段是否可被搜索和聚合，默认开启，适用于需要查询的字段。  
• **`store`**：决定字段值是否独立存储，默认关闭，适用于高频访问或禁用 `_source` 的场景。  
• **组合优化**：结合 `doc_values` 和 `_source` 配置，在保证功能的前提下减少资源消耗。  

合理配置这些属性，可显著提升 Elasticsearch 的 **查询性能** 和 **存储效率**。




