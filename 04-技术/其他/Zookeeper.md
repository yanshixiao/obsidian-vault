### Zookeeper

1. 数据模型
2. ACL权限控制
3. Watch监控

#### 数据模型
##### 节点
    
1. 持久节点
2. 临时节点
3. 有序节点

ZooKeeper 中的每个节点都维护有这些内容：一个二进制数组（byte data[]），用来存储节点的数据、ACL 访问控制信息、子节点数据（因为临时节点不允许有子节点，所以其子节点字段为 null），除此之外每个数据节点还有一个记录自身状态信息的字段 stat。

##### 节点状态数据
![](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/Ciqc1F6yL-yAKn9QAABsJSpQkFI688.png)

![](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/Ciqc1F6zbwWAVkt5AAC_yMQVCFo712.png)

##### 实现分布式锁

###### 悲观锁
利用临时节点实现

###### 乐观锁
CAS、使用version比较

> 在 ZooKeeper 的底层实现中，当服务端处理 setDataRequest 请求时，首先会调用 checkAndIncVersion 方法进行数据版本校验。ZooKeeper 会从 setDataRequest 请求中获取当前请求的版本 version，同时通过 getRecordForPath 方法获取服务器数据记录 nodeRecord， 从中得到当前服务器上的版本信息 currentversion。如果 version 为 -1，表示该请求操作不使用乐观锁，可以忽略版本对比；如果 version 不是 -1，那么就对比 version 和 currentversion，如果相等，则进行更新操作，否则就会抛出 BadVersionException 异常中断操作。

