# 关于Redis分布式锁释放锁是否必须用Lua脚本
一般我们会这样写
```java
  
   /**
     * 解锁
     * @param target
     * @param timeStamp
     */
    public void unlock(StringRedisTemplate stringRedisTemplate,String target,String timeStamp){
        try {
            String currentValue = stringRedisTemplate.opsForValue().get(target);
            if(!Strings.isNullOrEmpty(currentValue) && currentValue.equals(timeStamp) ){
                // 删除锁状态
                stringRedisTemplate.opsForValue().getOperations().delete(target);
            }
//            else{
//                System.out.println(target+"的锁已经失效");
//            }
        } catch (Exception e) {
            logger.error("警报！解锁异常{}",e);
        }
    }
```


在多线程情况下，很有可能线程A执行了if判断后失去了CPU执行权，同时锁的时间刚好超过了lock加锁时设置的时间。也就是说，这个时候线程A拿到的锁已经被释放掉。这个时候又来一个线程B拿到CPU执行权，并且执行了lock的逻辑，并成功，然后恰巧，线程B又失去了CPU执行权，A线程得以继续执行，A线程已经执行过值相等的判断，会直接删除（线程A和B的key相同），这时候线程A就把线程B获取的锁删除了，肯定会出问题，这时候再来一个线程C，一看没锁，立即lock，就出问题了，B和C同时执行了。

列个表格

| 程序A | 加锁3s | 程序执行超过3s，锁自动释放 | 程序执行完成，释放程序B的锁    |
| ----- | ------ | -------------------------- | ------------------------------ |
| 程序B |        | 因为程序A锁释放，所以B加锁 | B执行结束，释放锁但锁已被A释放 |

程序可以这么写：

```java
/**
     * 解锁
     * @param target
     * @param timeStamp
     */
    public void unlock(StringRedisTemplate stringRedisTemplate,String target,String timeStamp){
        try {
            String script = "if redis.call('get', KEYS[1]) == KEYS[2] then return redis.call('del', KEYS[1]) else return 0 end";
            RedisScript<Long> redisScript = new DefaultRedisScript<>(script, Long.class);
            Long result = stringRedisTemplate.execute(redisScript, Arrays.asList(target, timeStamp));
            if (result == null || result == 0) {
                logger.info("释放锁(" + target + "," + timeStamp + ")失败,该锁不存在或锁已经过期");
            } else {
                logger.info("释放锁(" + timeStamp + "," + timeStamp + ")成功");
            }
        } catch (Exception e) {
            logger.error("警报！解锁异常{}",e);
        }
    }
```

