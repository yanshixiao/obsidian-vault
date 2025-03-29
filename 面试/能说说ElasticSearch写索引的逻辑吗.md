---

UID: 20250329175026 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-29
---


ElasticSearch 是集群的 = 主分片 + 副本分片。

写索引只能写主分片，然后主分片同步到副本分片上。但主分片不是固定的，可能网络原因，之前

还是 Node1 是主分片，后来就变成了 Node2 经过选举成了主分片了。

客户端如何知道哪个是主分片呢？ 看下面过程。

1. 客户端向某个节点 NodeX 发送写请求

2. NodeX 通过文档信息，请求会转发到主分片的节点上

3. 主分片处理完，通知到副本分片同步数据，向 Nodex 发送成功信息。

4. Nodex 将处理结果返回给客户端。


[[ElasticSearch写索引的核心逻辑]]