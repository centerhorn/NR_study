% 该程序用来模拟信号QPSK调制，属于《链路级仿真软件设计》程序一的调制解调模块
function [y]=qpsk(x)
% y= myqpsk(x)
% x是1xLp 的向量，其中向量元素为[1] 或[0]，表示随机二进制数据源
% y为x通过qpsk调制后的输出信号,是1xLp/2 的向量
%作者：栗军伟  日期：2005－2－22
% 建立符号映射关系
%(00->sqrt(2)/2+sqrt(2)/2*j;01->-sqrt(2)/2+sqrt(2)/2*j;11->-sqrt(2)/2-sqrt(2)/2*j;10->sqrt(2)/2-sqrt(2)/2*j)
mapping=[sqrt(2)/2+sqrt(2)/2*j,sqrt(2)/2-sqrt(2)/2*j,-sqrt(2)/2+sqrt(2)/2*j,-sqrt(2)/2-sqrt(2)/2*j]; 
% 取得输入二进制序列长度
len=length(x);
temp=0;  
y=zeros(1,len/2);  
%  串并变换、符号映射
for I=1:len/2
    temp=x(2*I-1)*2+x(2*I);
    y(I)=mapping(temp+1);
end
