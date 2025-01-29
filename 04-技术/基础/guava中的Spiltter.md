---

UID: 20230519161641 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2023-05-19
---

## ✍内容


```java
List<Long> modalityIds = Splitter.on(",")  
        .trimResults()  
        .omitEmptyStrings()  
        .splitToList(replace).stream().map(e->Long.valueOf(e)).collect(Collectors.toList());
```

