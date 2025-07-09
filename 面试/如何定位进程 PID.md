---

UID: 20250423204340 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2025-04-23
---




#### **1. 定位 Java 进程的 PID​**​

在 Linux/Unix 系统中，可以通过以下方法找到 Java 进程的 PID：

##### ​**​方法 1：使用 `jps` 命令（JDK 自带工具）​**​

```bash
# 列出所有 Java 进程及其 PID
jps -l

# 输出示例：
# 12345 com.example.MainApplication
# 67890 sun.tools.jps.Jps
```

- 直接查找包含主类名的进程（如 `com.example.MainApplication`）。

##### ​**​方法 2：使用 `ps` + `grep`​**​

```bash
# 根据进程名查找（如 Java 应用启动类名）
ps -ef | grep java | grep -v grep

# 输出示例：
# user   12345 1  0 10:00 ?        00:10:00 java -jar app.jar
```

##### ​**​方法 3：通过端口号查找（如果应用绑定了端口）​**​

```bash
# 查找占用 8080 端口的进程 PID
lsof -i :8080
# 或
netstat -tulnp | grep :8080

# 输出示例：
# java    12345 user   23u  IPv6 0x...      0t0  TCP *:8080 (LISTEN)
```

##### ​**​方法 4：使用 `top` 或 `htop`​**​

- 运行 `top`，按 `Shift + P` 按 CPU 使用率排序，找到 CPU 占用高的 Java 进程。
- 或使用 `htop`（更友好的交互式工具）。
