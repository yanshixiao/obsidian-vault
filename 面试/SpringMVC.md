---

UID: 20250321231928 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-21
---







Spring MVC 是 Spring 框架中用于构建 Web 应用的核心模块，基于经典的 **MVC（Model-View-Controller）设计模式**，提供了一套灵活、解耦的请求处理机制。以下是其核心设计思想、工作流程及关键组件的详细解析：

---

### **一、Spring MVC 的核心设计思想**
1. **前端控制器模式**：  
   所有请求统一由 `DispatcherServlet` 调度，避免传统 Servlet 分散处理的复杂性。
2. **松耦合架构**：  
   通过接口定义各组件（如 `HandlerMapping`, `ViewResolver`），允许开发者按需替换实现。
3. **注解驱动开发**：  
   使用 `@Controller`, `@RequestMapping` 等注解简化配置，提升开发效率。
4. **与 Spring 生态无缝集成**：  
   天然支持依赖注入（DI）、AOP、事务管理等 Spring 特性。

---

### **二、Spring MVC 核心组件**
#### 1. **`DispatcherServlet`（前端控制器）**
• **角色**：请求处理的第一入口，负责协调各组件完成请求响应。
• **配置**：需在 `web.xml` 或 Java 配置类中定义，并指定 Spring 配置文件路径。
  ```xml
  <!-- web.xml -->
  <servlet>
      <servlet-name>dispatcher</servlet-name>
      <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
      <init-param>
          <param-name>contextConfigLocation</param-name>
          <param-value>/WEB-INF/spring-mvc.xml</param-value>
      </init-param>
  </servlet>
  ```

#### 2. **`HandlerMapping`（处理器映射）**
• **作用**：根据请求 URL 找到对应的处理器（Controller 或方法）。
• **常见实现**：  
  • `RequestMappingHandlerMapping`：基于 `@RequestMapping` 注解匹配请求。

#### 3. **`HandlerAdapter`（处理器适配器）**
• **作用**：调用处理器方法，处理请求参数并返回 `ModelAndView`。
• **关键实现**：  
  • `RequestMappingHandlerAdapter`：支持 `@Controller` 注解的处理器。

#### 4. **`ViewResolver`（视图解析器）**
• **作用**：将逻辑视图名（如 `"home"`）解析为实际视图（如 JSP、Thymeleaf 模板）。
• **示例配置**：
  ```xml
  <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
      <property name="prefix" value="/WEB-INF/views/"/>
      <property name="suffix" value=".jsp"/>
  </bean>
  ```

#### 5. **`Controller`（控制器）**
• **职责**：处理请求并返回模型和视图。
• **注解驱动示例**：
  ```java
  @Controller
  public class UserController {
      @GetMapping("/users")
      public String listUsers(Model model) {
          model.addAttribute("users", userService.findAll());
          return "user/list";  // 对应视图 /WEB-INF/views/user/list.jsp
      }
  }
  ```

---

### **三、Spring MVC 请求处理流程**
以下是典型请求的完整处理流程：

1. **用户发起请求**：  
   浏览器发送 HTTP 请求到 `DispatcherServlet`。

2. **请求映射**：  
   `DispatcherServlet` 查询 `HandlerMapping` 确定处理该请求的 Controller 方法。

3. **调用处理器**：  
   `HandlerAdapter` 执行目标方法，处理参数绑定（如 `@RequestParam`, `@RequestBody`）。

4. **处理业务逻辑**：  
   Controller 调用 Service 层处理业务，返回结果（可能封装为 `ModelAndView` 或直接返回数据）。

5. **视图解析**：  
   `ViewResolver` 将逻辑视图名转换为实际视图（如 JSP、HTML）。

6. **渲染视图**：  
   视图引擎（如 JSP）结合 Model 数据生成 HTML 响应。

7. **返回响应**：  
   `DispatcherServlet` 将渲染后的内容返回客户端。

---

### **四、关键特性与扩展能力**
#### 1. **灵活的请求映射**
• **注解支持**：  
  ```java
  @GetMapping("/user/{id}")
  public String getUser(@PathVariable Long id, Model model) {
      model.addAttribute("user", userService.findById(id));
      return "user/detail";
  }
  ```
• **RESTful 支持**：  
  通过 `@RestController` 和 `@ResponseBody` 直接返回 JSON/XML 数据。

#### 2. **参数绑定与验证**
• **自动绑定**：  
  支持将请求参数、路径变量、Header 等自动注入方法参数。
• **数据验证**：  
  结合 JSR-303 注解（如 `@Valid`, `@NotBlank`）进行校验：
  ```java
  @PostMapping("/users")
  public String createUser(@Valid User user, BindingResult result) {
      if (result.hasErrors()) {
          return "user/create";
      }
      userService.save(user);
      return "redirect:/users";
  }
  ```

#### 3. **拦截器（Interceptor）**
• **用途**：实现权限检查、日志记录等横切逻辑。
• **示例**：
  ```java
  public class AuthInterceptor implements HandlerInterceptor {
      @Override
      public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
          if (userNotLoggedIn(request)) {
              response.sendRedirect("/login");
              return false;
          }
          return true;
      }
  }
  ```
  ```xml
  <!-- 配置拦截器 -->
  <mvc:interceptors>
      <bean class="com.example.AuthInterceptor"/>
  </mvc:interceptors>
  ```

#### 4. **文件上传**
• **配置**：需注册 `MultipartResolver`：
  ```xml
  <bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver"/>
  ```
• **使用**：
  ```java
  @PostMapping("/upload")
  public String handleFileUpload(@RequestParam("file") MultipartFile file) {
      file.transferTo(new File("/uploads/" + file.getOriginalFilename()));
      return "redirect:/success";
  }
  ```

---

### **五、Spring MVC 与其他 MVC 框架对比**
| **特性**               | **Spring MVC**                                | **Struts 2**                          |
|-------------------------|-----------------------------------------------|----------------------------------------|
| **耦合度**              | 低（松耦合，组件可替换）                      | 较高（与 Struts API 强绑定）           |
| **配置方式**            | 注解驱动 + Java Config                        | XML 配置为主                           |
| **与 Spring 集成**       | 无缝集成（DI、AOP）                           | 需额外整合                             |
| **REST 支持**           | 完善（`@RestController`）                     | 需插件支持                             |
| **测试友好性**          | 高（MockMvc 支持单元测试）                    | 较低                                   |

---

### **六、最佳实践**
1. **分层架构**：  
   • **Controller 层**：仅处理请求分发、参数校验和视图跳转。
   • **Service 层**：实现业务逻辑。
   • **DAO/Repository 层**：负责数据持久化。

2. **使用 DTO 传输数据**：  
   避免直接暴露实体类到视图层，提升安全性。

3. **统一异常处理**：  
   通过 `@ControllerAdvice` 全局捕获异常：
   ```java
   @ControllerAdvice
   public class GlobalExceptionHandler {
       @ExceptionHandler(Exception.class)
       public ResponseEntity<String> handleException(Exception e) {
           return ResponseEntity.status(500).body("Error: " + e.getMessage());
       }
   }
   ```

---

### **总结**
Spring MVC 通过清晰的职责划分和灵活的扩展机制，成为构建现代 Java Web 应用的首选框架。其核心优势在于 **与 Spring 生态的无缝集成**、**注解驱动的开发模式** 和 **高度可定制性**，适用于从传统单体应用到 RESTful 微服务的全场景开发。