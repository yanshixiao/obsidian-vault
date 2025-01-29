# 				内存结构

### 1.程序计数器

#### 1.1 定义

Program Counter Register程序计数器（寄存器）

#### 1.2 作用

记住下一条JVM指令的执行地址

#### 1.3 特点

- 线程私有，属于线程
- 不会存在内存溢出

### 2.虚拟机栈

![内存结构-栈与栈帧](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/内存结构-栈与栈帧.png)





#### 2.1 定义

Java Virtual Machine Stacks (Java虚拟机栈)

- 每个线程运行时所需要的内存，称为虚拟机栈
- 每个栈由多个栈帧（Frame）组成，对应着每次方法调用时所占用的内存
- 每个线程只能有一个活动栈帧，对应着当前正在执行的那个方法

问题辨析

1.垃圾回收是否涉及栈内存？

栈内存随着栈帧的出栈会自动回收，不需要垃圾回收

2.栈内存分配越大越好吗？

有虚拟机参数指定  -Xxs size 一般默认1024k，即1M，windows系统比较特殊，取决于系统虚拟内存。栈内存不是越多越好，因为会减少同时可运行的线程的数目。

3.方法区的局部变量是否线程安全？

如果方法内局部变量作用范围没有逃离方法作用范围，就是线程安全的，反之是线程不安全的。

#### 2.2 栈内存溢出

- 栈帧过多导致栈内存溢出（方法调用层级过深，比如**递归调用**）

  idea 调试时，使用VM参数 -Xss200k这样的形式调整

  StackOverFlowError不仅仅会因为自己的代码引发，还有可能因为调用第三方而触发，比如两个对象互相引用时，对象转JSON字符，就会出现循环引用导致栈帧内存溢出。

- 栈帧过大导致栈内存溢出（不太容易出现）

#### 2.3 线程运行诊断

案例1：cpu占用过多

​	nohub java  java包名路径 &

​	定位

- 用top定位哪个进程对cpu的占用过高
- ps H -eo pid,tid,%cpu | grep 进程id（用ps命令进一步定位是哪个线程引起的cpu占用过高)
- jstack 进程id（输出中线程id是16进制，linux中是10进制，要进行转换进行查找，找到后便能定位代码行数）
- 可以根据线程id找到有问题的线程，进一步定位到问题代码的源码行数。

ps命令查看线程对CPU的占用情况：ps H -eo pid,tid,%cpu。其中H的含义是输出进程包含的线程信息。-oe后面指定感兴趣的列。正常情况下会打印出当前所有进程的信息，为了方便查看，在命令后添加 | grep 进程id。



案例2：程序运行很长时间没有结果

可能是多个线程发生了死锁。

### 3.本地方法栈

本地方法接口，比如Object的clone方法。

### 4.堆

#### 4.1 定义

Heap 堆

- 通过new关键字，创建对象都会使用堆内存

特点

- 它是线程共享的，堆中对象都需要考虑线程安全的问题
- 有垃圾回收机制

#### 4.2 堆内存溢出

![image-20210111165722831](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111165722831.png)

修改堆空间的jvm参数为-Xmx。本机默认4G, 如有必要建议设小一些，能尽快暴露问题，如8M

#### 4.3 堆内存诊断

示例代码：

```java
public class Demo {
    public static void main(String[] args) throws InterruptedException {
        System.out.println("1....");
        Thread.sleep(30000);
        byte[] array = new byte[1024 * 1024 * 10];//10MB
        System.out.println("2...");
        Thread.sleep(20000);
        array = null;
        System.gc();
        System.out.println("3...");
        Thread.sleep(1000000);
    }
}
```



1. jsp工具

- 查看当前系统中有哪些java进程

2. jmap

- 查看堆内存占用情况 jmap -heap 进程id

  ![image-20210111171756740](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111171756740.png)

3. jconsole工具

- 图形界面的，多功能的监测工具，可以连续监测。

  ![](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111172145478.png)



案例：

- 垃圾回收后，内存占用仍然很高

  jvisualvm工具中的内存堆dump获取虚拟机堆的快照

  ![image-20210111174619045](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111174619045.png)

  ![image-20210111174720640](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111174720640.png)

  ![image-20210111174653884](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111174653884.png)

  

### 5.方法区

#### 5.1 定义

![image-20210111180428852](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210111180428852.png)

#### 5.2 组成

![JVM内存结构-不同版本的JVM实现](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/JVM内存结构-不同版本的JVM实现.png)



#### 5.3 方法区内存溢出

- 1.8以前会导致永久代内存溢出

  > 演示永久代内存溢出 java.lang.OutOfMemoryError: PermGen space
  >
  > -XX:MaxPermSize=8m

  

