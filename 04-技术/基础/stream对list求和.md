---
author: yuanshuai
created: 2022-10-12 10:52:53
aliases: 
description:
tags: [04-技术/基础]
---


# stream对list求和

```java
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;
import java.util.stream.Collectors;
 
public class java_list_sum_test {
    public static class Person {
        int age;
        Person (int age) {
            this.age = age;
        }
        public int getAge() {
            return age;
        }
        public void setAge(int age) {
            this.age = age;
        }
    }
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        List<Long> testList = new ArrayList<>(Collections.nCopies(5, 0L));
        testList.set(0,1L);
        testList.set(1,2L);
        testList.set(2,3L);
        testList.set(3,4L);
        testList.set(4,5L);
        System.out.println("sum1 is " + testList.stream().reduce(0L, (a, b) -> a + b));
        // reduce根据初始值（参数1）和累积函数（参数2）依次对数据流进行操作，第一个值与初始值送入累积函数，后面计算结果和下一个数据流依次送入累积函数。
        System.out.println("sum2 is " + testList.stream().reduce(0L, Long::sum));
        System.out.println("sum3 is " + testList.stream().collect(Collectors.summingLong(Long::longValue)));
        // Collectors.summingLong()将流中所有元素视为Long类型，并计算所有元素的总和
        System.out.println("sum4 is " + testList.stream().mapToLong(Long::longValue).sum());
        System.out.println("***********************");
        List<Person> testList1 = new ArrayList<>(Collections.nCopies(5, new Person(1)));
        System.out.println("class sum1 is " + testList1.stream().map(e -> e.getAge()).reduce(0, (a,b) -> a + b));
        System.out.println("class sum2 is " + testList1.stream().map(e -> e.getAge()).reduce(0, Integer::sum));
        System.out.println("class sum3 is " + testList1.stream().collect(Collectors.summingInt(Person::getAge)));
        System.out.println("class sum4 is " + testList1.stream().map(e -> e.getAge()).mapToInt(Integer::intValue).sum());
        return;
    }
}
```








