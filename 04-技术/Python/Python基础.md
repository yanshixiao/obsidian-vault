Python

# 模块
>将函数分组，分别放在不同的文件里，一个.py文件就称为一个模块（Module）。  
为了避免模块名冲突，引入按目录组织模块的非那根啊，称为包（Package）。  
每一个包目录下面都会有一个__init__.py的文件，这个文件是必须存在的，否则，Python就把这个目录当成普通目录，而不是一个包。__init__.py本身就是一个模块，模块名就是包名。  

`print("hello")`

- ## 使用模块
- ### 使用模块
```
import sys

if __name__ == '__main__': 
    main()
```
>sys模块有一个argv变量，用list存储了命令行的所有参数。argv至少有一个元素，因为第一个参数永远是该.py文件的名称，例如：运行python3 hello.py获得的sys.argv就是['hello.py']  

- ### 作用域  

>在一个模块中，我们可能会定义很多函数和变量，但有的函数和变量我们希望给别人使用，有的函数和变量我们希望仅仅在模块内部使用。在Python中，是通过_前缀来实现的。  
类似\_xxx或\_\_xxx样的函数或变量就是非公开的（private），不应该被直接引用，比如_abc, __abc等。  
外部不需要引用的函数全部定义成private，只有外部需要引用的函数才定义为public。  

- ## 安装第三方模块
        pip install Pillow

# 面向对象编程
- ## 类和实例
```
class Student(object):

    def __init__(self, name, score):
        self.name = name
        self.score = score
```
 <font color="red">注意：特殊方法“init”前后有两个下划线！！！</font>
 注意到init方法的第一个参数永远是self，表示创建的实例本身，因此，在init方法内部，就可以把各种属性绑定到self，因为self就指向创建的实例本身。  

- ## 访问限制  

>如果要让内部属性不被外部访问，可以把属性的名称前加上两个下划线\_\_，在Python中，实例的变量名如果以\_\_开头，就变成了一个私有变量（private），只有内部可以访问，外部不能访问。
有些时候，你会看到以一个下划线开头的实例变量名，比如_name，这样的实例变量外部是可以访问的，但是，按照约定俗成的规定，当你看到这样的变量时，意思就是，“虽然我可以被访问，但是，请把我视为私有变量，不要随意访问”。

>双下划线开头的实例变量是不是一定不能从外部访问呢？其实也不是。不能直接访问\_\_name是因为Python解释器对外把\_\_name变量改成了_Student\_\_name。但是不同版本的Python解释器可能会把__name改成不同的变量名。

- ## 继承和多态  

- #### 静态语言 vs 动态语言

>对于静态语言（例如Java）来说，如果需要传入Animal类型，则传入的对象必须是Animal类型或者它的子类，否则，将无法调用run()方法。
对于Python这样的动态语言来说，则不一定需要传入Animal类型。我们只需要保证传入的对象有一个run()方法就可以了： 

- ## 获取对象信息  
- #### 使用type()

>使用type()函数判断对象类型  
基本类型都可以用type()判断  
判断一个对象是否是函数用types模块脏哦能定义的常量：types.FunctionType, types.BuiltinFunctionType, types.LambdaType  

- #### 使用isinstance()

- #### 使用dir()

>如果要获得一个对象的所有属性和方法，可以使用dir()函数，它返回一个包含字符串的list。

`dir('ABC')`

`len('ABC')`  
`'ABC'.__len__()`

上面两种方式是等价的。

>仅仅把属性和方法列出来是不够的，配合getattr()、setattr()以及hasattr()，我们可以直接操作一个对象的状态。

- ## 实例属性和类属性

>不要把实例属性和类属性使用相同的名字，因为相同名称的实例属性将屏蔽掉类属性，但是当你删除实例属性后，再使用相同的名称，访问到的将是类属性。

# 面向对象高级编程
- ## 使用\_\_slots__

>给实例绑定一个方法
```
>>> def set_age(self, age): # 定义一个函数作为实例方法
...     self.age = age
...
>>> from types import MethodType
>>> s.set_age = MethodType(set_age, s) # 给实例绑定一个方法
>>> s.set_age(25) # 调用实例方法
>>> s.age # 测试结果
25
```
>但是，给一个实例绑定的方法，对另一个实例是不起作用的  为了给所有实例都绑定方法，可以给class绑定方法：

>如果想要限制示例的属性，只允许对示例添加name和age属性。  
为了达到限制的目的，Python允许在定义class的时候，定义一个特殊的**\_\_slots__**变量，来限制该class实例能添加的属性：
```
class Student(object):
    __slots__ = ('name', 'age') # 用tuple定义允许绑定的属性名称
```

- ## 使用@property

>get(),set()方法去限定属性过于繁琐，利用装饰器将get方法变为属性,Python内置的@property装饰器就是负责把一个方法变成属性调用。
```
class Student(object):

    @property
    def score(self):
        return self._score

    @score.setter
    def score(self, value):
        if not isinstance(value, int):
            raise ValueError('score must be an integer!')
        if value < 0 or value > 100:
            raise ValueError('score must between 0 ~ 100!')
        self._score = value
```
>还可以定义只读属性，只定义getter方法，不定义setter方法就是一个只读属性。

