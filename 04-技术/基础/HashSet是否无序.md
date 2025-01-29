---
author: yuanshuai
created: 2021-10-15 17:31:38
aliases: 
description:
tags: [基础, HashSet]
---


HashSet的迭代器在输出时“**不保证有序**”，但也不是“**保证无序**”。也就是说，输出时有序也是允许的，但是你的程序不应该依赖这一点。

#### 一、问题起因

《Core Java Volume I—Fundamentals》中对HashSet的描述是这样的：

> HashSet：一种没有重复元素的无序集合

解释：我们一般说HashSet是无序的，它既不能保证存储和取出顺序一致，更不能保证自然顺序（a-z）

下面是《Thinking in Java》中的使用Integer对象的HashSet的示例

```java
  import java.util.*;
  
  public class SetOfInteger {
      public static void main(String[] args) {
          Random rand = new Random(47);
          Set<Integer> intset = new HashSet<Integer>();
          for (int i = 0; i<10000; i++)
              intset.add(rand.nextInt(30));
          System.out.println(intset);
  
      }
  }/* Output:
  
  [15, 8, 23, 16, 7, 22, 9, 21, 6, 1 , 29 , 14, 24, 4, 19, 26, 11, 18, 3, 12, 27, 17, 2, 13, 28, 20, 25, 10, 5, 0]
```

在0-29之间的10000个随机数被添加到了Set中，大量的数据是重复的，但输出结果却每一个数只有一个实例出现在结果中，并且输出的结果没有任何规律可循。 这正与其**不重复**，且**无序**的特点相吻合。



看来两本书的结果，以及我们之前所学的知识，看起来都是一致的，一切就是这么美好。

随手运行了一下这段书中的代码，结果却让人大吃一惊

```java
//JDK1.8下 Idea中运行
  import java.util.*;
  ​
  public class SetOfInteger {
      public static void main(String[] args) {
          Random rand = new Random(47);
          Set<Integer> intset = new HashSet<Integer>();
          for (int i = 0; i<10000; i++)
              intset.add(rand.nextInt(30));
          System.out.println(intset);
      }
  }
  ​
  //运行结果
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]

```

嗯！**不重复**的特点依旧吻合，但是为什么遍历输出结果却是有序的？？？

写一个最简单的程序再验证一下：

```java
import java.util.*;
  
  public class HashSetDemo {
      public static void main(String[] args) {
  
          Set<Integer> hs = new HashSet<Integer>();
  
          hs.add(1);
          hs.add(2);
          hs.add(3);
  
          //增强for遍历
          for (Integer s : hs) {
              System.out.print(s + " ");
          }
      }
  }
  
  //运行结果
  1 2 3

```

我还不死心，是不是元素数据不够多，有序这只是一种巧合的存在，增加元素数量试试

```java
import java.util.*;
  
  public class HashSetDemo {
      public static void main(String[] args) {
          
          Set<Integer> hs = new HashSet<Integer>();
  
          for (int i = 0; i < 10000; i++) {
              hs.add(i);
          }
  
          //增强for遍历
          for (Integer s : hs) {
              System.out.print(s + " ");
          }
      }
  }
  
  //运行结果
  1 2 3 ... 9997 9998 9999
```

可以看到，遍历后输出依旧是有序的

#### 二、过程

通过一步一步分析源码，我们来看一看，这究竟是怎么一回事，首先我们先从程序的第一步——集合元素的存储开始看起，先看一看HashSet的add方法源码：

```java
  // HashSet 源码节选-JKD8
  public boolean add(E e) {
      return map.put(e, PRESENT)==null;
  }
```

我们可以看到，HashSet直接调用HashMap的put方法，并且将元素e放到map的key位置（保证了唯一性 ）

顺着线索继续查看HashMap的put方法源码：

```java
  //HashMap 源码节选-JDK8
  public V put(K key, V value) {
      return putVal(hash(key), key, value, false, true);
  }
```

而我们的值在返回前需要经过HashMap中的hash方法

接着定位到hash方法的源码：

```java
  //HashMap 源码节选-JDK8
  static final int hash(Object key) {
      int h;
      return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
  }
```

hash方法的返回结果中是一句三目运算符，键 (key) 为null即返回 0,存在则返回后一句的内容

```java
  (h = key.hashCode()) ^ (h >>> 16)
```



JDK8中 HashMap——hash 方法中的这段代码叫做 “**扰动函数**”

我们来分析一下：

