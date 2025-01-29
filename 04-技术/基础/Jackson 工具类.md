---
author: yuanshuai
created: 2022-11-11 15:20:03
aliases: 
description:
tags: [04-技术/基础]
---


# Jackson 工具类

```java
public class JsonUtils {
  /**
   * 功能描述: 重载方法,只传入一个object就可以,默认的日期格式就是"yyyy-MM-dd HH:mm:ss"
   * @return java.lang.String
   */
  public static String getJson(Object object) {
    return getJson(object, "yyyy-MM-dd HH:mm:ss");
  }

  //静态方法,拿来即用,日期就输入格式,不是日期就调用上面的,就日期格式也不影响
  public static String getJson(Object object, String dateformat) {
    ObjectMapper mapper = new ObjectMapper();
    //不使用时间差的方式  WRITE_DATE_KEYS_AS_TIMESTAMPS:将日期键作为时间戳写入 改为false
    mapper.configure(SerializationFeature.WRITE_DATE_KEYS_AS_TIMESTAMPS, false);
    SimpleDateFormat format = new SimpleDateFormat(dateformat);
    //指定日期格式
    mapper.setDateFormat(format);
    try {
      //就是不是日期对象也不影响,都是正常调用了writeValueAsString方法
      return mapper.writeValueAsString(object);
    } catch (JsonProcessingException e) {
      e.printStackTrace();
    }
    //如果有异常,就返回null
    return null;
  }
}

```








