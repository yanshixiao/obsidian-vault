> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [www.w3school.com.cn](https://www.w3school.com.cn/sql/sql_union.asp)

SQL UNION 操作符
-------------

UNION 操作符用于合并两个或多个 SELECT 语句的结果集。

请注意，UNION 内部的 SELECT 语句必须拥有相同数量的列。列也必须拥有相似的数据类型。同时，每条 SELECT 语句中的列的顺序必须相同。

### SQL UNION 语法

```
SELECT column_name(s) FROM table_name1
UNION
SELECT column_name(s) FROM table_name2


```

注释：默认地，UNION 操作符选取不同的值。如果允许重复的值，请使用 UNION ALL。

### SQL UNION ALL 语法

```
SELECT column_name(s) FROM table_name1
UNION ALL
SELECT column_name(s) FROM table_name2


```

另外，UNION 结果集中的列名总是等于 UNION 中第一个 SELECT 语句中的列名。

下面的例子中使用的原始表：
-------------

### Employees_China:

<table><tbody><tr><th>E_ID</th><th>E_Name</th></tr><tr><td>01</td><td>Zhang, Hua</td></tr><tr><td>02</td><td>Wang, Wei</td></tr><tr><td>03</td><td>Carter, Thomas</td></tr><tr><td>04</td><td>Yang, Ming</td></tr></tbody></table>

### Employees_USA:

<table><tbody><tr><th>E_ID</th><th>E_Name</th></tr><tr><td>01</td><td>Adams, John</td></tr><tr><td>02</td><td>Bush, George</td></tr><tr><td>03</td><td>Carter, Thomas</td></tr><tr><td>04</td><td>Gates, Bill</td></tr></tbody></table>

使用 UNION 命令
-----------

### 实例

列出所有在中国和美国的不同的雇员名：

```
UNION

```

### 结果

<table><tbody><tr><th>E_Name</th></tr><tr><td>Zhang, Hua</td></tr><tr><td>Wang, Wei</td></tr><tr><td>Carter, Thomas</td></tr><tr><td>Yang, Ming</td></tr><tr><td>Adams, John</td></tr><tr><td>Bush, George</td></tr><tr><td>Gates, Bill</td></tr></tbody></table>

注释：这个命令无法列出在中国和美国的所有雇员。在上面的例子中，我们有两个名字相同的雇员，他们当中只有一个人被列出来了。UNION 命令只会选取不同的值。

UNION ALL
---------

UNION ALL 命令和 UNION 命令几乎是等效的，不过 UNION ALL 命令会列出所有的值。

```
SQL Statement 1
UNION ALL
SQL Statement 2


```

使用 UNION ALL 命令
---------------

### 实例：

列出在中国和美国的所有的雇员：

```
UNION ALL

```

### 结果

<table><tbody><tr><th>E_Name</th></tr><tr><td>Zhang, Hua</td></tr><tr><td>Wang, Wei</td></tr><tr><td>Carter, Thomas</td></tr><tr><td>Yang, Ming</td></tr><tr><td>Adams, John</td></tr><tr><td>Bush, George</td></tr><tr><td>Carter, Thomas</td></tr><tr><td>Gates, Bill</td></tr></tbody></table>