---

UID: 20250323220850 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---





在 Spring Boot 中，**监视器（Monitor）** 通常指的是通过 **Spring Boot Actuator** 模块提供的功能，用于监控和管理应用程序的运行状态、性能指标和健康状况。Actuator 为生产环境提供了一系列开箱即用的监控端点（Endpoints），帮助开发者和运维人员实时获取应用信息、诊断问题并优化性能。

---

### **Spring Boot Actuator 的核心功能**
1. **健康检查（Health Check）**  
   - 提供 `/actuator/health` 端点，返回应用的健康状态（UP/DOWN）。
   - 可集成数据库、磁盘空间、外部服务（如 Redis、MongoDB）等自定义健康检查。

2. **指标收集（Metrics）**  
   - 通过 `/actuator/metrics` 端点暴露 JVM 内存、线程、HTTP 请求、系统资源使用等指标。
   - 支持集成 Micrometer，对接 Prometheus、Grafana 等监控系统。

3. **环境信息（Environment）**  
   - 通过 `/actuator/env` 端点查看所有环境变量、配置属性（如 `application.properties` 中的配置）。

4. **应用详情（Info）**  
   - 通过 `/actuator/info` 端点显示自定义应用信息（如版本号、构建时间）。

5. **其他管理功能**  
   - 日志级别动态调整（`/actuator/loggers`）。
   - 线程转储（`/actuator/threaddump`）。
   - HTTP 请求跟踪（`/actuator/httptrace`）。

---

### **如何使用 Actuator？**
1. **添加依赖**  
   在 `pom.xml` 中引入 `spring-boot-starter-actuator`：
   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-actuator</artifactId>
   </dependency>
   ```

2. **配置暴露的端点**  
   默认仅暴露 `health` 和 `info` 端点。可通过 `application.properties` 自定义：
   ```properties
   # 暴露所有端点（生产环境需谨慎）
   management.endpoints.web.exposure.include=*
   # 或按需暴露
   management.endpoints.web.exposure.include=health,info,metrics
   ```

3. **访问端点**  
   - HTTP 访问：`http://localhost:8080/actuator/health`。
   - JMX 访问：通过 JConsole 或 VisualVM 查看。

---

### **示例：健康检查端点**
访问 `/actuator/health` 返回：
```json
{
  "status": "UP",
  "components": {
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 500107862016,
        "free": 250107862016,
        "threshold": 10485760
      }
    },
    "db": {
      "status": "UP",
      "details": {
        "database": "H2"
      }
    }
  }
}
```

---

### **安全配置**
默认情况下，敏感端点（如 `shutdown`）未暴露。若需保护端点，可集成 Spring Security：
1. 添加依赖：
   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-security</artifactId>
   </dependency>
   ```
2. 配置权限：
   ```properties
   spring.security.user.name=admin
   spring.security.user.password=secret
   management.endpoints.web.exposure.include=*
   management.endpoint.health.roles=ACTUATOR_ADMIN
   ```

---

### **自定义监控功能**
1. **自定义健康指示器**  
   实现 `HealthIndicator` 接口：
   ```java
   @Component
   public class CustomHealthIndicator implements HealthIndicator {
       @Override
       public Health health() {
           // 检查自定义服务状态
           boolean isHealthy = checkService();
           return isHealthy 
               ? Health.up().withDetail("message", "服务正常").build()
               : Health.down().withDetail("error", "服务异常").build();
       }
   }
   ```

2. **自定义指标**  
   使用 Micrometer 添加自定义指标：
   ```java
   @Service
   public class MyService {
       private final Counter requestCounter;

       public MyService(MeterRegistry registry) {
           requestCounter = registry.counter("myapp.requests.count");
       }

       public void processRequest() {
           requestCounter.increment();
       }
   }
   ```

---

### **与监控系统集成**
- **Prometheus + Grafana**：  
  通过 `micrometer-registry-prometheus` 依赖暴露 Prometheus 格式的指标，再通过 Grafana 可视化。
- **Spring Boot Admin**：  
  使用 [Spring Boot Admin](https://github.com/codecentric/spring-boot-admin) 构建集中式监控面板，管理多个 Spring Boot 应用实例。

---

### **总结**
Spring Boot 的监视器（通过 Actuator 实现）是应用监控的核心工具，提供以下价值：
1. **实时洞察**：快速获取应用健康、性能和环境信息。
2. **生产就绪**：开箱即用的端点支持运维需求。
3. **灵活扩展**：可自定义健康检查、指标和安全策略。
4. **生态集成**：无缝对接 Prometheus、Grafana 等监控系统。

对于微服务和云原生架构，合理使用 Actuator 能显著提升系统的可观察性和可维护性。