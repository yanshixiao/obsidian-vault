
---
author: yuanshuai
created: 2022-01-11 18:31:35
aliases: 
description:
tags: [其他]
---


在实现阻塞模式socket编程时，PrintWriter的write方法不生效，println就可以。

跟踪一下源码

```java
public void println(String x) {  
    synchronized (lock) {  
        print(x);  
		 println();  
	}  
}
```

print方法里调用了write。
而println方法中调用了`newLine`

![](Pasted%20image%2020220111183440.png)

newLine方法中主要是拼了一个系统分行符lineSeparator

```java
private void newLine() {  
    try {  
        synchronized (lock) {  
            ensureOpen();  
			 out.write(lineSeparator);  
			 if (autoFlush)  
				out.flush();  
		}  
    }  
    catch (InterruptedIOException x) {  
        Thread.currentThread().interrupt();  
	}  
    catch (IOException x) {  
        trouble = true;  
	}  
}
```

debug可以看到lineSeparator的值为\r\n，所以write()只要加上\r\n等同于println()。

![](Pasted%20image%2020220111184115.png)