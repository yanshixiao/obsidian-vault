---

UID: 20250322121836 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---

在 Spring 框架中，**BeanFactory** 和 **FactoryBean** 是名称相似但功能完全不同的两个接口，理解它们的区别对掌握 Spring 的核心机制至关重要。以下是它们的详细对比：

---

### **1. BeanFactory：IoC 容器的根基**
#### **定义**  
`BeanFactory` 是 Spring 的 **核心容器接口**，负责管理 Bean 的整个生命周期（实例化、配置、装配）。它是所有 Spring 容器（如 `ApplicationContext`）的顶层接口。

#### **核心职责**  
- **创建 Bean**：根据配置（XML、注解）实例化 Bean。
- **依赖注入**：自动装配 Bean 之间的依赖关系。
- **管理作用域**：控制 Bean 的作用域（单例、原型等）。
- **访问 Bean**：通过 `getBean()` 方法获取容器中的 Bean。

#### **示例代码**  
```java
// 创建 BeanFactory（以 XML 配置为例）
BeanFactory factory = new XmlBeanFactory(new ClassPathResource("beans.xml"));
// 获取 Bean
UserService userService = factory.getBean(UserService.class);
```

#### **特点**  
- **延迟加载**：默认在首次请求时初始化 Bean（节省资源）。
- **基础功能**：仅提供最基础的依赖注入和 Bean 管理。

---

### **2. FactoryBean：复杂对象的工厂**
#### **定义**  
`FactoryBean` 是一个 **创建复杂对象的工厂接口**，用于封装难以直接通过构造函数实例化的对象（如第三方库组件、需要动态生成的代理对象）。

#### **核心职责**  
- **定制化创建逻辑**：通过 `getObject()` 方法返回目标对象。
- **隐藏复杂性**：将复杂对象的创建过程封装在工厂中，简化配置。

#### **示例代码**  
```java
// 实现 FactoryBean 接口
public class MyFactoryBean implements FactoryBean<MyComplexObject> {
    @Override
    public MyComplexObject getObject() {
        // 复杂对象的创建逻辑（如连接池、代理对象）
        return new MyComplexObject();
    }

    @Override
    public Class<?> getObjectType() {
        return MyComplexObject.class;
    }

    @Override
    public boolean isSingleton() {
        return true;
    }
}

// XML 配置
<bean id="myComplexObject" class="com.example.MyFactoryBean"/>
```

#### **特点**  
- **双重身份**：`FactoryBean` 本身是一个 Bean，但它生成的 Bean 是 `getObject()` 的返回值。
- **获取方式**：
  - 默认获取目标对象：`context.getBean("myComplexObject")` → `MyComplexObject` 实例。
  - 获取工厂本身：`context.getBean("&myComplexObject")` → `MyFactoryBean` 实例。

---

### **3. 关键区别对比**
| **特性**              | **BeanFactory**                          | **FactoryBean**                          |
|-----------------------|------------------------------------------|------------------------------------------|
| **角色**              | IoC 容器，管理所有 Bean 的生命周期        | 特殊 Bean，用于创建其他复杂对象            |
| **接口类型**          | 核心容器接口                             | 工厂接口，用于扩展对象创建逻辑             |
| **获取对象的方式**    | 直接通过 `getBean()` 获取 Bean            | 通过 `FactoryBean.getObject()` 生成对象    |
| **典型应用场景**      | 所有 Bean 的基础管理                      | 集成第三方库（如 MyBatis 的 `SqlSessionFactoryBean`） |
| **设计目的**          | 提供依赖注入和 Bean 管理的基础设施        | 封装复杂对象的创建过程                     |

---

### **4. 常见应用场景**
#### **BeanFactory 的典型使用**  
- 管理应用中所有组件（Service、DAO 等）的依赖关系。
- 控制 Bean 的作用域和生命周期。

#### **FactoryBean 的典型使用**  
- **创建连接池**：如 `DataSource` 的复杂初始化。
- **生成代理对象**：AOP 中动态生成代理类。
- **集成框架**：如 Spring 整合 MyBatis 时，通过 `SqlSessionFactoryBean` 创建 `SqlSessionFactory`。

---

### **5. 代码示例：FactoryBean 的实际应用**
#### **场景**：自定义一个线程安全的 `DateFormat` 工厂。
```java
public class DateFormatFactoryBean implements FactoryBean<DateFormat> {
    private String pattern;

    public void setPattern(String pattern) {
        this.pattern = pattern;
    }

    @Override
    public DateFormat getObject() {
        // 每个线程独立的 SimpleDateFormat（解决线程安全问题）
        return new ThreadLocal<DateFormat>() {
            @Override
            protected DateFormat initialValue() {
                return new SimpleDateFormat(pattern);
            }
        }.get();
    }

    @Override
    public Class<?> getObjectType() {
        return DateFormat.class;
    }

    @Override
    public boolean isSingleton() {
        return false; // 每个线程需要独立实例
    }
}
```

#### **XML 配置**：
```xml
<bean id="dateFormat" class="com.example.DateFormatFactoryBean">
    <property name="pattern" value="yyyy-MM-dd"/>
</bean>
```

#### **使用 Bean**：
```java
// 获取线程安全的 DateFormat
DateFormat dateFormat = context.getBean("dateFormat");
```

---

### **总结**
- **BeanFactory** 是 Spring 的 **核心容器**，负责所有 Bean 的创建和管理。
- **FactoryBean** 是 **创建复杂对象的工厂**，通过实现该接口自定义对象的生成逻辑。
- **关键区别**：BeanFactory 是容器本身，FactoryBean 是容器中的一个特殊 Bean，用于生成其他对象。



