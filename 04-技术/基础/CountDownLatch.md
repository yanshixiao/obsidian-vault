1、CountDownLatch end = new CountDownLatch(N); //构造对象时候 需要传入参数N

2、end.await() 能够阻塞线程 直到调用N次end.countDown() 方法才释放线程

3、end.countDown() 可以在多个线程中调用 计算调用次数是所有线程调用次数的总和

[传送门](https://www.cnblogs.com/cuglkb/p/8572239.html)