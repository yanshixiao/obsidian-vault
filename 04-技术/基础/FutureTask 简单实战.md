> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [www.cnblogs.com](https://www.cnblogs.com/flylinran/p/10171449.html)

FutureTask 是什么？
---------------

> 线程池的实现核心之一是 FutureTask。在提交任务时，用户实现的 Callable 实例 task 会被包装为 FutureTask 实例 ftask；提交后任务异步执行，无需用户关心；当用户需要时，再调用 FutureTask#get() 获取结果——或异常。

基本使用
----

方法中可能会调用到多个服务 / 方法，且这些服务 / 方法之间是互相独立的，不存在先后关系。在高并发场景下，如果执行比较耗时，可以考虑多线程异步的方式调用。

### 我们先模拟两个耗时服务

一个 **150ms**，一个 **200ms**：

```
public class UserApi {

    /** 查询用户基本信息，模拟耗时150ms */
    public String queryUserInfo(long userId) {
        String userInfo = "userInfo: " + userId;

        try {
            TimeUnit.MILLISECONDS.sleep(150L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return userInfo;
    }

    /** 查询用户地址，模拟耗时200ms */
    public String queryUserAddress(long userId) {
        String userAddress = "userAddress: " + userId;

        try {
            TimeUnit.MILLISECONDS.sleep(200L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return userAddress;
    }
}


```

### 不使用 FutureTask

```
@Test
public void testNotUseFutureTask() {
    UserApi userApi = new UserApi();

    long userId = 12;
    long startTime = System.currentTimeMillis();

    // 获取用户基本信息
    String userInfo = userApi.queryUserInfo(userId);
    // 获取用户地址
    String userAddress = userApi.queryUserAddress(userId);

    System.err.println("testNotUseFutureTask 耗时：" + (System.currentTimeMillis() - startTime));
}


```

执行几次，结果:

```
testNotUseFutureTask 耗时：358
testNotUseFutureTask 耗时：360


```

从结果中，可以看到，总耗时是大于`queryUserInfo`和`queryUserAddress`之和的。但这两个服务逻辑上并不存在先后关系，理论上最长耗时取决于最慢的那个，即`queryUserAddress`

### 使用 FutureTask

下例使用了`FutureTask`，来异步调用`queryUserInfo`和`queryUserAddress`。

```
@Test
public void testUseFutureTask() throws ExecutionException, InterruptedException {
    UserApi userApi = new UserApi();

    long userId = 12;
    long startTime = System.currentTimeMillis();

    Callable<String> userInfoCallable = new Callable<String>() {
        @Override
        public String call() throws Exception {
            return userApi.queryUserInfo(userId);
        }
    };
    Callable<String> userAddressCallable = new Callable<String>() {
        @Override
        public String call() throws Exception {
            return userApi.queryUserAddress(userId);
        }
    };
    FutureTask<String> userInfoFutureTask = new FutureTask<>(userInfoCallable);
    FutureTask<String> userAddressFutureTask = new FutureTask<>(userAddressCallable);

    new Thread(userInfoFutureTask).start();
    new Thread(userAddressFutureTask).start();

    String userInfo = userInfoFutureTask.get();
    String userAddress = userAddressFutureTask.get();
    System.err.println("testUseFutureTask 耗时：" + (System.currentTimeMillis() - startTime));
}



```

执行几次，结果:

```
testUseFutureTask 耗时：239
testUseFutureTask 耗时：237


```

很明显，总耗时大大减少了，这就验证了前面所说，总耗时取决于`queryUserAddress`的耗时。

### 实现一个简单的 FutureTask

从前面使用 FutureTask 的代码中可以看到，一个 FutureTask 需要包含以下几点：

```
1、范型
2、构造函数，传入Callable
3、实现Runnable
4、有返回值


```

*   `MyFutureTask`代码如下：

```
public class MyFutureTask<T> implements Runnable {

    private Callable<T> callable;
    private T           result;
    private String      state;

    public MyFutureTask(Callable<T> callable) {
        this.callable = callable;
    }

    @Override
    public void run() {
        state = "NEW";
        try {
            result = callable.call();
        } catch (Exception e) {
            e.printStackTrace();
        }
        state = "DONE";
        synchronized (this) {
            this.notify();
        }
    }

    /** 获取调用结果 */
    public T get() throws InterruptedException {
        if ("DOEN".equals(state)) {
            return result;
        }
        synchronized (this) {
            this.wait();
        }
        return result;
    }
}


```

*   使用：

```
@Test
public void testMyUseFutureTask() throws InterruptedException {
    UserApi userApi = new UserApi();

    long userId = 12;
    long startTime = System.currentTimeMillis();

    Callable<String> userInfoCallable = new Callable<String>() {
        @Override
        public String call() throws Exception {
            return userApi.queryUserInfo(userId);
        }
    };
    Callable<String> userAddressCallable = new Callable<String>() {
        @Override
        public String call() throws Exception {
            return userApi.queryUserAddress(userId);
        }
    };
    
    // 不同点
    MyFutureTask<String> userInfoFutureTask = new MyFutureTask<>(userInfoCallable);
    MyFutureTask<String> userAddressFutureTask = new MyFutureTask<>(userAddressCallable);

    new Thread(userInfoFutureTask).start();
    new Thread(userAddressFutureTask).start();

    String userInfo = userInfoFutureTask.get();
    String userAddress = userAddressFutureTask.get();
    System.err.println("testMyUseFutureTask 耗时：" + (System.currentTimeMillis() - startTime));
}


```

*   输出结果：

```
testMyUseFutureTask 耗时：208
testMyUseFutureTask 耗时：211


```

从结果中看到，预期与使用`FutureTask`的一致。至于使用我们自定义的`MyFutureTask`执行耗时为何会比`FutureTask`长，我猜测是我们自己写的未做更多的检查和判断。我们自己写的只是用来学习`FutureTask`。

总结
--

不使用异步的方式时，`queryUserAddress`在`queryUserInfo`执行之后才会执行，两者相加的时间算入总调用耗时。如果使用了异步线程调用，由于`queryUserAddress`耗时长，这样在`queryUserAddress`执行结束前，`queryUserInfo`就执行结束了，这样`queryUserInfo`调用耗时就不计了。