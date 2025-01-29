#### Maven项目配置文件读取

##### pom文件
```
<build>
        <resources>
            <resource>
                <directory>src/main/java</directory>
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                </includes>
                <filtering>true</filtering>
            </resource>
            <resource>
                <directory>src/main/resources</directory>
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                </includes>
                <filtering>true</filtering>
            </resource>
        </resources>
    </build>
```

###### 读取
- props.load(new FileInputStream("db.properties")); 是读取当前目录的db.properties文件
- getClass.getResourceAsStream("db.properties"); 是读取当前类所在位置一起的db.properties文件。加上一个classloader就是读取resource下的配置文件。

Thread.getCurrentThread().getContextClassLoader()和c.getClass().getClassLoader()返回结果都是AppClassLoader

- getClass.getResourceAsStream("/db.properties"); 是读取ClassPath的根的db.properties文件,注意ClassPath如果是多个路径或者jar文件的,只要在任意一个路径目录下或者jar文件里的根下都可以,如果存在于多个路径下的话,按照ClassPath中的先后顺序,使用先找到的,其余忽略.
