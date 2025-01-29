Spring官网解释：

> Circular dependencies
If you use predominantly constructor injection, it is possible to create an unresolvable circular dependency scenario.
For example: Class A requires an instance of class B through constructor injection, and class B requires an instance of class A through constructor injection. If you configure beans for classes A and B to be injected into each other, the Spring IoC container detects this circular reference at runtime, and throws a BeanCurrentlyInCreationException.
One possible solution is to edit the source code of some classes to be configured by setters rather than constructors. Alternatively, avoid constructor injection and use setter injection only. In other words, although it is not recommended, you can configure circular dependencies with setter injection.
Unlike the typical case (with no circular dependencies), a circular dependency between bean A and bean B forces one of the beans to be injected into the other prior to being fully initialized itself (a classic chicken/egg scenario).
循环依赖
如果主要使用构造函数注入，则可能会创建无法解决的循环依赖方案。
例如：A类通过构造函数注入需要B类的实例，而B类通过构造函数注入需要A类的实例。如果您为将类A和B相互注入而配置了bean，则Spring IoC容器会在运行时检测到此循环引用，并抛出 BeanCurrentlyInCreationException。
一种可能的解决方案是编辑某些类的源代码，这些类将由设置者而不是构造函数来配置。或者，避免构造函数注入，而仅使用setter注入。换句话说，尽管不建议这样做，但是您可以使用setter注入配置循环依赖关系。
与典型情况（没有循环依赖关系）不同，Bean A和Bean B之间的循环依赖关系迫使其中一个Bean在完全完全初始化之前被注入另一个Bean（经典的“鸡与蛋”场景）。