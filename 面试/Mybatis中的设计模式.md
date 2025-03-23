---

UID: 20250323143856 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---



MyBatis 作为一款优秀的持久层框架，其源码中广泛运用了多种设计模式以提升扩展性、灵活性和可维护性。以下是 MyBatis 中常见设计模式及其具体应用场景的详细解析：

---

### **1. 工厂模式（Factory Pattern）**
#### **应用场景**
- **`SqlSessionFactory`**：用于创建 `SqlSession` 对象，屏蔽底层数据库连接细节。
- **`ObjectFactory`**：负责创建结果对象（如实体类实例），可自定义扩展。

#### **核心实现**
```java
// 工厂接口
public interface SqlSessionFactory {
    SqlSession openSession();
}

// 默认实现类
public class DefaultSqlSessionFactory implements SqlSessionFactory {
    @Override
    public SqlSession openSession() {
        return new DefaultSqlSession(...);
    }
}
```

#### **优势**
- **解耦对象创建与使用**：客户端无需关心 `SqlSession` 的构建细节。
- **统一管理资源**：集中控制数据库连接的创建逻辑。

---

### **2. 建造者模式（Builder Pattern）**
#### **应用场景**
- **`SqlSessionFactoryBuilder`**：解析 XML 配置（如 `mybatis-config.xml`），逐步构建 `SqlSessionFactory`。
- **`XMLConfigBuilder`**：解析全局配置文件，生成 `Configuration` 对象。

#### **核心实现**
```java
public class SqlSessionFactoryBuilder {
    public SqlSessionFactory build(InputStream inputStream) {
        XMLConfigBuilder parser = new XMLConfigBuilder(inputStream);
        Configuration config = parser.parse();
        return new DefaultSqlSessionFactory(config);
    }
}
```

#### **优势**
- **分步构建复杂对象**：适用于配置文件的层级解析。
- **链式调用**：提升代码可读性。

---

### **3. 代理模式（Proxy Pattern）**
#### **应用场景**
- **Mapper 接口动态代理**：通过 `MapperProxy` 生成 Mapper 接口的代理对象，将接口方法调用转换为 SQL 执行。
- **延迟加载（Lazy Loading）**：使用动态代理拦截关联属性的访问，触发按需查询。

#### **核心实现**
```java
public class MapperProxy<T> implements InvocationHandler {
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) {
        // 将方法调用转换为 SQL 执行（通过 MappedStatement）
        return execute(method, args);
    }
}

// 生成代理对象
UserMapper userMapper = sqlSession.getMapper(UserMapper.class);
```

#### **优势**
- **接口与实现解耦**：无需编写 Mapper 实现类。
- **灵活扩展**：可在代理层添加缓存、日志等逻辑。

---

### **4. 装饰器模式（Decorator Pattern）**
#### **应用场景**
- **`LoggingExecutor`**：对 `Executor` 添加日志功能，增强原有执行器。
- **缓存装饰器**：如 `CachingExecutor` 包裹基础 Executor，添加二级缓存功能。

#### **核心实现**
```java
public class CachingExecutor implements Executor {
    private final Executor delegate; // 被装饰的 Executor

    @Override
    public <E> List<E> query(...) {
        // 先查缓存，未命中则调用 delegate.query()
    }
}
```

#### **优势**
- **动态增强功能**：不修改原有代码，通过包装扩展行为。
- **组合复用**：支持多层装饰（如缓存 + 日志）。

---

### **5. 模板方法模式（Template Method Pattern）**
#### **应用场景**
- **`BaseExecutor`**：定义 SQL 执行流程（如查询、更新），子类（如 `SimpleExecutor`、`BatchExecutor`）实现具体步骤。
- **`BaseTypeHandler`**：定义类型转换的通用逻辑，子类实现数据库类型与 Java 类型的映射。

#### **核心实现**
```java
public abstract class BaseExecutor implements Executor {
    // 模板方法
    public <E> List<E> query(...) {
        Statement stmt = prepareStatement(...); // 抽象方法
        return doQuery(stmt, ...);              // 抽象方法
    }

    protected abstract Statement prepareStatement(...);
    protected abstract <E> List<E> doQuery(...);
}
```

#### **优势**
- **复用算法骨架**：统一 SQL 执行流程，子类仅需实现差异部分。
- **减少重复代码**：如事务管理、连接获取等逻辑集中处理。

---

### **6. 责任链模式（Chain of Responsibility Pattern）**
#### **应用场景**
- **插件机制（Interceptor）**：通过 `InterceptorChain` 将多个插件按顺序串联，逐层拦截 SQL 执行过程（如分页、性能监控）。

#### **核心实现**
```java
public class InterceptorChain {
    private final List<Interceptor> interceptors = new ArrayList<>();

    public Object pluginAll(Object target) {
        for (Interceptor interceptor : interceptors) {
            target = interceptor.plugin(target); // 层层包装
        }
        return target;
    }
}

// 插件示例（分页插件）
public class PageInterceptor implements Interceptor {
    @Override
    public Object intercept(Invocation invocation) {
        // 修改 SQL 为分页语句
        return invocation.proceed(); // 调用下一个拦截器
    }
}
```

#### **优势**
- **动态扩展功能**：无需修改核心代码，通过插件灵活增强。
- **解耦处理逻辑**：每个拦截器仅关注单一职责。

---

### **7. 策略模式（Strategy Pattern）**
#### **应用场景**
- **数据库方言（Dialect）**：不同数据库（MySQL、Oracle）的分页 SQL 生成策略。
- **`Executor` 类型选择**：根据配置选择 `SIMPLE`、`REUSE` 或 `BATCH` 执行器。

#### **核心实现**
```java
public interface Dialect {
    String getLimitString(String sql, int offset, int limit);
}

public class MySQLDialect implements Dialect {
    @Override
    public String getLimitString(String sql, int offset, int limit) {
        return sql + " LIMIT " + offset + ", " + limit;
    }
}
```

#### **优势**
- **灵活切换算法**：如动态适配不同数据库的 SQL 语法。
- **开放扩展**：新增方言无需修改现有代码。

---

### **8. 单例模式（Singleton Pattern）**
#### **应用场景**
- **`ErrorContext`**：线程级别的错误上下文，每个线程唯一实例。
- **`LogFactory`**：日志工厂类，全局唯一实例。

#### **核心实现**
```java
public class ErrorContext {
    private static final ThreadLocal<ErrorContext> LOCAL = ThreadLocal.withInitial(ErrorContext::new);

    public static ErrorContext instance() {
        return LOCAL.get();
    }
}
```

#### **优势**
- **资源节省**：避免重复创建对象。
- **全局访问点**：如统一管理线程错误信息。

---

### **总结**
MyBatis 通过巧妙运用设计模式，实现了高内聚低耦合的架构：
- **扩展性**：插件机制（责任链）、策略模式支持灵活扩展。  
- **解耦**：工厂、代理模式分离接口与实现。  
- **复用性**：模板方法、装饰器模式复用核心逻辑。  
- **性能优化**：代理模式实现延迟加载，责任链模式支持批处理。  

理解这些设计模式不仅能深入掌握 MyBatis 的工作原理，也为开发高质量框架提供最佳实践参考。

