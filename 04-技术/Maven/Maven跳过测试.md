---

UID: 20230724102241 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2023-07-24
---

## ✍内容


>[!note] 
>fdipasofuij
>sdpaufi




##  1、背景

Maven 构建生命周期为我们提供了对项目执行各种操作，例如验证，清理、打包、测试和部署项目。

而有时候我们需要跳过单元测试，例如，在处理新模块时，还有未通过的单元测试时。在这些情况下，我们可以跳过测试以避免编译和运行测试时发生的时间。在本文中，我们将了解可用于跳过 maven 项目中的测试的各种方法。

## 2、几种跳过的方法

- 可以在插件标签的配置中设置跳过测试元素属性。
- 通过在 Maven 执行命令中使用 -DskipTests 参数的命令行。
- 通过在触发 maven 命令以执行阶段时使用 maven.test.skip 属性。
- 在使用 surefire 时，通过在 pom.xml 的插件标签中使用 exclude 元素和要排除的类的名称来排除一些测试类

### 2.1. 跳过 pom 中的测试元素

如果您希望跳过某个项目的测试，您可以通过以下方式在项目的 pom.xml 文件的插件标记中将 skipTests 属性指定为 true：

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.0.0-M4</version>
    <configuration>
        <skipTests>true</skipTests>
    </configuration>
</plugin>
```


### 2.2. DskipTests 参数

执行编译测试类，但是跳过执行测试过程。

命令：

```
mvn clean package -DskipTests
```

### 2.3. maven.test.skip 属性

完全跳过测试编译，可以在 maven 命令中使用 maven-test-skip 属性。

大多数测试插件都支持这个属性，包括 failsafe 和 surefire，甚至 maven 的编译器插件。从命令行执行 maven 命令时，可以通过以下方式使用上述属性：

命令：
```
mvn package -Dmaven.test.skip=true
```

## 3. 最终的：默认跳过，然后在必要时覆盖它

**方法**

- 在 pom.xml 文件中定义一个属性变量并 初始化为 true , 并在跳过测试元素的节点上指定这个变量。
    
- 当需要执行测试时，在命令行中为 maven 执行的命令中指定属性值来覆盖此属性的值。这可以通过以下方式完成 -
    

比如： 在 properties 节点声明一个 defaultValueOfSkip 变量。在 <skipTests> 节点 使用 ${defaultValueOfSkip}

代码：

```xml
<project>
  <properties>
    <defaultValueOfSkip>true</defaultValueOfSkip>
  </properties>
  
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.0.0-M4</version>
        <configuration>
          <skipTests>${defaultValueOfSkip}</skipTests>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

那么，当有必要测试项目，可以这样做，只需在我的命令中通过以下方式将属性 defaultValueOfSkip 的值设置为 false：

命令：

```ad-example
mvn package -DdefaultValueOfSkip=false
```

