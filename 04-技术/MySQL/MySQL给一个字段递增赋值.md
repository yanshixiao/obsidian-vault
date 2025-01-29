---

UID: 20230427112518 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2023-04-27
---

## ✍内容

MySQL给一个字段递增赋值

首先设置一个变量，初始值为0：

```
set @r:=0;
```

然后更新表中对应的指定列：

```
update tablename set columnname=(@r:=@r+1)
```