- 1.8以后会导致元空间内存溢出

  > 演示元空间内存溢出 java.lang.OutOfMemoryError: Metaspace
  >
  > -XX:MaxMetaspaceSize=8m

  ```java
  package com.yanshixiao.jvm;
  
  
  import jdk.internal.org.objectweb.asm.ClassWriter;
  import jdk.internal.org.objectweb.asm.Opcodes;
  
  /**
   * 演示元空间内存溢出
   * -XX:MaxMetaspaceSize=8m
   * @author: yanshixiao
   * @date Created in 14:55 2021/1/13
   */
  public class Demo1_8 extends ClassLoader{
      public static void main(String[] args) {
          int j = 0;
          try {
              Demo1_8 test = new Demo1_8();
              for (int i = 0; i < 10000; i++, j++) {
                  //ClassWriter作用是生成二进制字节码
                  ClassWriter cw = new ClassWriter(0);
                  //版本号，public，类名，包名，父类，接口
                  cw.visit(Opcodes.V1_8, Opcodes.ACC_PUBLIC, "Class"+i, null, "java/lang/Object", null);
                  //返回byte[]
                  byte[] code = cw.toByteArray();
                  test.defineClass("Class" + i, code, 0, code.length);
  
              }
          } finally {
              System.out.println(j);
          }
      }
  }
  
  ```

  ![image-20210113150956154](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210113150956154.png)

  设为8m时提示过小，9m如上图所示，为何会这样？TODO

场景：动态代理中使用这种动态生成字节码的技术。

#### 5.4 运行时常量池

javap命令反编译class文件生成可读的**字节码指令**文件。-v参数表示输出详细信息

常量池：

![image-20210113180209562](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210113180209562.png)

方法指令：

![image-20210113175842541](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210113175842541.png)



