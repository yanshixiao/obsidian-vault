https://blog.csdn.net/wangkaichenjuan/article/details/70053209

序列化和反序列化

MySerial.java
```
package cn.yanshixiao.serial;

import java.io.*;

public class MySerial {
    /**
     * 将对象序列化到文件
     * @throws Exception
     */
    public static void write() throws Exception {
        Person person = new Person();
        person.setName("jack");
        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(new File("C://test//a.test")));
        oos.writeObject(person);
        oos.close();
        System.out.println("success");
    }

    /**
     * 从文件中反序列化得到对象
     * @throws Exception
     */
    public static void read() throws Exception {
        ObjectInputStream ois = new ObjectInputStream(new FileInputStream(new File("C://test//a.test")));
        Person p = (Person)ois.readObject();
        System.out.println(p);
        System.out.println("success");
    }

    public static void main(String[] args) throws Exception {
        write();
        read();
    }
}
```

Person.java
```
package cn.yanshixiao.serial;

import java.io.Serializable;

public class Person implements Serializable{
    private static final long serialVersionUID = 745297523164360158L;
    private String name;
    //添加一个属性
    private String address;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", address='" + address + '\'' +
                '}';
    }
}
```

versionUID顾名思义，是为了标识版本，可以用1L,2L,3L,不过一般都自动生成，如果没有指定，jvm自动生成一个，每次要序列化的对象改变（哪怕只是加了一个空格）后都会改变，此时反序列化就会报错，文件流中的对象和classpath中的不一致。

所以一般我们手动生成一个，这样就算已经序列化后，再改变classpath中的类，依然可以正常从磁盘读取并反序列化。