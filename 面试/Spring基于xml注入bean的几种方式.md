---

UID: 20250322120619 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---


Spring 通过 XML 配置实现依赖注入（Dependency Injection, DI）是传统但依然重要的方式，以下是基于 XML 的几种主要注入方式及其详细说明和示例：

---

### **1. 构造函数注入（Constructor Injection）**
通过 Bean 的构造函数传递依赖项，适用于**强制依赖**的初始化。

#### **XML 配置示例**：
```xml
<bean id="userService" class="com.example.UserService">
    <!-- 通过构造函数参数按顺序注入 -->
    <constructor-arg index="0" value="admin"/>
    <constructor-arg index="1" ref="userRepository"/>
</bean>
```
或通过参数类型匹配：
```xml
<bean id="userService" class="com.example.UserService">
    <constructor-arg type="java.lang.String" value="admin"/>
    <constructor-arg type="com.example.UserRepository" ref="userRepository"/>
</bean>
```
或通过参数名匹配（需启用调试符号或使用 `@ConstructorProperties` 注解）：
```xml
<bean id="userService" class="com.example.UserService">
    <constructor-arg name="username" value="admin"/>
    <constructor-arg name="userRepository" ref="userRepository"/>
</bean>
```

#### **适用场景**：
- 依赖项必须在对象创建时初始化。
- 避免因依赖缺失导致对象状态不一致。

---

### **2. Setter 方法注入（Setter Injection）**
通过 Bean 的 Setter 方法注入依赖项，适用于**可选依赖**或需要动态更新的场景。

#### **XML 配置示例**：
```xml
<bean id="orderService" class="com.example.OrderService">
    <!-- 通过 property 标签调用 setter 方法 -->
    <property name="paymentGateway" ref="alipayGateway"/>
    <property name="timeout" value="5000"/>
</bean>
```

#### **对应 Java 类**：
```java
public class OrderService {
    private PaymentGateway paymentGateway;
    private int timeout;

    // Setter 方法
    public void setPaymentGateway(PaymentGateway paymentGateway) {
        this.paymentGateway = paymentGateway;
    }

    public void setTimeout(int timeout) {
        this.timeout = timeout;
    }
}
```

#### **适用场景**：
- 依赖项可选或可能后续修改。
- 需要灵活配置的 Bean（如配置参数）。

---

### **3. 字段注入（Field Injection）**
通过直接注入字段值（需结合 `@Autowired` 注解，但 XML 中需开启注解支持）。严格来说，XML 本身不直接支持字段注入，但可以通过注解驱动实现。

#### **XML 配置**：
```xml
<!-- 开启注解驱动 -->
<context:annotation-config/>

<bean id="userController" class="com.example.UserController">
    <!-- 不显式配置字段，依赖 @Autowired 注解 -->
</bean>
<bean id="userService" class="com.example.UserService"/>
```

#### **Java 类**：
```java
public class UserController {
    @Autowired
    private UserService userService;
}
```

#### **适用场景**：
- 快速开发，减少 XML 配置代码。
- 结合注解简化依赖管理（需注意隐藏的耦合性）。

---

### **4. 集合类型注入**
注入集合类型（List、Set、Map、Properties 等），常用于配置复杂数据结构。

#### **XML 配置示例**：
```xml
<bean id="configBean" class="com.example.ConfigBean">
    <!-- List 注入 -->
    <property name="serverList">
        <list>
            <value>server1.example.com</value>
            <value>server2.example.com</value>
        </list>
    </property>

    <!-- Map 注入 -->
    <property name="configMap">
        <map>
            <entry key="timeout" value="3000"/>
            <entry key="maxRetry" value="5"/>
        </map>
    </property>

    <!-- Properties 注入 -->
    <property name="dbProperties">
        <props>
            <prop key="jdbc.url">jdbc:mysql://localhost:3306/mydb</prop>
            <prop key="jdbc.username">root</prop>
        </props>
    </property>
</bean>
```

#### **适用场景**：
- 配置参数组、白名单、路由表等。
- 需要结构化数据管理的场景。

---

### **5. 内部 Bean 注入**
在属性或构造函数中直接定义匿名 Bean，该 Bean 仅对当前属性可见。

#### **XML 配置示例**：
```xml
<bean id="orderService" class="com.example.OrderService">
    <property name="validator">
        <!-- 内部 Bean，无需 id -->
        <bean class="com.example.OrderValidator">
            <property name="strictMode" value="true"/>
        </bean>
    </property>
</bean>
```

#### **适用场景**：
- 依赖项无需复用或共享。
- 简化配置，避免全局 Bean 定义污染。

---

### **6. 自动装配（Autowiring）**
通过约定而非显式配置实现依赖注入，XML 中通过 `autowire` 属性指定模式。

#### **XML 配置示例**：
```xml
<!-- byName：根据属性名匹配 Bean ID -->
<bean id="userService" class="com.example.UserService" autowire="byName"/>

<!-- byType：根据属性类型匹配 Bean（需确保类型唯一） -->
<bean id="paymentService" class="com.example.PaymentService" autowire="byType"/>
```

#### **自动装配模式**：
| **模式**       | **说明**                              |
|----------------|---------------------------------------|
| `no`           | 默认，不自动装配（需显式配置）          |
| `byName`       | 根据属性名匹配 Bean ID                 |
| `byType`       | 根据属性类型匹配 Bean                  |
| `constructor`  | 按构造函数参数类型匹配 Bean            |

#### **适用场景**：
- 减少冗余配置，提升开发效率。
- 需注意类型冲突和隐式依赖带来的维护成本。

---

### **7. 命名空间简化配置**
使用 `p命名空间` 和 `c命名空间` 简化 XML 配置。

#### **p命名空间（属性注入）**：
```xml
<!-- 引入命名空间 -->
<beans xmlns:p="http://www.springframework.org/schema/p">

<bean id="userService" class="com.example.UserService"
    p:username="admin"
    p:userRepository-ref="userRepository"/>
```

#### **c命名空间（构造函数注入）**：
```xml
<!-- 引入命名空间 -->
<beans xmlns:c="http://www.springframework.org/schema/c">

<bean id="userService" class="com.example.UserService"
    c:username="admin"
    c:userRepository-ref="userRepository"/>
```

#### **适用场景**：
- 简化 XML 配置，减少代码量。
- 快速定义简单依赖关系。

---

### **总结**
| **注入方式**         | **核心标签/属性**       | **适用场景**                     |
|----------------------|------------------------|---------------------------------|
| 构造函数注入          | `<constructor-arg>`    | 强制依赖，不可变对象              |
| Setter 注入           | `<property>`           | 可选依赖，动态配置                |
| 集合注入              | `<list>`, `<map>` 等   | 结构化数据配置                    |
| 内部 Bean             | 嵌套 `<bean>`           | 私有依赖，无需复用                |
| 自动装配              | `autowire` 属性        | 快速开发，减少配置量              |
| 命名空间简化          | `p:` 和 `c:`           | 简化 XML 语法                    |

通过合理选择 XML 注入方式，可以灵活管理 Bean 的依赖关系，平衡配置的清晰度与开发效率。


