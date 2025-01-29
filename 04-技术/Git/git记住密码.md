---

UID: 20230419111556 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: live
created: 2023-04-19
---

## ✍内容



## Https记住密码
### 永久记住密码
```shell
git config --global credential.helper store
```

会在用户主目录的.gitconfig文件中生成下面的配置。

```
[credential]
	helper = store
```

如果没有--global，则在当前项目下的.git/config文件中添加。

当然，你也可以直接复制上面生成的配置到配置文件中。

### 临时记住密码
默认记住15分钟：
```shell
git config –global credential.helper cache
```

#### 下面是自定义配置记住1小时：

```shell
git config credential.helper ‘cache –timeout=3600’
```



