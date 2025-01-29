#### BeanUtils
**作用**:

将对象的属性（或配置文件读取的）封装到对象中

**方法**：


**BeanUtils.setProperty(bean, name, value)**;
其中bean是指你将要设置的对象，name指的是将要设置的属性（写成”属性名”）,value（从配置文件中读取到到的字符串值）

**BeanUtils.copyProperties(bean, name, value)**，
和上面的方法是完全一样的。使用哪个都可以

**ConvertUtils.register(Converter converter** , ..)，
当需要将String数据转换成引用数据类型（自定义数据类型时），需要使用此方法实现转换。

**BeanUtils.populate(bean,Map)**，
其中Map中的key必须与目标对象中的属性名相同，否则不能实现拷贝。

**BeanUtils.copyProperties(newObject,oldObject)**，
实现对象的拷贝

==自定义数据类型==使用BeanUtils工具时，本身必须具备getter和setter方法，因为BeanUtils工具本身也是一种内省的实现方法，所以也是借助于底层的getter和setter方法进行转换的。
