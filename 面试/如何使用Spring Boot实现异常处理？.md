---

UID: 20250323222334 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-23
---

在Spring Boot中实现异常处理可以通过以下步骤完成，确保应用能够统一处理异常并返回结构化的错误信息：

### **步骤 1：创建自定义异常类**
定义带有`@ResponseStatus`注解的自定义异常类，指定默认HTTP状态码：
```java
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

### **步骤 2：创建全局异常处理类**
使用`@RestControllerAdvice`注解定义全局异常处理器，并处理特定异常：
```java
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // 处理自定义异常
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage()
        );
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }

    // 处理参数校验失败异常
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.toList());
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors
        );
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    // 处理其他未捕获的异常
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleAllExceptions(Exception ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal server error"
        );
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```

### **步骤 3：定义统一错误响应体**
创建`ErrorResponse`类，规范错误响应格式：
```java
import lombok.Data;
import java.util.List;

@Data
public class ErrorResponse {
    private int status;
    private String message;
    private List<String> details; // 可选，用于详细错误信息

    public ErrorResponse(int status, String message) {
        this.status = status;
        this.message = message;
    }

    public ErrorResponse(int status, String message, List<String> details) {
        this.status = status;
        this.message = message;
        this.details = details;
    }
}
```

### **步骤 4：处理框架自带异常（可选）**
通过继承`ResponseEntityExceptionHandler`复用Spring的默认异常处理逻辑：
```java
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
        MethodArgumentNotValidException ex,
        HttpHeaders headers,
        HttpStatus status,
        WebRequest request
    ) {
        List<String> errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.toList());
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors
        );
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
}
```

### **步骤 5：在控制器中抛出异常**
在业务代码中按需抛出异常：
```java
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class MyController {

    @GetMapping("/resource/{id}")
    public ResponseEntity<Resource> getResource(@PathVariable Long id) {
        Resource resource = resourceService.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Resource not found with id: " + id));
        return ResponseEntity.ok(resource);
    }
}
```

### **验证异常处理**
- **触发自定义异常**：访问不存在的资源路径，返回404状态码和自定义消息。
- **参数校验失败**：提交无效请求体，返回400状态码及详细错误列表。
- **未捕获异常**：模拟内部错误，返回500状态码和通用错误信息。

### **配置属性（可选）**
在`application.properties`中自定义Actuator错误路径或禁用默认白标页面：
```properties
# 自定义错误路径
server.error.path=/error

# 禁用默认白标错误页面
server.error.whitelabel.enabled=false
```

### **总结**
通过上述步骤，Spring Boot应用能够：
1. **统一异常响应格式**：确保所有异常返回结构化的JSON。
2. **精准处理特定异常**：如资源不存在、参数校验失败等。
3. **全局覆盖默认处理**：替代Spring Boot的默认错误页面，适配RESTful API。
4. **灵活扩展**：轻松添加新的异常类型和处理逻辑。



