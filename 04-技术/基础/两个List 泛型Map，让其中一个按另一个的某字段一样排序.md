---

UID: 20230912164152 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2023-09-12
---

## ✍内容





在 Java 中，如果你有两个 List<Map>，并且想要对其中一个 List 按照另一个 List 的某个字段进行相同的排序，可以使用`Comparator`和`Collections`的`sort`方法结合`stream()`来实现。

以下是一个示例代码：

```java
import java.util.*;

public class Main {
    public static void main(String[] args) {
        List<Map<String, Integer>> list1 = new ArrayList<>();
        List<Map<String, Integer>> list2 = new ArrayList<>();

        // 初始化 list1 和 list2
        Map<String, Integer> map1 = new HashMap<>();
        map1.put("id", 1);
        map1.put("value", 100);
        list1.add(map1);

        Map<String, Integer> map2 = new HashMap<>();
        map2.put("id", 2);
        map2.put("value", 50);
        list1.add(map2);

        Map<String, Integer> map3 = new HashMap<>();
        map3.put("id", 3);
        map3.put("value", 200);
        list1.add(map3);

        Map<String, Integer> map4 = new HashMap<>();
        map4.put("id", 1);
        map4.put("value", 400);
        list2.add(map4);

        Map<String, Integer> map5 = new HashMap<>();
        map5.put("id", 2);
        map5.put("value", 300);
        list2.add(map5);

        Map<String, Integer> map6 = new HashMap<>();
        map6.put("id", 3);
        map6.put("value", 500);
        list2.add(map6);

        // 按list2中的"id"字段顺序重排list1
        list1.sort(Comparator.comparing(map -> {
            Integer id = (Integer) map.get("id");
            int index = -1;
            for (int i = 0; i < list2.size(); i++) {
                if (list2.get(i).containsValue(id)) {
                    index = i;
                    break;
                }
            }
            return index;
        }));

        // 输出重排后的结果
        for (Map<String, Integer> map : list1) {
            System.out.println(map);
        }
    }
}
```

以上代码按照`list2`中的"id"字段顺序对`list1`进行重排。首先，通过`Comparator.comparing()`方法指定比较的方式，其中比较函数返回的是在`list2`中"id"字段对应的索引位置。然后，在`sort()`方法中使用这个`Comparator`进行排序。

在输出结果中，你将看到`list1`按照`list2`中"id"字段顺序进行了重排：

```
{id=1, value=100}
{id=2, value=50}
{id=3, value=200}
```

请注意，这里假设`list2`中的"id"字段的值在`list1`中都存在。如果存在不一致的情况，你可能需要对此进行额外的处理。

