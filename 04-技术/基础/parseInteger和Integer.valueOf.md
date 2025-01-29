idea黄线警告中提示

![image-20210827150037464](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210827150037464.png)

意思是：内部有多余的自动装箱操作。

在Java中，int是基本的数据类型，Integer则是对象类型。从jdk1.5开始，Java提供了自动装箱和拆箱的功能。自动装箱就是将基本数据类型转换成对象类型的过程。

`Integer valueOf(String s)`的源码长这样：

```java
 public static Integer valueOf(String s) throws NumberFormatException {
        return Integer.valueOf(parseInt(s, 10));
    }
```

我们看到，valueOf的方法是调用parseInt之后再做一次类型转换，也就是说，它多了一个装箱的操作。因此，这里我们理解IDEA的告警了，如果你想把字符串转换成int类型，那么parseInt即可，如果调用valueOf，会先调用parseInt返回int类型，然后使用Integer.valueOf()做一次装箱操作，然后返回值需要int，Java再做一次拆箱操作，显然这种方式更加低效。而如果返回值是Integer类型，则不管哪种方式都一样。这就是valueOf和parseInt的区别，也就是记住尽量使用parseInt即可。

