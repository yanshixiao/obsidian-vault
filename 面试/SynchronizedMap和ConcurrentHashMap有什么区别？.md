---

UID: 20250315011848 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-15
---
在Java中，`Collections.synchronizedMap`和`ConcurrentHashMap`都是用于在多线程环境下提供线程安全的`Map`实现，但它们的实现机制、性能表现和适用场景有显著区别。以下是两者的详细对比：

---

### **1. 核心区别总结**
| **特性**               | **SynchronizedMap**                          | **ConcurrentHashMap**                          |
|------------------------|---------------------------------------------|------------------------------------------------|
| **实现机制**           | 基于`synchronized`关键字锁住整个Map实例       | 分段锁（JDK 1.7）或CAS + `synchronized`（JDK 1.8+） |
| **锁的粒度**           | 粗粒度锁（锁整个Map）                        | 细粒度锁（锁单个桶或节点）                       |
| **并发性能**           | 低（高并发下竞争激烈）                        | 高（支持更高的并发度）                           |
| **迭代器行为**         | 强一致性（迭代时修改会抛出`ConcurrentModificationException`） | 弱一致性（允许迭代时修改，不抛异常）               |
| **空值支持**           | 允许`key`和`value`为`null`                   | 不允许`key`或`value`为`null`                    |
| **适用场景**           | 低并发或只读场景                              | 高并发读写场景                                   |

---

### **2. 实现机制详解**
#### **(1) SynchronizedMap**
- **实现方式**：  
  `Collections.synchronizedMap`通过包装普通的`Map`，并在所有方法上添加`synchronized`块，锁住整个`Map`实例。
  ```java
  public static <K,V> Map<K,V> synchronizedMap(Map<K,V> m) {
      return new SynchronizedMap<>(m);
  }

  static class SynchronizedMap<K,V> implements Map<K,V> {
      private final Map<K,V> m;
      final Object mutex; // 锁对象（默认是this）

      public V get(Object key) {
          synchronized (mutex) { return m.get(key); }
      }
      public V put(K key, V value) {
          synchronized (mutex) { return m.put(key, value); }
      }
      // 其他方法类似...
  }
  ```

- **锁的粒度**：  
  每次操作锁住整个`Map`，同一时间只能有一个线程访问`Map`，性能较低。

#### **(2) ConcurrentHashMap**
- **JDK 1.7及之前**：  
  使用**分段锁（Segment）**，将`Map`划分为多个段（默认16段），每个段独立加锁。不同段的操作可以并行执行。
  ```java
  final Segment<K,V>[] segments; // 分段数组
  static final class Segment<K,V> extends ReentrantLock { ... }
  ```

- **JDK 1.8及之后**：  
  改用 **CAS（Compare and Swap） + `synchronized`锁单个节点（Node）**，进一步细化锁的粒度。
  ```java
  // 插入操作（简化代码）
  final V putVal(K key, V value, boolean onlyIfAbsent) {
      Node<K,V>[] tab; 
      if (key == null || value == null) throw new NullPointerException();
      int hash = spread(key.hashCode());
      // 使用CAS和synchronized保证线程安全
      synchronized (tabAt(tab, i)) { ... }
  }
  ```

- **锁的粒度**：  
  - JDK 1.7：锁段（默认16段）。  
  - JDK 1.8：锁单个桶（哈希槽）或节点，并发度更高。

---

### **3. 性能对比**
| **场景**               | **SynchronizedMap**                          | **ConcurrentHashMap**                          |
|------------------------|---------------------------------------------|------------------------------------------------|
| **读多写少**           | 一般（所有读操作需竞争同一锁）                | 高（读操作无锁，直接访问）                       |
| **写操作频繁**         | 低（锁竞争激烈）                              | 高（锁粒度细，竞争概率低）                       |
| **高并发场景**         | 性能急剧下降                                  | 吞吐量稳定                                       |

#### **示例：并发吞吐量**
- **SynchronizedMap**：线程越多，锁竞争越激烈，性能下降明显。
- **ConcurrentHashMap**：通过细粒度锁或CAS，支持更高的并发度，性能随线程数增长更平稳。

---

### **4. 功能特性对比**
#### **(1) 迭代器行为**
- **SynchronizedMap**：  
  - 迭代器是**强一致性**的，迭代过程中如果其他线程修改`Map`，会抛出`ConcurrentModificationException`。
  - 必须通过`synchronized`块手动同步迭代操作：
    ```java
    Map<K,V> syncMap = Collections.synchronizedMap(new HashMap<>());
    synchronized (syncMap) {
        Iterator<K> it = syncMap.keySet().iterator();
        while (it.hasNext()) { ... }
    }
    ```

- **ConcurrentHashMap**：  
  - 迭代器是**弱一致性**的，允许在迭代过程中修改`Map`，不会抛异常。
  - 迭代器反映的是遍历开始时的快照或部分修改后的状态。

#### **(2) 空值（Null）支持**
- **SynchronizedMap**：  
  - 允许`key`和`value`为`null`（底层`Map`允许的情况下，如`HashMap`）。
