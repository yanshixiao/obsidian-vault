---
author: yuanshuai
created: 2022-01-10 11:40:29
aliases: 
description:
tags: [软件使用]
---

```groovy
groovyScript("def format= ''; def params=\"${_1}\".replaceAll('[\\\\[|\\\\]|\\\\s]', '').split(',').toList(); for(i = 0; i < params.size; i++) {if(i==0){format+= params[i] ;}else{format+= ', ' + params[i] + ':\{\}'}}; return format;", methodParameters());
```

```groovy
groovyScript("def params=\"${_1}\".replaceAll('[\\\\[|\\\\]|\\\\s]', ''); return params;", methodParameters());
```

```groovy
groovyScript("def result=''; def params=\"${_1}\".replaceAll('[\\\\[|\\\\]|\\\\s]', '').split(',').toList();for(i = 0; i < params.size(); i++) {if(i==0){result+='\+\" ' + params[i] + ' :\"\+ '+params[i];}else{result+=' \+\"\; ' + params[i] + ' :\"\+ '+params[i];}}; return result;", methodParameters());
```
