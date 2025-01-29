--- 

tags: [timeline, 卡片库 ] 

--- 

<span class='ob-timelines' data-date='2021-09-30-15' data-title='垃圾回收' data-class='orange' data-type='range' data-end='2021-09-30-15'> 
</span>

mapper一般用在接口上，代码如下：
```java
@Mapper
public interface UserDAO {
    
	@Select("select * from user where name = #{name}")

	User find(String name);

	@Select("select * from user where name = #{name} and pwd = #{pwd}")
    
	/**

	* 对于多个参数来说，每个参数之前都要加上@Param注解，

	* 要不然会找不到对应的参数进而报错

	*/
	User login(@Param("name")String name, @Param("pwd")String pwd);
    
}
```

使用 @Mapper，最终 Mybatis 会有一个拦截器，会自动的把 @Mapper 注解的接口生成动态代理类。

但是有个问题，就是每个接口上面都要写@Mapper，比较麻烦，所以一般用另一种方法，即在启动类上加上@MapperScan注解，扫描mapper接口所在的包

```java
  
@MapperScan("com.rimag.manage.mapper")  
@SpringBootApplication  
//@EnableDiscoveryClient  
public class ManageApplication{  
  
    public static void main(String[] args) {  
        SpringApplication.run(ManageApplication.class, args);  
 }  
  
}
```

经测试，@MapperScan的参数可以这么写
- com.rimag.manage.mapper
- com.rimag.manage.mapp*
- com.rimag.*.mapper

但是不能这么写
- com.rimag.manage.mapper.*
- com.rimag.manage.*