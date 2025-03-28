---

UID: 20250328124447 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-28
---

### 补偿事务 TCC（Try-Confirm-Cancel）详解

TCC（Try-Confirm-Cancel）是一种 **业务侵入式** 的分布式事务解决方案，通过 **预留资源** 和 **补偿机制** 保证事务的原子性。它适用于高并发、要求强一致性的场景（如支付、库存扣减）。以下是其核心原理、实现步骤及示例说明：

---

#### 一、TCC 的核心阶段
TCC 将事务分为三个阶段，每个阶段需由开发者显式实现：

1. **Try（预留资源）**  
   • **目的**：检查资源可用性并预留资源（如冻结库存、预扣款）。  
   • **特点**：不实际修改业务数据，仅锁定资源。  
   • **示例**：  
     ```java  
     // 冻结库存  
     boolean tryResult = inventoryService.freeze(itemId, quantity);  
     ```

2. **Confirm（提交确认）**  
   • **目的**：执行实际业务操作（如扣减库存、完成支付）。  
   • **触发条件**：所有参与者的 Try 阶段均成功。  
   • **示例**：  
     ```java  
     // 实际扣减库存  
     inventoryService.confirmDeduct(itemId, quantity);  
     ```

3. **Cancel（取消补偿）**  
   • **目的**：回滚 Try 阶段的预留操作（如解冻库存、退款）。  
   • **触发条件**：任一参与者的 Try 阶段失败或事务需全局回滚。  
   • **示例**：  
     ```java  
     // 解冻库存  
     inventoryService.cancelFreeze(itemId, quantity);  
     ```

---

#### 二、TCC 的执行流程（以电商下单为例）

```plaintext
1. 订单服务 → Try：生成订单（状态为"处理中"）。
2. 库存服务 → Try：冻结库存。
3. 支付服务 → Try：预扣款（冻结余额）。
   ↓
   [若所有 Try 成功]
4. 订单服务 → Confirm：更新订单为"已支付"。
5. 库存服务 → Confirm：实际扣减库存。
6. 支付服务 → Confirm：完成扣款。
   ↓
   [若任一 Try 失败]
7. 订单服务 → Cancel：取消订单。
8. 库存服务 → Cancel：解冻库存。
9. 支付服务 → Cancel：解冻余额。
```

---

#### 三、TCC 的关键特性

| **特性**          | **说明**                                                                 |
|-------------------|-------------------------------------------------------------------------|
| **业务侵入性高**   | 需开发者手动实现 Try/Confirm/Cancel 接口，与业务逻辑强耦合。                    |
| **强一致性**       | 通过资源预留确保数据一致，适合金融等高要求场景。                                  |
| **资源锁定时间短** | Try 阶段仅冻结资源，Confirm 阶段快速提交，减少锁竞争。                             |
| **灵活性高**       | 可根据业务需求定制补偿逻辑（如部分回滚、自定义重试策略）。                           |

---

#### 四、TCC 的适用场景

1. **短事务高并发场景**：如秒杀、支付扣款。  
2. **需强一致性的业务**：如账户余额修改、库存扣减。  
3. **跨服务调用链**：微服务架构下的分布式事务（如订单→库存→支付）。  

---

#### 五、TCC 的挑战与解决方案

##### **1. 幂等性要求**  
• **问题**：网络重试可能导致 Confirm/Cancel 被重复调用。  
• **方案**：  
  • 接口设计支持幂等（如通过唯一事务ID判断状态）。  
  ```java  
  // 通过事务ID判断是否已执行  
  public void confirmDeduct(String txId, String itemId, int quantity) {  
      if (txLogService.isProcessed(txId)) return;  
      inventoryMapper.deduct(itemId, quantity);  
      txLogService.markProcessed(txId);  
  }  
  ```

##### **2. 空回滚（Cancel 未执行 Try）**  
• **问题**：Try 未执行但收到 Cancel 指令（如网络超时后补偿触发）。  
• **方案**：  
  • 记录 Try 阶段状态，若未执行 Try 则忽略 Cancel。  
  ```java  
  public void cancelFreeze(String txId, String itemId, int quantity) {  
      if (!txLogService.exists(txId)) return; // 未执行 Try，无需补偿  
      inventoryMapper.unfreeze(itemId, quantity);  
  }  
  ```

##### **3. 悬挂问题（Confirm/Cancel 先于 Try 到达）**  
• **问题**：Try 阶段因网络延迟最后到达，导致资源长期锁定。  
• **方案**：  
  • 事务管理器记录操作时序，丢弃延迟的 Try 请求。  

---

#### 六、TCC 与其他方案的对比

| **方案** | **一致性** | **性能** | **侵入性** | **适用场景**              |
|----------|------------|----------|------------|---------------------------|
| TCC      | 强一致      | 高       | 高         | 高并发、短事务（支付、库存） |
| 2PC      | 强一致      | 低       | 低         | 传统数据库跨库事务          |
| Saga     | 最终一致    | 中       | 中         | 长流程、异步业务（订单）     |
| 消息队列 | 最终一致    | 高       | 低         | 异步通知（物流、积分）      |

---

#### 七、实现 TCC 的常见框架

1. **Seata TCC 模式**：  
   • 通过注解 `@TwoPhaseBusinessAction` 定义 Try/Confirm/Cancel 方法。  
   • **示例**：  
     ```java  
     @TwoPhaseBusinessAction(name = "inventoryAction", commitMethod = "confirm", rollbackMethod = "cancel")  
     public boolean freeze(BusinessActionContext context, String itemId, int quantity) {  
         // Try 逻辑  
     }  
     public boolean confirm(BusinessActionContext context) {  
         // Confirm 逻辑  
     }  
     public boolean cancel(BusinessActionContext context) {  
         // Cancel 逻辑  
     }  
     ```

2. **ByteTCC**：  
   • 基于 Spring 的 TCC 框架，提供事务管理器和补偿机制。  

---

#### 八、最佳实践

1. **事务状态追踪**：  
   • 通过日志表记录事务 ID、状态（Try/Confirm/Cancel）。  
   ```sql  
   CREATE TABLE tcc_log (  
       tx_id VARCHAR(64) PRIMARY KEY,  
       status ENUM('TRYING', 'CONFIRMED', 'CANCELLED'),  
       create_time TIMESTAMP  
   );  
   ```

2. **超时控制**：  
   • 为每个事务设置超时时间，超时后自动触发 Cancel。  

3. **补偿告警**：  
   • 监控 Cancel 操作失败率，及时人工介入修复数据。  

---

### 总结

TCC 通过 **预留资源 → 提交/回滚** 的机制，在业务层实现分布式事务的原子性，适合对一致性要求严格的场景。尽管需开发者手动实现补偿逻辑，但其高性能和强一致性优势使其成为高并发系统的首选方案。设计时需重点处理 **幂等性**、**空回滚** 和 **悬挂问题**，结合框架（如 Seata）可降低实现复杂度。




