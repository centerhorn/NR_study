% �ó�������ģ���ź�QPSK���ƣ����ڡ���·�����������ơ�����һ�ĵ��ƽ��ģ��
function [y]=qpsk(x)
% y= myqpsk(x)
% x��1xLp ����������������Ԫ��Ϊ[1] ��[0]����ʾ�������������Դ
% yΪxͨ��qpsk���ƺ������ź�,��1xLp/2 ������
%���ߣ�����ΰ  ���ڣ�2005��2��22
% ��������ӳ���ϵ
%(00->sqrt(2)/2+sqrt(2)/2*j;01->-sqrt(2)/2+sqrt(2)/2*j;11->-sqrt(2)/2-sqrt(2)/2*j;10->sqrt(2)/2-sqrt(2)/2*j)
mapping=[sqrt(2)/2+sqrt(2)/2*j,sqrt(2)/2-sqrt(2)/2*j,-sqrt(2)/2+sqrt(2)/2*j,-sqrt(2)/2-sqrt(2)/2*j]; 
% ȡ��������������г���
len=length(x);
temp=0;  
y=zeros(1,len/2);  
%  �����任������ӳ��
for I=1:len/2
    temp=x(2*I-1)*2+x(2*I);
    y(I)=mapping(temp+1);
end
