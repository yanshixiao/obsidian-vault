---

UID: 20241122105041 
alias: 
tags: 
source: 
cssclass: 
obsidianUIMode: preview
obsidianEditingMode: source
created: 2024-11-22
---

# 认识与安装
![[2683417321761202.png]]
![[12698117321762072.png]]
![[14248617321762162.png]]
![[31148417321764032.png]]
![[37924717321764582.png]]
![[52783417321769822.png]]
![[77741317321772052.png]]
![[100659517321774102.png]]
# 倒排索引
![[47085717321779012.png]]
![[69142617321781532.png]]
![[82548317321787382.png]]

# IK分词器
![[ES.png]]
![[ES-1.png]]
![[ES-2.png]]
![[ES-3.png]]
如何测试呢？使用kibana
![[ES-4.png]]
标准分词器把中文每个字都拆开了
![[ES-5.png]]
ik分词器有两种模式：ik_smart 和 ik_max_word
![[ES-6.png]]
![[ES-7.png]]

一些网络新词ik不支持，就需要对词典进行扩展 
![[ES-8.png]]
词典内容直接文字，然后换行
![[ES-10.png]]

![[ES-9.png]]

# 基础概念

![[ES-11.png]]
![[ES-12.png]]
![[ES-13.png]]
![[ES-14.png]]
![[ES-15.png]]

# 索引库操作
## Mapping映射属性
![[ES-16.png]]

## 索引库CRUD
![[ES-17.png]]
![[ES-18.png]]
浏览器添加
![[ES-20.png]]
添加后查询
![[ES-21.png]]
删除后再次查询
![[ES-22.png]]
![[ES-23.png]]
ES索引库不支持修改，准确的说是**不能对已有的索引库字段做修改**
![[ES-24.png]]
![[ES-25.png]]

# 文档操作
## CRUD
![[ES-26.png]]
![[ES-27.png]]![[ES-28.png]]
![[ES-29.png]]
![[ES-30.png]]

![[ES-32.png]]
put请求如果id不存在，那么就成了新增
![[ES-31.png]]
![[ES-33.png]]

![[ES-34.png]]

## 批量处理
![[ES-35.png]]
![[ES-36.png|批量新增和删除示例]]

# JavaRestClient
## 客户端初始化
![[ES-37.png|es客户端版本]]

## 商品表Mapping映射
## 索引库操作
## 文档操作
## 批处理
