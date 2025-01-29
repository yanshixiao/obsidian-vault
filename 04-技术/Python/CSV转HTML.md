---
author: yuanshuai
created: 2022-01-10 11:32:08
aliases: 
description:
tags: [Python]
---


安装

pip install --upgrade csvtotable

查看帮助

csvtotable --help

以data.csv文件为例，将data.csv转换为data.html

csvtotable data.csv data.html

直接在浏览器中打开转换的结果，而不是写入文件中

csvtotable data.csv --serve