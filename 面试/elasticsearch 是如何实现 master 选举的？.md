---

UID: 20250329182028 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-03-29
---

Elasticsearch 的 Master 选举通过 **Zen Discovery 模块**（旧版本）或 **集群协调子系统**（7.x 及之后版本）实现，核心目标是 **快速选出唯一主节点，避免脑裂**。以下是其实现原理与流程：

---

### **一、选举前提条件**
1. **节点角色**：  
   • 只有配置了 `node.master: true` 的节点（Master-eligible 节点）才能参与选举。
2. **集群状态**：  
   • 节点必须拥有最新的集群状态（Cluster State），确保数据一致性。

---

### **二、选举流程**
#### **1. 节点故障检测**
• **心跳机制**：节点间通过定期发送心跳包（默认每秒一次）检测存活状态。  
• **超时判定**：若 Master 节点在 `discovery.zen.fd.ping_timeout`（默认 30秒）内无响应，触发重新选举。

#### **2. 发起选举**
• **候选节点**：所有存活的 Master-eligible 节点均可成为候选者。  
• **选举请求**：候选节点向其他 Master-eligible 节点发送 `StartJoinRequest`，发起选举。

#### **3. 投票与多数决**
• **投票规则**：  
  • 每个 Master-eligible 节点仅投票一次，遵循 **先到先投** 原则。  
  • 候选节点需获得 **多数票（Quorum）** 才能成为新 Master。  
    ◦ 多数票公式：`(number_of_master_nodes / 2) + 1`  
    ◦ 示例：3 个 Master-eligible 节点 → 至少 2 票。  
• **优先规则**：  
  • 节点优先级（`cluster.election.max_votes_per_node`）影响选举结果（默认相同优先级）。  
  • 高版本 Elasticsearch（7.x+）优先选择 **集群状态版本号最新** 的节点。

#### **4. 宣布新 Master**
• **选举成功**：候选节点获得多数票后，广播成为新 Master。  
• **集群状态同步**：新 Master 发布最新集群状态，其他节点确认并同步。

---

### **三、防脑裂机制**
#### **1. 法定人数（Quorum）**
• **`discovery.zen.minimum_master_nodes`**（旧版本）：  
  • 必须显式配置为多数值（如 3 节点集群设为 2）。  
  • 若存活节点数不足 Quorum，集群进入 **Red 状态**，拒绝服务直到恢复。  
• **自动配置（7.x+）**：  
  • 移除 `discovery.zen.minimum_master_nodes`，由系统根据节点列表动态计算 Quorum。  

#### **2. 集群状态版本号（Cluster State Version）**
• **版本冲突解决**：  
  • 若多个节点声称自己是 Master，选择 **集群状态版本号最高** 的节点。  
  • 版本号低的节点自动降级为 Follower。

---

### **四、新版本优化（7.x+）**
Elasticsearch 7.0 引入 **集群协调子系统**，改进选举算法：
• **更快的故障检测**：基于 `Raft` 变种算法（非完整 Raft），缩短选举时间。  
• **状态机优化**：将集群状态变更建模为日志，确保一致性。  
• **安全性增强**：通过 **Pre-Vote** 机制防止网络分区导致的无效选举。

---

### **五、配置建议**
1. **Master-eligible 节点数量**：  
   • 生产环境至少 3 个专用 Master 节点（避免与 Data 节点混部）。  
2. **避免频繁选举**：  
   • 调整 `discovery.zen.fd.ping_interval`（心跳间隔）和 `ping_timeout`。  
3. **网络隔离处理**：  
   • 使用 `gateway.recover_after_nodes` 控制最小恢复节点数。

---

### **六、故障排查**
• **查看选举日志**：  
  ```bash
  # 启用 TRACE 级别日志
  PUT /_cluster/settings
  { "transient": { "logger.org.elasticsearch.cluster.service": "TRACE" } }
  ```
• **检查集群状态**：  
  ```bash
  GET /_cluster/state?filter_path=metadata,master_node
  ```

---

### **总结**
Elasticsearch 的 Master 选举通过 **多数票决策、集群状态版本控制、心跳检测** 实现高可用性，其核心思想是 **优先保证数据一致性，其次追求可用性**。合理配置节点角色与网络参数，可有效避免脑裂并提升集群稳定性。