hashCode是Object类中的一个方法，在子类中一般都会重写，而根据我们之前自己给出的程序，暂以Integer类型为例，我们来看一下Integer中hashCode方法的源码：

```java
  /**
   * Returns a hash code for this {@code Integer}.
   *
   * @return  a hash code value for this object, equal to the
   *          primitive {@code int} value represented by this
   *          {@code Integer} object.
   */
  @Override
  public int hashCode() {
      return Integer.hashCode(value);
  }
  
  /**
   * Returns a hash code for a {@code int} value; compatible with
   * {@code Integer.hashCode()}.
   *
   * @param value the value to hash
   * @since 1.8
   *
   * @return a hash code value for a {@code int} value.
   */
  public static int hashCode(int value) {
      return value;
  }
```

Integer中hashCode方法的返回值就是这个数本身

注：整数的值因为与整数本身一样唯一，所以它是一个足够好的散列

所以，下面的A、B两个式子就是等价的

```java
  //注：key为 hash(Object key)参数
  
  A：(h = key.hashCode()) ^ (h >>> 16)
  
  B：key ^ (key >>> 16)
```

分析到这一步，我们的式子只剩下位运算了，先不急着算什么，我们先理清思路

HashSet因为底层使用**哈希表（链表结合数组）**实现，存储时key通过一些运算后得出自己在数组中所处的位置。

我们在hashCoe方法中返回到了一个等同于本身值的散列值，但是考虑到int类型数据的范围：-2147483648~2147483647 ，着很显然，这些散列值不能直接使用，因为内存是没有办法放得下，一个40亿长度的数组的。所以它使用了对数组长度进行**取模运算**，得余后再作为其数组下标，**indexFor( )** ——JDK7中，就这样出现了，在JDK8中 indexFor()就消失了，而全部使用下面的语句代替，原理是一样的。

```java
  //JDK8中
  (tab.length - 1) & hash；
```



```java
  //JDK7中
  bucketIndex = indexFor(hash, table.length);
  
  static int indexFor(int h, int length) {
      return h & (length - 1);
  }
```

提一句，为什么取模运算时我们用 & 而不用 % 呢，因为位运算直接对内存数据进行操作，不需要转成十进制，因此处理速度非常快，这样就导致位运算 & 效率要比取模运算 % 高很多。



看到这里我们就知道了，存储时key需要通过**hash方法**和**indexFor( )**运算，来确定自己的对应下标

(取模运算，应以JDK8为准，但为了称呼方便，还是按照JDK7的叫法来说，下面的例子均为此，特此提前声明)



但是先直接看与运算(&)，好像又出现了一些问题，我们举个例子：

HashMap中初始长度为16，length - 1 = 15；其二进制表示为 00000000 00000000 00000000 00001111

而与运算计算方式为：遇0则0，我们随便举一个key值

```java
          1111 1111 1010 0101 1111 0000 0011 1100
  &       0000 0000 0000 0000 0000 0000 0000 1111
  ----------------------------------------------------
          0000 0000 0000 0000 0000 0000 0000 1100
```

我们将这32位从中分开，左边16位称作高位，右边16位称作低位，可以看到经过&运算后 结果就是高位全部归0，剩下了低位的最后四位。但是问题就来了，我们按照当前初始长度为默认的16，HashCode值为下图两个，可以看到，在不经过扰动计算时，只进行与(&)运算后 Index值均为 12 这也就导致了哈希冲突

![image-20210924154331169](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210924154331169.png)

> 哈希冲突的简单理解：计划把一个对象插入到散列表(哈希表)中，但是发现这个位置已经被别的对象所占据了

例子中，两个不同的HashCode值却经过运算后，得到了相同的值，也就代表，他们都需要被放在下标为2的位置

一般来说，如果数据分布比较广泛，而且存储数据的数组长度比较大，那么哈希冲突就会比较少，否则很高。

但是，如果像上例中只取最后几位的时候，这可不是什么好事，即使我的数据分布很散乱，但是哈希冲突仍然会很严重。

别忘了，我们的扰动函数还在前面搁着呢，这个时候它就要发挥强大的作用了,还是使用上面两个发生了哈希冲突的数据，这一次我们加入扰动函数再进行与(&)运算

![image-20210924162731541](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210924162731541.png)

> 补充 ：>>> 按位右移补零操作符，左操作数的值按右操作数指定的为主右移，移动得到的空位以零填充 
> ​	     ^     位异或运算，相同则0，不同则1

