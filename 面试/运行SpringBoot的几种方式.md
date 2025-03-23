---

UID: 20250323214656 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---


运行 Spring Boot 应用有多种方式，适用于不同的开发和生产场景。以下是常见的几种方法及其使用方式：

---

### 1. **通过 IDE 直接运行主类**
   - **适用场景**：开发阶段快速调试。
   - **步骤**：
     1. 在 `@SpringBootApplication` 标注的主类中，右键运行 `main` 方法。
     2. IDE（如 IntelliJ IDEA、Eclipse）会自动启动内嵌服务器。
   - **示例代码**：
     ```java
     @SpringBootApplication
     public class MyApp {
         public static void main(String[] args) {
             SpringApplication.run(MyApp.class, args);
         }
     }
     ```

---

### 2. **使用 Maven/Gradle 插件运行**
   - **适用场景**：命令行环境或 CI/CD 流程。
   - **Maven 命令**：
     ```bash
     mvn spring-boot:run
     ```
   - **Gradle 命令**：
     ```bash
     gradle bootRun
     ```
   - **特点**：自动编译代码并启动应用，无需手动打包。

---

### 3. **打包为可执行 JAR 文件**
   - **适用场景**：生产环境部署。
   - **步骤**：
     1. 使用 Maven 或 Gradle 打包：
        ```bash
        mvn clean package       # Maven
        gradle bootJar          # Gradle
        ```
     2. 运行生成的 JAR 文件：
        ```bash
        java -jar target/myapp-0.0.1-SNAPSHOT.jar
        ```
   - **特点**：
     - 内嵌服务器（默认 Tomcat），无需外部容器。
     - 支持通过 `--spring.profiles.active` 指定环境：
       ```bash
       java -jar myapp.jar --spring.profiles.active=prod
       ```

---

### 4. **部署为 WAR 文件到外部服务器**
   - **适用场景**：需与现有 Tomcat/JBoss 等服务器集成。
   - **步骤**：
     1. 修改 `pom.xml`，设置打包方式为 `war`：
       ```xml
       <packaging>war</packaging>
       ```
     2. 排除内嵌 Tomcat（避免冲突）：
       ```xml
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-tomcat</artifactId>
           <scope>provided</scope> <!-- 编译时依赖，运行时由服务器提供 -->
       </dependency>
       ```
     3. 主类继承 `SpringBootServletInitializer`：
       ```java
       @SpringBootApplication
       public class MyApp extends SpringBootServletInitializer {
           @Override
           protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
               return builder.sources(MyApp.class);
           }
           public static void main(String[] args) {
               SpringApplication.run(MyApp.class, args);
           }
       }
       ```
     4. 打包后，将 WAR 文件部署到外部服务器（如 Tomcat 的 `webapps` 目录）。

---

### 5. **通过 Docker 容器运行**
   - **适用场景**：云原生部署或微服务架构。
   - **步骤**：
     1. 编写 `Dockerfile`：
       ```dockerfile
       FROM openjdk:17-jdk-slim
       COPY target/myapp-0.0.1-SNAPSHOT.jar /app.jar
       EXPOSE 8080
       ENTRYPOINT ["java", "-jar", "/app.jar"]
       ```
     2. 构建镜像并运行容器：
       ```bash
       docker build -t myapp .
       docker run -p 8080:8080 myapp
       ```
   - **特点**：环境隔离，便于扩展和管理。

---

### 6. **云平台部署（如 AWS、K8s）**
   - **适用场景**：云环境或容器编排。
   - **常见方式**：
     - **AWS Elastic Beanstalk**：直接上传 JAR 或 WAR 文件。
     - **Kubernetes**：编写 Deployment 配置，通过容器化运行。
     - **Heroku**：通过 Git 推送部署。

---

### 7. **结合 Spring Boot DevTools 热部署**
   - **适用场景**：开发阶段实时更新代码。
   - **配置**：添加依赖：
     ```xml
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-devtools</artifactId>
         <scope>runtime</scope>
         <optional>true</optional>
     </dependency>
     ```
   - **效果**：修改代码后自动重启应用（需 IDE 启用自动编译）。

---

### 方式对比
| 方式                | 适用场景         | 特点                                                                 |
|---------------------|------------------|----------------------------------------------------------------------|
| IDE 运行            | 开发调试         | 快速启动，无需打包                                                   |
| Maven/Gradle 插件   | 本地命令行测试   | 自动编译，适合持续集成                                              |
| 可执行 JAR          | 生产环境         | 内嵌服务器，一键部署                                                 |
| 外部服务器部署      | 传统企业环境     | 兼容现有 Tomcat/JBoss 等服务器                                       |
| Docker 容器         | 云原生、微服务   | 环境隔离，便于扩展                                                   |
| 云平台              | 分布式、高可用   | 集成云服务（如 AWS、Azure）                                          |

---

### 总结
Spring Boot 提供了灵活的启动和部署方式，覆盖从开发到生产的全生命周期。**推荐选择**：
- 开发阶段：IDE 运行或 `mvn spring-boot:run`。
- 生产环境：可执行 JAR 或 Docker 容器化部署。
- 传统服务器集成：WAR 文件部署到外部 Tomcat。


