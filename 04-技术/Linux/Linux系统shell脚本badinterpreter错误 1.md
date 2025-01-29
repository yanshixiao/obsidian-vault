>在windows下编辑保存后，会出现这种问题。原因是文件被转换成windows下的==dos==文本格式了。


解决方法很简单
vim打开脚本文件，`:set ff?`检查格式。

`:set ff=unix`修改，然后:wq保存退出就ok了。