可以看到，本发生了哈希冲突的两组数据，经过扰动函数处理后，数值变得不再一样了，也就避免了冲突

其实在**扰动函数**中，将**数据右位移16位**，哈希码的**高位和低位混合**了起来，这也正解决了前面所讲 高位归0，计算只依赖低位最后几位的情况,  这使得高位的一些特征也**对低位产生了影响**，使得**低位的随机性加强**，能更好的**避免冲突**



到这里，我们一步步研究到了这一些知识

```java
  HashSet add() → HashMap put() → HashMap hash() → HashMap (tab.length - 1) & hash；
```

有了这些知识的铺垫，我对于刚开始自己举的例子又产生了一些疑惑,我使用for循环添加一些整型元素进入集合，难道就没有任何一个发生哈希冲突吗，为什么遍历结果是有序输出的，经过简单计算 2 和18这两个值就都是2

(这个疑惑是有问题的，后面解释了错在了哪里)

```java
  //key = 2,(length -1) = 15
  
  h = key.hashCode()      0000 0000 0000 0000 0000 0000 0000 0010 
  h >>> 16                0000 0000 0000 0000 0000 0000 0000 0000
  hash = h^(h >>> 16)     0000 0000 0000 0000 0000 0000 0000 0010
  (tab.length-1)&hash     0000 0000 0000 0000 0000 0000 0000 1111
                          0000 0000 0000 0000 0000 0000 0000 0010  
  -------------------------------------------------------------
                          0000 0000 0000 0000 0000 0000 0000 0010
  
  //2的十进制结果：2
```



```java
  //key = 18,(length -1) = 15
  
  h = key.hashCode()      0000 0000 0000 0000 0000 0000 0001 0010 
  h >>> 16                0000 0000 0000 0000 0000 0000 0000 0000
  hash = h^(h >>> 16)     0000 0000 0000 0000 0000 0000 0001 0010
  (tab.length-1)&hash     0000 0000 0000 0000 0000 0000 0000 1111
                          0000 0000 0000 0000 0000 0000 0000 0010  
  -------------------------------------------------------------
                          0000 0000 0000 0000 0000 0000 0000 0010
  
  //18的十进制结果：2
```



按照我们上面的知识，按理应该输出 1 2 18 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 但却仍有序输出了

```java
  import java.util.*;
  
  public class HashSetDemo {
      public static void main(String[] args) {
  
          Set<Integer> hs = new HashSet<Integer>();
  
          for (int i = 0; i < 19; i++) {
              hs.add(i);
          }
  
          //增强for遍历
          for (Integer s : hs) {
              System.out.print(s + " ");
          }
      }
  }
  
  //运行结果：
  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 
```

再试一试

```java
  import java.util.*;
  
  public class HashSetDemo {
      public static void main(String[] args) {
  
          Set<Integer> hs = new HashSet<Integer>();
          
          hs.add(0)
          hs.add(1);
          hs.add(18);
          hs.add(2);
          hs.add(3);
          hs.add(4);
          ......
          hs.add(17)
  
          //增强for遍历
          for (Integer s : hs) {
              System.out.print(s + " ");
          }
      }
  }
  
  //运行结果：
  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
```

真让人头大，不死心再试一试，由于偷懒，就只添加了几个，就是这个偷懒，让我发现了新大陆！

```java
  import java.util.*;
  
  public class HashSetDemo {
      public static void main(String[] args) {
  
          Set<Integer> hs = new HashSet<Integer>();
  
          hs.add(1);
          hs.add(18);
          hs.add(2);
          hs.add(3);
          hs.add(4);
  
          //增强for遍历
          for (Integer s : hs) {
              System.out.print(s + " ");
          }
      }
  }
  
  //运行结果：
  1 18 2 3 4
```

这一段程序按照我们认为应该出现的顺序出现了！！！

突然恍然大悟，我忽略了最重要的一个问题，也就是数组长度问题

```java
  //HashMap 源码节选-JDK8
  
  /**
  * The default initial capacity - MUST be a power of two.
  */
  static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16
  
  /**
  * The load factor used when none specified in constructor.
  */
  static final float DEFAULT_LOAD_FACTOR = 0.75f;
```

> << ：按位左移运算符，做操作数按位左移右错作数指定的位数，即左边最高位丢弃，右边补齐0，计算的简便方法就是：把 << 左面的数据乘以2的移动次幂 
> 为什么初始长度为16：1 << 4 即 1 * 2 ^4 =16; 



