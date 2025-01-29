---

UID: 20241221234741 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-12-21
---

**fail-fast** 机制是 Java 集合（Collection）中的一种错误机制。当多个线程对同一个集合的内容进行
操作时，就可能会产生 fail-fast 事件。

例如：当某一个线程 A 通过 iterator 去遍历某集合的过程中，若该集合的内容被其他线程所改变
了，那么线程 A 访问集合时，就会抛出<font color="#9bbb59">ConcurrentModificationException</font> 异常，产生 fail-fast 事
件。这里的操作主要是指 add、remove 和 clear，对集合元素个数进行修改。

**解决办法**：建议使用“java.util.concurrent 包下的类”去取代“java.util 包下的类”。

可以这么理解：在遍历之前，把 modCount（修改计数器）和expectModCount记下来，后面expectModCount 去和 modCount 进行比较，如果不相等了，证明已并发了，被修改了，于是抛出
ConcurrentModificationException 异常。


> [!note] 
> 单线程下也会出现这种情况，通常是使用了List的remove而非iterator的remove方法

我们通常说的Java中的fail-fast机制，默认指的是Java集合中的一种错误检测机制，当多个线程对集合进行结构性的改变时，有可能会出发fail-fast机制，这个时候会抛出ConcurrentModificationException异常。很多时候单线程环境下也会出发这个异常，导致我们摸不着头脑，接下来具体分析一下：

当使用foreach遍历集合时对集合元素进行add / remove时，就会抛出ConcurrentModificationException。
```java
for(String str : list){
    if(str.equals("haha")){
        list.remove(str);   //抛出异常
    }
}
```
在对错误分析之前，我们先对foreach进行解语法糖，进行反编译，可以得到以下代码：
```java
Iterator iterator = userNames.iterator();
do
{
    if(!iterator.hasNext())
        break;
    String userName = (String)iterator.next();
    if(userName.equals("Jobs"))
        userNames.remove(userName);
} while(true);
```
可以看到，foreach底层实际上是利用iterator和while循环实现的。

发生异常的的代码是iterator的next方法，该方法中调用了checkForComodification（）方法：

```java
final void checkForComodification() {
    if (modCount != expectedModCount)
        throw new ConcurrentModificationException();
}
```

可以发现，问题出现在于当modCount 和 expectedModCount 不相等时，就会抛出异常。那么什么是modCount ，什么是expectedModCount ，为什么remove操作会导致这两个变量不相等呢？
3. 原因分析
modCount是ArrayList中的一个成员变量，它表示集合实际被修改的次数，当ArrayList被创建时就存在了，初始值为0。

expectedModCount 是iterator中的一个成员变量，而iterator是ArrayList的一个内部类，当ArrayList调用iterator（）方法获取一个迭代器时，会创建一个iterator，并且将expectedModCount 初始化为modCount的值。只有该迭代器修改了集合，expectedModCount 才会修改。

那么，接下来我们来分析，remove操作发生了什么？
```java
private void fastRemove(int index) {
    modCount++;
    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
    elementData[--size] = null; // clear to let GC do its work
}
```

可以发现，集合的remove操作只修改了modCount，而没有修改expectedModCount ，这就导致了modCount和expectedModCount 不一致。



