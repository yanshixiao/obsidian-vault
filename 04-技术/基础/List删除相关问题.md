---
author: yuanshuai
created: 2023-02-22 16:21:24
aliases: 
description:
tags: [04-技术/基础]
---


# List删除相关问题

## 源码解读

### 删除指定对象
![[Pasted image 20230222162641.png]]
![[Pasted image 20230222162708.png]]
1. for循环匹配传入的值 
2. 调用fastRemove(index)删除数据
	1. 将index+1及之后的元素向前移动一位，覆盖被删除值。`System.arraycopy(elementData, index+1, elementData, index, numMoved);`
	2. 清空最后一个元素。`elementData[--size]=null`


### 删除指定位置元素
![[Pasted image 20230222162216.png]]

1. 范围检查是否越界。`rangeCheck(index)`
2. 去除旧数据。`E oldValue = elementData(index);`
3. 将index+1及之后的元素向前移动一位，覆盖被删除值。`System.arraycopy(elementData, index+1, elementData, index, numMoved);`
4. 清空最后一个元素。`elementData[--size]=null`

### 缩容
1. 当容量为0时，重置为空数组
2. 容量小于数组缓冲区容量，创建一个新的数组拷贝过去。`Arrays.copyOf(elementData, size);`



