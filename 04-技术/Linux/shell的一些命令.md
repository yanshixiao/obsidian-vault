#### $()和``和${}


`$()`和``都是用来做命令替换的。

```
[root@localhost ~]# echo today is $(date "+%Y-%m-%d")
today is 2017-11-07
[root@localhost ~]# echo today is `date "+%Y-%m-%d"`
today is 2017-11-07
```

``也有相同的效果，建议使用$(),比较直观，但某些系统不支持，反引号都支持。


`${var}`和`$var`是没有区别的，但是加上括号可以比较精确地界定变量名称的范围。

#### tr
translate的简写。tr只能对标准输入进行翻译。并且只能翻译`单个字符`。 

格式：tr set1 set2。作用是将set1的字符替换为set2相应位置上的字符。

```
[root@localhsot ~]# echo "123456" | tr "12" "234" 
233456
```

也可以`tr set1 set2 < 【文件名】`来替换文件中的字符。

#### if判断文件是否存在等

+ -e filename 如果 filename存在，则为真 
+ -d filename 如果 filename为目录，则为真 
+ -f filename 如果 filename为常规文件，则为真 
+ -L filename 如果 filename为符号链接，则为真 
+ -r filename 如果 filename可读，则为真 
+ -w filename 如果 filename可写，则为真 
+ -x filename 如果 filename可执行，则为真 
+ -s filename 如果文件长度不为0，则为真 
+ -h filename 如果文件是软链接，则为真

```
if[! -d "folder_name"]; then
    mkdir "folder_name"
fi
```