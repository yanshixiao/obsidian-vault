### 哈希

Hash，一般翻译做“散列”，也有直接音译为“哈希”的，就是把任意长度的输入，通过散列算法，变换成固定长度的输出，该输出就是散列值。这种转换是一种压缩映射，也就是，散列值的空间通常远小于输入的空间，不同的输入可能会散列成相同的输出，所以不可能从散列值来唯一的确定输入值。简单的说就是一种将任意长度的消息压缩到某一固定长度的消息摘要的函数。

所有散列函数都有如下一个基本特性：根据同一散列函数计算出的散列值如果不同，那么输入值肯定也不同。但是，根据同一散列函数计算出的散列值如果相同，输入值不一定相同。

两个不同的输入值，根据同一散列函数计算出的散列值相同的现象叫做碰撞。

常见的Hash函数有以下几个：

- 直接定址法：直接以关键字k或者k加上某个常数（k+c）作为哈希地址。

- 数字分析法：提取关键字中取值比较均匀的数字作为哈希地址。

- 除留余数法：用关键字k除以某个不大于哈希表长度m的数p，将所得余数作为哈希表地址。

- 分段叠加法：按照哈希表地址位数将关键字分成位数相等的几部分，其中最后一部分可以比较短。然后将这几部分相加，舍弃最高进位后的结果就是该关键字的哈希地址。

- 平方取中法：如果关键字各个部分分布都不均匀的话，可以先求出它的平方值，然后按照需求取中间的几位作为哈希地址。

- 伪随机数法：采用一个伪随机数当作哈希函数。

常见的解决碰撞的方法有以下几种：

- 开放定址法：
> 开放定址法就是一旦发生了冲突，就去寻找下一个空的散列地址，只要散列表足够大，空的散列地址总能找到，并将记录存入。
- 链地址法
> 将哈希表的每个单元作为链表的头结点，所有哈希地址为i的元素构成一个同义词链表。即发生冲突时就把该关键字链在以该单元为头结点的链表的尾部。
- 再哈希法
> 当哈希地址发生冲突用其他的函数计算另一个哈希函数地址，直到冲突不再产生为止。
- 建立公共溢出区
> 将哈希表分为基本表和溢出表两部分，发生冲突的元素都放入溢出表中。


### HashMap
数据结构为数组加链表
![](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/640.png)

### HashMap in Java 7

```
final int hash(Object k) {

    int h = hashSeed;
    
    if (0 != h && k instanceof String) {
        return sun.misc.Hashing.stringHash32((String) k);
    
    }
    
     
    h ^= k.hashCode();
    
    h ^= (h >>> 20) ^ (h >>> 12);
    
    return h ^ (h >>> 7) ^ (h >>> 4);

}

 
static int indexFor(int h, int length) {

    return h & (length-1);

}
```

其中**return h & (length-1)**就是取余操作。

Java之所有使用位运算(&)来代替取模运算(%)，最主要的考虑就是效率。位运算(&)效率要比代替取模运算(%)高很多，主要原因是位运算直接对内存数据进行操作，不需要转成十进制，因此处理速度非常快。

```
X % 2^n = X & (2^n – 1)

2^n表示2的n次方，也就是说，一个数对2^n取模 == 一个数和(2^n – 1)做按位与运算 。

假设n为3，则2^3 = 8，表示成2进制就是1000。2^3 = 7 ，即0111。

此时X & (2^3 – 1) 就相当于取X的2进制的最后三位数。

从2进制角度来看，X / 8相当于 X >> 3，即把X右移3位，此时得到了X / 8的商，而被移掉的部分(后三位)，则是X % 8，也就是余数。
```

所以，return h & (length-1);只要保证length的长度是2^n的话，就可以实现取模运算了。而HashMap中的length也确实是2的倍数，初始值是16，之后每次扩充为原来的2倍。

---

再说碰撞问题
![](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/20200528181833.png)

不同的key，indexOf的结果都一样，这就发生了碰撞。

上面代码是这么处理的：

```
h ^= k.hashCode();

h ^= (h >>> 20) ^ (h >>> 12);

return h ^ (h >>> 7) ^ (h >>> 4);
```

这段代码是为了对key的hashCode进行扰动计算，防止不同hashCode的高位不同但低位相同导致的hash冲突。简单点说，就是为了把高位的特征和低位的特征组合起来，降低哈希冲突的概率，也就是说，尽量做到任何一位的变化都能对最终得到的结果产生影响。


### HashTable In Java 7
```
private int hash(Object k) {

// hashSeed will be zero if alternative hashing is disabled.

return hashSeed ^ k.hashCode();

}
```

可以看到只是简单做了hash，并且没有index方法，取而代之的是```int index = (hash & 0x7FFFFFFF) % tab.length```这段代码，按位与0x7FFFFFFF的原因是为了获取一个正数。

为什么直接进行取模操作？

```
HashTable默认的初始大小为11，之后每次扩充为原来的2n+1。

也就是说，HashTable的链表数组的默认大小是一个素数、奇数。之后的每次扩充结果也都是奇数。

由于HashTable会尽量使用素数、奇数作为容量的大小。当哈希表的大小为素数时，简单的取模哈希的结果会更加均匀。
```

### ConcurrentHashMap in Java 7
```
private int hash(Object k) {

    int h = hashSeed;
    
     
    if ((0 != h) && (k instanceof String)) {
    
        return sun.misc.Hashing.stringHash32((String) k);
    
    }

 
    h ^= k.hashCode();
    
     
    // Spread bits to regularize both segment and index locations,
    
    // using variant of single-word Wang/Jenkins hash.
    
    h += (h << 15) ^ 0xffffcd7d;
    
    h ^= (h >>> 10);
    
    h += (h << 3);
    
    h ^= (h >>> 6);
    
    h += (h << 2) + (h << 14);
    
    return h ^ (h >>> 16);

}

int j = (hash >>> segmentShift) & segmentMask;
```

### in Java 8
Java 8 的HashMap数据结构使用了平衡树，ConcurrentHashMap使用了红黑树，hash的原理与java7一致，实现方法上有区别


[传送门](https://blog.csdn.net/qq_33296156/article/details/82428026)