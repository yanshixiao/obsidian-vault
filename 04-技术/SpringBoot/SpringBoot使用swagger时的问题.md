启动项目后浏览器访问访问localhost:8080/swagger-ui.html出现弹框提示

![image-20210826094709349](https://yanshixiao-markdown.oss-cn-beijing.aliyuncs.com/image-20210826094709349.png)

出现这种情况，一般在启动类上加上@EnableSwagger2注解即可。

```java
//@MapperScan("com.rimag.equipment.mapper.*")
@SpringBootApplication
//@EnableDiscoveryClient
@EnableSwagger2
public class EquipmentApplication {

    public static void main(String[] args) {
        SpringApplication.run(EquipmentApplication.class, args);
    }

}
```

当然了，也可以选择写一个配置类

```java
package com.rimag.manage.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@EnableSwagger2
public class SwaggerConfig {
    @Bean
    public Docket createRestApi(){
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.rimag.manage.controller"))
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("rimag综合运营管理平台api接口")
                .description("rimag-manage-api")
                .contact("rimag")
                .version("1.0")
                .build();
    }

}
```

