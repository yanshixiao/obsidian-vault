Java 循环删除 List 元素正确方法！_
========================================


----

```
package com.test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * 
 * @Description: List的正确删除remove的姿势
 * @ClassName: ListRemoveTest.java
 * @author ChenYongJia
 * @Date 2019年7月3日 12:25
 * @Email chen87647213@163.com
 */
public class ListRemoveTest {

	public static void main(String[] args) {

		/**
		 * 先声明一个集合
		 */
		List<String> list = new ArrayList<>(Arrays.asList("c1", "cy2", "c3", "cy4", "c5", "cy6", "c7", "cy8", "c9"));
		
		/**
		 * 正确的删除方式
		 * 通过 CopyOnWriteArrayList 解决了 List的并发问题。每次remove的都是复制出的list
		 */
		final CopyOnWriteArrayList<String> cowList = new CopyOnWriteArrayList<String>(list);
        for (String item : cowList) {
            if (item.equals("y")) {
                cowList.remove(item);
            }
        }
        
        System.out.print(cowList+"\n");

		/**
		 * 报错 java.util.ConcurrentModificationException
		 */
		for (String str : list) {
			if (str.contains("y")) {
				list.remove(str);
			}
		}
		
		System.out.print(list+"\n");

		/**
		 * 报错：下标越界 java.lang.IndexOutOfBoundsException
		 */
		int size = list.size();
		for (int i = 0; i < size; i++) {
			String str = list.get(i);
			if (str.contains("y")) {
				list.remove(i);
			}
		}

		System.out.print(list+"\n");
		
		/**
		 * 正常删除，每次调用size方法，损耗性能，不推荐
		 */
		for (int i = 0; i < list.size(); i++) {
			String str = list.get(i);
			if (str.contains("y")) {
				list.remove(i);
			}
		}

		System.out.print(list+"\n");
		
		/**
		 * 正常删除，推荐使用
		 */
		for (Iterator<String> ite = list.iterator(); ite.hasNext();) {
			String str = ite.next();
			if (str.contains("y")) {
				ite.remove();
			}
		}

		System.out.print(list+"\n");
		
		/**
		 * 报错 java.util.ConcurrentModificationException
		 */
		for (Iterator<String> ite = list.iterator(); ite.hasNext();) {
			String str = ite.next();
			if (str.contains("y")) {
				list.remove(str);
			}
		}

		System.out.print(list+"\n");
		
	}

}
```

##### _以下解释对应上述代码_

> *   for 循环遍历 list  
>       
>     这种方式的问题在于，删除某个元素后，list 的大小发生了变化，而你的索引也在变化，所以会导致你在遍历的时候漏掉某些元素。比如当你删除第 1 个元素后，继续根据索引访问第 2 个元素时，因为删除的关系后面的元素都往前移动了一位，所以实际访问的是第 3 个元素。因此，这种方式可以用在删除特定的一个元素时使用，但不适合循环删除多个元素时使用。

> *   增强 for 循环  
>       
>     这种方式的问题在于，删除元素后继续循环会报错误信息 ConcurrentModificationException，因为元素在使用的时候发生了并发的修改，导致异常抛出。但是删除完毕马上使用 break 跳出，则不会触发报错。

> *   iterator 遍历  
>       
>     这种方式可以正常的循环及删除。但要注意的是，使用 iterator 的 remove 方法，如果用 list 的 remove 方法同样会报上面提到的 ConcurrentModificationException 错误，所以使用 iterator 的 remove 方法才是正解。

> *   小结  
>       
>     （1）循环删除 list 中特定一个元素的，可以使用三种方式中的任意一种，但在使用中要注意上面分析的各个问题。  
>       
>     （2）循环删除 list 中多个元素的，应该使用迭代器 iterator 方式。

#### _继续分析_

_**报异常 IndexOutOfBoundsException 我们很理解，是动态删除了元素导致数组下标越界了。**_

> *   _**那 ConcurrentModificationException 呢？**_

其中, for(xx in xx) 是增强的 for 循环，即迭代器 Iterator 的加强实现，其内部是调用的 Iterator 的方法，为什么会报 ConcurrentModificationException 错误，我们来看下源码

![](https://img-blog.csdnimg.cn/20190703130832408.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yc19jaGVucw==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20190703130751356.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yc19jaGVucw==,size_16,color_FFFFFF,t_70)  
![](https://img-blog.csdnimg.cn/2019070313085611.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yc19jaGVucw==,size_16,color_FFFFFF,t_70)

*   通过代码我们发现 Itr 是 ArrayList 中定义的一个私有内部类，
    
*   在 next、remove 方法中都会调用 checkForComodification 方法，该方法的作用是判断 modCount != expectedModCount 是否相等，如果不相等则抛出 ConcurrentModificationException 异常。
    
*   每次正常执行 remove 方法后，都会对执行 expectedModCount = modCount 赋值，保证两个值相等，那么问题基本上已经清晰了，在 foreach 循环中执行 list.remove(item);，对 list 对象的 modCount 值进行了修改，而 list 对象的迭代器的 expectedModCount 值未进行修改，因此抛出了 ConcurrentModificationException 异常。
    

_**取下个元素的时候都会去判断要修改的数量和期待修改的数量是否一致，不一致则会报错，而通过迭代器本身调用 remove 方法则不会有这个问题，因为它删除的时候会把这两个数量同步，而 list 则不然。搞清楚它是增加的 for 循环就不难理解其中的奥秘了。**_

_**List 源码如下**_

![](https://img-blog.csdnimg.cn/20190703131026953.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L01yc19jaGVucw==,size_16,color_FFFFFF,t_70)
