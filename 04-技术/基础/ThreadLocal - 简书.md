> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [www.jianshu.com](https://www.jianshu.com/p/3c5d7f09dfbd)

> Don't forget, a person's greatest emotional need is to feel appreciated.  
> 莫忘记，人类情感上最大的需要是感恩。

在阅读 Handler 源码时发现了这么一个东西，本想直混在其他博客中一笔带过，但仔细想了下这个东西还是蛮重要的，于是开了这篇博客。

#### ThreadLocal

threadlocal 使用方法很简单

```
static final ThreadLocal<T> sThreadLocal = new ThreadLocal<T>();
sThreadLocal.set()
sThreadLocal.get()


```

threadlocal 而是一个线程内部的存储类，可以在指定线程内存储数据，数据存储以后，只有指定线程可以得到存储数据，官方解释如下。

```
/**
 * This class provides thread-local variables.  These variables differ from
 * their normal counterparts in that each thread that accesses one (via its
 * {@code get} or {@code set} method) has its own, independently initialized
 * copy of the variable.  {@code ThreadLocal} instances are typically private
 * static fields in classes that wish to associate state with a thread (e.g.,
 * a user ID or Transaction ID).
 */


```

大致意思就是 ThreadLocal 提供了线程内存储变量的能力，这些变量不同之处在于每一个线程读取的变量是对应的互相独立的。通过 get 和 set 方法就可以得到当前线程对应的值。

做个不恰当的比喻，从表面上看 ThreadLocal 相当于维护了一个 map，key 就是当前的线程，value 就是需要存储的对象。

**这里的这个比喻是不恰当的，实际上是 ThreadLocal 的静态内部类 ThreadLocalMap 为每个 Thread 都维护了一个数组 table，ThreadLocal 确定了一个数组下标，而这个下标就是 value 存储的对应位置。**。

作为一个存储数据的类，关键点就在 get 和 set 方法。

```
//set 方法
public void set(T value) {
      //获取当前线程
      Thread t = Thread.currentThread();
      //实际存储的数据结构类型
      ThreadLocalMap map = getMap(t);
      //如果存在map就直接set，没有则创建map并set
      if (map != null)
          map.set(this, value);
      else
          createMap(t, value);
  }
  
//getMap方法
ThreadLocalMap getMap(Thread t) {
      //thred中维护了一个ThreadLocalMap
      return t.threadLocals;
 }
 
//createMap
void createMap(Thread t, T firstValue) {
      //实例化一个新的ThreadLocalMap，并赋值给线程的成员变量threadLocals
      t.threadLocals = new ThreadLocalMap(this, firstValue);
}


```

从上面代码可以看出**每个线程持有一个 ThreadLocalMap 对象**。每一个新的线程 Thread 都会实例化一个 ThreadLocalMap 并赋值给成员变量 threadLocals，使用时若已经存在 threadLocals 则直接使用已经存在的对象。

#### Thread

```
/* ThreadLocal values pertaining to this thread. This map is maintained
     * by the ThreadLocal class. */
    ThreadLocal.ThreadLocalMap threadLocals = null;


```

Thread 中关于 ThreadLocalMap 部分的相关声明，接下来看一下 createMap 方法中的实例化过程。

#### ThreadLocalMap

##### set 方法

```
//Entry为ThreadLocalMap静态内部类，对ThreadLocal的若引用
//同时让ThreadLocal和储值形成key-value的关系
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
           super(k);
            value = v;
    }
}

//ThreadLocalMap构造方法
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
        //内部成员数组，INITIAL_CAPACITY值为16的常量
        table = new Entry[INITIAL_CAPACITY];
        //位运算，结果与取模相同，计算出需要存放的位置
        //threadLocalHashCode比较有趣
        int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
        table[i] = new Entry(firstKey, firstValue);
        size = 1;
        setThreshold(INITIAL_CAPACITY);
}


```

通过上面的代码不难看出在实例化 ThreadLocalMap 时创建了一个长度为 16 的 Entry 数组。通过 hashCode 与 length 位运算确定出一个索引值 i，这个 i 就是被存储在 table 数组中的位置。

前面讲过每个线程 Thread 持有一个 ThreadLocalMap 类型的实例 threadLocals，结合此处的构造方法可以理解成每个线程 Thread 都持有一个 Entry 型的数组 table，而一切的读取过程都是通过操作这个数组 table 完成的。

_显然 table 是 set 和 get 的焦点，在看具体的 set 和 get 方法前，先看下面这段代码。_

```
//在某一线程声明了ABC三种类型的ThreadLocal
ThreadLocal<A> sThreadLocalA = new ThreadLocal<A>();
ThreadLocal<B> sThreadLocalB = new ThreadLocal<B>();
ThreadLocal<C> sThreadLocalC = new ThreadLocal<C>();


```

由前面我们知道对于一个 Thread 来说只有持有一个 ThreadLocalMap，所以 ABC 对应同一个 ThreadLocalMap 对象。为了管理 ABC，于是将他们存储在一个数组的不同位置，而这个数组就是上面提到的 Entry 型的数组 table。

那么问题来了，ABC 在 table 中的位置是如何确定的？为了能正常够正常的访问对应的值，肯定存在一种方法计算出确定的索引值 i，show me code。

```
  //ThreadLocalMap中set方法。
  private void set(ThreadLocal<?> key, Object value) {

            // We don't use a fast path as with get() because it is at
            // least as common to use set() to create new entries as
            // it is to replace existing ones, in which case, a fast
            // path would fail more often than not.

            Entry[] tab = table;
            int len = tab.length;
            //获取索引值，这个地方是比较特别的地方
            int i = key.threadLocalHashCode & (len-1);

            //遍历tab如果已经存在则更新值
            for (Entry e = tab[i];
                 e != null;
                 e = tab[i = nextIndex(i, len)]) {
                ThreadLocal<?> k = e.get();

                if (k == key) {
                    e.value = value;
                    return;
                }

                if (k == null) {
                    replaceStaleEntry(key, value, i);
                    return;
                }
            }
            
            //如果上面没有遍历成功则创建新值
            tab[i] = new Entry(key, value);
            int sz = ++size;
            //满足条件数组扩容x2
            if (!cleanSomeSlots(i, sz) && sz >= threshold)
                rehash();
        }


```

在 ThreadLocalMap 中的 set 方法与构造方法能看到以下代码片段。

*   `int i = key.threadLocalHashCode & (len-1)`
*   `int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1)`  
    简而言之就是将 threadLocalHashCode 进行一个位运算（取模）得到索引 i，threadLocalHashCode 代码如下。

```
    //ThreadLocal中threadLocalHashCode相关代码.
    
    private final int threadLocalHashCode = nextHashCode();

    /**
     * The next hash code to be given out. Updated atomically. Starts at
     * zero.
     */
    private static AtomicInteger nextHashCode =
        new AtomicInteger();

    /**
     * The difference between successively generated hash codes - turns
     * implicit sequential thread-local IDs into near-optimally spread
     * multiplicative hash values for power-of-two-sized tables.
     */
    private static final int HASH_INCREMENT = 0x61c88647;

    /**
     * Returns the next hash code.
     */
    private static int nextHashCode() {
        //自增
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }


```

因为 static 的原因，在每次`new ThreadLocal`时因为 threadLocalHashCode 的初始化，会使 threadLocalHashCode 值自增一次，增量为 0x61c88647。

0x61c88647 是斐波那契散列乘数, 它的优点是通过它散列 (hash) 出来的结果分布会比较均匀，可以很大程度上避免 hash 冲突，已初始容量 16 为例，hash 并与 15 位运算计算数组下标结果如下：

<table><thead><tr><th>hashCode</th><th>数组下标</th></tr></thead><tbody><tr><td>0x61c88647</td><td>7</td></tr><tr><td>0xc3910c8e</td><td>14</td></tr><tr><td>0x255992d5</td><td>5</td></tr><tr><td>0x8722191c</td><td>12</td></tr><tr><td>0xe8ea9f63</td><td>3</td></tr><tr><td>0x4ab325aa</td><td>10</td></tr><tr><td>0xac7babf1</td><td>1</td></tr><tr><td>0xe443238</td><td>8</td></tr><tr><td>0x700cb87f</td><td>15</td></tr></tbody></table>

总结如下：

1.  对于某一 ThreadLocal 来讲，他的索引值 i 是确定的，在不同线程之间访问时访问的是不同的 table 数组的同一位置即都为 table[i]，只不过这个不同线程之间的 table 是独立的。
2.  对于同一线程的不同 ThreadLocal 来讲，这些 ThreadLocal 实例共享一个 table 数组，然后每个 ThreadLocal 实例在 table 中的索引 i 是不同的。

##### get() 方法

```
//ThreadLocal中get方法
public T get() {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null) {
            @SuppressWarnings("unchecked")
            T result = (T)e.value;
            return result;
        }
    }
    return setInitialValue();
}
    
//ThreadLocalMap中getEntry方法
private Entry getEntry(ThreadLocal<?> key) {
       int i = key.threadLocalHashCode & (table.length - 1);
       Entry e = table[i];
       if (e != null && e.get() == key)
            return e;
       else
            return getEntryAfterMiss(key, i, e);
   }


```

理解了 set 方法，get 方法也就清楚明了，无非是通过计算出索引直接从数组对应位置读取即可。

ThreadLocal 实现主要涉及 Thread，ThreadLocal，ThreadLocalMap 这三个类。关于 ThreadLocal 的实现流程正如上面写的那样，实际代码还有许多细节处理的部分并没有在这里写出来。

#### ThreadLocal 特性

ThreadLocal 和 Synchronized 都是为了解决多线程中相同变量的访问冲突问题，不同的点是

*   Synchronized 是通过线程等待，牺牲时间来解决访问冲突
*   ThreadLocal 是通过每个线程单独一份存储空间，牺牲空间来解决冲突，并且相比于 Synchronized，ThreadLocal 具有线程隔离的效果，只有在线程内才能获取到对应的值，线程外则不能访问到想要的值。

正因为 ThreadLocal 的线程隔离特性，使他的应用场景相对来说更为特殊一些。在 android 中 Looper、ActivityThread 以及 AMS 中都用到了 ThreadLocal。当某些数据是以线程为作用域并且不同线程具有不同的数据副本的时候，就可以考虑采用 ThreadLocal。