- **ConcurrentHashMap**：  
  - **不允许`key`或`value`为`null`（设计约束，避免二义性）**，插入`null`会抛出`NullPointerException`。

---

### **5. 适用场景**
| **场景**               | **推荐选择**          | **理由**                                                                 |
|------------------------|----------------------|-------------------------------------------------------------------------|
| **低并发读写**          | SynchronizedMap      | 实现简单，代码量少，适合对性能要求不高的场景。                                 |
| **高并发读写**          | ConcurrentHashMap    | 高吞吐量，锁粒度细，适合多线程频繁读写（如缓存、计数器）。                       |
| **需要强一致性迭代**    | SynchronizedMap      | 需通过同步块手动控制迭代过程（但性能受限）。                                   |
| **允许弱一致性迭代**    | ConcurrentHashMap    | 支持并发修改，迭代效率更高。                                                 |
| **需要空值支持**        | SynchronizedMap      | 允许`key`或`value`为`null`（需确保底层`Map`支持，如`HashMap`）。              |

---

### **6. 代码示例**
#### **(1) SynchronizedMap**
```java
Map<String, String> map = Collections.synchronizedMap(new HashMap<>());
map.put("key", "value");

// 迭代时需手动同步
synchronized (map) {
    Iterator<String> it = map.keySet().iterator();
    while (it.hasNext()) {
        System.out.println(it.next());
    }
}
```

#### **(2) ConcurrentHashMap**
```java
ConcurrentHashMap<String, String> map = new ConcurrentHashMap<>();
map.put("key", "value");

// 迭代时无需同步（弱一致性）
Iterator<String> it = map.keySet().iterator();
while (it.hasNext()) {
    System.out.println(it.next()); // 允许其他线程并发修改
}
```

---

### **7. 总结**
| **维度**       | **SynchronizedMap**                                      | **ConcurrentHashMap**                                      |
|---------------|---------------------------------------------------------|-----------------------------------------------------------|
| **锁机制**     | 粗粒度锁（锁整个Map）                                    | 细粒度锁（分段锁或节点锁）                                   |
| **并发性能**   | 低（适合低并发）                                         | 高（适合高并发）                                            |
| **迭代器**     | 强一致性（需手动同步）                                   | 弱一致性（允许并发修改）                                      |
| **空值支持**   | 支持                                                    | 不支持                                                     |
| **实现复杂度** | 简单（基于`synchronized`）                               | 复杂（CAS + `synchronized`，分段锁优化）                     |

**核心结论**：  
- 在**低并发或只读场景**中，`SynchronizedMap`更简单直接。  
- 在**高并发读写场景**中，`ConcurrentHashMap`的吞吐量和扩展性显著更优。在Java中，`Collections.synchronizedMap`和`ConcurrentHashMap`都是用于在多线程环境下提供线程安全的`Map`实现，但它们的实现机制、性能表现和适用场景有显著区别。以下是两者的详细对比：

---

### **1. 核心区别总结**
| **特性**               | **SynchronizedMap**                          | **ConcurrentHashMap**                          |
|------------------------|---------------------------------------------|------------------------------------------------|
| **实现机制**           | 基于`synchronized`关键字锁住整个Map实例       | 分段锁（JDK 1.7）或CAS + `synchronized`（JDK 1.8+） |
| **锁的粒度**           | 粗粒度锁（锁整个Map）                        | 细粒度锁（锁单个桶或节点）                       |
| **并发性能**           | 低（高并发下竞争激烈）                        | 高（支持更高的并发度）                           |
| **迭代器行为**         | 强一致性（迭代时修改会抛出`ConcurrentModificationException`） | 弱一致性（允许迭代时修改，不抛异常）               |
| **空值支持**           | 允许`key`和`value`为`null`                   | 不允许`key`或`value`为`null`                    |
| **适用场景**           | 低并发或只读场景                              | 高并发读写场景                                   |

---

### **2. 实现机制详解**
#### **(1) SynchronizedMap**
- **实现方式**：  
  `Collections.synchronizedMap`通过包装普通的`Map`，并在所有方法上添加`synchronized`块，锁住整个`Map`实例。
  ```java
  public static <K,V> Map<K,V> synchronizedMap(Map<K,V> m) {
      return new SynchronizedMap<>(m);
  }

  static class SynchronizedMap<K,V> implements Map<K,V> {
      private final Map<K,V> m;
      final Object mutex; // 锁对象（默认是this）

      public V get(Object key) {
          synchronized (mutex) { return m.get(key); }
      }
      public V put(K key, V value) {
          synchronized (mutex) { return m.put(key, value); }
      }
      // 其他方法类似...
  }
  ```

- **锁的粒度**：  
  每次操作锁住整个`Map`，同一时间只能有一个线程访问`Map`，性能较低。

#### **(2) ConcurrentHashMap**
- **JDK 1.7及之前**：  
  使用**分段锁（Segment）**，将`Map`划分为多个段（默认16段），每个段独立加锁。不同段的操作可以并行执行。
  ```java
  final Segment<K,V>[] segments; // 分段数组
  static final class Segment<K,V> extends ReentrantLock { ... }
  ```

