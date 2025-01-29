nacos springboot注册发现使用registerInstance报错failed to req API:/nacos/v1/ns/instance after all servers...

springboot使用的版本是2.0.3.RELEASE。注意：尽量使用正式版而非快照版，否则很容易出问题

代码如下：

```java
package com.example.demo.controller;  
  
import com.alibaba.nacos.api.annotation.NacosInjected;  
import com.alibaba.nacos.api.exception.NacosException;  
import com.alibaba.nacos.api.naming.NamingService;  
import com.alibaba.nacos.api.naming.pojo.Instance;  
import org.springframework.beans.factory.annotation.Value;  
import org.springframework.web.bind.annotation.RequestMapping;  
import org.springframework.web.bind.annotation.RequestParam;  
import org.springframework.web.bind.annotation.ResponseBody;  
import org.springframework.web.bind.annotation.RestController;  
  
import javax.annotation.PostConstruct;  
import java.util.List;  
  
import static org.springframework.web.bind.annotation.RequestMethod.GET;  
  
/**  
 * @author yuanshuai  
 */@RestController  
@RequestMapping("discovery")  
public class DiscoveryController {  
    @NacosInjected  
 private NamingService namingService;  
  
 @RequestMapping(value = "/get", method = GET)  
    @ResponseBody  
 public List<Instance> get(@RequestParam String serviceName) throws NacosException {  
        return namingService.getAllInstances(serviceName);  
 }  
  
    @PostConstruct  
 public void set() throws NacosException {  
        System.out.println("--------------------服务注册--------------------------");  
 namingService.registerInstance("demo", "127.0.0.1", 8080);  
 }  
  
  
}
```
原因是因为pom文件nacos相关依赖版本，由0.2.1升级到0.2.2就行

```xml
<properties>  
 <java.version>1.8</java.version>  
 <nacos-config-spring-boot.version>0.2.2</nacos-config-spring-boot.version>  
</properties>

...

<dependency>  
 <groupId>com.alibaba.boot</groupId>  
 <artifactId>nacos-config-spring-boot-starter</artifactId>  
 <version>${nacos-config-spring-boot.version}</version>  
</dependency>  
<dependency>  
 <groupId>com.alibaba.boot</groupId>  
 <artifactId>nacos-discovery-spring-boot-starter</artifactId>  
 <version>${nacos-config-spring-boot.version}</version>  
</dependency>
```
[传送门](https://www.jianshu.com/p/61a0fc2f56b6)
