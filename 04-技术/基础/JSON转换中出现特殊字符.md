对象转换为json字符串时（fastjson）,结果中出现`“$ref”`这样的字符是为何？

一般是由于数据中有完全一样的内容，转换时会将重复的部分以==引用==形式展现，也就是前面的$ref。

解决方法：

```
JSON.toJSONString(obj, SerializerFeature.DisableCircularReferenceDetect)
```
