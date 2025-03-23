---

UID: 20250323215631 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---





在 Spring Boot 中，若要在应用启动时执行特定代码，可以通过以下几种方式实现。这些方法适用于不同的场景，例如初始化资源、加载配置、预检查等：

---

### **1. 使用 `CommandLineRunner` 或 `ApplicationRunner` 接口**  
这两个接口的 `run` 方法会在 **Spring 上下文准备完成后**、**应用完全启动前** 执行，适合初始化逻辑。

#### **区别**：
- **`CommandLineRunner`**：接收原始命令行参数（`String[] args`）。
- **`ApplicationRunner`**：封装命令行参数为 `ApplicationArguments` 对象，提供更灵活的解析方式。

#### **示例**：
```java
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.ApplicationArguments;
import org.springframework.stereotype.Component;

@Component
public class MyStartupRunner implements CommandLineRunner {
    @Override
    public void run(String... args) {
        System.out.println("CommandLineRunner: 应用启动，执行初始化代码");
        // 例如：初始化缓存、预加载数据
    }
}

@Component
@Order(1) // 控制多个 Runner 的执行顺序（值越小优先级越高）
public class MyAppRunner implements ApplicationRunner {
    @Override
    public void run(ApplicationArguments args) {
        System.out.println("ApplicationRunner: 启动参数为 " + args.getOptionNames());
        // 例如：解析特定启动参数并执行逻辑
    }
}
```

---

### **2. 监听 `ApplicationReadyEvent` 事件**  
当应用完全就绪（内嵌服务器已启动、所有 Bean 已初始化）时触发，适合需要 **确保所有组件已就绪** 的场景。

#### **示例**：
```java
import org.springframework.context.event.EventListener;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.stereotype.Component;

@Component
public class MyStartupListener {
    @EventListener(ApplicationReadyEvent.class)
    public void onAppReady(ApplicationReadyEvent event) {
        System.out.println("ApplicationReadyEvent: 应用已完全启动");
        // 例如：启动后台线程、连接外部服务
    }
}
```

---

### **3. 使用 `@PostConstruct` 注解**  
在 Bean 初始化完成后立即执行，但此时 **可能部分依赖未完全就绪**（例如其他 Bean 尚未初始化）。

#### **示例**：
```java
import javax.annotation.PostConstruct;
import org.springframework.stereotype.Component;

@Component
public class MyInitializer {
    @PostConstruct
    public void init() {
        System.out.println("@PostConstruct: Bean 初始化完成");
        // 例如：初始化当前 Bean 的本地资源
    }
}
```

---

### **4. 实现 `InitializingBean` 接口**  
与 `@PostConstruct` 类似，但属于 Spring 原生接口，而非 JSR-250 标准。

#### **示例**：
```java
import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;

@Component
public class MyBeanInitializer implements InitializingBean {
    @Override
    public void afterPropertiesSet() {
        System.out.println("InitializingBean: Bean 属性注入完成");
        // 例如：校验配置合法性
    }
}
```

---

### **5. 自定义 `ApplicationContextInitializer`**  
在 Spring 上下文初始化之前执行，适合 **极早期** 的全局配置（如环境变量设置）。

#### **步骤**：
1. 实现 `ApplicationContextInitializer`：
   ```java
   import org.springframework.context.ApplicationContextInitializer;
   import org.springframework.context.ConfigurableApplicationContext;

   public class MyContextInitializer 
       implements ApplicationContextInitializer<ConfigurableApplicationContext> {
       @Override
       public void initialize(ConfigurableApplicationContext context) {
           System.out.println("ApplicationContextInitializer: 上下文初始化前执行");
           // 例如：设置环境变量
       }
   }
   ```
2. 注册初始化器：  
   在 `application.properties` 中指定：
   ```properties
   context.initializer.classes=com.example.MyContextInitializer
   ```
   或通过 `SpringApplication.addInitializers()` 编程式注册。

---

### **方法对比与适用场景**
| 方法                          | 执行时机                           | 适用场景                            | 注意事项                     |
|------------------------------|-----------------------------------|-----------------------------------|----------------------------|
| `CommandLineRunner`/`ApplicationRunner` | 上下文就绪后，应用启动完成前       | 通用初始化逻辑（如数据预加载）       | 多个 Runner 需用 `@Order` 控制顺序 |
| `ApplicationReadyEvent`       | 应用完全就绪（包括服务器启动）     | 依赖外部服务的初始化（如连接池）     | 确保所有 Bean 已就绪        |
| `@PostConstruct`              | Bean 初始化后，依赖注入完成后      | 单个 Bean 的本地资源初始化           | 不保证其他 Bean 已就绪       |
| `InitializingBean`            | Bean 属性注入完成后               | 校验配置或简单初始化                 | 与 `@PostConstruct` 类似    |
| `ApplicationContextInitializer` | 上下文初始化前                   | 极早期的全局环境设置                 | 不推荐处理业务逻辑          |

---

### **总结**
- **推荐选择**：  
  - 通用启动任务：使用 `CommandLineRunner` 或 `ApplicationRunner`。
  - 确保完全就绪：监听 `ApplicationReadyEvent`。
  - 单 Bean 初始化：`@PostConstruct` 或 `InitializingBean`。
- **避免在初始化阶段执行耗时操作**，以免影响启动速度。