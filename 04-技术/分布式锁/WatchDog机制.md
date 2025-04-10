---

UID: 20250410234634 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-10
---



### 如果锁快到期了，但是业务逻辑还没有执行完怎么办
Redission的lock方法默认申请的是一个30秒的锁。

Redission的分布式锁有watchdog，每过1/3的时间就会续锁，改成30秒

释放锁watchdog子线程就没有了

[[watchdog续期什么情况下会失败]]