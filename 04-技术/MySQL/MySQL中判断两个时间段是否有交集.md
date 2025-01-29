---

UID: 20231128104921 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2023-11-28
---

## ✍内容

在 MySQL 中，判断两个时间段是否有交集可以使用一些条件表达式来实现。假设有两个时间段，分别由开始时间 (`start_time`) 和结束时间 (`end_time`) 表示，你可以使用以下条件来检查它们是否有交集：

```sql
SELECT * 
FROM your_table 
WHERE 
	(start_time1 <= end_time2 AND end_time1 >= start_time2)    
	OR     
	(start_time2 <= end_time1 AND end_time2 >= start_time1)
```



在这个查询中，`start_time1` 和 `end_time1` 表示第一个时间段的开始和结束时间，`start_time2` 和 `end_time2` 表示第二个时间段的开始和结束时间。

条件 `(start_time1 <= end_time2 AND end_time1 >= start_time2)` 表示第一个时间段的开始时间在第二个时间段的结束时间之前，并且第一个时间段的结束时间在第二个时间段的开始时间之后，这就表示两个时间段有交集。条件 `(start_time2 <= end_time1 AND end_time2 >= start_time1)` 则是相反的情况，同样表示两个时间段有交集。

你需要根据实际情况替换列名和表名。这个查询会返回两个时间段有交集的记录。如果没有交集，查询结果将为空。



