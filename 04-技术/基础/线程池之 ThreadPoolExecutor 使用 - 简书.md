> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [www.jianshu.com](https://www.jianshu.com/p/f030aa5d7a28)

ThreadPoolExecutor 提供了四个构造方法：

![](http://upload-images.jianshu.io/upload_images/11183270-47fdeae96bf0213d.png) ThreadPoolExecutor 构造方法. png

我们以最后一个构造方法（参数最多的那个），对其参数进行解释：

```
 public ThreadPoolExecutor(int corePoolSize, // 1
                              int maximumPoolSize,  // 2
                              long keepAliveTime,  // 3
                              TimeUnit unit,  // 4
                              BlockingQueue<Runnable> workQueue, // 5
                              ThreadFactory threadFactory,  // 6
                              RejectedExecutionHandler handler ) { //7
        if (corePoolSize < 0 ||
            maximumPoolSize <= 0 ||
            maximumPoolSize < corePoolSize ||
            keepAliveTime < 0)
            throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null)
            throw new NullPointerException();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }


```

<table><thead><tr><th>序号</th><th>名称</th><th>类型</th><th>含义</th></tr></thead><tbody><tr><td>1</td><td>corePoolSize</td><td>int</td><td>核心线程池大小</td></tr><tr><td>2</td><td>maximumPoolSize</td><td>int</td><td>最大线程池大小</td></tr><tr><td>3</td><td>keepAliveTime</td><td>long</td><td>线程最大空闲时间</td></tr><tr><td>4</td><td>unit</td><td>TimeUnit</td><td>时间单位</td></tr><tr><td>5</td><td>workQueue</td><td>BlockingQueue&lt;Runnable&gt;</td><td>线程等待队列</td></tr><tr><td>6</td><td>threadFactory</td><td>ThreadFactory</td><td>线程创建工厂</td></tr><tr><td>7</td><td>handler</td><td>RejectedExecutionHandler</td><td>拒绝策略</td></tr></tbody></table>

如果对这些参数作用有疑惑的请看 [ThreadPoolExecutor 概述](https://www.jianshu.com/p/c41e942bcd64)。  
知道了各个参数的作用后，我们开始构造符合我们期待的线程池。首先看 JDK 给我们预定义的几种线程池：

##### 一、预定义线程池

1.  **FixedThreadPool**

```
    public static ExecutorService newFixedThreadPool(int nThreads) {
        return new ThreadPoolExecutor(nThreads, nThreads,
                                      0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>());
    }


```

> *   corePoolSize 与 maximumPoolSize 相等，即其线程全为核心线程，是一个固定大小的线程池，是其优势；
> *   keepAliveTime = 0 该参数默认对核心线程无效，而 FixedThreadPool 全部为核心线程；
> *   workQueue 为 LinkedBlockingQueue（无界阻塞队列），队列最大值为 Integer.MAX_VALUE。如果任务提交速度持续大余任务处理速度，会造成队列大量阻塞。因为队列很大，很有可能在拒绝策略前，内存溢出。是其劣势；
> *   FixedThreadPool 的任务执行是无序的；

适用场景：可用于 Web 服务瞬时削峰，但需注意长时间持续高峰情况造成的队列阻塞。

2.  **CachedThreadPool**

```
     public static ExecutorService newCachedThreadPool() {
        return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                      60L, TimeUnit.SECONDS,
                                      new SynchronousQueue<Runnable>());
    }


```

> *   corePoolSize = 0，maximumPoolSize = Integer.MAX_VALUE，即线程数量几乎无限制；
> *   keepAliveTime = 60s，线程空闲 60s 后自动结束。
> *   workQueue 为 SynchronousQueue 同步队列，这个队列类似于一个接力棒，入队出队必须同时传递，因为 CachedThreadPool 线程创建无限制，不会有队列等待，所以使用 SynchronousQueue；

适用场景：快速处理大量耗时较短的任务，如 Netty 的 NIO 接受请求时，可使用 CachedThreadPool。

3.  **SingleThreadExecutor**

```
    public static ExecutorService newSingleThreadExecutor() {
        return new FinalizableDelegatedExecutorService
            (new ThreadPoolExecutor(1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>()));
    }


```

咋一瞅，不就是 newFixedThreadPool(1) 吗？定眼一看，这里多了一层 FinalizableDelegatedExecutorService 包装，这一层有什么用呢，写个 dome 来解释一下：

```
    public static void main(String[] args) {
        ExecutorService fixedExecutorService = Executors.newFixedThreadPool(1);
        ThreadPoolExecutor threadPoolExecutor = (ThreadPoolExecutor) fixedExecutorService;
        System.out.println(threadPoolExecutor.getMaximumPoolSize());
        threadPoolExecutor.setCorePoolSize(8);
        
        ExecutorService singleExecutorService = Executors.newSingleThreadExecutor();
//      运行时异常 java.lang.ClassCastException
//      ThreadPoolExecutor threadPoolExecutor2 = (ThreadPoolExecutor) singleExecutorService;
    }


```

对比可以看出，FixedThreadPool 可以向下转型为 ThreadPoolExecutor，并对其线程池进行配置，而 SingleThreadExecutor 被包装后，无法成功向下转型。**因此，SingleThreadExecutor 被定以后，无法修改，做到了真正的 Single。**

4.  **ScheduledThreadPool**

```
    public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
        return new ScheduledThreadPoolExecutor(corePoolSize);
    }


```

newScheduledThreadPool 调用的是 ScheduledThreadPoolExecutor 的构造方法，而 ScheduledThreadPoolExecutor 继承了 ThreadPoolExecutor，构造是还是调用了其父类的构造方法。

```
    public ScheduledThreadPoolExecutor(int corePoolSize) {
        super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
              new DelayedWorkQueue());
    }


```

对于 ScheduledThreadPool 本文不做描述，其特性请关注后续篇章。

##### 二、自定义线程池

以下是自定义线程池，使用了有界队列，自定义 ThreadFactory 和拒绝策略的 demo：

```
public class ThreadTest {

    public static void main(String[] args) throws InterruptedException, IOException {
        int corePoolSize = 2;
        int maximumPoolSize = 4;
        long keepAliveTime = 10;
        TimeUnit unit = TimeUnit.SECONDS;
        BlockingQueue<Runnable> workQueue = new ArrayBlockingQueue<>(2);
        ThreadFactory threadFactory = new NameTreadFactory();
        RejectedExecutionHandler handler = new MyIgnorePolicy();
        ThreadPoolExecutor executor = new ThreadPoolExecutor(corePoolSize, maximumPoolSize, keepAliveTime, unit,
                workQueue, threadFactory, handler);
        executor.prestartAllCoreThreads(); // 预启动所有核心线程
        
        for (int i = 1; i <= 10; i++) {
            MyTask task = new MyTask(String.valueOf(i));
            executor.execute(task);
        }

        System.in.read(); //阻塞主线程
    }

    static class NameTreadFactory implements ThreadFactory {

        private final AtomicInteger mThreadNum = new AtomicInteger(1);

        @Override
        public Thread newThread(Runnable r) {
            Thread t = new Thread(r, "my-thread-" + mThreadNum.getAndIncrement());
            System.out.println(t.getName() + " has been created");
            return t;
        }
    }

    public static class MyIgnorePolicy implements RejectedExecutionHandler {

        public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
            doLog(r, e);
        }

        private void doLog(Runnable r, ThreadPoolExecutor e) {
            // 可做日志记录等
            System.err.println( r.toString() + " rejected");
//          System.out.println("completedTaskCount: " + e.getCompletedTaskCount());
        }
    }

    static class MyTask implements Runnable {
        private String name;

        public MyTask(String name) {
            this.name = name;
        }

        @Override
        public void run() {
            try {
                System.out.println(this.toString() + " is running!");
                Thread.sleep(3000); //让任务执行慢点
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        public String getName() {
            return name;
        }

        @Override
        public String toString() {
            return "MyTask []";
        }
    }
}


```

输出结果如下：

![](http://upload-images.jianshu.io/upload_images/11183270-ef3cb072affbec03.png) image.png

其中线程线程 1-4 先占满了核心线程和最大线程数量，然后 4、5 线程进入等待队列，7-10 线程被直接忽略拒绝执行，等 1-4 线程中有线程执行完后通知 4、5 线程继续执行。

#### 总结，通过自定义线程池，我们可以更好的让线程池为我们所用，更加适应我的实际场景。

多线程系列目录（不断更新中）：  
[线程启动原理](https://www.jianshu.com/p/8c16aeea7e1a)  
[线程中断机制](https://www.jianshu.com/p/e0ff2e420ab6)  
[多线程实现方式](https://www.jianshu.com/p/7950ea349dbb)  
[FutureTask 实现原理](https://www.jianshu.com/p/d1f2afaf9a19)  
[线程池之 ThreadPoolExecutor 概述](https://www.jianshu.com/p/c41e942bcd64)  
[线程池之 ThreadPoolExecutor 使用](https://www.jianshu.com/p/f030aa5d7a28)  
[线程池之 ThreadPoolExecutor 状态控制](https://www.jianshu.com/p/18065a78178b)  
[线程池之 ThreadPoolExecutor 执行原理](https://www.jianshu.com/p/23cb8b903d2c)  
[线程池之 ScheduledThreadPoolExecutor 概述](https://www.jianshu.com/p/5d994ee6d4ff)  
[线程池的优雅关闭实践](https://www.jianshu.com/p/bdf06e2c1541)