---
author: yuanshuai
created: 2022-02-22 10:28:11
aliases: 
description:
tags: [java, stream]
---

## map转list
```java
Map<String, String> map = new HashMap<>();
// Convert all Map keys to a List
List<String> result = new ArrayList(map.keySet());
// Convert all Map values to a List
List<String> result2 = new ArrayList(map.values());
// Java 8, Convert all Map keys to a List
List<String> result3 = map.keySet().stream()
	.collect(Collectors.toList());
// Java 8, Convert all Map values  to a List
List<String> result4 = map.values().stream()
	.collect(Collectors.toList());
// Java 8, seem a bit long, but you can enjoy the Stream features like filter and etc.
List<String> result5 = map.values().stream()
	.filter(x -> !"apple".equalsIgnoreCase(x))
	.collect(Collectors.toList());
// Java 8, split a map into 2 List, it works!
// refer example 3 below
```

其中，map的value转list写法为`map.values().stream()
	.collect(Collectors.toList());`

## list的list转list

```java
List collect = IntStream.range(1, 10).boxed().collect(Collectors.toList());

List collect1 = IntStream.range(10, 20).boxed().collect(Collectors.toList());

List> lists = new ArrayList<>();

lists.add(collect);

lists.add(collect1);

ArrayList collect2 = lists.stream().collect(ArrayList::new, ArrayList::addAll, ArrayList::addAll);

System.out.println(collect2);
```

其中关键是代码是
`list.stream().collect(ArrayList::new, ArrayList::addAll, ArrayList::addAll);`
