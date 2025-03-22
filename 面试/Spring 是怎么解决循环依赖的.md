---

UID: 20250322122655 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-22
---

Spring 通过 **三级缓存（三级对象存储）** 和 **提前暴露半成品 Bean 的引用** 来解决循环依赖问题。其核心思想是在 Bean 未完全初始化完成前，提前暴露其引用供其他 Bean 依赖注入，从而打破循环链。

---

### **核心原理与步骤**
1. **三级缓存的作用**
   - **一级缓存（`singletonObjects`）**：存储完全初始化好的单例 Bean。
   - **二级缓存（`earlySingletonObjects`）**：存储早期暴露的 Bean（已实例化但未完成属性注入和初始化）。
   - **三级缓存（`singletonFactories`）**：存储 Bean 工厂对象（`ObjectFactory`），用于生成早期 Bean 的引用。

2. **解决流程（以 Bean A 依赖 Bean B，Bean B 依赖 Bean A 为例）**
   - **步骤 1**：创建 Bean A，调用构造器实例化 A（此时 A 未完成属性注入）。
   - **步骤 2**：将 A 的工厂对象（`ObjectFactory`）存入三级缓存。
   - **步骤 3**：发现 A 依赖 B，尝试从缓存获取 B，未找到则开始创建 B。
   - **步骤 4**：创建 Bean B，调用构造器实例化 B，将 B 的工厂对象存入三级缓存。
   - **步骤 5**：发现 B 依赖 A，从三级缓存中获取 A 的工厂对象，生成 A 的早期引用，并将 A 移动到二级缓存。
   - **步骤 6**：将 A 的早期引用注入到 B 中，完成 B 的初始化，将 B 存入一级缓存。
   - **步骤 7**：回到 A 的创建流程，将 B 注入到 A 中，完成 A 的初始化，将 A 存入一级缓存。

---

### **关键点**
1. **仅支持单例 Bean 的循环依赖**  
   Spring 默认只解决单例作用域（Singleton）Bean 的循环依赖。原型（Prototype）作用域的 Bean 会直接抛出异常。

2. **构造函数注入无法解决循环依赖**  
   - 若循环依赖通过构造函数注入（如 `A(B b)` 和 `B(A a)`），Spring 会抛出 `BeanCurrentlyInCreationException`。  
   - 原因：构造函数调用时 Bean 尚未实例化，无法提前暴露引用。

3. **AOP 代理与三级缓存**  
   - 若 Bean 需要 AOP 代理，三级缓存中的 `ObjectFactory` 会提前生成代理对象，确保依赖注入的是最终代理对象，而非原始对象。

---

### **代码示例**
```java
// 一级缓存（完全初始化的 Bean）
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>();

// 二级缓存（早期暴露的 Bean）
private final Map<String, Object> earlySingletonObjects = new ConcurrentHashMap<>();

// 三级缓存（Bean 工厂）
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>();

protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        // 从二级缓存获取早期 Bean
        singletonObject = this.earlySingletonObjects.get(beanName);
        if (singletonObject == null && allowEarlyReference) {
            // 从三级缓存获取工厂对象并生成 Bean
            ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
            if (singletonFactory != null) {
                singletonObject = singletonFactory.getObject();
                this.earlySingletonObjects.put(beanName, singletonObject);
                this.singletonFactories.remove(beanName);
            }
        }
    }
    return singletonObject;
}
```

---

### **总结**
- **核心机制**：通过三级缓存提前暴露半成品 Bean，允许未完全初始化的对象被引用。
- **适用场景**：单例 Bean 的属性注入（Setter 或 Field 注入）。
- **不适用场景**：构造函数注入、原型作用域 Bean。
- **设计意义**：在保证 Bean 生命周期完整性的前提下，优雅解决循环依赖问题。




