---

UID: 20250312225818 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-12
---

![[说一下JVM 的主要组成部分及其作用？.png]]

JVM包含两个子系统和两个组件，分别为

- Class loader(类装载子系统)
- Execution engine(执行引擎子系统)；
- Runtime data area(运行时数据区组件)
- Native Interface(本地接口组件)。

**「Class loader(类装载)：」** 根据给定的全限定名类名(如：java.lang.Object)来装载class文件

到运行时数据区的方法区中。「Execution engine（执行引擎）」：执行class的指令。

**「Native Interface(本地接口)：」** 与native lib交互，是其它编程语言交互的接口。

**「Runtime data area(运行时数据区域)」**：即我们常说的JVM的内存。


首先通过编译器把 Java源代码转换成字节码，Class loader(类装载)再把字节码加载到内存
中，将其放在运行时数据区的方法区内，而字节码文件只是 JVM 的一套指令集规范，并不能直
接交给底层操作系统去执行，因此需要特定的命令解析器执行引擎（Execution Engine），将
字节码翻译成底层系统指令，再交由 CPU 去执行，而这个过程中需要调用其他语言的本地库
接口（Native Interface）来实现整个程序的功能。

