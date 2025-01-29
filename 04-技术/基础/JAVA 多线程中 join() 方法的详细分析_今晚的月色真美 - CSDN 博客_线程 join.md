> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [blog.csdn.net](https://blog.csdn.net/u013425438/article/details/80205693)

虽然关于讨论线程 join() 方法的博客已经非常极其特别多了，但是前几天我有一个困惑却没有能够得到详细解释，就是当系统中正在运行多个线程时，join() 到底是暂停了哪些线程，大部分博客给的例子看起来都像是 t.join() 方法会使所有线程都暂停并等待 t 的执行完毕。当然，这也是因为我对多线程中的各种方法和同步的概念都理解的不是很透彻。通过看别人的分析和自己的实践之后终于想明白了，详细解释一下希望能帮助到和我有相同困惑的同学。

首先给出结论：t.join()方法只会使主线程 (或者说调用 t.join() 的线程)进入等待池并等待 t 线程执行完毕后才会被唤醒。并不影响同一时刻处在运行状态的其他线程。

下面则是分析过程。

之前对于 join() 方法只是了解它能够使得 t.join() 中的 t 优先执行，当 t 执行完后才会执行其他线程。能够使得线程之间的并行执行变成串行执行。

```
package CSDN;
public class TestJoin {
 
	public static void main(String[] args) throws InterruptedException {
		// TODO Auto-generated method stub
		ThreadTest t1=new ThreadTest("A");
		ThreadTest t2=new ThreadTest("B");
		t1.start();
		t2.start();
	}
 
 
}
class ThreadTest extends Thread {
	private String name;
	public ThreadTest(String name){
		this.name=name;
	}
	public void run(){
		for(int i=1;i<=5;i++){
				System.out.println(name+"-"+i);
		}		
	}
}
```

运行结果：

```
A-1
B-1
B-2
B-3
A-2
B-4
A-3
B-5
A-4
A-5
```

可以看出 A 线程和 B 线程是交替执行的。

而在其中加入 join() 方法后 (后面的代码都略去了 ThreadTest 类的定义)

```
package CSDN;
public class TestJoin {
 
	public static void main(String[] args) throws InterruptedException {
		// TODO Auto-generated method stub
		ThreadTest t1=new ThreadTest("A");
		ThreadTest t2=new ThreadTest("B");
		t1.start();
		t1.join();
		t2.start();
	}
}
```

运行结果：

```
A-1
A-2
A-3
A-4
A-5
B-1
B-2
B-3
B-4
B-5
```

显然，使用 t1.join() 之后，B 线程需要等 A 线程执行完毕之后才能执行。需要注意的是，t1.join() 需要等 t1.start() 执行之后执行才有效果，此外，如果 t1.join() 放在 t2.start() 之后的话，仍然会是交替执行，然而并不是没有效果，这点困扰了我很久，也没在别的博客里看到过。

为了深入理解，我们先看一下 join() 的源码。

```
    /**
     * Waits for this thread to die.
     *
     * <p> An invocation of this method behaves in exactly the same
     * way as the invocation
     *
     * <blockquote>
     * {@linkplain #join(long) join}{@code (0)}
     * </blockquote>
     *
     * @throws  InterruptedException
     *          if any thread has interrupted the current thread. The
     *          <i>interrupted status</i> of the current thread is
     *          cleared when this exception is thrown.
     */
    public final void join() throws InterruptedException {
        join(0);            //join()等同于join(0)
    }
    /**
     * Waits at most {@code millis} milliseconds for this thread to
     * die. A timeout of {@code 0} means to wait forever.
     *
     * <p> This implementation uses a loop of {@code this.wait} calls
     * conditioned on {@code this.isAlive}. As a thread terminates the
     * {@code this.notifyAll} method is invoked. It is recommended that
     * applications not use {@code wait}, {@code notify}, or
     * {@code notifyAll} on {@code Thread} instances.
     *
     * @param  millis
     *         the time to wait in milliseconds
     *
     * @throws  IllegalArgumentException
     *          if the value of {@code millis} is negative
     *
     * @throws  InterruptedException
     *          if any thread has interrupted the current thread. The
     *          <i>interrupted status</i> of the current thread is
     *          cleared when this exception is thrown.
     */
    public final synchronized void join(long millis) throws InterruptedException {
        long base = System.currentTimeMillis();
        long now = 0;
 
        if (millis < 0) {
            throw new IllegalArgumentException("timeout value is negative");
        }
 
        if (millis == 0) {
            while (isAlive()) {
                wait(0);           //join(0)等同于wait(0)，即wait无限时间直到被notify
            }
        } else {
            while (isAlive()) {
                long delay = millis - now;
                if (delay <= 0) {
                    break;
                }
                wait(delay);
                now = System.currentTimeMillis() - base;
            }
        }
    }
```

可以看出，join() 方法的底层是利用 wait() 方法实现的。可以看出，join 方法是一个同步方法，当主线程调用 t1.join() 方法时，主线程先获得了 t1 对象的锁，随后进入方法，调用了 t1 对象的 wait() 方法，使主线程进入了 t1 对象的等待池，此时，A 线程则还在执行，并且随后的 t2.start() 还没被执行，因此，B 线程也还没开始。等到 A 线程执行完毕之后，主线程继续执行，走到了 t2.start()，B 线程才会开始执行。

此外，对于 join() 的位置和作用的关系，我们可以用下面的例子来分析

```
package CSDN;
 
public class TestJoin {
 
	public static void main(String[] args) throws InterruptedException {
		// TODO Auto-generated method stub
		System.out.println(Thread.currentThread().getName()+" start");
		ThreadTest t1=new ThreadTest("A");
		ThreadTest t2=new ThreadTest("B");
		ThreadTest t3=new ThreadTest("C");
		System.out.println("t1start");
		t1.start();
		System.out.println("t2start");
		t2.start();
		System.out.println("t3start");
		t3.start();
		System.out.println(Thread.currentThread().getName()+" end");
	}
 
}
```

运行结果为

```
main start
t1start
t1end
t2start
t2end
t3start
t3end
A-1
A-2
main end
C-1
C-2
C-3
C-4
C-5
A-3
B-1
B-2
B-3
B-4
B-5
A-4
A-5
```

A、B、C 和主线程交替运行。加入 join() 方法后

```
package CSDN;
 
public class TestJoin {
 
	public static void main(String[] args) throws InterruptedException {
		// TODO Auto-generated method stub
		System.out.println(Thread.currentThread().getName()+" start");
		ThreadTest t1=new ThreadTest("A");
		ThreadTest t2=new ThreadTest("B");
		ThreadTest t3=new ThreadTest("C");
		System.out.println("t1start");
		t1.start();
		System.out.println("t1end");
		System.out.println("t2start");
		t2.start();
		System.out.println("t2end");
		t1.join();
		System.out.println("t3start");
		t3.start();
		System.out.println("t3end");
		System.out.println(Thread.currentThread().getName()+" end");
	}
 
}
```

运行结果：

```
main start
t1start
t1end
t2start
t2end
A-1
B-1
A-2
A-3
A-4
A-5
B-2
t3start
t3end
B-3
main end
B-4
B-5
C-1
C-2
C-3
C-4
C-5
```

多次实验可以看出，主线程在 t1.join() 方法处停止，并需要等待 A 线程执行完毕后才会执行 t3.start()，然而，并不影响 B 线程的执行。因此，可以得出结论，t.join() 方法只会使主线程进入等待池并等待 t 线程执行完毕后才会被唤醒。并不影响同一时刻处在运行状态的其他线程。

PS:join 源码中，只会调用 wait 方法，并没有在结束时调用 notify，这是因为线程在 die 的时候会自动调用自身的 notifyAll 方法，来释放所有的资源和锁。