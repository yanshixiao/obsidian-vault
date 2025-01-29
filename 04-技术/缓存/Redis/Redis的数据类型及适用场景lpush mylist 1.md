### Redis的几种数据类型
- Strings
- Hashed
- Lists
- Sets
- Sorted Sets

> 除了这5种类型之外，还有Bitmaps、HyperLogLogs、Streams等。

#### Strings
```
set key value
```

#### Hashes
类似map的一种结构，这个一般就是可以将结构化的数据，比如一个对象（前提是**这个对象没嵌套其他的对象**）给缓存在 Redis 里，然后每次读写缓存的时候，可以就操作 hash 里的某个字段。
```
set person name zhangsan
set person age 21
```

#### Lists
Lists是有序列表。可以存储粉丝列表、文章评论列表之类的东西。

可以通过lrange命令，读取某个闭区间内的元素，可以基于list实现分页查询，类似于微博下拉不断分页。

```
# 0开始位置，-1结束位置，结束位置为-1时，表示列表的最后一个位置，即查看所有。
lrange mylist 0 -1
```

可以搞一个简单的消息队列，从list头怼进去，从list尾巴弄出来

```
lpush mylist 1
lpush mylist 2
lpush mylist 3 4 5

# 1
rpop mylist
```

#### Sets
无序集合，自动去重

系统部署在多台机器上时，可以基于Redis进行全局的set去重。

交集、并集、差集。交集可以做两人共同好友功能。

```
#-------操作一个set-------
# 添加元素
sadd mySet 1

# 查看全部元素
smembers mySet

# 判断是否包含某个值
sismember mySet 3

# 删除某个/些元素
srem mySet 1
srem mySet 2 4

# 查看元素个数
scard mySet

# 随机删除一个元素
spop mySet

#-------操作多个set-------
# 将一个set的元素移动到另外一个set
smove yourSet mySet 2

# 求两set的交集
sinter yourSet mySet

# 求两set的并集
sunion yourSet mySet

# 求在yourSet中而不在mySet中的元素
sdiff yourSet mySet
```

#### Sorted Sets
Sorted Sets 是排序的 set，去重但可以排序，写进去的时候给一个分数，自动根据分数排序。

```
zadd board 85 zhangsan
zadd board 72 lisi
zadd board 96 wangwu
zadd board 63 zhaoliu

# 获取排名前三的用户（默认是升序，所以需要 rev 改为降序）
zrevrange board 0 3

# 获取某用户的排名
zrank board zhaoliu

```