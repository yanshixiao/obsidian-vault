---

UID: 20250327003828 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-27
---
Redis 集群并没有使用一致性 hash，而是引入了哈希槽的概念。Redis 集群有 16384（2^14）个哈希槽，每个 key 通过 CRC16 校验后对 16384 取模来决定放置哪个槽，集群的每个节点负责一部分hash 槽。