- **JDK 1.8及之后**：  
  改用 **CAS（Compare and Swap） + `synchronized`锁单个节点（Node）**，进一步细化锁的粒度。
  ```java
  // 插入操作（简化代码）
  final V putVal(K key, V value, boolean onlyIfAbsent) {
      Node<K,V>[] tab; 
      if (key == null || value == null) throw new NullPointerException();
      int hash = spread(key.hashCode());
      // 使用CAS和synchronized保证线程安全
      synchronized (tabAt(tab, i)) { ... }
  }
  ```

- **锁的粒度**：  
  - JDK 1.7：锁段（默认16段）。  
  - JDK 1.8：锁单个桶（哈希槽）或节点，并发度更高。

---

### **3. 性能对比**
| **场景**               | **SynchronizedMap**                          | **ConcurrentHashMap**                          |
|------------------------|---------------------------------------------|------------------------------------------------|
| **读多写少**           | 一般（所有读操作需竞争同一锁）                | 高（读操作无锁，直接访问）                       |
| **写操作频繁**         | 低（锁竞争激烈）                              | 高（锁粒度细，竞争概率低）                       |
| **高并发场景**         | 性能急剧下降                                  | 吞吐量稳定                                       |

#### **示例：并发吞吐量**
- **SynchronizedMap**：线程越多，锁竞争越激烈，性能下降明显。
- **ConcurrentHashMap**：通过细粒度锁或CAS，支持更高的并发度，性能随线程数增长更平稳。

---

### **4. 功能特性对比**
#### **(1) 迭代器行为**
- **SynchronizedMap**：  
  - 迭代器是**强一致性**的，迭代过程中如果其他线程修改`Map`，会抛出`ConcurrentModificationException`。
  - 必须通过`synchronized`块手动同步迭代操作：
    ```java
    Map<K,V> syncMap = Collections.synchronizedMap(new HashMap<>());
    synchronized (syncMap) {
        Iterator<K> it = syncMap.keySet().iterator();
        while (it.hasNext()) { ... }
    }
    ```

- **ConcurrentHashMap**：  
  - 迭代器是**弱一致性**的，允许在迭代过程中修改`Map`，不会抛异常。
  - 迭代器反映的是遍历开始时的快照或部分修改后的状态。

#### **(2) 空值（Null）支持**
- **SynchronizedMap**：  
  - 允许`key`和`value`为`null`（底层`Map`允许的情况下，如`HashMap`）。
- **ConcurrentHashMap**：  
  - **不允许`key`或`value`为`null`（设计约束，避免二义性）**，插入`null`会抛出`NullPointerException`。

---

### **5. 适用场景**
| **场景**               | **推荐选择**          | **理由**                                                                 |
|------------------------|----------------------|-------------------------------------------------------------------------|
| **低并发读写**          | SynchronizedMap      | 实现简单，代码量少，适合对性能要求不高的场景。                                 |
| **高并发读写**          | ConcurrentHashMap    | 高吞吐量，锁粒度细，适合多线程频繁读写（如缓存、计数器）。                       |
| **需要强一致性迭代**    | SynchronizedMap      | 需通过同步块手动控制迭代过程（但性能受限）。                                   |
| **允许弱一致性迭代**    | ConcurrentHashMap    | 支持并发修改，迭代效率更高。                                                 |
| **需要空值支持**        | SynchronizedMap      | 允许`key`或`value`为`null`（需确保底层`Map`支持，如`HashMap`）。              |

---

### **6. 代码示例**
#### **(1) SynchronizedMap**
```java
Map<String, String> map = Collections.synchronizedMap(new HashMap<>());
map.put("key", "value");

// 迭代时需手动同步
synchronized (map) {
    Iterator<String> it = map.keySet().iterator();
    while (it.hasNext()) {
        System.out.println(it.next());
    }
}
```

#### **(2) ConcurrentHashMap**
```java
ConcurrentHashMap<String, String> map = new ConcurrentHashMap<>();
map.put("key", "value");

// 迭代时无需同步（弱一致性）
Iterator<String> it = map.keySet().iterator();
while (it.hasNext()) {
    System.out.println(it.next()); // 允许其他线程并发修改
}
```

---

### **7. 总结**
| **维度**       | **SynchronizedMap**                                      | **ConcurrentHashMap**                                      |
|---------------|---------------------------------------------------------|-----------------------------------------------------------|
| **锁机制**     | 粗粒度锁（锁整个Map）                                    | 细粒度锁（分段锁或节点锁）                                   |
| **并发性能**   | 低（适合低并发）                                         | 高（适合高并发）                                            |
| **迭代器**     | 强一致性（需手动同步）                                   | 弱一致性（允许并发修改）                                      |
| **空值支持**   | 支持                                                    | 不支持                                                     |
| **实现复杂度** | 简单（基于`synchronized`）                               | 复杂（CAS + `synchronized`，分段锁优化）                     |

**核心结论**：  
- 在**低并发或只读场景**中，`SynchronizedMap`更简单直接。  
- 在**高并发读写场景**中，`ConcurrentHashMap`的吞吐量和扩展性显著更优。




