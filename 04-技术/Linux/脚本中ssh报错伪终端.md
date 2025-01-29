#### ssh@host:""ssh切换到其他机器上执行多条命令;Pseudo-terminal will not be allocated because stdin is not a terminal.


字面意思是伪终端将无法分配，因为标准输入不是终端。 
强迫症的人肯定感觉很烦的（也就是说不影响正常运行）。 
这个时候我们可以加上参数去解决这个问题。 
所以需要增加-tt参数来强制伪终端分配，即使标准输入不是终端。 
或者加上-Tq这个参数也可以。


解决方法：ssh 加参数 -tt。表明是来自脚本的调用。