---

UID: 20241114112052 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-11-14
---
![[Screenshot_20241113_190747.jpg]]


AT模式有脏写问题
![[Screenshot_20241113_190757.jpg]]

通过全局锁来规避
![[Screenshot_20241113_191650.jpg]]

非seata事务并发来临后，会造成死锁，重试多次后释放就可以解决
但是脏写问题还没解决，这里AT模式会记录修改前修改后两个快照，发现当前值和修改后的不一样，说明事务期间有别的事务修改成功了，就得人工介入了

![[Screenshot_20241113_191935.jpg]]