我们还观察到一个叫做加载因子的东西，他默认值为0.75f，这是什么意思呢，我们来补充一点它的知识：

> 加载因子就是表示哈希表中元素填满的程度，当表中元素过多，超过加载因子的值时，哈希表会自动扩容，一般是一倍，这种行为可以称作rehashing(再哈希)。
> 加载因子的值设置的越大，添加的元素就会越多，确实空间利用率的到了很大的提升，但是毫无疑问，就面临着哈希冲突的可能性增大，反之，空间利用率造成了浪费，但哈希冲突也减少了，所以我们希望在空间利用率与哈希冲突之间找到一种我们所能接受的平衡，经过一些试验，定在了0.75f



现在可以解决我们上面的疑惑了

数组初始的实际长度 = 16 * 0.75 = 12

这代表当我们元素数量增加到12以上时就会发生扩容，当我们上例中for循环添加0-18， 这19个元素时，先保存到前12个到第十三个元素时，超过加载因子，导致数组发生了一次扩容，而扩容以后对应与(&)运算的(tab.length-1)就发生了变化,从16-1 变成了 32-1 即31

我们来算一下

```java
  //key = 2,(length -1) = 31
  
  h = key.hashCode()      0000 0000 0000 0000 0000 0000 0001 0010 
  h >>> 16                0000 0000 0000 0000 0000 0000 0000 0000
  hash = h^(h >>> 16)     0000 0000 0000 0000 0000 0000 0001 0010
  (tab.length-1)&hash     0000 0000 0000 0000 0000 0000 0011 1111 
                          0000 0000 0000 0000 0000 0000 0000 0010      
  -------------------------------------------------------------
                          0000 0000 0000 0000 0000 0000 0000 0010
  
  //十进制结果：2
```



```java
  //key = 18,(length -1) = 31
  
  h = key.hashCode()      0000 0000 0000 0000 0000 0000 0001 0010 
  h >>> 16                0000 0000 0000 0000 0000 0000 0000 0000
  hash = h^(h >>> 16)     0000 0000 0000 0000 0000 0000 0001 0010
  (tab.length-1)&hash     0000 0000 0000 0000 0000 0000 0011 1111 
                          0000 0000 0000 0000 0000 0000 0000 0010      
  -------------------------------------------------------------
                          0000 0000 0000 0000 0000 0000 0001 0010
  
  //十进制结果：18
```

当length -  1 的值发生改变的时候，18的值也变成了本身。

到这里，才意识到自己之前用2和18计算时 均使用了 length -1 的值为 15是错误的，当时并不清楚加载因子及它的扩容机制，这才是导致提出有问题疑惑的根本原因。



#### 三、总结

JDK7到JDK8，其内部发生了一些变化，导致在不同版本JDK下运行结果不同，根据上面的分析，我们从HashSet追溯到HashMap的hash算法、加载因子和默认长度。

由于我们所创建的HashSet是Integer类型的，这也是最巧的一点，Integer类型hashCode()的返回值就是其int值本身，而存储的时候元素通过一些运算后会得出自己在数组中所处的位置。由于在这一步，其本身即下标(只考虑这一步)，其实已经实现了排序功能，由于int类型范围太广，内存放不下，所以对其进行取模运算，为了减少哈希冲突，又在取模前进行了，扰动函数的计算，得到的数作为元素下标，按照JDK8下的hash算法，以及load factor及扩容机制，这就导致数据在经过 HashMap.hash()运算后仍然是自己本身的值，且没有发生哈希冲突。



补充：对于有序无序的理解

集合所说的序，是指元素存入集合的顺序，当元素存储顺序和取出顺序一致时就是有序，否则就是无序。 

HashSet的无序指的是存取无序。不是储存数据无序。即并不是说存储数据的时候无序，没有规则，当我们不论使用for循环随机数添加元素的时候，还是for循环有序添加元素的时候，最后遍历输出的结果均为按照值的大小排序输出，随机添加元素，但结果仍有序输出，这就对照着上面那句，存储顺序和取出顺序是不一致的，所以我们说HashSet是无序的，虽然我们按照123的顺序添加元素，结果虽然仍为123，但这只是一种巧合而已。

存储数据是有序的，这个顺序是JDK的Hash算法决定的，每次输出的顺序是一样的，但是这个顺序对你的程序毫无意义。从存储数据的角度来看，**每个数据结构都是有序的**。

所以HashSet只是**不保证有序**，并**不是保证无序**

[HashSet是否是无序的](HashSet是否是无序的.drawio)



