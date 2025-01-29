---
author: yuanshuai
created: 2022-11-03 18:19:42
aliases: 
description:
tags: [04-技术/基础]
---


# List里有map，根据map字段排序

```java
/**
     * List<Map>根据map字段排序
     * 
     * @param list
     * @param feild 排序字段
     * @param sortTyp 排序方式 desc-倒序 asc-正序
     * @return
     */
    public static List<Map<String, Object>> sortByField(List<Map<String, Object>> list, String field, String sortTyp) {
        if (CollectionUtils.isNotEmpty(list)) {
           list.sort((m1, m2) -> {
                if (StringUtils.equals(sortTyp, "desc")) {
                    return String.valueOf(m2.get(field)).compareTo(String.valueOf(m1.get(field)));
                } else {
                    return String.valueOf(m1.get(field)).compareTo(String.valueOf(m2.get(field)));
                }
            });
            // 或者 Collections类里面的sort方法也是list.sort()与上面一样
            // Collections.sort(list, (m1, m2)-> String.valueOf(m1.get(feild)).compareTo(String.valueOf(m2.get(feild)))); // lamuda排序
        }

        return list;
    }
```








