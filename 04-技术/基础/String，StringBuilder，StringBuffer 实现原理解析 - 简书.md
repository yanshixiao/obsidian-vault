> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [www.jianshu.com](https://www.jianshu.com/p/64519f1b1137)

定义：
---

    从 jdk1.5 开始提供的新的封装字符串的类，**_StringBuilder，其字符串拼接操作的效率远远高于 String。_**

    Java 里面提供了 String，StringBuffer 和 StringBuilder 三个类来封装字符串

简介：
---

    我们知道字符串其实就是由若干个字符线性排列而成的，可以理解为字符数组 Array，那么既然是数组实现的，那就需要考虑到数组的特性，数组在内存中是一块连续的地址空间块，即在定义数组的时候需要指定数组的大小

    换言之， 数组就分为可变数组和不可变数组。可变数组能够动态插入和删除，而不可变数组一旦分配好空间后则不能进行动态插入或删除操作。

    在实际的字符串应用场景中，涉及到多种操作，比如字符串的插入，删除，修改，拼接，查询，替换...

String:
-------

   **_不可变类_**，属性 value 为_**不可变数组**_，即 String 初始化构造器没有初始容量为 16 的概念，你定义多少，String 中字符数组的长度就是多少，不存在字符数组扩容一说。看下源码：

![](http://upload-images.jianshu.io/upload_images/5362354-078a3342b88f5fa0.png) 2 ![](http://upload-images.jianshu.io/upload_images/5362354-d44d4ed593cfa30f.png) 3

final 修饰的 String 类，以及 final 修饰的 char[] value, 表示 String 类不可被继承，且 value 只能被初始化一次。这里的 value 变量其实就是存储了 String 字符串中的所有字符。

那既然 String，不可变。我们再看下它的**_截取方法 subString（）实现_**

![](http://upload-images.jianshu.io/upload_images/5362354-747b8021ae5ed379.png) 4

这里可以看到，在 substring 方法中，如果传入的参数为 0，就返回自身原对象，否则就是_**重新创建一个新的对象**_。

![](http://upload-images.jianshu.io/upload_images/5362354-2054bb5c07573c13.png) 5 ![](http://upload-images.jianshu.io/upload_images/5362354-357f1f7a43e156aa.png) 6

类似的我们可以看到，String 类的 concat 方法，replace 方法，都是内部重新生成一个 String 对象的。

这也就是为什么我们如果采用_**String 对象频繁的进行拼接，截取，替换操作效率很低下**_的原因。

下面再看下 StringBuilder 对象的源码，分析为何其在做字符串的拼接，截取，替换方面效率远远高于 String

StringBuilder：
--------------

    内部**_可变数组_**，存在初始化 StringBuilder 对象中**_字符数组容量为 16，存在扩容_**。

![](http://upload-images.jianshu.io/upload_images/5362354-6541f26b3f361c0c.png) 7

StringBuilder 类继承 AbstractStringBuilder 抽象类，其中 StringBuilder 的大部分方法都是直接调用的父类的实现。

首先看下 StringBuilder 的构造方法

![](http://upload-images.jianshu.io/upload_images/5362354-abcd880b2da6ffdc.png) 8

1：空参数的构造方法

![](http://upload-images.jianshu.io/upload_images/5362354-6f2592de6b3fe420.png) 9 ![](http://upload-images.jianshu.io/upload_images/5362354-64ee89780b054ee0.png) 10

2：自定义初始容量 - 构造函数

![](http://upload-images.jianshu.io/upload_images/5362354-47d69e48629ff026.png) 11

3：以字符串 String 作为参数的构造

![](http://upload-images.jianshu.io/upload_images/5362354-171507a17fda1ee3.png) 12

在参数 Str 数组长度的基础上再增加 16 个字符长度，作为 StringBuilder 实例的初始数组容量，并将 str 字符串 append 到 StringBuilder 的数组中。

![](http://upload-images.jianshu.io/upload_images/5362354-0be5e4014fdd6bd2.png) 13

具体看下父类 AbstractStringBuilder 的 append 方法

![](http://upload-images.jianshu.io/upload_images/5362354-f220c062ddf988f6.png) 14

1：首先判断 append 的参数是否为 null，如果为 null 的话，这里也是可以 append 进去的

![](http://upload-images.jianshu.io/upload_images/5362354-60e3d76ecdcc2cf4.png) 15

其中 ensureCapacityInternal 方法是确保这次 append 的时候 StringBuilder 的内部数组容量是满足的，即这次要 append 的 null 字符长度为 4，加上之前内部数组中已有的字符位数 c 之后作为参数执行。

![](http://upload-images.jianshu.io/upload_images/5362354-97d65df1b5a02c37.png) 16

2：如果不为 null 的话，就获取这次需要 append 的 str 的字符长度。紧接着执行是否需要扩容的方法

3：重点看下 append 方法的关键：String 的 **_getChars 方法_**（从 str 的 0 位开始，到 str 的长度，当前 StringBuilder 对象的字符数组，当前数组已有的字符长度）

![](http://upload-images.jianshu.io/upload_images/5362354-5bfb9b28ec893edf.png) 17 ![](http://upload-images.jianshu.io/upload_images/5362354-87961884184a7fb1.png) 18

其实是调用了 System 的 arraycopy 方法 参数如下：

    **_value_** 为 str 的内部不可变字符数组，

    _**srcBegin**_ 为从 str 字符串数组的 0 下标开始，

    **_srcEnd_** 为 str 字符串数组的长度，

    _**dst**_ 为 StringBuilder 对象的内部可变字符数组，

    _**dstBegin**_ 则为 StringBuilder 对象中已有的字符长度（char[] 已有的元素长度）

即整个 StringBuilder 的 append 方法，本质上是调用 System 的 native 方法，直接将 String 类型的 str 字符串中的字符数组，拷贝到了 StringBuilder 的字符数组中

![](http://upload-images.jianshu.io/upload_images/5362354-874e3442e4873708.png) 19

#### toString()：

    最后说下 StringBuilder 的 toString 方法，

![](http://upload-images.jianshu.io/upload_images/5362354-04dafc4f17b870c6.png)

    这里的_**toString 方法直接 new 一个 String 对象，将 StringBuilder 对象的 value 进行一个拷贝，重新生成一个对象，不共享之前 StringBuilder 的 char[]**_

以上就是 StringBuilder 的拼接字符串的原理分析，可以发现没有像 String 一样去重新 new 对象，所以在频繁的拼接字符上，StringBuilder 的效率远远高于 String 类。

StringBuffer：
-------------

    线程安全的高效字符串操作类，看下源码：

![](http://upload-images.jianshu.io/upload_images/5362354-921c369fcd91f88f.png) 19

类图和 StringBuilder 一样，不多说

构造函数：

![](http://upload-images.jianshu.io/upload_images/5362354-9ce422aefee16d0f.png) 20

和 StringBuilder 一样，也不用多说，重点看下其 append 方法：

![](http://upload-images.jianshu.io/upload_images/5362354-ccb4415469b38c58.png) 21

可以看到这里就是在 append 方法上加了同步锁，来实现多线程下的线程安全。其他的和 StringBuilder 一致。

这里比 StringBuilder 多了一个参数

![](http://upload-images.jianshu.io/upload_images/5362354-44b71dcbe5ee342f.png) 22

这里的作用简单介绍一下，就是去缓存 toString 的

可以看下 StringBuffer 的 toString 方法

![](http://upload-images.jianshu.io/upload_images/5362354-f84292e9ce021a53.png) 23

这里的作用就是如果 StringBuffer 对象此时存在 toStringCache，在多次调用其 toString 方法时，其 new 出来的 String 对象是会共享同一个 char[] 内存的，达到共享的目的。但是 StringBuffer 只要做了修改，其_**toStringCache 属性**_值都会置 null 处理。**_这也是 StringBuffer 和 StringBuilder 的一个区别点。_**

总结：
---

    String 类不可变，内部维护的 char[] 数组长度不可变，为 final 修饰，String 类也是 final 修饰，不存在扩容。字符串拼接，截取，都会生成一个新的对象。频繁操作字符串效率低下，因为每次都会生成新的对象。

    StringBuilder 类内部维护可变长度 char[] ， 初始化数组容量为 16，存在扩容， 其 append 拼接字符串方法内部调用 System 的 native 方法，进行数组的拷贝，不会重新生成新的 StringBuilder 对象。非线程安全的字符串操作类， 其每次调用 toString 方法而重新生成的 String 对象，不会共享 StringBuilder 对象内部的 char[]，会进行一次 char[] 的 copy 操作。

    StringBuffer 类内部维护可变长度 char[]， 基本上与 StringBuilder 一致，但其为线程安全的字符串操作类，大部分方法都采用了 Synchronized 关键字修改，以此来实现在多线程下的操作字符串的安全性。其 toString 方法而重新生成的 String 对象，会共享 StringBuffer 对象中的 toStringCache 属性（char[]），但是每次的 StringBuffer 对象修改，都会置 null 该属性值。