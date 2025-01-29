---
author: yuanshuai
created: 2021-11-24 09:36:45
aliases: 
description:
tags: [MySQL]
---


## select_type
查询的类型，区分是普通查询，联合查询，还是子查询等复杂查询
可能的值有：
- SIMPLE：简单的select查询，不包含子查询或UNION
- PRIMARY：查询中若包含任何复杂的子部分，最外层查询被标记为primary
- SUBQUERY：在select或where列表中包含了子查询
- DERIVED：在from列表中包含的子查询被标记为DERIVED（衍生）MySQL会递归执行这些子查询，把结果放在临时表里。
- UNION：若第二个select出现在union之后，则被标记为union；若union包含在from字句的子查询中，外层select将被标记为：DERIVED
- UNION RESULT：从UNION表获取结果的SELECT

## table
显示这一行的数据是关于哪张表的。

## type
访问类型排序，一共有8种值
![](Pasted%20image%2020211124094156.png)
```ad-note
用来显示查询使用了何种类型，效率从**最高到最差**依次是：
system>const>eq_ref>ref>range>index>ALL
```

==一般来说，得保证查询至少达到range级别，最好能达到ref。==

### system
表只有一行记录（等于系统表），这是const类型的特立，平时基本不会出现，可以忽略不计

### const

表示通过索引一次就找到了，const用于比较primary key或unique索引。因为只匹配一行数据，所以很快；如果将主键置于where列表中，MySQL就能将该查询转换为一个常量。
![](clipboard%201.png)

### eq_ref

唯一性索引扫描，对于每个索引建，表中只有一条记录与之匹配。常见于主键或唯一索引扫描。

![](clipboard%20(1).png)

t1表和t2.id关联后t1只有一条数据

### ref
非唯一索引扫描，返回匹配某个单独值的所有行，本质上也是一种索引访问，它返回所有匹配某个单独之的航，然而，它可能会找到多个符合条件的行，所以它应该属于查找和扫描的混合体。

![](clipboard%20(2).png)

### range
只检索给定范围的行，使用一个索引来选择行。key列显示了使用哪个索引，一般就是在你的where语句中出现了between、<、>、in等的查询。这种范围扫描索引比全表扫描要好，因为它只需要开始于索引的某一点，而结束于另一点，不用扫描全部索引。

![](clipboard%20(3).png)

### index
Full Index Scan，index与ALL区别为index类型只遍历索引树。这通常比ALL快，因为索引文件通常比数据文件小。（也就是说虽然all和index都是读全表，但index是从索引中读取的，而all是从硬盘中读取的）

![](clipboard%20(4).png)

### all
Full Table Scan，将遍历全表以找到匹配的行

## possible_keys

显示可能应用在这张表中的索引，一个或多个。

查询涉及到的字段上若存在索引，则该索引将被列出，但==不一定被查询实际使用==

## key

实际使用的索引。如果为NULL，则没有使用索引

**查询中若使用了[[覆盖索引]]，则该索引仅出现在key列表中**

![](clipboard%20(5).png)

select后面的字段和建好的符合索引的个数顺序都一致，就出现了**覆盖索引**。

## key_len

表示索引中使用的字节数，可通过该列计算查询中使用的索引的长度。在不损失精度的情况下，长度越短越好。

key_len显示的值为索引字段的最大可能长度，并非实际使用长度，即key_len是根据表定义计算而得，不是通过表内检索出的。

![](image.png)

![](image%20(1).png)

## ref

显示索引的哪一列被使用了，如果可能的话，是一个常数。哪些列或者常量被用于查找索引列上的值。

![](image%20(2).png)

## row

根据表统计信息及索引选用情况，大致估算出找到所需的记录所需要读取的行数。即每张表有多少行被优化器查询。

## Extra

包含不适合在其他列中显示但十分重要的额外信息

1. Using filesort: 说明mysql会对数据使用一个外部的索引排序，而不是按照表内的索引顺序进行读取。MySQL中无法利用索引完成的排序操作成为“文件排序”
2. Using Temporary:使用了临时表保存中间结果，MySQL对查询结果进行排序时使用临时表。常见于排序order by和分组group by。
3. Using Index:表示相应的select操作中使用了覆盖索引（Covering Index），避免访问了表的数据行，效率不错。如果同时出现using where，表明索引被用来执行索引键值的查找；如果没有同时出现using where， 表明索引用来读取数据而非执行查找动作。
4. Using where:表明使用了where查询
5. Using join buffer：使用了连接缓存
6. impossible where：where子句的值总是false，不能用来获取任何数据
7. select tables optimized away：在没有group by子句的情况下，基于索引优化MIN/MAX操作或者对于MyISAM存储引擎优化COUNT(\*)操作，不必等到执行阶段再进行计算，查询执行计划生成的阶段即完成优化。
8. distinct：优化distinct操作，在找到第一匹配的元组后即停止找同样值的动作。