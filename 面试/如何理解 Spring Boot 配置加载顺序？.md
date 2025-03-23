---

UID: 20250323223341 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---





Spring Boot的配置加载顺序遵循特定的优先级规则，允许开发者通过多种方式灵活管理应用配置。以下是配置加载顺序的详细说明：

---

### **配置源优先级（从高到低）**
1. **命令行参数**  
   ```bash
   java -jar app.jar --server.port=8081
   ```
   - 启动时通过`--`传递的参数优先级最高。

2. **JNDI属性**  
   - 来自`java:comp/env`的JNDI属性（常用于传统应用服务器）。

3. **Java系统属性（`-D`参数）**  
   ```bash
   java -Dserver.port=8082 -jar app.jar
   ```

4. **操作系统环境变量**  
   - 例如：`export SERVER_PORT=8083`（需转换为`server.port`）。

5. **外部配置文件（按位置优先级）**  
   - **优先级顺序**（从高到低）：
     1. 当前目录的`./config/`子目录。
     2. 当前目录（`./`）。
     3. Classpath的`/config/`包。
     4. Classpath根目录（`/`）。
   - 支持`application.properties`和`application.yml`。

6. **内部配置文件（打包在JAR内的文件）**  
   - 同样遵循上述位置优先级，但位于JAR内部。

7. **`@PropertySource`注解**  
   - 在`@Configuration`类中指定自定义属性文件：
     ```java
     @PropertySource("classpath:custom.properties")
     ```

8. **默认属性（`SpringApplication.setDefaultProperties`）**  
   - 通过代码设置的默认值，优先级最低。

---

### **Profile 对配置的影响**
1. **Profile 激活**  
   - 通过`spring.profiles.active`指定激活的Profile（如`dev`、`prod`）。
   - **示例**：  
     ```bash
     java -jar app.jar --spring.profiles.active=prod
     ```

2. **Profile 专属配置**  
   - 文件命名规则：`application-{profile}.properties`。
   - **优先级**：带Profile的配置文件 > 默认配置文件（`application.properties`）。

3. **多Profile合并**  
   - 若同时激活多个Profile（如`dev,cloud`），配置按激活顺序合并，后激活的Profile覆盖前者。

---

### **配置文件加载顺序示例**
假设有以下配置源：
1. `classpath:application.properties`（端口：8080）
2. `file:./config/application-dev.properties`（端口：8081）
3. 命令行参数`--server.port=8082`

**结果**：`server.port=8082`（命令行参数优先级最高）。

---

### **配置覆盖规则**
- **同名属性**：高优先级配置源覆盖低优先级的同名属性。
- **松散绑定**：支持不同格式的属性名（如`server.port`、`SERVER_PORT`、`server-port`）。

---

### **验证配置加载顺序**
#### 步骤 1：创建不同位置的配置文件
- `src/main/resources/application.properties`  
  ```properties
  server.port=8080
  ```
- `./config/application.properties`  
  ```properties
  server.port=8081
  ```

#### 步骤 2：通过命令行启动应用
```bash
java -jar app.jar --server.port=8082
```

#### 结果
- 实际端口为`8082`（命令行参数覆盖所有文件配置）。

---

### **总结**
- **优先级策略**：确保灵活性，允许通过环境变量、命令行等快速覆盖配置。
- **Profile 机制**：支持环境隔离，简化多环境配置管理。
- **最佳实践**：  
  - 通用配置放在`application.properties`。
  - 环境相关配置使用`application-{profile}.properties`。
  - 敏感信息通过环境变量或命令行参数注入。

通过理解这些规则，开发者可以高效管理Spring Boot应用的配置，适应不同部署环境的需求。