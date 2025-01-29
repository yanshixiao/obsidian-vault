`两者都是反射的手段`

`Class.forName(className)`实际调用是`Class.forName(className, true, classLoader);`
第二个参数表示类是否需要初始化。Class.forName(className)默认是需要初始化，一旦初始化，就会触发目标对象的static块代码执行，static参数也会被再次初始化。

`ClassLoader.loadClass(className)`方法，内部实际调用的是`ClassLoader.loadClass(className,false);`
第二个参数表示目标对象是否进行链接，false表示不进行链接，不进行链接意味着不进行包括初始化等一系列步骤，那么静态块和静态对象就不会得到执行。

