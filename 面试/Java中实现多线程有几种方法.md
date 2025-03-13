---

UID: 20250313230438 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-13
---


创建线程的常用三种方式：

1. 继承Thread类

2. 实现Runnable接口

3. 实现Callable接口（ JDK1.5>= ）

4. 线程池方式创建

通过继承Thread类或者实现Runnable接口、Callable接口都可以实现多线程，不过实现Runnable

接口与实现Callable接口的方式基本相同，只是Callable接口里定义的方法返回值，可以声明抛出异

常而已。因此将实现Runnable接口和实现Callable接口归为一种方式。这种方式与继承Thread方式

之间的主要差别如下。

**采用实现Runnable、Callable接口的方式创建线程的优缺点**

**优点：** 线程类只是实现了Runnable或者Callable接口，还可以继承其他类。这种方式下，多个线程可以共享一个target对象，所以非常适合多个相同线程来处理同一份资源的情况，从而可以将CPU、代码和数据分开，形成清晰的模型，较好的体现了面向对象的思想。

**缺点：** 编程稍微复杂一些，如果需要访问当前线程，则必须使用 Thread.currentThread() 方法

**采用继承Thread类的方式创建线程的优缺点**

**优点**：编写简单，如果需要访问当前线程，则无需使用 Thread.currentThread() 方法，直接使用this即可获取当前线程

**缺点**：因为线程类已经继承了Thread类，Java语言是单继承的，所以就不能再继承其他父类了。


