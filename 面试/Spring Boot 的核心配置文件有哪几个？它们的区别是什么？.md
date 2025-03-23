---

UID: 20250323224220 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---


Spring Boot 的核心配置文件主要有 **`application.properties`** 和 **`application.yml`**（或 `application.yaml`）。它们的核心区别在于**语法格式**和**适用场景**，同时 Spring Boot 还支持通过 **Profile 机制**（如 `application-{profile}.properties`）实现多环境配置的灵活管理。以下是详细说明：

---

### **1. 核心配置文件**
| 配置文件                 | 说明                                                                                   |
|--------------------------|---------------------------------------------------------------------------------------|
| **`application.properties`** | 传统键值对格式，语法简单直接，适合小规模或简单的配置。                                 |
| **`application.yml`**（或 `yaml`） | 基于 YAML 格式，支持层次化结构，适合复杂配置（如嵌套对象、集合），可读性更强。        |

#### **语法对比示例**
- **`application.properties`**：
  ```properties
  server.port=8080
  spring.datasource.url=jdbc:mysql://localhost:3306/mydb
  spring.datasource.username=root
  spring.datasource.password=123456
  ```
- **`application.yml`**：
  ```yaml
  server:
    port: 8080
  spring:
    datasource:
      url: jdbc:mysql://localhost:3306/mydb
      username: root
      password: 123456
  ```

#### **区别总结**
| 特性               | `application.properties`                      | `application.yml`                          |
|--------------------|-----------------------------------------------|--------------------------------------------|
| **语法**           | 键值对（`key=value`）                         | 缩进层级结构，支持复杂数据类型（如列表、对象） |
| **可读性**         | 简单直接，适合少量配置                        | 层次清晰，适合复杂配置                      |
| **维护性**         | 键名冗余（如 `spring.datasource.url`）         | 通过缩进减少重复前缀                        |
| **适用场景**       | 简单项目或开发者偏好                          | 微服务、多环境配置等复杂场景                |

---

### **2. Profile 专属配置文件**
通过文件名中的 **`-{profile}`** 区分不同环境配置（如开发、测试、生产环境）。  
- **命名规则**：`application-{profile}.properties` 或 `application-{profile}.yml`  
- **激活方式**：  
  - 命令行参数：`--spring.profiles.active=dev`  
  - 环境变量：`SPRING_PROFILES_ACTIVE=prod`  
  - 主配置文件：`spring.profiles.active=test`  

#### **示例**
- 开发环境配置：`application-dev.yml`
  ```yaml
  server:
    port: 8081
  spring:
    datasource:
      url: jdbc:mysql://dev-db:3306/mydb
  ```
- 生产环境配置：`application-prod.yml`
  ```yaml
  server:
    port: 8080
  spring:
    datasource:
      url: jdbc:mysql://prod-db:3306/mydb
  ```

#### **优先级规则**
- **Profile 配置文件 > 默认配置文件**：  
  激活某个 Profile 后，对应的 `application-{profile}.yml` 会覆盖默认的 `application.yml` 中的相同配置项。  
- **多 Profile 合并**：  
  若同时激活多个 Profile（如 `dev,cloud`），后激活的 Profile 配置会覆盖前面的同名配置。

---

### **3. 其他配置文件**
| 配置文件                | 说明                                                                                   |
|-------------------------|---------------------------------------------------------------------------------------|
| **`bootstrap.yml`**     | 在 Spring Cloud 应用中使用，优先于 `application.yml` 加载，用于配置服务发现、配置中心等。 |
| **`application-fallback.yml`** | 自定义名称的配置文件，需通过 `spring.config.name` 指定。                              |

---

### **配置加载顺序与优先级**
Spring Boot 配置加载遵循以下优先级（从高到低）：  
1. **命令行参数**（`--key=value`）  
2. **Java 系统属性**（`-Dkey=value`）  
3. **操作系统环境变量**  
4. **外部配置文件**（如 `./config/application.yml`）  
5. **打包在 JAR 内的配置文件**（`classpath:application.yml`）  
6. **默认配置**（通过 `@PropertySource` 或代码设置）  

---

### **最佳实践**
1. **多环境管理**：  
   - 使用 `application-{profile}.yml` 管理不同环境配置。  
   - 通过 `spring.profiles.active` 动态切换环境。  
2. **敏感信息保护**：  
   - 将密码等敏感信息存储在环境变量或外部配置中心（如 Spring Cloud Config）。  
3. **格式选择**：  
   - 简单项目用 `properties`，复杂配置用 `yml`。  
4. **配置覆盖**：  
   - 高优先级配置（如命令行参数）可覆盖低优先级配置。  

---

### **总结**
- **核心文件**：`application.properties` 和 `application.yml` 是 Spring Boot 的默认配置文件，区别在于语法和适用场景。  
- **环境隔离**：通过 `application-{profile}.yml` 实现多环境配置，结合 `spring.profiles.active` 灵活切换。  
- **优先级机制**：外部配置（如命令行、环境变量）优先级高于文件配置，确保部署时的灵活性。


