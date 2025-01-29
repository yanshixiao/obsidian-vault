---

UID: 20240607161303 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-06-07
---

```sql
SELECT 
    DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) AS week_start,
    DATE_ADD(CURDATE(), INTERVAL (6 - WEEKDAY(CURDATE())) DAY) AS week_end,
    DATE_SUB(CURDATE(), INTERVAL DAY(CURDATE()) - 1 DAY) AS month_start,
    LAST_DAY(CURDATE()) AS month_end;

```
### 解释

1. **`CURDATE()`**：获取当前日期。
2. **`WEEKDAY(CURDATE())`**：获取当前日期是星期几（0 表示周一，6 表示周日）。
3. **`DATE_SUB` 和 `DATE_ADD`**：用于计算相对日期。
4. **`DAY(CURDATE())`**：获取当前日期是当月的第几天。
5. **`LAST_DAY(CURDATE())`**：获取当前日期所在月的最后一天。