```
class Student(object):

    @property
    def birth(self):
        return self._birth

    @birth.setter
    def birth(self, value):
        self._birth = value

    @property
    def age(self):
        return 2015 - self._birth
```

- ## 多重继承

>通过多重继承，一个子类就可以同时获得多个父类的所有功能。

- ## 定制类
- #### \_\_str__

>print某实例时，调用\_\_str\_\_方法，不print，直接对象名调用\_\_repr()\_\_方法。  
两者的区别是\_\_str\_\_()返回用户看到的字符串，而\_\_repr\_\_()返回程序开发者看到的字符串，也就是说，\_\_repr__()是为调试服务的。

- #### \_\_iter__

>如果一个类想被用于for ... in循环，类似list或tuple那样，就必须实现一个\_\_iter\_\_()方法，该方法返回一个迭代对象，然后，Python的for循环就会不断调用该迭代对象的\_\_next\_\_()方法拿到循环的下一个值，直到遇到StopIteration错误时退出循环。  
斐波那契为例
```
class Fib(object):
    def __init__(self):
        self.a, self.b = 0, 1 # 初始化两个计数器a，b

    def __iter__(self):
        return self # 实例本身就是迭代对象，故返回自己

    def __next__(self):
        self.a, self.b = self.b, self.a + self.b # 计算下一个值
        if self.a > 100000: # 退出循环的条件
            raise StopIteration()
        return self.a # 返回下一个值
```

- #### \_\_getitem__

>要表现得像list那样按照下标取出元素，需要实现\_\_getitem__()方法：
```
class Fib(object):
    def __getitem__(self, n):
        a, b = 1, 1
        for x in range(n):
            a, b = b, a + b
        return a
```
就可以用下标访问了

- #### \_\_getattr__

>找不到属性情况下，会调用\_\_getattr__  
REST API

```
class Chain(object):

    def __init__(self, path=''):
        self._path = path

    def __getattr__(self, path):
        return Chain('%s/%s' % (self._path, path))

    def __str__(self):
        return self._path

    __repr__ = __str__
```

- #### \_\_call__

>初始化实例就调用

```
class Student(object):
    def __init__(self, name):
        self.name = name

    def __call__(self):
        print('My name is %s.' % self.name)

s = Student('YUAN')
s()
```
>通过callable()函数判断一个对象（函数）是否可以被调用。

- ## 使用枚举类

>定义常量
```
from enum import Enum

Month = Enum('Month', ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
```

>枚举类
```
from enum import Enum

Month = Enum('Month', ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))

for name, member in Month.__members__.items():
    print(name, '=>', member, ',', member.value)
```

>要精确的控制枚举类型，可以继承Enum, unique帮助检查是否唯一
```
from enum import Enum, unique

@unique
class Weekday(Enum):
    Sun = 0 # Sun的value被设定为0
    Mon = 1
    Tue = 2
    Wed = 3
    Thu = 4
    Fri = 5
    Sat = 6
```

- ## 使用元类
- #### type()

>type()函数既可以返回一个对象的类型，又可以创建出新的类型，比如，我们可以通过type()函数创建出Hello类，而无需通过class Hello(object)...的定义：

>要创建一个class对象，type()函数依次传入3个参数:  
class的名称；  
继承的父类集合，注意Python支持多重继承，如果只有一个父类，别忘了tuple的单元素写法；  
class的方法名称与函数绑定，这里我们把函数fn绑定到方法名hello上。

```
def fn(self, name='world'): # 先定义函数
    print('Hello, %s.' % name)
 Hello = type('Hello', (object,), dict(hello=fn)) # 创建Hello class
```

# 错误、调试和测试
- ## 错误处理
- #### 错误处理

    >try...except...finally...

- #### 调用堆栈
- #### 记录错误

    >logging，打印完错误信息后会继续执行，并正常退出。

- #### 抛出错误

    >raise

- ## 调试

>print()打印变量

- #### 断言

    >assert

```
    def foo(s):
        n = int(s)
        assert n != 0, 'n is zero!'
        return 10 / n

    def main():
        foo('0')
```

    >程序中如果到处充斥着assert，和print()相比也好不到哪去。不过，启动Python解释器时可以用-O参数来关闭assert。

- #### logging

    >logging不会抛出错误，而且可以输出到文件。

```
    import logging
    logging.basicConfig(level=logging.INFO)

    s = '0'
    n = int(s)
    logging.info('n = %d' % n)
    print(10 / n)
```
>它允许你指定记录信息的级别，有debug，info，warning，error等几个级别。


- #### pdb

    >让程序以单步方式运行，可以随时查看运行状态。

- #### pdb.set_trace()

    >设置断点

- ## 单元测试
>unittest
- #### 运行单元测试
- #### setUp与tearDown
    >setUp()和tearDown()方法。这两个方法会分别在每调用一个测试方法的前后分别被执行。

- ## 文档测试

>doctest

# IO编程
- ## 文件读写
- ## StringIO和BytesIO
- ## 操作文件和目录
- ## 序列化

# 进程和线程
- ## 多进程
- ## 多线程
- ## ThreadLoacl
- ## 进程 vs 线程
- ## 分布式进程