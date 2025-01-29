### 安装
先安装python，直接选择anaconda
pip install djando

配置环境变量

验证

![](/images/python/1.png)

### 运行服务器

在django的bin目录下有一个django-admin.py文件。执行命令：

`django-admin.py startproject mysite` 会在当前路径生成一个mysite文件夹。

`cd mysite`进入路径，`python manage.py runserver` 即可运行，默认端口是8000，可以跟在后面指定端口。

浏览器 http://127.0.0.1:8000 查看