> $ javap -v HelloWorld.class
> Classfile /E:/workspaces/IdeaProjects/learn-java/demo/target/classes/com/yanshixiao/jvm/HelloWorld.class
>   Last modified 2021-1-13; size 571 bytes
>   MD5 checksum ef6c35e9d657e5263999abbc98fb934c
>   Compiled from "HelloWorld.java"
> public class com.yanshixiao.jvm.HelloWorld
>   minor version: 0
>   major version: 51
>   flags: ACC_PUBLIC, ACC_SUPER
> Constant pool:
>    #1 = Methodref          #6.#20         // java/lang/Object."<init>":()V
>    #2 = Fieldref           #21.#22        // java/lang/System.out:Ljava/io/PrintStream;
>    #3 = String             #23            // Hello World
>    #4 = Methodref          #24.#25        // java/io/PrintStream.println:(Ljava/lang/String;)V
>    #5 = Class              #26            // com/yanshixiao/jvm/HelloWorld
>    #6 = Class              #27            // java/lang/Object
>    #7 = Utf8               <init>
>    #8 = Utf8               ()V
>    #9 = Utf8               Code
>   #10 = Utf8               LineNumberTable
>   #11 = Utf8               LocalVariableTable
>   #12 = Utf8               this
>   #13 = Utf8               Lcom/yanshixiao/jvm/HelloWorld;
>   #14 = Utf8               main
>   #15 = Utf8               ([Ljava/lang/String;)V
>   #16 = Utf8               args
>   #17 = Utf8               [Ljava/lang/String;
>   #18 = Utf8               SourceFile
>   #19 = Utf8               HelloWorld.java
>   #20 = NameAndType        #7:#8          // "<init>":()V
>   #21 = Class              #28            // java/lang/System
>   #22 = NameAndType        #29:#30        // out:Ljava/io/PrintStream;
>   #23 = Utf8               Hello World
>   #24 = Class              #31            // java/io/PrintStream
>   #25 = NameAndType        #32:#33        // println:(Ljava/lang/String;)V
>   #26 = Utf8               com/yanshixiao/jvm/HelloWorld
>   #27 = Utf8               java/lang/Object
>   #28 = Utf8               java/lang/System
>   #29 = Utf8               out
>   #30 = Utf8               Ljava/io/PrintStream;
>   #31 = Utf8               java/io/PrintStream
>   #32 = Utf8               println
>   #33 = Utf8               (Ljava/lang/String;)V
> {
>   public com.yanshixiao.jvm.HelloWorld();
>     descriptor: ()V
>     flags: ACC_PUBLIC
>     Code:
>       stack=1, locals=1, args_size=1
>          0: aload_0
>          1: invokespecial #1                  // Method java/lang/Object."<init>":()V
>          4: return
>       LineNumberTable:
>         line 7: 0
>       LocalVariableTable:
>         Start  Length  Slot  Name   Signature
>             0       5     0  this   Lcom/yanshixiao/jvm/HelloWorld;
>
>   public static void main(java.lang.String[]);
>     descriptor: ([Ljava/lang/String;)V
>     flags: ACC_PUBLIC, ACC_STATIC
>     Code:
>       stack=2, locals=1, args_size=1
>          0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
>          3: ldc           #3                  // String Hello World
>          5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
>          8: return
>       LineNumberTable:
>         line 9: 0
>         line 10: 8
>       LocalVariableTable:
>         Start  Length  Slot  Name   Signature
>             0       9     0  args   [Ljava/lang/String;
> }
> SourceFile: "HelloWorld.java"



- 常量池，就是一张表，虚拟机指令根据这张常量表找到要执行的类名、方法名、参数类型、字面量等信息。
- 运行时常量池，常量池是*.class文件中的，当该类被加载，它的常量池信息就会放入运行时常量池，并把里面的符号地址变为真实地址。

#### 5.5 StringTable

![image-20210113182815130](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210113182815130.png)

从常量池加载2号常量数据，然后astore_1赋值给本地变量1。



![image-20210113184957361](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210113184957361.png)

astore_1 和 aload_1相对，前者存储到本地变量表，后者从本地变量表获取数据。

关于其中dup的含义，参照[传送门](https://www.zhihu.com/question/52749416)

#### 5.5 StringTable 特征

- 常量池中的字符串仅是符号，第一次用到时才变为对象
- 利用串池的机制，来避免重复创建字符串对象
- 字符串变量拼接的原理是StringBuilder（1.8）
- 字符串常量拼接的原理是编译器优化
- 可以使用intern方法，主动将串池中还没有的字符串对象放入串池
  - 1.8 将这个字符串对象尝试放入串池，如果有则并不会放入，如果没有则放入串池，不论有没有都会把串池中的对象返回
  - 1.6 将这个字符串对象尝试放入串池，如果有则并不会放入，如果没有会把此对象复制一份，不论有没有都会把串池中的对象返回

#### 5.6 StringTable的位置

![image-20210114184925733](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210114184925733.png)

GC overhead limit exceeded:是指花了98%的时间回收了不到2%的空间，会报GC overhead limit exceeded

可以使用参数-XX:-UserGCOverheadLimit关闭，关闭后再运行报错就变成了OutOfMemoryError: Java Heap Space,即堆空间内存溢出，从而可以证明1.8版本StringTable是在堆中。而1.6的OutOfMemoryError:PermGen Space证明1.6版本在永久代中。

#### 5.7 StringTable垃圾回收

-Xmx10m -XX:+PrintStringTableStatistics -XX:+PrintGCDetails -verbose:gc

使用如上运行时jvm参数可以打印StringTable统计信息，但实际测试中，循环创建了100个字符串并入池，StringTable中entries的数量并没非准确增加一百。不过创建10000个对象入池后，数量只有两万多，证明进行了垃圾回收。

![image-20210116163656649](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210116163656649.png)

由于分配失败导致垃圾回收

#### 5.8 StringTable性能调优

- 调整-XX:StringTableSize=桶个数

调整StringTable 的 bucket数量大小，StringTable实际上是个hash表，数组加链表。参数为 **-XX:StringTableSize=200000**

字符串常量数量很多，可以把参数适当调大，降低hash冲突的概率。**加快速度**

- 考虑将字符串对象是否入池

入池后重复的内容不会再占用堆内存，可以大大**节省空间**

### 6 直接内存

#### 6.1 定义

directBuffer

- 常见于NIO操作时，用于数据缓冲区
- 分配回收成本较高，但读写性能高
- 不受JVM内存回收管理

![image-20210116171424576](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210116171424576.png)





#### 6.2 直接内存溢出

![image-20210118165349679](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210118165349679.png)



#### 6.3 直接内存分配和回收的原理

- 使用了Unsafe对象完成直接内存的分配回收，并且回收需要主动调用freeMemory方法
- ByteBuffer的实现类内部，使用了Cleaner（虚引用）来检测ByteBuffer对象，一旦ByteBuffer对象被垃圾回收，那么就会由ReferenceHandler线程通过Cleaner的clean方法调用freeMemory来释放直接内存。

byteBuffer分配直接内存时底层调用了**unsafe.allocateMemory**![image-20210118171438122](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210118171438122.png)





Cleaner虚引用对象，当其关联的对象被回收时，调用.clean方法。clean方法中会执行任务对象（Deallocator）的run方法，

![](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210118171842795.png)

![image-20210118171603438](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210118171603438.png)



-XX:+DisableExplicitGC 禁用显式的GC， 即System.gc()