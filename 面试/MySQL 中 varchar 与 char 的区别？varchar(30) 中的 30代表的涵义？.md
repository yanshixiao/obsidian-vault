---

UID: 20250325002559 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-25
---





- varchar 与 char 的区别，char 是一种固定长度的类型，varchar 则是一种可变长度的类型。

- varchar(30) 中 30 的涵义最多存放 30 个字符。varchar(30) 和 (130) 存储 hello 所占空间一样，但后者在排序时会消耗更多内存，因为 ORDER BY col 采用 fixed_length 计算 col 长度（memory 引擎也一样）。

- 对效率要求高用 char，对空间使用要求高用 varchar