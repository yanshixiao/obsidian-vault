> 此接口在 spring 内部被广泛使用，用来获取代理对 象等等, dubbo 等自定义标签后，通过实现该返回 getObject 方法生成的对远程服务调用的代理

一般情况下，Spring 通过反射机制利用 bean 的 class 属性指定实现类来实例化 bean 。在某些情况下，实例化 bean 过程比较复杂，如果按照传统的方式，则需要在 <bean> 中提供大量的配置信息，配置方式的灵活性是受限的，这时采用编码的方式可能会得到一个简单的方案。Spring 为此提供了一个 org.Springframework.bean.factory.FactoryBean 的工厂类接口，用户可以通过实现该接口定制实例化 bean 的逻辑。

FactoryBean 接口对于 Spring 框架来说占有重要的地位，Spring 自身就提供了 70 多个 FactoryBean 的实现。它们隐藏了实例化一些复杂 bean 的细节，给上层应用带来了便利。从 Spring 3.0 开始， FactoryBean 开始支持泛型，即接口声明改为 FactoryBean<T> 的形式：
	
```java
package org.Springframework.beans.factory; 
public interface FactoryBean<T> {    
   T getObject() throws Exception;    
   Class<?> getObjectType(); boolean isSingleton();
}
```

在该接口中还定义了以下 3 个方法。

T getObject()：返回由 FactoryBean 创建的 bean 实例，如果 isSingleton() 返回 true，则该实例会放到 Spring 容器中单实例缓存池中。

boolean isSingleton()：返回由 FactoryBean 创建的 bean 实例的作用域是 singleton 还是 prototype。

Class<T> getObjectType()：返回 FactoryBean 创建的 bean 类型。

当配置文件中 <bean> 的 class 属性配置的实现类是 FactoryBean 时，通过 getBean() 方法返回的不是 FactoryBean 本身，而是 FactoryBean#getObject() 方法所返回的对象，相当于 FactoryBean#getObject() 代理了 getBean() 方法。例如：如果使用传统方式配置下面 Car 的 < bean > 时，Car 的每个属性分别对应一个 < property > 元素标签。


```java
public class Car  { 
    private   int maxSpeed ; 
	private String brand ; 
	private   double price ;   
   //get/set方法 
｝
```

如果用 FactoryBean 的方式实现就会灵活一些，下例通过逗号分割符的方式一次性地为 Car 的所有属性指定配置值：


```java
public class CarFactoryBean implements FactoryBean<Car> { 
     private String carInfo; 
     public Car getObject() throws Exception {
        Car car = new Car();
        String[] infos = carInfo.split(",");
        car.setBrand(infos[0]);
        car.setMaxSpeed(Integer.valueOf(infos[1]));
        car.setPrice(Double.valueOf(infos[2])); return car;
    }
    public Class<Car> getObjectType() { 
      return Car.class;
    }
    public boolean isSingleton() {
      return false;
   } 
}
```

有了这个 CarFactoryBean 后，就可以在配置文件中使用下面这种自定义的配置方式配置 Car Bean 了：

```xml
<bean id="car" class="com.test.factorybean.CarFactoryBean" carInfo="大众SUV,180,180000"/>
```

当调用 getBean("car") 时，Spring 通过反射机制发现 CarFactoryBean 实现了 FactoryBean 的接口，这时 Spring 容器就调用接口方法 CarFactoryBean#getObject() 方法返回。如果希望获取 CarFactoryBean 的实例，则需要在使用 getBean(beanName) 方法时在 beanName 前显示的加上 "&" 前缀，例如 getBean("&car")。
