mysql查询当天的所有信息：

```
select * from test where year(regdate)=year(now()) and month(regdate)=month(now()) and day(regdate)=day(now())
```

这个有一些繁琐，还有简单的写法：

```
select * from table where date(regdate) = curdate();
```

查询当天的记录

```
select * from hb_article_view where TO_DAYS(hb_AddTime) = TO_DAYS(NOW())
```

date()函数获取日期部分, 扔掉时间部分，然后与当前日期比较即可

- 补充：本周、上周、本月、上个月份的数据

查询当前这周的数据

```
SELECT name,submittime FROM enterprise WHERE YEARWEEK(date_format(submittime,'%Y-%m-%d')) = YEARWEEK(now());
```

查询上周的数据

```
SELECT name,submittime FROM enterprise WHERE YEARWEEK(date_format(submittime,'%Y-%m-%d')) = YEARWEEK(now())-1;
```

查询当前月份的数据

```
select name,submittime from enterprise where date_format(submittime,'%Y-%m')=date_format(now(),'%Y-%m')
```

查询距离当前现在6个月的数据

```
select name,submittime from enterprise where submittime between date_sub(now(),interval 6 month) and now();
```