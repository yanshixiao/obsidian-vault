---

UID: 20250410230429 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-10
---


![[竞争synchronized锁的线程在哪里等待.png]]

抛开锁升级前的偏向锁和轻量级锁，线程获取轻量级锁自旋次数过多之后，就会变为重量级锁，线程进入monitor的entrySet等候。


