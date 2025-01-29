git diff

执行 git diff 来查看执行 git status 的结果的详细信息。

git diff 命令显示已写入缓存与已修改但尚未写入缓存的改动的区别。git diff 有两个主要的应用场景。

-   尚未缓存的改动：git diff
-   查看已缓存的改动： git diff --cached
-   查看已缓存的与未缓存的所有改动：git diff HEAD
-   显示摘要而非整个 diff：git diff --stat