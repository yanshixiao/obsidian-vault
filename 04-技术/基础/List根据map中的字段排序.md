---

UID: 20230912153137 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2023-09-12
---

## ✍内容
在 Java 中，可以使用 `Comparator` 和 `Collections` 的 `sort` 方法对 List<Map> 根据 map 中某一字段进行倒序排列。

以下是一个示例代码：

```java
import java.util.*;

public class Main {
    public static void main(String[] args) {
        List<Map<String, Integer>> list = new ArrayList<>();

        // 初始化 List<Map>
        Map<String, Integer> map1 = new HashMap<>();
        map1.put("id", 1);
        map1.put("value", 100);
        list.add(map1);

        Map<String, Integer> map2 = new HashMap<>();
        map2.put("id", 2);
        map2.put("value", 50);
        list.add(map2);

        Map<String, Integer> map3 = new HashMap<>();
        map3.put("id", 3);
        map3.put("value", 200);
        list.add(map3);

        // 倒序排列 List<Map>，根据"value"字段
        Collections.sort(list, Comparator.comparing(map -> (Integer) map.get("value"), Comparator.reverseOrder()));

        // 输出排序后的结果
        for (Map<String, Integer> map : list) {
            System.out.println(map);
        }
    }
}
```

以上代码使用 `Comparator.comparing()` 方法指定根据 Map 中的 "value" 字段进行比较。然后通过 `Comparator.reverseOrder()` 方法对比较结果进行倒序排列。

在输出结果中，可以看到根据 "value" 字段进行倒序排列后的 List<Map> 结果：

```
{id=3, value=200}
{id=1, value=100}
{id=2, value=50}
```

请注意，这里假设 "value" 字段的值为 Integer 类型。如果字段的值为其他类型，需要进行相应的类型转换。


