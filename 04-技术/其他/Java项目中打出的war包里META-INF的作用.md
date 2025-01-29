---
author: yuanshuai
created: 2021-11-16 17:09:58
aliases: 
description:
tags: [其他]
---


If you remove META-INF from a jar then there is no MANIFEST.MF and so java -jar can't find the main class.

You can create jars without META-INF but when you are going to execute a jar a META-INF/MANIFEST.MF is required.

See [http://docs.oracle.com/javase/7/docs/technotes/guides/jar/jar.html](http://docs.oracle.com/javase/7/docs/technotes/guides/jar/jar.html)

这句英文很简单，简单翻译如下：

如果你将Jar中的META-INF文件夹删除，那么jar文件里边就没有MANIFEST.MF文件。那么，java -jar就找不到main class.

没有META-INF你仍然可以创建一个Jar文件。但是，当你想要执行jar文件的时候，这个jar是需要具备 META-INF/MANIFEST.MF的。