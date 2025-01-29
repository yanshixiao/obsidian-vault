---
author: yuanshuai
created: 2021-10-15 11:02:47
aliases: 
description:
tags: [基础, Java]
---


一. Java 创建线程的三种方式
=================

Java 中创建线程主要有三种方式：  
1. 继承 Thread 类  
2. 实现 Runnable 接口  
3. 使用 Callable 和 Future

1. 继承 Thead 类创建线程
-----------------

（1）继承 Thread 类并重写 run 方法  
（2）创建线程对象  
（3）调用该线程对象的 start() 方法来启动线程

```
public class CreateThreadTest {
    public static void main(String[] args) {
        new ThreadTest().start();
        new ThreadTest().start();
    }
}

class ThreadTest extends Thread{
    private int i = 0;

    @Override
    public void run() {
        for (; i < 100; i++) {
            System.out.println(Thread.currentThread().getName() + " is running: " + i);
        }
    }
}
```

2. 实现 Runnable 接口创建线程
---------------------

（1）定义一个类实现 Runnable 接口，并重写该接口的 run() 方法  
（2）创建 Runnable 实现类的对象，作为创建 Thread 对象的 target 参数，此 Thread 对象才是真正的线程对象  
（3）调用线程对象的 start() 方法来启动线程

```
public class CreateThreadTest {
    public static void main(String[] args) {
        RunnableTest runnableTest = new RunnableTest();
        new Thread(runnableTest, "线程1").start();
        new Thread(runnableTest, "线程2").start();
    }
}

class RunnableTest implements Runnable{
    private int i = 0;

    @Override
    public void run() {
        for (; i < 100; i++) {
            System.out.println(Thread.currentThread().getName()  + " is running: " + i);
        }
    }
}
```

3. 使用 Callable 和 Future 创建线程
----------------------------

和 Runnable 接口不一样，Callable 接口提供了一个 call() 方法作为线程执行体，call() 方法比 run() 方法功能要强大：call() 方法可以有返回值，可以声明抛出异常。

```
public interface Callable<V> {
    V call() throws Exception;
}
```

Java5 提供了 Future 接口来接收 Callable 接口中 call() 方法的返回值。  
Callable 接口是 Java5 新增的接口，不是 Runnable 接口的子接口，所以 Callable 对象不能直接作为 Thread 对象的 target。针对这个问题，引入了 RunnableFuture 接口，RunnableFuture 接口是 Runnable 接口和 Future 接口的子接口，可以作为 Thread 对象的 target 。同时，Java5 提供了一个 RunnableFuture 接口的实现类：FutureTask ，FutureTask 可以作为 Thread 对象的 target。

![](http://upload-images.jianshu.io/upload_images/3072290-877afd6489b5f7a7.png) FutureTask 类继承关系

介绍了相关概念之后，使用 Callable 和 Future 创建线程的步骤如下：  
（1）定义一个类实现 Callable 接口，并重写 call() 方法，该 call() 方法将作为线程执行体，并且有返回值  
（2）创建 Callable 实现类的实例，使用 FutureTask 类来包装 Callable 对象  
（3）使用 FutureTask 对象作为 Thread 对象的 target 创建并启动线程  
（4）调用 FutureTask 对象的 get() 方法来获得子线程执行结束后的返回值

```
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

public class CreateThreadTest {
    public static void main(String[] args) {
        CallableTest callableTest = new CallableTest();
        FutureTask<Integer> futureTask = new FutureTask<>(callableTest);
        new Thread(futureTask).start();
        try {
            System.out.println("子线程的返回值: " + futureTask.get());
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
    }
}

class CallableTest implements Callable{

    @Override
    public Integer call() throws Exception {
        int sum = 0;
        for (int i = 1; i < 101; i++) {
            sum += i;
        }
        System.out.println(Thread.currentThread().getName() + " is running: " + sum);
        return sum;
    }
}
```

二. 创建线程的三种方式的对比
===============

1. 实现 Runnable/Callable 接口相比继承 Thread 类的优势
------------------------------------------

（1）适合多个线程进行资源共享  
（2）可以避免 java 中单继承的限制  
（3）增加程序的健壮性，代码和数据独立  
（4）线程池只能放入 Runable 或 Callable 接口实现类，不能直接放入继承 Thread 的类

2.Callable 和 Runnable 的区别
-------------------------

(1) Callable 重写的是 call() 方法，Runnable 重写的方法是 run() 方法  
(2) call() 方法执行后可以有返回值，run() 方法没有返回值  
(3) call() 方法可以抛出异常，run() 方法不可以  
(4) 运行 Callable 任务可以拿到一个 Future 对象，表示异步计算的结果 。通过 Future 对象可以了解任务执行情况，可取消任务的执行，还可获取执行结果